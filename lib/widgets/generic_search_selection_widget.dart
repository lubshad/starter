import 'dart:async';
import 'package:flutter/material.dart';

import '../exporter.dart';
import '../mixins/search_mixin.dart';
import 'custom_appbar.dart';
import 'default_loading_widget.dart';
import 'error_widget_with_retry.dart';
import 'loading_button.dart';
import 'no_item_found.dart';
import 'search_field.dart';

/// Generic search selection widget that works with any model type
/// Supports search, pagination, single/multi-selection, and initial selection
class GenericSearchSelectionWidget<T> extends StatefulWidget {
  /// Title to display in the app bar
  final String title;

  /// Function to fetch data with search and pagination
  final Future<List<T>> Function(String searchQuery, int page, int pageSize)
  onSearch;

  /// Function to build list item widget
  final Widget Function(T item, bool isSelected, VoidCallback onTap)
  itemBuilder;

  /// Function to get display text for search results
  final String Function(T item) getDisplayText;

  /// Function to get unique identifier for items
  final String Function(T item) getItemId;

  /// Whether to allow multiple selection
  final bool allowMultiSelection;

  /// Initial selected items
  final List<T>? initialSelection;

  /// Maximum number of items that can be selected (only for multi-selection)
  final int? maxSelection;

  /// Page size for pagination
  final int pageSize;

  /// Debounce delay for search (in milliseconds)
  final int searchDebounceMs;

  /// Whether to show search field
  final bool showSearch;

  /// Placeholder text for search field
  final String searchPlaceholder;

  /// Custom empty state widget
  final Widget? emptyStateWidget;

  /// Custom loading widget
  final Widget? loadingWidget;

  /// Custom error widget
  final Widget? Function(String error)? errorWidgetBuilder;

  /// Callback when selection changes
  final void Function(List<T> selectedItems)? onSelectionChanged;

  /// Callback when done button is pressed (for multi-selection)
  final void Function(List<T> selectedItems)? onDone;

  /// Callback when item is selected (for single selection)
  final void Function(T selectedItem)? onItemSelected;

  const GenericSearchSelectionWidget({
    super.key,
    required this.title,
    required this.onSearch,
    required this.itemBuilder,
    required this.getDisplayText,
    required this.getItemId,
    this.allowMultiSelection = false,
    this.initialSelection,
    this.maxSelection,
    this.pageSize = 20,
    this.searchDebounceMs = 500,
    this.showSearch = true,
    this.searchPlaceholder = 'Search...',
    this.emptyStateWidget,
    this.loadingWidget,
    this.errorWidgetBuilder,
    this.onSelectionChanged,
    this.onDone,
    this.onItemSelected,
  });

  @override
  State<GenericSearchSelectionWidget<T>> createState() =>
      _GenericSearchSelectionWidgetState<T>();
}

class _GenericSearchSelectionWidgetState<T>
    extends State<GenericSearchSelectionWidget<T>>
    with SearchMixin {
  final ScrollController _scrollController = ScrollController();

  List<T> _items = [];
  List<T> _selectedItems = [];
  List<T> _filteredItems = [];

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _hasMoreData = true;
  int _currentPage = 1;

  Timer? _searchDebounceTimer;

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.initialSelection?.toList() ?? [];
    _loadData();

    _scrollController.addListener(_onScroll);

    addSearchListener(() {
      _loadData(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadData({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
        _items.clear();
        _filteredItems.clear();
      });
    }

    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final newItems = await widget.onSearch(
        searchController.text,
        _currentPage,
        widget.pageSize,
      );

      setState(() {
        if (refresh || _currentPage == 1) {
          _items = newItems;
        } else {
          _items.addAll(newItems);
        }

        _filteredItems = _items;
        _hasMoreData = newItems.length == widget.pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _currentPage++;
    });

    await _loadData();
  }

  void _onItemTap(T item) {
    if (widget.allowMultiSelection) {
      _toggleItemSelection(item);
    } else {
      widget.onItemSelected?.call(item);
      Navigator.of(context).pop(item);
    }
  }

  void _toggleItemSelection(T item) {
    final itemId = widget.getItemId(item);
    final isSelected = _selectedItems.any(
      (selected) => widget.getItemId(selected) == itemId,
    );

    setState(() {
      if (isSelected) {
        _selectedItems.removeWhere(
          (selected) => widget.getItemId(selected) == itemId,
        );
      } else {
        if (widget.maxSelection != null &&
            _selectedItems.length >= widget.maxSelection!) {
          return; // Don't add more items if max selection reached
        }
        _selectedItems.add(item);
      }
    });

    widget.onSelectionChanged?.call(_selectedItems);
  }

  void _onDonePressed() {
    widget.onDone?.call(_selectedItems);
    Navigator.of(context).pop(_selectedItems);
  }

  void _clearSelection() {
    setState(() {
      _selectedItems.clear();
    });
    widget.onSelectionChanged?.call(_selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        showBorder: false,
        title: widget.title,
        actions: TextButton(
          onPressed: _clearSelection,
          child: Text(
            'Clear',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontFamily: theme.textTheme.labelLarge?.fontFamily,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (widget.showSearch)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingLarge),
              child: SearchField(
                hint: widget.searchPlaceholder,
                controller: searchController,
              ),
            ),
          if (widget.allowMultiSelection && _selectedItems.isNotEmpty)
            _buildSelectionSummary(),
          Expanded(child: _buildContent()),
        ],
      ),
      bottomNavigationBar: widget.allowMultiSelection
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildSelectionSummary() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Reduce divider opacity in light mode
    final dividerColor = theme.brightness == Brightness.light
        ? colorScheme.outline.withValues(alpha: 0.3)
        : colorScheme.outline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        border: Border(bottom: BorderSide(color: dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 20),
          gapSmall,
          Expanded(
            child: Text(
              '${_selectedItems.length} item${_selectedItems.length == 1 ? '' : 's'} selected',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontFamily: theme.textTheme.bodyLarge?.fontFamily,
              ),
            ),
          ),
          if (widget.maxSelection != null)
            Text(
              '${_selectedItems.length}/${widget.maxSelection}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontFamily: theme.textTheme.bodySmall?.fontFamily,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_hasError) {
      return widget.errorWidgetBuilder?.call(_errorMessage) ??
          _buildDefaultErrorWidget();
    }

    if (_filteredItems.isEmpty && !_isLoading) {
      return widget.emptyStateWidget ?? _buildDefaultEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: () => _loadData(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _filteredItems.length + (_hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredItems.length) {
            return _buildLoadingIndicator();
          }

          final item = _filteredItems[index];
          final itemId = widget.getItemId(item);
          final isSelected = _selectedItems.any(
            (selected) => widget.getItemId(selected) == itemId,
          );

          return widget.itemBuilder(item, isSelected, () => _onItemTap(item));
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    if (!_isLoading) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return widget.loadingWidget ?? LoadingWidget(color: colorScheme.primary);
  }

  Widget _buildDefaultErrorWidget() {
    return ErrorWidgetWithRetry(
      exception: Exception(_errorMessage),
      retry: () => _loadData(refresh: true),
    );
  }

  Widget _buildDefaultEmptyWidget() {
    return NoItemsFound(message: 'No Results Found');
  }

  Widget _buildBottomBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Reduce divider opacity in light mode
    final dividerColor = theme.brightness == Brightness.light
        ? colorScheme.outline.withValues(alpha: 0.3)
        : colorScheme.outline;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: dividerColor, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${_selectedItems.length} item${_selectedItems.length == 1 ? '' : 's'} selected',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontFamily: theme.textTheme.bodyLarge?.fontFamily,
                ),
              ),
            ),
            Expanded(
              child: LoadingButton(
                aspectRatio: 200 / 50,
                onPressed: _onDonePressed,
                text: 'Done',
                buttonLoading: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

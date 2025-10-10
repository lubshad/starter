import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../core/app_route.dart';
import '../exporter.dart';
import '../mixins/search_mixin.dart';
import 'error_widget_with_retry.dart';
import 'no_item_found.dart';
import 'search_field.dart';
import 'shimwrapper.dart';

class TypeAheadSearchField<T> extends StatelessWidget {
  const TypeAheadSearchField({
    super.key,
    required this.selected,
    required this.label,
    required this.onSuggestionSelected,
    required this.suggestionsCallback,
    required this.clearSelection,
    required this.displayText,
    required this.itemBuilder,
    this.horizontalPadding = 0,
    required this.hint,
    this.validator,
  });

  final T? selected;
  final String label;
  final String hint;
  final Function(T) onSuggestionSelected;
  final VoidCallback clearSelection;
  final double horizontalPadding;
  final String? Function(T?)? validator;
  final Function(int, String, PagingController<int, T>) suggestionsCallback;
  final String Function(T) displayText;
  final Widget Function(BuildContext context, T item, bool isSelected)
  itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
      ).copyWith(top: paddingLarge),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          TextFormField(
            readOnly: true,
            onTap: () => Navigator.push(
              context,
              downToTop(
                const RouteSettings(name: "Selection"),
                SelectionScreen<T>(
                  suggestionsCallback: suggestionsCallback,
                  label: label,
                  hint: hint,
                  onSuggestionSelected: onSuggestionSelected,
                  selectedItems: selected == null ? [] : [selected as T],
                  itemBuilder: itemBuilder,
                ),
              ),
            ),
            validator: validator == null
                ? null
                : (value) => validator!(selected),
            controller: TextEditingController(
              text: selected != null ? displayText(selected as T) : '',
            ),
            decoration: InputDecoration(
              // hintStyle: hintStyle.copyWith(
              //   fontSize: 12.sp,
              // ),
              contentPadding: const EdgeInsets.only(top: paddingLarge),
              hintText: "Eg : $hint",
              suffixIcon: Builder(
                builder: (context) {
                  if (selected != null) {
                    return IconButton(
                      onPressed: clearSelection,
                      icon: const Icon(Icons.clear_sharp),
                    );
                  }
                  return const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.arrow_drop_down)],
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: -paddingSmall,
            left: 0,
            child: Text(
              label,
              // style: hintStyle.copyWith(
              //   color: Colors.black,
              // ),
            ),
          ),
        ],
      ),
    );
  }
}

class SelectionScreen<T> extends StatefulWidget {
  const SelectionScreen({
    super.key,
    required this.label,
    required this.hint,
    required this.onSuggestionSelected,
    this.selectedItems = const [],
    required this.suggestionsCallback,
    required this.itemBuilder,
    this.poponSelection = true,
  });

  final String label;
  final String hint;
  final Function(T) onSuggestionSelected;
  final List<T> selectedItems;
  final Function(int, String, PagingController<int, T>) suggestionsCallback;
  final Widget Function(BuildContext context, T item, bool isSelected)
  itemBuilder;
  final bool poponSelection;

  @override
  State<SelectionScreen<T>> createState() => _SelectionScreenState<T>();
}

class _SelectionScreenState<T> extends State<SelectionScreen<T>>
    with SearchMixin {
  late final PagingController<int, T> pagingController;
  @override
  void initState() {
    super.initState();
    pagingController = PagingController(
      getNextPageKey: (state) => state.nextIntPageKey,
      fetchPage: (pageKey) => widget.suggestionsCallback(
        pageKey,
        searchController.text,
        pagingController,
      ),
    );
    addSearchListener(() {
      pagingController.refresh();
    });
  }

  @override
  void dispose() {
    removeSearchListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: paddingLarge),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.maybePop(context, true),
                    child: const Text("Cancel"),
                  ),
                  Text(widget.label),
                  InkWell(
                    onTap: () => Navigator.maybePop(context, true),
                    child: const Text("Done "),
                  ),
                ],
              ),
              SearchField(
                autofocus: true,
                hint: "Eg : ${widget.hint}",
                controller: searchController,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => pagingController.refresh(),
                  child: PagingListener(
                    controller: pagingController,
                    builder: (context, state, fetchNextPage) =>
                        PagedListView<int, T>(
                          fetchNextPage: fetchNextPage,
                          state: state,
                          padding: const EdgeInsets.all(padding),
                          builderDelegate: PagedChildBuilderDelegate(
                            firstPageErrorIndicatorBuilder: (context) =>
                                SizedBox(
                                  height: 400,
                                  child: ErrorWidgetWithRetry(
                                    exception: state.error as Exception,
                                    retry: pagingController.refresh,
                                  ),
                                ),
                            noItemsFoundIndicatorBuilder: (context) =>
                                const NoItemsFound(),
                            firstPageProgressIndicatorBuilder: (context) =>
                                Column(
                                  children: List.generate(
                                    10,
                                    (index) => const ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Shimwrapper(child: Text("data")),
                                    ),
                                  ),
                                ),
                            itemBuilder: (context, item, index) {
                              final isSelected = widget.selectedItems.contains(
                                item,
                              );
                              return InkWell(
                                onTap: () {
                                  widget.onSuggestionSelected(item);
                                  if (widget.poponSelection) {
                                    Navigator.maybePop(context, true);
                                  } else {
                                    if (widget.selectedItems.contains(item)) {
                                      widget.selectedItems.remove(item);
                                    } else {
                                      widget.selectedItems.add(item);
                                    }
                                    setState(() {});
                                  }
                                },
                                child: widget.itemBuilder(
                                  context,
                                  item,
                                  isSelected,
                                ),
                              );
                            },
                          ),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

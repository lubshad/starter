import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../core/app_route.dart';
import '../core/universal_argument.dart';
import '../exporter.dart';
import '../mixins/search_mixin.dart';
import '../models/name_id.dart';
import 'error_widget_with_retry.dart';
import 'no_item_found.dart';
import 'search_field.dart';
import 'shimwrapper.dart';

class TypeAheadSearchField extends StatelessWidget {
  const TypeAheadSearchField({
    super.key,
    required this.selected,
    required this.label,
    required this.onSuggestionSelected,
    required this.suggestionsCallback,
    required this.clearSelection,
    this.horizontalPadding = 0,
    required this.hint,
    this.validator,
  });

  final NameId? selected;
  final String label;
  final String hint;
  final Function(NameId) onSuggestionSelected;
  final VoidCallback clearSelection;
  final double horizontalPadding;
  final String? Function(NameId?)? validator;
  final Function(int, String, PagingController) suggestionsCallback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding).copyWith(
        top: paddingLarge,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          TextFormField(
            readOnly: true,
            onTap: () => Navigator.push(
              context,
              downToTop(
                const RouteSettings(name: "Selection"),
                SelectionScreen(
                  suggestionsCallback: suggestionsCallback,
                  label: label,
                  hint: hint,
                  onSuggestionSelected: onSuggestionSelected,
                  selectedItems: selected == null ? [] : [selected!],
                ),
              ),
            ),
            validator:
                validator == null ? null : (value) => validator!(selected),
            controller: TextEditingController(text: selected?.name),
            decoration: InputDecoration(
              // hintStyle: hintStyle.copyWith(
              //   fontSize: 12.fSize,
              // ),
              contentPadding: const EdgeInsets.only(top: paddingLarge),
              hintText: "Eg : $hint",
              suffixIcon: Builder(builder: (context) {
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
              }),
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

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({
    super.key,
    required this.label,
    required this.hint,
    required this.onSuggestionSelected,
    this.selectedItems = const [],
    required this.suggestionsCallback,
    this.poponSelection = true,
  });

  final String label;
  final String hint;
  final Function(NameId) onSuggestionSelected;
  final List<NameId> selectedItems;
  final Function(int, String, PagingController) suggestionsCallback;
  final bool poponSelection;

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> with SearchMixin {
  PagingController<int, NameId> pagingController =
      PagingController(firstPageKey: 1);
  @override
  void initState() {
    super.initState();
    pagingController
        .addPageRequestListener((pageKey) => widget.suggestionsCallback(
              pageKey,
              searchController.text,
              pagingController,
            ));
    addSearchListener(
      () {
        pagingController.refresh();
      },
    );
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
          padding: const EdgeInsets.symmetric(
            horizontal: paddingLarge,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: () => Navigator.maybePop(context, true),
                      child: const Text("Cancel")),
                  Text(widget.label),
                  InkWell(
                      onTap: () => Navigator.maybePop(context, true),
                      child: const Text("Done ")),
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
                    child: PagedListView<int, NameId>(
                      padding: const EdgeInsets.all(padding),
                      pagingController: pagingController,
                      builderDelegate: PagedChildBuilderDelegate(
                          firstPageErrorIndicatorBuilder: (context) => SizedBox(
                                height: 400,
                                child: ErrorWidgetWithRetry(
                                    exception: pagingController.error,
                                    retry: pagingController.refresh),
                              ),
                          noItemsFoundIndicatorBuilder: (context) =>
                              const NoItemsFound(),
                          firstPageProgressIndicatorBuilder: (context) =>
                              Column(
                                children: List.generate(
                                  10,
                                  (index) => const ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Shimwrapper(child: Text("data"))),
                                ),
                              ),
                          itemBuilder: (context, item, index) => ListTile(
                                leading: widget.selectedItems.contains(item)
                                    ? const Icon(Icons.check)
                                    : null,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
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
                                title: Text(
                                  item.name,
                                ),
                              )),
                      // separatorBuilder: (context, index) => gap,
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}

FutureOr onSuccess(
    PaginationModel<NameId> value, PagingController pagingController) {
  if (value.isLastPage) {
    pagingController.appendLastPage(value.newItems);
  } else {
    pagingController.appendPage(value.newItems, value.nextPage);
  }
}

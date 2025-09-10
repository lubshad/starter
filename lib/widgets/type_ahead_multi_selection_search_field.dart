import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
// import 'package:flutter_svg/svg.dart';
import '../../../exporter.dart';
import '../../../widgets/custom_chip.dart';
import '../../../widgets/form_header.dart';
import '../core/app_route.dart';
import '../models/name_id.dart';
import 'type_ahead_search_field.dart';

class TypeAheadMultiSelectionSearchField extends StatelessWidget {
  const TypeAheadMultiSelectionSearchField({
    super.key,
    required this.selectedItems,
    required this.onSuggestionSelected,
    required this.suggestionsCallback,
    this.validator,
    required this.label,
    this.hint = "Search here",
  });

  final List<NameId> selectedItems;
  final Function(NameId) onSuggestionSelected;
  final Function(int, String, PagingController) suggestionsCallback;

  // final Future<List<NameId>> Function(String) suggestionsCallback;
  final String? Function(List<NameId>)? validator;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return FormHeader(
      label: label,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          IgnorePointer(
            child: Opacity(
              opacity: 0,
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: kToolbarHeight * .5,
                  minWidth: double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: paddingXL),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    spacing: padding,
                    runSpacing: padding,
                    children: [
                      ...selectedItems.map(
                        (e) => CustomChip(
                          onRemove: () => onSuggestionSelected(e),
                          text: e.name,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: TextFormField(
              textAlignVertical: TextAlignVertical.bottom,
              expands: true,
              maxLines: null,
              readOnly: true,
              onTap: () => Navigator.push(
                context,
                downToTop(
                  const RouteSettings(name: "Selection"),
                  SelectionScreen(
                    poponSelection: false,
                    suggestionsCallback: suggestionsCallback,
                    label: label,
                    hint: hint,
                    onSuggestionSelected: onSuggestionSelected,
                    selectedItems: selectedItems,
                    itemBuilder:
                        (BuildContext context, NameId item, bool isSelected) {
                          return ListTile(title: Text(item.name));
                        },
                  ),
                ),
              ),
              validator: validator == null
                  ? null
                  : (value) => validator!(selectedItems),
              // controller: TextEditingController(text: selected?.name),
              decoration: const InputDecoration(
                // hintStyle: hintStyle.copyWith(
                //   fontSize: 12.sp,
                // ),
                contentPadding: EdgeInsets.only(top: paddingLarge),
                // hintText: "Eg : $hint",
                // suffixIcon: Builder(
                //   builder: (context) {
                //     if (selected != null) {
                //       return IconButton(
                //         onPressed: clearSelection,
                //         icon: SvgPicture.asset(
                //           Assets.svgs.clearTypeAhead,
                //         ),
                //       );
                //     }
                //     return Row(
                //       mainAxisSize: MainAxisSize.min,
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         SvgPicture.asset(
                //           Assets.svgs.arrowDownTypeAhead,
                //         ),
                //       ],
                //     );
                //   },
              ),
            ),
          ),
          // child: TypeAheadField<NameId>(
          //   key: Key(selectedItems.toString()),
          //   itemBuilder: (context, value) => ListTile(
          //     title: Text(value.name),
          //   ),
          //   onSelected: onSuggestionSelected,
          //   suggestionsCallback: suggestionsCallback,
          //   builder: (context, controller, focusNode) => TextFormField(
          //     textAlignVertical: TextAlignVertical.bottom,
          //     expands: true,
          //     maxLines: null,
          //     controller: controller,
          //     focusNode: focusNode,
          //     validator: validator,
          //   ),
          // ),
          // ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.start,
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                spacing: padding,
                runSpacing: padding,
                children: [
                  ...selectedItems.map(
                    (e) => CustomChip(
                      onRemove: () => onSuggestionSelected(e),
                      text: e.name,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

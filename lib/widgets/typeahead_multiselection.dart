
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../../widgets/form_header.dart';
import '../exporter.dart';
import '../models/name_id.dart';
import 'custom_chip.dart';

class TypeAheadMultiSelection extends StatelessWidget {
  const TypeAheadMultiSelection({
    super.key,
    required this.selectedItems,
    required this.onSuggestionSelected,
    required this.suggestionsCallback,
    this.validator,
    required this.label,
  });

  final List<NameId> selectedItems;
  final Function(NameId) onSuggestionSelected;
  final Future<List<NameId>> Function(String) suggestionsCallback;
  final String? Function(String?)? validator;
  final String label;

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
                  padding: const EdgeInsets.only(
                    bottom: paddingXL,
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    spacing: padding,
                    runSpacing: padding,
                    children: [
                      ...selectedItems.map((e) => CustomChip(
                            onRemove: () => onSuggestionSelected(e),
                            text: e.name,
                          )),
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
            child: TypeAheadField<NameId>(
              key: Key(selectedItems.toString()),
              itemBuilder: (context, value) => ListTile(
                title: Text(value.name),
              ),
              onSelected: onSuggestionSelected,
              suggestionsCallback: suggestionsCallback,
              builder: (context, controller, focusNode) => TextFormField(
                textAlignVertical: TextAlignVertical.bottom,
                expands: true,
                maxLines: null,
                controller: controller,
                focusNode: focusNode,
                validator: validator,
              ),
            ),
          ),
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
                  ...selectedItems.map((e) => CustomChip(
                        onRemove: () => onSuggestionSelected(e),
                        text: e.name,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

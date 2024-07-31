import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../exporter.dart';
import '../models/name_id.dart';

class TypeAheadDropdown extends StatelessWidget {
  const TypeAheadDropdown({
    super.key,
    required this.selected,
    required this.label,
    required this.onSuggestionSelected,
    required this.suggestionsCallback,
    required this.clearSelection,
    this.horizontalPadding = 0,
    required this.hint,
    this.validator,
    this.setFocusnode,
  });

  final NameId? selected;
  final String label;
  final String hint;
  final Function(NameId) onSuggestionSelected;
  final Future<List<NameId>> Function(String) suggestionsCallback;
  final VoidCallback clearSelection;
  final double horizontalPadding;
  final String? Function(NameId?)? validator;
  final Function(FocusNode)? setFocusnode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding).copyWith(
        top: paddingLarge,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          TypeAheadField<NameId>(
            retainOnLoading: false,
            builder: (context, controller, focusNode) {
              if (setFocusnode != null) {
                setFocusnode!(focusNode);
              }
              clear() {
                controller.clear();
                clearSelection();
              }

              return TextFormField(
                readOnly: selected != null,
                onTap: selected != null ? clear : null,
                focusNode: focusNode,
                validator:
                    validator == null ? null : (value) => validator!(selected),
                controller: selected == null
                    ? controller
                    : TextEditingController(text: selected!.name),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: paddingLarge),
                  hintText: "Eg : $hint",
                  suffixIcon: Builder(builder: (context) {
                    if (selected != null) {
                      return IconButton(
                          onPressed: clear, icon: const Icon(Icons.clear));
                    }
                    return const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_drop_down),
                      ],
                    );
                  }),
                ),
              );
            },
            suggestionsCallback: suggestionsCallback,
            onSelected: (item) {
              onSuggestionSelected(item);
            },
            itemBuilder: (context, item) {
              return ListTile(title: Text(item.name));
            },
          ),
          Positioned(
            top: -paddingSmall,
            left: 0,
            child: Text(
              label,
            ),
          ),
        ],
      ),
    );
  }
}

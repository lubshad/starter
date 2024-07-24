import 'package:flutter/material.dart';

import '../constants.dart';

mixin DateSelectionMixin<T extends StatefulWidget> on State<T> {
  DateTime? primaryDate;
  DateTime now = DateTime.now();
  pickDate() async {
    var result = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(
        const Duration(
          days: 60,
        ),
      ),
    );
    if (result == null) return;
    primaryDate = result;
    setState(() {});
  }

  Widget dateSelectionField({String? title}) => TextFormField(
        onTap: pickDate,
        readOnly: true,
        controller: TextEditingController(
            text: primaryDate == null ? "" : dateFormat.format(primaryDate!)),
        decoration: InputDecoration(
          label: Text(title ?? "Date"),
        ),
      );

  DateTime? secondaryDate;
  pickDateSecondary() async {
    var result = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(
        const Duration(
          days: 60,
        ),
      ),
    );
    if (result == null) return;
    secondaryDate = result;
    setState(() {});
  }

  Widget dateSelectionFieldSecondary({String? title}) => TextFormField(
        onTap: pickDateSecondary,
        readOnly: true,
        controller: TextEditingController(
          text: secondaryDate == null
              ? ""
              : dateFormat.format(
                  secondaryDate!,
                ),
        ),
        decoration: InputDecoration(
          label: Text(title ?? "Date"),
        ),
      );
  DateTime? thirdDate;
  pickDatethirdDate() async {
    var result = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(
        const Duration(
          days: 60,
        ),
      ),
    );
    if (result == null) return;
    thirdDate = result;
    setState(() {});
  }

  Widget dateSelectionFieldthirdDate({String? title}) => TextFormField(
        onTap: pickDatethirdDate,
        readOnly: true,
        controller: TextEditingController(
          text: thirdDate == null
              ? ""
              : dateFormat.format(
                  thirdDate!,
                ),
        ),
        decoration: InputDecoration(
          label: Text(title ?? "Date"),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';

class AppDropdownInput<T> extends StatelessWidget {
  final String hintText;
  final List<T> options;
  final T value;
  final String Function(T) getLabel;
  final void Function(T) onChanged;

  AppDropdownInput({
    this.hintText = 'Please select an Option',
    this.options = const [],
    this.getLabel,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      builder: (FormFieldState<T> state) {
        return InputDecorator(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(left: 5.0),
            border: InputBorder.none,
          ),
          isEmpty: value == null || value == '',
          expands: false,
          textAlign: TextAlign.start,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.cardTextColor,
                size: 20,
              ),
              dropdownColor: Colors.white,
              isExpanded: false,
              isDense: false,
              style: TextStyle(fontSize: 8.0),
              onChanged: onChanged,
              items: options.map((T value) {
                return DropdownMenuItem<T>(
                  value: value,
                  child: Text(getLabel(value),
                      style: TextStyle(
                          fontSize: 10.0,
                          color: AppColors.cardTextColor,
                          fontWeight: FontWeight.w700)),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

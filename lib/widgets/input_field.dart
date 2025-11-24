import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';

class InputField extends StatefulWidget {
  final String title;
  final dynamic onChange;
  final dynamic validator;
  final bool icon;
  final TextEditingController value;
  final TextInputType keyboardType;
  final bool phone; 
  final int maxLength;
  final String hint;
  final double radius;
  final bool readOnly;

  InputField(
      {Key? key,
      required this.title,
      required this.value,
      required this.onChange,
      required this.validator,
      this.keyboardType = TextInputType.text,
      this.phone = false,
      this.icon = false,
      required this.maxLength,
      this.hint = '',
      this.radius = 8.0,
      this.readOnly = false
      });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        widget.title.isNotEmpty ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 10),
          child: Text(
            widget.title,
            style: TextStyle(
              color: AppColor.black.withOpacity(0.5),
              fontFamily: AppFont.StemMedium,
              fontSize: 16,
            ),
            // textAlign: TextAlign.start,
          ),
        ):Container(),
        Container(
          child: TextFormField(
            readOnly: widget.readOnly,
            controller: widget.value,
            obscureText: widget.icon ? hidden : !hidden,
            inputFormatters: widget.phone?<TextInputFormatter>[
                      LengthLimitingTextInputFormatter(widget.maxLength),

              // FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              FilteringTextInputFormatter.allow(RegExp("[0-9 ]")),
MaskedTextInputFormatter(
mask: '000 XX XXX XX XX',
separator: " ",)
            ]:<TextInputFormatter>[
              
            ],
            keyboardType: widget.keyboardType,
             decoration: InputDecoration(
            counterText: '',
            labelText: widget.hint,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: AppColor.primary.withOpacity(0.5), width: 1.0),
                borderRadius: BorderRadius.circular(widget.radius)),
            border: OutlineInputBorder(
                borderSide: BorderSide(),
                borderRadius: BorderRadius.circular(widget.radius)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColor.secondaryText.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(widget.radius)),
            errorBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppColor.red.withOpacity(0.2), width: 1),
                borderRadius: BorderRadius.circular(widget.radius)),
            focusColor: AppColor.primary),
            style: TextStyle(fontSize: 14, fontFamily: AppFont.StemRegular),
            cursorColor: AppColor.primary,
            validator: widget.validator,
            onChanged: (value){},// (value) => widget.onChange(value),
            maxLength: widget.maxLength,
            // maxLengthEnforcement: MaxLengthEnforcement.none
            // ,

          ),
        ),
      ]),
    );
  }
}

class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;
  MaskedTextInputFormatter({
    required this.mask,
    required this.separator,
  });
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      if (newValue.text.length > oldValue.text.length) {
        if (newValue.text.length > mask.length) return oldValue;
        if (newValue.text.length < mask.length &&
            mask[newValue.text.length - 1] == separator) {
          return TextEditingValue(
            text:
                '${oldValue.text}$separator${newValue.text.substring(newValue.text.length - 1)}',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
    }
    return newValue;
  }
}

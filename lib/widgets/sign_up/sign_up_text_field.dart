import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MaskedTextController extends TextEditingController {
  MaskedTextController({String text, this.mask, Map<String, RegExp> translator})
      : super(text: text) {
    this.translator = translator ?? MaskedTextController.getDefaultTranslator();

    this.addListener(() {
      var previous = this._lastUpdatedText;
      if (this.beforeChange(previous, this.text)) {
        this.updateText(this.text);
        this.afterChange(previous, this.text);
      } else {
        this.updateText(this._lastUpdatedText);
      }
    });

    this.updateText(this.text);
  }

  String mask;

  Map<String, RegExp> translator;

  Function afterChange = (String previous, String next) {};
  Function beforeChange = (String previous, String next) {
    return true;
  };

  String _lastUpdatedText = '';

  void updateText(String text) {
    if(text != null){
      this.text = this._applyMask(this.mask, text);
    }
    else {
      this.text = '';
    }

    this._lastUpdatedText = this.text;
  }

  void updateMask(String mask, {bool moveCursorToEnd = true}) {
    this.mask = mask;
    this.updateText(this.text);

    if (moveCursorToEnd) {
      this.moveCursorToEnd();
    }
  }

  void moveCursorToEnd() {
    var text = this._lastUpdatedText;
    this.selection = new TextSelection.fromPosition(
        new TextPosition(offset: (text ?? '').length));
  }

  @override
  void set text(String newText) {
    if (super.text != newText) {
      super.text = newText;
      this.moveCursorToEnd();
    }
  }

  static Map<String, RegExp> getDefaultTranslator() {
    return {
      'A': new RegExp(r'[A-Za-z]'),
      '0': new RegExp(r'[0-9]'),
      '@': new RegExp(r'[A-Za-z0-9]'),
      '*': new RegExp(r'.*')
    };
  }

  String _applyMask(String mask, String value) {
    String result = '';

    var maskCharIndex = 0;
    var valueCharIndex = 0;

    while (true) {
      // if mask is ended, break.
      if (maskCharIndex == mask.length) {
        break;
      }

      // if value is ended, break.
      if (valueCharIndex == value.length) {
        break;
      }

      var maskChar = mask[maskCharIndex];
      var valueChar = value[valueCharIndex];

      // value equals mask, just set
      if (maskChar == valueChar) {
        result += maskChar;
        valueCharIndex += 1;
        maskCharIndex += 1;
        continue;
      }

      // apply translator if match
      if (this.translator.containsKey(maskChar)) {
        if (this.translator[maskChar].hasMatch(valueChar)) {
          result += valueChar;
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }

      // not masked value, fixed char on mask
      result += maskChar;
      maskCharIndex += 1;
      continue;
    }

    return result;
  }
}

class SignUpTextField extends StatelessWidget {
  const SignUpTextField({
    this.hint,
    this.minLines,
    this.maxLines = 1,
    this.textInputType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.controller,
  });

  final String hint;
  final int minLines;
  final int maxLines;
  final TextInputType textInputType;
  final bool obscureText;
  final bool enabled;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: const [
        BoxShadow(
          blurRadius: 4.0,
          color: Color(0x80000000),
          offset: Offset(0.0, 2.0),
          spreadRadius: 0.0,
        )
      ]),
      child: TextField(
        autocorrect: false,
        controller: controller ?? TextEditingController(),
        enabled: enabled,
        decoration: InputDecoration(
          hintStyle: TextStyle(
            color: Color(0xa6323339),
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.62,
          ),
          hintText: hint,
          contentPadding: const EdgeInsets.all(8.0),
        ),
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: textInputType,
        obscureText: obscureText,
      ),
    );
  }
}

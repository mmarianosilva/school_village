import 'package:flutter/material.dart';

class SignUpTextField extends StatelessWidget {
  const SignUpTextField({
    this.hint,
    this.minLines,
    this.maxLines = 1,
    this.textInputType = TextInputType.text,
    this.obscureText = false,
  });

  final String hint;
  final int minLines;
  final int maxLines;
  final TextInputType textInputType;
  final bool obscureText;

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

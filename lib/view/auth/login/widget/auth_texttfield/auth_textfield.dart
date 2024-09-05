import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  final bool obscureText;
  final TextEditingController? controller;

  AuthTextField({this.obscureText = false, this.controller});

  @override
  _AuthTextFieldState createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      maxLines: 1,
      style: TextStyle(
        color: Colors.white70,
      ),
      decoration: InputDecoration(
        suffixIcon: widget.obscureText
            ? IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Color.fromRGBO(194, 38, 156, 1), width: 2.5),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

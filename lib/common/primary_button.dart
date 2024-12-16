import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Text title;
  final Color backgroundColor;

  const PrimaryButton({
    super.key,
    this.onPressed,
    required this.title,
    this.backgroundColor = Colors.green,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor,
          minimumSize: Size(MediaQuery.of(context).size.width * 1,
              MediaQuery.of(context).size.height * 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: widget.title);
  }
}

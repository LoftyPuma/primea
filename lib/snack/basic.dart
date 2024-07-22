import 'package:flutter/material.dart';

class BasicSnack extends SnackBar {
  const BasicSnack({super.key, required super.content})
      : super(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          showCloseIcon: true,
          behavior: SnackBarBehavior.fixed,
          dismissDirection: DismissDirection.horizontal,
        );
}

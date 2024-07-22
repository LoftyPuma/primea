import 'package:flutter/material.dart';

class BasicSnack extends SnackBar {
  BasicSnack({super.key, required super.content})
      : super(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          // margin: const EdgeInsets.all(16),
          showCloseIcon: true,
          behavior: SnackBarBehavior.fixed,
          dismissDirection: DismissDirection.horizontal,
        );
}

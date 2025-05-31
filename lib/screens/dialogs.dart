import 'package:flutter/material.dart';

Future<bool?> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Підтвердження'),
      content: const Text('Ви дійсно хочете вийти?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Ні'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Так'),
        ),
      ],
    ),
  );
}

void showErrorDialog(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Помилка'),
      content: Text(message),
      actions: [
        TextButton(
          child: const Text('ОК'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

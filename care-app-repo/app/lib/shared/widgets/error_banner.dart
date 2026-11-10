import 'package:flutter/material.dart';
import '../../core/errors/app_error.dart';
import '../../core/theme/app_colors.dart';

class ErrorBanner extends StatelessWidget {
  final AppError error;
  final VoidCallback onRetry;
  const ErrorBanner({super.key, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.ink,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(children: [
              const Icon(Icons.wifi_off, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(error.message, style: const TextStyle(color: Colors.white, fontSize: 13.5))),
              TextButton(onPressed: onRetry, child: const Text('다시 연결', style: TextStyle(color: Colors.white))),
            ]),
          ),
        ),
      );
}

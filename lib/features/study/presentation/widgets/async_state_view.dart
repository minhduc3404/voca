import 'package:flutter/material.dart';

import 'package:voca_app/app/theme/app_theme.dart';

/// Widget dùng chung cho loading/error state của màn có dữ liệu async.
///
/// Phase 3 deferred (xem task contract 2026-07-31-phase-3-state-management.md)
/// — ban đầu đặt ở `features/study/presentation/widgets/`; khi có ≥2 feature
/// thật sự dùng chung mới chuyển lên `core/widgets/` (two-feature rule,
/// CLAUDE.md §6).
class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.child,
    this.loadingLabel,
  });

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final Widget child;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.accent),
            if (loadingLabel != null) ...[
              const SizedBox(height: 12),
              Text(loadingLabel!, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      );
    }
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    return child;
  }
}

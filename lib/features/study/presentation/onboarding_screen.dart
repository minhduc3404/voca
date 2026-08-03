import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:voca_app/app/theme/app_icon.dart';
import 'package:voca_app/app/theme/app_theme.dart';

import '../application/providers.dart';
import 'main_scaffold.dart';

/// 3 màn onboarding giới thiệu app (theo wireframe màn 1):
/// "Học tiếng Anh bằng cách nghe và lặp lại tự nhiên".
/// Hiện 1 lần đầu, sau đó flag qua [OnboardingFlagRepository].
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      icon: 'volume-up',
      title: 'Học tiếng Anh bằng cách nghe và lặp lại tự nhiên',
      subtitle:
          'Nghe hội thoại thực tế theo chủ đề, hiểu nhanh, nhớ lâu, dùng được ngay.',
    ),
    (
      icon: 'book-open',
      title: 'Chủ đề gần gũi hằng ngày',
      subtitle: 'Du lịch, công việc, mua sắm, giao tiếp hằng ngày...',
    ),
    (
      icon: 'pause',
      title: 'Rảnh tay — Học mọi lúc mọi nơi',
      subtitle: 'Chỉ cần bấm phát, lắng nghe và lặp lại. Ứng dụng lo phần còn lại.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref
        .read(onboardingFlagRepositoryProvider)
        .markSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScaffold()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.accentGlow,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: AppIcon(
                            page.icon,
                            size: 56,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textFaint,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < _pages.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: i == _page ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: i == _page
                                ? AppColors.accent
                                : AppColors.controlBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (_page < _pages.length - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        } else {
                          _finish();
                        }
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_page < _pages.length - 1 ? 'Tiếp tục' : 'Bắt đầu học'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

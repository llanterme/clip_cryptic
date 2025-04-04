import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clip_cryptic/core/theme/app_theme.dart';
import 'package:clip_cryptic/core/router/app_router.dart';
import 'package:clip_cryptic/core/providers/theme_provider.dart';
import 'package:clip_cryptic/core/services/ad_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Mobile Ads SDK
  final adService = AdService();
  await adService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        adServiceProvider.overrideWithValue(adService),
      ],
      child: const ClipCrypticApp(),
    ),
  );
}

class ClipCrypticApp extends ConsumerWidget {
  const ClipCrypticApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'ClipCryptic',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

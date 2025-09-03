import 'package:app_receitas/data/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/services/auth_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

const _duration = Duration(seconds: 5);

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(duration: _duration, vsync: this)
      ..addStatusListener(_startListener);

    _scaleAnimation = CurvedAnimation(
      curve: Curves.easeInOut,
      parent: _animationController,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
          ),
        );

    _animationController.forward();
  }

  void _startListener(AnimationStatus status) async {
    if (status == AnimationStatus.completed) {
      final isLoggedIn = getIt<IAuthService>().currentUser != null;
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      isLoggedIn ? context.go('/home') : context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (_, __) {
          return SplashComponent(
            scale: _scaleAnimation.value,
            slideAnimation: _slideAnimation,
            fadeAnimation: _fadeAnimation,
            width: _scaleAnimation.value * 100,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class SplashComponent extends StatelessWidget {
  const SplashComponent({
    super.key,
    this.width,
    this.scale = 1.0,

    this.fadeAnimation,
    this.slideAnimation,
  });

  final double? width;
  final double? scale;

  final Animation<double>? fadeAnimation;
  final Animation<Offset>? slideAnimation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 100,
            child: Transform.scale(
              scale: scale,
              child: Image.asset(
                'assets/icons/logo.png',
                color: Colors.black,
                width: width,
              ),
            ),
          ),
          FadeTransition(
            opacity: fadeAnimation!,
            child: SlideTransition(
              position: slideAnimation!,
              child: Text(
                'Eu Amo Cozinhar',
                textAlign: TextAlign.center,
                style: GoogleFonts.dancingScript(
                  fontSize: 38,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

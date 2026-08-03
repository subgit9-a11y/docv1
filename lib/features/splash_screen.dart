import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:doctro/core/constants/prefConstatnt.dart';
import 'package:doctro/core/constants/preferences.dart';
import 'package:doctro/core/navigator_key.dart';
import 'package:doctro/theme/ayureze_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotateAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeIn),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), _checkNavigation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkNavigation() {
    debugPrint('SplashScreen: _checkNavigation called, mounted=$mounted');
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    bool isLoggedIn = false;
    try {
      isLoggedIn = SharedPreferenceHelper.getBoolean(Preferences.is_logged_in);
    } catch (e) {
      debugPrint(
          'SplashScreen: SharedPreferences error, defaulting to not logged in: $e');
      isLoggedIn = false;
    }

    final targetRoute = isLoggedIn ? 'loginHome' : 'SignIn';
    debugPrint('SplashScreen: navigating to $targetRoute');
    try {
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.pushNamedAndRemoveUntil(
          targetRoute,
          (route) => false,
        );
        debugPrint('SplashScreen: navigation successful');
      } else {
        debugPrint('SplashScreen: navigatorKey.currentState is null, retrying');
        _hasNavigated = false;
        Timer(const Duration(milliseconds: 500), _checkNavigation);
      }
    } catch (e, stack) {
      debugPrint('SplashScreen: navigation failed: $e\n$stack');
      _hasNavigated = false;
      Timer(const Duration(milliseconds: 500), _checkNavigation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Elegant animated background gradient
          AnimatedContainer(
            duration: const Duration(seconds: 3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AyurezeTheme.forestDeep.withOpacity(0.9),
                  AyurezeTheme.canvas,
                  AyurezeTheme.healingGreen50.withOpacity(0.4),
                ],
              ),
            ),
          ),
          // Glassmorphic overlay ring animations
          Positioned(
            top: -height * 0.1,
            right: -width * 0.2,
            child: _buildBlurCircle(
                width * 0.7, AyurezeTheme.healingGreen50.withOpacity(0.18)),
          ),
          Positioned(
            bottom: -height * 0.1,
            left: -width * 0.2,
            child: _buildBlurCircle(
                width * 0.8, AyurezeTheme.forestDeep.withOpacity(0.15)),
          ),
          // Brand Presentation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AyurezeTheme.canvas.withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AyurezeTheme.canvas.withOpacity(0.15)),
                        boxShadow: [
                          BoxShadow(
                            color: AyurezeTheme.forestDeep.withOpacity(0.15),
                            blurRadius: 30,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: Image.asset(
                        "assets/images/appIcon.png",
                        height: 90,
                        width: 90,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback elegant brand icon if logo file is missing
                          return Icon(
                            Icons.healing_rounded,
                            size: 80,
                            color: AyurezeTheme.healingGreen50,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        "AYUREZE",
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4.0,
                                  color: AyurezeTheme.canvas,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "DOCTOR WORKSPACE",
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.0,
                                  color: AyurezeTheme.canvas.withOpacity(0.65),
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                // Glowing custom rotation loader
                RotationTransition(
                  turns: _rotateAnimation,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AyurezeTheme.canvas.withOpacity(0.1),
                        width: 3,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: AyurezeTheme.healingGreen50,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AyurezeTheme.healingGreen50,
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/services/service_auth.dart';
import 'halaman_login.dart';
import 'halaman_beranda.dart';

// ============================================================================
// 🖥️ SCREEN/UI - Halaman Splash Screen
// ============================================================================
class HalamanSplash extends StatefulWidget {
  const HalamanSplash({super.key});

  @override
  State<HalamanSplash> createState() => _HalamanSplashState();
}

class _HalamanSplashState extends State<HalamanSplash>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoFadeAnimation;
  
  late Animation<double> _textFadeAnimation;
  
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animasi logo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Simple fade in animation
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeIn,
      ),
    );

    // Setup animasi text - simple fade
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    // Setup animasi progress
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animasi sequence
    _startAnimations();
    
    // Navigate setelah animasi selesai
    _checkAuthAndNavigate();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _progressController.forward();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    
    if (!mounted) return;

    // Check apakah user sudah login
    final currentUser = await ServiceAuth.getCurrentUser();
    
    if (!mounted) return;

    // Fade out animation
    await _logoController.reverse();
    
    if (!mounted) return;

    if (currentUser != null) {
      // Jika sudah login, langsung ke Beranda
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HalamanBeranda(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // Jika belum login, ke halaman Login
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HalamanLogin(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2193b0), // Tosca tua
              Color(0xFF6dd5ed), // Tosca muda/cyan
            ],
          ),
        ),
        child: Stack(
          children: [
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo - Simple Fade In
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: Image.asset(
                      'assets/logo/1.png',
                      width: 280,
                      height: 280,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback jika logo tidak ditemukan
                        return const Icon(
                          Icons.directions_car,
                          size: 180,
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Animated App Name - Simple Fade
                  FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Column(
                      children: [
                        Text(
                          'HexoCar',
                          style: GoogleFonts.poppins(
                            fontSize: 42,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 3),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Tagline
                        Text(
                          'Mobil Keren Ada Disini Boss',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Version
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF2196F3).withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Text(
                            'v1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1565C0),
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // Animated Progress Bar
                  FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Column(
                      children: [
                        // Progress bar
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 200,
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 200 * _progressAnimation.value,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 255, 255, 255),
                                        Color(0xFF2196F3),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF2196F3).withOpacity(0.6),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Loading Text
                        const Text(
                          'Loading your experience...',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(255, 255, 255, 255),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Copyright at bottom
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textFadeAnimation,
                child: const Text(
                  '© 2024 HexoCar. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64B5F6),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

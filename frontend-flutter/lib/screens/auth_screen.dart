import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signInWithService(
    BuildContext context,
    Future<dynamic> Function() signInMethod,
    String service,
  ) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await signInMethod();
      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Inicio de sesión exitoso con $service'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Volver a la pantalla anterior
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al iniciar sesión con $service'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    Icon(
                      Icons.download_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Video Downloader Pro',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Inicia sesión para descargar videos de tus plataformas favoritas',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    _buildAuthButton(
                      context: context,
                      icon: 'assets/icons/google.png',
                      text: 'Continuar con Google',
                      color: Colors.white,
                      textColor: Colors.black87,
                      onPressed: () => _signInWithService(
                        context,
                        () => context.read<AuthService>().signInWithGoogle(),
                        'Google',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAuthButton(
                      context: context,
                      icon: 'assets/icons/facebook.png',
                      text: 'Continuar con Facebook',
                      color: const Color(0xFF1877F2),
                      textColor: Colors.white,
                      onPressed: () => _signInWithService(
                        context,
                        () => context.read<AuthService>().signInWithFacebook(),
                        'Facebook',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildAuthButton(
                      context: context,
                      icon: 'assets/icons/twitter.png',
                      text: 'Continuar con Twitter',
                      color: const Color(0xFF1DA1F2),
                      textColor: Colors.white,
                      onPressed: () => _signInWithService(
                        context,
                        () => context.read<AuthService>().signInWithTwitter(),
                        'Twitter',
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Continuar sin iniciar sesión',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAuthButton({
    required BuildContext context,
    required String icon,
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            height: 24,
            width: 24,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

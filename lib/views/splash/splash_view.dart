import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/catalog_controller.dart';
import '../../core/app_colors.dart';
import '../../core/routes.dart';
import '../../widgets/app_logo.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 2400),
  )..forward();

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    // Warm the catalogue while the animation plays.
    final catalog = context.read<CatalogController>();
    final auth = context.read<AuthController>();
    await Future.wait([
      catalog.load(),
      Future<void>.delayed(Duration(milliseconds: 2600)),
    ]);
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      auth.isLoggedIn ? Routes.shell : Routes.login,
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: _anim,
      curve: Interval(0, 0.5, curve: Curves.easeOut),
    );
    final pop = CurvedAnimation(
      parent: _anim,
      curve: Interval(0, 0.6, curve: Curves.elasticOut),
    );
    final illus = CurvedAnimation(
      parent: _anim,
      curve: Interval(0.3, 0.9, curve: Curves.easeOutBack),
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bg, AppColors.splashEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 3),
              ScaleTransition(
                scale: pop,
                child: FadeTransition(
                  opacity: fade,
                  child: AppLogo(size: 64, showTagline: true, vertical: true),
                ),
              ),
              Spacer(flex: 2),
              ScaleTransition(scale: illus, child: _Illustration()),
              Spacer(flex: 2),
              AnimatedBuilder(
                animation: _anim,
                builder: (_, _) => Container(
                  width: 46,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _anim.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shopping illustration built from plain shapes and icons (no assets).
class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    Widget bubble(double size, Color c) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );

    return SizedBox(
      width: 240,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          bubble(200, AppColors.primaryLight),
          Positioned(
            top: 10,
            right: 26,
            child: bubble(14, AppColors.primary.withValues(alpha: 0.28)),
          ),
          Positioned(
            bottom: 22,
            left: 20,
            child: bubble(22, AppColors.primary.withValues(alpha: 0.18)),
          ),
          Positioned(
            top: 6,
            left: 36,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 22,
              color: Color(0xFFFFC94D),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 56,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: Color(0xFFFFC94D),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 34,
            child: Transform.rotate(
              angle: -0.15,
              child: Icon(
                Icons.inventory_2_rounded,
                size: 52,
                color: Color(0xFF6FA0FF),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 30,
            child: Transform.rotate(
              angle: 0.18,
              child: Icon(
                Icons.shopping_bag_rounded,
                size: 50,
                color: Color(0xFF93B8FF),
              ),
            ),
          ),
          ShaderMask(
            shaderCallback: (r) => AppColors.brandGradient.createShader(r),
            blendMode: BlendMode.srcIn,
            child: Icon(
              Icons.shopping_bag_rounded,
              size: 130,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

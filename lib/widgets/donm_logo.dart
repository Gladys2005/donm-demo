import 'package:flutter/material.dart';
import '../core/theme/donm_theme.dart';

class DonMLogoWidget extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? textColor;

  const DonMLogoWidget({
    super.key,
    this.size = 60,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo icon - cercle orange avec icône de livraison
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [DonMTheme.orangeDonM, DonMTheme.orangeClairDonM],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.2),
            boxShadow: [
              BoxShadow(
                color: DonMTheme.orangeDonM.withOpacity(0.3),
                blurRadius: size * 0.15,
                offset: Offset(0, size * 0.08),
              ),
            ],
          ),
          child: Icon(
            Icons.local_shipping,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
        
        if (showText) ...[
          const SizedBox(width: 12),
          Text(
            'DonM',
            style: TextStyle(
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              color: textColor ?? DonMTheme.noirDonM,
              fontFamily: 'Poppins',
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}

class DonMCircularLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const DonMCircularLogo({
    super.key,
    this.size = 40,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: backgroundColor != null 
            ? LinearGradient(colors: [backgroundColor!, backgroundColor!])
            : const LinearGradient(
                colors: [DonMTheme.orangeDonM, DonMTheme.orangeClairDonM],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: DonMTheme.orangeDonM.withOpacity(0.3),
            blurRadius: size * 0.15,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Icon(
        Icons.local_shipping,
        color: iconColor ?? Colors.white,
        size: size * 0.5,
      ),
    );
  }
}

class DonMSplashLogo extends StatelessWidget {
  final double size;
  final Animation<double> animation;

  const DonMSplashLogo({
    super.key,
    this.size = 120,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [DonMTheme.orangeDonM, DonMTheme.orangeClairDonM],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(size * 0.25),
              boxShadow: [
                BoxShadow(
                  color: DonMTheme.orangeDonM.withOpacity(0.4),
                  blurRadius: size * 0.2,
                  offset: Offset(0, size * 0.1),
                ),
              ],
            ),
            child: Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        );
      },
    );
  }
}

class DonMLogoWithSlogan extends StatelessWidget {
  final double logoSize;
  final double? fontSize;

  const DonMLogoWithSlogan({
    super.key,
    this.logoSize = 80,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DonMLogoWidget(
          size: logoSize,
          showText: true,
        ),
        const SizedBox(height: 8),
        Text(
          'Livraison rapide et fiable',
          style: TextStyle(
            fontSize: fontSize ?? 14,
            color: DonMTheme.grisDonM,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

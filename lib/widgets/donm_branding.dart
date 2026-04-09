import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/theme/donm_theme.dart';

class DonMBranding {
  // Logo SVG personnalisé DonM
  static Widget getLogo({
    double size = 60,
    Color? color,
    bool showText = true,
  }) {
    return Container(
      width: size * 2,
      height: size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône de livraison stylisée
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: DonMTheme.gradientPrincipal,
              borderRadius: BorderRadius.circular(size * 0.15),
              boxShadow: [
                BoxShadow(
                  color: DonMTheme.orangeDonM.withOpacity(0.3),
                  blurRadius: size * 0.2,
                  offset: Offset(0, size * 0.1),
                ),
              ],
            ),
            child: Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: size * 0.6,
            ),
          ),
          
          if (showText) ...[
            const SizedBox(width: 12),
            Text(
              'DonM',
              style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: FontWeight.bold,
                color: color ?? DonMTheme.noirDonM,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Logo circulaire pour les icônes
  static Widget getCircularLogo({
    double size = 40,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: backgroundColor != null 
            ? LinearGradient(colors: [backgroundColor!, backgroundColor!])
            : DonMTheme.gradientPrincipal,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: DonMTheme.orangeDonM.withOpacity(0.3),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.1),
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

  // Badge de statut avec style DonM
  static Widget getStatusBadge({
    required String text,
    required DonMStatus status,
    double? fontSize,
  }) {
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case DonMStatus.success:
        backgroundColor = DonMTheme.succesDonM;
        textColor = Colors.white;
        break;
      case DonMStatus.warning:
        backgroundColor = DonMTheme.avertissementDonM;
        textColor = Colors.white;
        break;
      case DonMStatus.error:
        backgroundColor = DonMTheme.erreurDonM;
        textColor = Colors.white;
        break;
      case DonMStatus.info:
        backgroundColor = DonMTheme.infoDonM;
        textColor = Colors.white;
        break;
      case DonMStatus.pending:
        backgroundColor = DonMTheme.grisDonM;
        textColor = Colors.white;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize ?? 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  // Carte avec style DonM
  static Widget getDonMCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    double? elevation,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: elevation ?? 4,
      shadowColor: DonMTheme.noirDonM.withOpacity(0.1),
      color: backgroundColor ?? DonMTheme.blancDonM,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }

  // Bouton principal DonM
  static Widget getDonMButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isOutlined = false,
    DonMButtonType type = DonMButtonType.primary,
    double? width,
    double? height,
    IconData? icon,
  }) {
    Color backgroundColor;
    Color foregroundColor;
    Color borderColor;
    
    switch (type) {
      case DonMButtonType.primary:
        backgroundColor = DonMTheme.orangeDonM;
        foregroundColor = Colors.white;
        borderColor = DonMTheme.orangeDonM;
        break;
      case DonMButtonType.secondary:
        backgroundColor = DonMTheme.vertDonM;
        foregroundColor = Colors.white;
        borderColor = DonMTheme.vertDonM;
        break;
      case DonMButtonType.tertiary:
        backgroundColor = Colors.transparent;
        foregroundColor = DonMTheme.orangeDonM;
        borderColor = DonMTheme.orangeDonM;
        break;
    }
    
    return SizedBox(
      width: width,
      height: height ?? 50,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: foregroundColor,
                side: BorderSide(color: borderColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _buildButtonContent(text, icon, isLoading),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                elevation: 0,
                shadowColor: backgroundColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _buildButtonContent(text, icon, isLoading),
            ),
    );
  }

  static Widget _buildButtonContent(String text, IconData? icon, bool isLoading) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    
    return Text(text);
  }

  // Header avec style DonM
  static Widget getDonMHeader({
    required String title,
    String? subtitle,
    Widget? action,
    bool showBackButton = false,
    VoidCallback? onBackPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: DonMTheme.gradientPrincipal,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (showBackButton)
                  GestureDetector(
                    onTap: onBackPressed ?? () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (showBackButton) const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (action != null) action,
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Bottom sheet avec style DonM
  static Widget getDonMBottomSheet({
    required Widget child,
    double? height,
  }) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: DonMTheme.grisDonM,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  // Animation de chargement DonM
  static Widget getDonMLoader({double size = 50}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(DonMTheme.orangeDonM),
        backgroundColor: DonMTheme.orangeClairDonM.withOpacity(0.3),
      ),
    );
  }
}

enum DonMStatus {
  success,
  warning,
  error,
  info,
  pending,
}

enum DonMButtonType {
  primary,
  secondary,
  tertiary,
}

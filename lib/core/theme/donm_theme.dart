import 'package:flutter/material.dart';
import 'app_theme.dart';

class DonMTheme {
  // Couleurs principales DonM - Inspirées du drapeau ivoirien
  static const Color orangeDonM = Color(0xFFFF6B35);      // Orange vif
  static const Color vertDonM = Color(0xFF00A651);        // Vert ivoirien
  static const Color vertFonceDonM = Color(0xFF007A3D);   // Vert foncé
  static const Color orangeClairDonM = Color(0xFFFFB366);  // Orange clair
  
  // Couleurs secondaires
  static const Color blancDonM = Color(0xFFFFFFFF);         // Blanc pur
  static const Color noirDonM = Color(0xFF1A1A1A);        // Noir profond
  static const Color grisDonM = Color(0xFF6B7280);        // Gris moderne
  static const Color grisClairDonM = Color(0xFFF3F4F6);   // Gris clair
  
  // Couleurs fonctionnelles
  static const Color succesDonM = Color(0xFF10B981);      // Vert succès
  static const Color erreurDonM = Color(0xFFEF4444);       // Rouge erreur
  static const Color avertissementDonM = Color(0xFFF59E0B); // Orange avertissement
  static const Color infoDonM = Color(0xFF3B82F6);         // Bleu info
  
  // Gradients DonM
  static const LinearGradient gradientPrincipal = LinearGradient(
    colors: [orangeDonM, vertDonM],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientOrange = LinearGradient(
    colors: [orangeDonM, orangeClairDonM],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient gradientVert = LinearGradient(
    colors: [vertDonM, vertFonceDonM],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Thème clair DonM
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: Brightness.light,
      
      // Couleurs principales
      colorScheme: const ColorScheme.light(
        primary: orangeDonM,
        secondary: vertDonM,
        tertiary: vertFonceDonM,
        surface: blancDonM,
        background: grisClairDonM,
        error: erreurDonM,
        onPrimary: blancDonM,
        onSecondary: blancDonM,
        onTertiary: blancDonM,
        onSurface: noirDonM,
        onBackground: noirDonM,
        onError: blancDonM,
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: blancDonM,
        foregroundColor: noirDonM,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: noirDonM,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(
          color: noirDonM,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: orangeDonM,
          size: 24,
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: blancDonM,
        selectedItemColor: orangeDonM,
        unselectedItemColor: grisDonM,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins',
        ),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orangeDonM,
          foregroundColor: blancDonM,
          elevation: 0,
          shadowColor: orangeDonM.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      
      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: orangeDonM,
          side: const BorderSide(color: orangeDonM, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: vertDonM,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      
      // Card
      cardTheme: CardTheme(
        color: blancDonM,
        elevation: 4,
        shadowColor: noirDonM.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grisClairDonM,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: grisDonM, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: orangeDonM, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: erreurDonM, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: grisDonM,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        labelStyle: const TextStyle(
          color: noirDonM,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: orangeDonM,
        foregroundColor: blancDonM,
        elevation: 6,
        shape: CircleBorder(),
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: grisClairDonM,
        selectedColor: orangeDonM.withOpacity(0.1),
        disabledColor: grisDonM.withOpacity(0.1),
        labelStyle: const TextStyle(
          color: noirDonM,
          fontSize: 12,
          fontFamily: 'Poppins',
        ),
        secondaryLabelStyle: const TextStyle(
          color: orangeDonM,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: noirDonM,
        size: 24,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: noirDonM,
          fontFamily: 'Poppins',
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: noirDonM,
          fontFamily: 'Poppins',
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: noirDonM,
          fontFamily: 'Poppins',
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: noirDonM,
          fontFamily: 'Poppins',
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: noirDonM,
          fontFamily: 'Poppins',
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: noirDonM,
          fontFamily: 'Poppins',
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: noirDonM,
          fontFamily: 'Poppins',
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: noirDonM,
          fontFamily: 'Poppins',
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: noirDonM,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: noirDonM,
          fontFamily: 'Poppins',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: noirDonM,
          fontFamily: 'Poppins',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: noirDonM,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  // Thème sombre DonM
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      brightness: Brightness.dark,
      
      // Couleurs principales
      colorScheme: const ColorScheme.dark(
        primary: orangeDonM,
        secondary: vertDonM,
        tertiary: vertFonceDonM,
        surface: Color(0xFF1F2937),
        background: Color(0xFF111827),
        error: erreurDonM,
        onPrimary: blancDonM,
        onSecondary: blancDonM,
        onTertiary: blancDonM,
        onSurface: blancDonM,
        onBackground: blancDonM,
        onError: blancDonM,
      ),
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F2937),
        foregroundColor: blancDonM,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: blancDonM,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
        iconTheme: IconThemeData(
          color: blancDonM,
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: orangeDonM,
          size: 24,
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1F2937),
        selectedItemColor: orangeDonM,
        unselectedItemColor: grisDonM,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Card
      cardTheme: CardTheme(
        color: const Color(0xFF1F2937),
        elevation: 4,
        shadowColor: noirDonM.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF374151),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: grisDonM, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: orangeDonM, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: erreurDonM, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(
          color: grisDonM,
          fontSize: 14,
          fontFamily: 'Poppins',
        ),
        labelStyle: const TextStyle(
          color: blancDonM,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
      
      // Text Theme pour mode sombre
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: blancDonM,
          fontFamily: 'Poppins',
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: blancDonM,
          fontFamily: 'Poppins',
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: blancDonM,
          fontFamily: 'Poppins',
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: blancDonM,
          fontFamily: 'Poppins',
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: blancDonM,
          fontFamily: 'Poppins',
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: blancDonM,
          fontFamily: 'Poppins',
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: blancDonM,
          fontFamily: 'Poppins',
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: blancDonM,
          fontFamily: 'Poppins',
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: blancDonM,
          fontFamily: 'Poppins',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: blancDonM,
          fontFamily: 'Poppins',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: blancDonM,
          fontFamily: 'Poppins',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: blancDonM,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

// Widget personnalisé pour le logo DonM
class DonMLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const DonMLogo({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: DonMTheme.gradientPrincipal,
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: DonMTheme.orangeDonM.withOpacity(0.3),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'DonM',
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

// Widget personnalisé pour les icônes DonM
class DonMIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const DonMIcon({
    super.key,
    required this.icon,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? DonMTheme.orangeDonM.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: color ?? DonMTheme.orangeDonM,
      ),
    );
  }
}

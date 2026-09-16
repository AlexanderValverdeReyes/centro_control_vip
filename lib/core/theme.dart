import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Extensión semántica de colores empresariales para Centro de Control VIP
/// Toda la UI debe leer sus colores de esta paleta mediante Theme.of(context).extension<AppPalette>()
class AppPalette extends ThemeExtension<AppPalette> {
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color tertiary;
  final Color onTertiary;
  final Color neutral;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color outline;
  final Color textoPrincipal;
  final Color textoSecundario;
  final Color exito;
  final Color advertencia;
  final Color peligro;
  final Color gold;

  const AppPalette({
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.tertiary,
    required this.onTertiary,
    required this.neutral,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.outline,
    required this.textoPrincipal,
    required this.textoSecundario,
    required this.exito,
    required this.advertencia,
    required this.peligro,
    required this.gold,
  });

  @override
  ThemeExtension<AppPalette> copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? tertiary,
    Color? onTertiary,
    Color? neutral,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? outline,
    Color? textoPrincipal,
    Color? textoSecundario,
    Color? exito,
    Color? advertencia,
    Color? peligro,
    Color? gold,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      tertiary: tertiary ?? this.tertiary,
      onTertiary: onTertiary ?? this.onTertiary,
      neutral: neutral ?? this.neutral,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      outline: outline ?? this.outline,
      textoPrincipal: textoPrincipal ?? this.textoPrincipal,
      textoSecundario: textoSecundario ?? this.textoSecundario,
      exito: exito ?? this.exito,
      advertencia: advertencia ?? this.advertencia,
      peligro: peligro ?? this.peligro,
      gold: gold ?? this.gold,
    );
  }

  @override
  ThemeExtension<AppPalette> lerp(covariant ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      onTertiary: Color.lerp(onTertiary, other.onTertiary, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      textoPrincipal: Color.lerp(textoPrincipal, other.textoPrincipal, t)!,
      textoSecundario: Color.lerp(textoSecundario, other.textoSecundario, t)!,
      exito: Color.lerp(exito, other.exito, t)!,
      advertencia: Color.lerp(advertencia, other.advertencia, t)!,
      peligro: Color.lerp(peligro, other.peligro, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette {
    return Theme.of(this).extension<AppPalette>() ?? AppPaletteDefaults.light;
  }

  TextStyle mono({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize ?? 12,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? palette.textoPrincipal,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize ?? 13,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? palette.textoPrincipal,
      letterSpacing: letterSpacing,
      height: height,
    );
  }
}

class AppPaletteDefaults {
  static const AppPalette light = AppPalette(
    primary: Color(0xFF0B3B6F), // Azul corporativo
    onPrimary: Colors.white,
    secondary: Color(0xFFD4AF37), // Oro metálico
    onSecondary: Colors.black,
    tertiary: Color(0xFFF5B700), // Ámbar de acento
    onTertiary: Colors.black,
    neutral: Color(0xFF1A1A1B),
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFF0F1F4),
    outline: Color(0xFFE2E4E9),
    textoPrincipal: Color(0xFF1A1A1B),
    textoSecundario: Color(0xFF6B7280),
    exito: Color(0xFF2E7D32),
    advertencia: Color(0xFFEF6C00),
    peligro: Color(0xFFC62828),
    gold: Color(0xFFD4AF37),
  );

  static const AppPalette dark = AppPalette(
    primary: Color(0xFF1E5A9E), // Azul aclarado para contraste en oscuro
    onPrimary: Colors.white,
    secondary: Color(0xFFD4AF37),
    onSecondary: Colors.black,
    tertiary: Color(0xFFF5B700),
    onTertiary: Colors.black,
    neutral: Color(0xFF1A1A1B),
    background: Color(0xFF1A1A1B),
    surface: Color(0xFF232326),
    surfaceVariant: Color(0xFF2C2C30),
    outline: Color(0xFF3A3A3E),
    textoPrincipal: Color(0xFFFFFFFF),
    textoSecundario: Color(0xFFB0B3B8),
    exito: Color(0xFF66BB6A),
    advertencia: Color(0xFFFFA726),
    peligro: Color(0xFFEF5350),
    gold: Color(0xFFD4AF37),
  );
}

ThemeData buildLightTheme() {
  const p = AppPaletteDefaults.light;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: p.background,
    canvasColor: p.background,
    cardColor: p.surface,
    dividerColor: p.outline,
    extensions: const [p],
    colorScheme: ColorScheme.light(
      primary: p.primary,
      onPrimary: p.onPrimary,
      secondary: p.secondary,
      onSecondary: p.onSecondary,
      surface: p.surface,
      onSurface: p.textoPrincipal,
      error: p.peligro,
      onError: Colors.white,
      outline: p.outline,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: p.textoPrincipal,
      displayColor: p.textoPrincipal,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: p.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
  );
}

ThemeData buildDarkTheme() {
  const p = AppPaletteDefaults.dark;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: p.background,
    canvasColor: p.background,
    cardColor: p.surface,
    dividerColor: p.outline,
    extensions: const [p],
    colorScheme: ColorScheme.dark(
      primary: p.primary,
      onPrimary: p.onPrimary,
      secondary: p.secondary,
      onSecondary: p.onSecondary,
      surface: p.surface,
      onSurface: p.textoPrincipal,
      error: p.peligro,
      onError: Colors.white,
      outline: p.outline,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: p.textoPrincipal,
      displayColor: p.textoPrincipal,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: p.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    ),
  );
}

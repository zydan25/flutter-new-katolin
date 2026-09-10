import 'package:flutter/material.dart';

/// Design tokens extracted from the web app (web/src/App.tsx, MainHomeScreen.tsx).
/// These exact values guarantee visual parity between Flutter and web.
class WebTheme {
  WebTheme._();

  /// Content background of the app frame (web: #F4F6F9).
  static const Color bg = Color(0xFFF4F6F9);

  /// Alternate home background (web MainHomeScreen: #F7F9FC).
  static const Color homeBg = Color(0xFFF7F9FC);

  static const Color white = Colors.white;

  // ---- Text ----
  static const Color textPrimary = Color(0xFF1E293B); // slate-800
  static const Color textSecondary = Color(0xFF64748B); // slate-500
  static const Color textMuted = Color(0xFF94A3B8); // slate-400

  // ---- Borders ----
  static const Color border = Color(0xFFE2E8F0); // slate-200
  static const Color borderStrong = Color(0xFFCBD5E1); // slate-300

  // ---- Accents (web-colors) ----
  static const Color cyan = Color(0xFF0284C7);
  static const Color emerald = Color(0xFF059669);
  static const Color emeraldBtn = Color(0xFF4CAF50);
  static const Color greenBtn = Color(0xFF4CAF50);
  static const Color blueBtn = Color(0xFF1E88E5);
  static const Color whatsappBtn = Color(0xFF00BCD4);
  static const Color coral = Color(0xFFE57373);
  static const Color crimson = Color(0xFF8B1D3B);

  // ---- Tab tracks (web) ----
  static const Color tabTrack = Color(0xFFFED7AA); // standard
  static const Color tabTrack4G = Color(0xFFBAE6FD);
  static const Color tabTrackNet = Color(0xFFC7D2FE);
  static const Color tabTrackSabafon = Color(0xFFE0F2FE);

  // ---- Amber tinted surfaces (web باقات tab) ----
  static const Color amberSurface = Color(0xFFFFF8F0); // bg-[#FFF8F0]
  static const Color amberBorder = Color(0xFFFCD9A0); // amber-200/90
  static const Color amberDivider = Color(0xFFFDE68A); // amber-200/60
  static const Color amberTrack = Color(0xFFFFF8F0); // #FFF8F0 / #FDFBF7
  static const Color amberPill = Color(0xFFFEF3C7); // bg-[#FEF3C7]
  static const Color amberPillText = Color(0xFF92400E); // text-[#92400E]
  static const Color amberAction = Color(0xFFFED7AA);
  static const Color amberActionHover = Color(0xFFFDBA74);
  static const Color accordionBody = Color(0xFFFDFBF7);

  // ---- Misc web surfaces ----
  static const Color cyanBanner = Color(0xFF26C6DA);
  static const Color labelBg = Color(0xFFE0E7FF); // indigo-100 (inquiry tables)
  static const Color slateMuted = Color(0xFFF8FAFC); // slate-50
  static const Color slate100 = Color(0xFFF1F5F9); // slate-100

  static const Color rose = Color(0xFFE11D48);
  static const Color amberStrong = Color(0xFFF59E0B);
}

/// White rounded web-style card (rounded-2xl, border slate-200, soft shadow).
class WebCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final double borderRadius;
  final Border? border;
  final bool shadow;

  const WebCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.color = Colors.white,
    this.borderRadius = 18,
    this.border,
    this.shadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(color: WebTheme.border),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

/// Multicolored 8-dots spinner exactly like the web loading modal.
class WebDotsLoader extends StatefulWidget {
  final double size;
  const WebDotsLoader({Key? key, this.size = 54}) : super(key: key);

  @override
  State<WebDotsLoader> createState() => _WebDotsLoaderState();
}

class _WebDotsLoaderState extends State<WebDotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const List<Color> _colors = [
    Color(0xFFEF4444), // red-500
    Color(0xFFF97316), // orange-500
    Color(0xFFFACC15), // yellow-400
    Color(0xFF10B981), // emerald-500
    Color(0xFF06B6D4), // cyan-500
    Color(0xFF2563EB), // blue-600
    Color(0xFF9333EA), // purple-600
    Color(0xFFEC4899), // pink-500
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final dot = size * 0.22;
    final center = size / 2;

    return SizedBox(
      width: size,
      height: size,
      child: RotationTransition(
        turns: _controller,
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(8, (i) {
            final angle = i * 3.141592653589793 / 4;
            final r = center - dot / 2;
            final dx = center + r * _cos(angle);
            final dy = center + r * _sin(angle);
            return Positioned(
              left: dx - dot / 2,
              top: dy - dot / 2,
              child: Container(
                width: dot,
                height: dot,
                decoration: BoxDecoration(
                  color: _colors[i],
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  double _cos(double angle) {
    const table = <int, double>{
      0: 1.0,
      1: 0.7071067811865476,
      2: 0.0,
      3: -0.7071067811865476,
      4: -1.0,
      5: -0.7071067811865476,
      6: 0.0,
      7: 0.7071067811865476,
    };
    final known = angle == 0 ? 0 : (angle / 3.141592653589793 * 4).round();
    return table[((known % 8) + 8) % 8] ?? 1.0;
  }

  double _sin(double angle) {
    // cos(90 - angle)
    return _cos(1.5707963267948966 - angle);
  }
}

/// Open the full-page loading dialog (8 colored dots + "الرجاء الإنتظار قليلاً...").
Future<void> showWebLoadingModal(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black38,
    builder: (ctx) => const Directionality(
      textDirection: TextDirection.rtl,
      child: WebLoadingModal(),
    ),
  );
}

void hideWebLoadingModal(BuildContext context) {
  Navigator.of(context).pop();
}

class WebLoadingModal extends StatelessWidget {
  const WebLoadingModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: WebCard(
        color: Colors.white,
        borderRadius: 24,
        padding: const EdgeInsets.all(26),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WebDotsLoader(),
            SizedBox(height: 16),
            Text(
              'الرجاء الإنتظار قليلاً...',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Success popup matching web MODAL 5 (green check circle + المرجع + تم).
Future<void> showWebSuccess(
  BuildContext context, {
  required String title,
  required String message,
  String referenceId = '',
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: WebSuccessDialog(
        title: title,
        message: message,
        referenceId: referenceId,
      ),
    ),
  );
}

class WebSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String referenceId;

  const WebSuccessDialog({
    Key? key,
    required this.title,
    required this.message,
    this.referenceId = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: Color(0xFF059669), size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.5),
          ),
          if (referenceId.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'المرجع: $referenceId',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('تم', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}

/// Failure popup matching web MODAL 4 (orange (i) + السبب + موافق coral).
Future<void> showWebFailure(
  BuildContext context, {
  required String title,
  required String reason,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: WebFailureDialog(title: title, reason: reason),
    ),
  );
}

class WebFailureDialog extends StatelessWidget {
  final String title;
  final String reason;

  const WebFailureDialog({Key? key, required this.title, required this.reason})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF59E0B), width: 4),
            ),
            alignment: Alignment.center,
            child: const Text(
              'i',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            reason,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE57373),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('موافق', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
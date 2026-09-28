import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brutal_wallz/components/brutal_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ─── Brand colours (matches HomePage palette) ───────────────────────────────
  static const Color bg = Color(0xFFF4F0E6);
  static const Color yellow = Color(0xFFFDE047);
  static const Color pink = Color(0xFFF9A8D4);
  static const Color blue = Color(0xFF93C5FD);
  static const Color green = Color(0xFF86EFAC);
  static const Color orange = Color(0xFFFDBA74);

  // ─── Create-account form state ───────────────────────────────────────────────
  bool _showCreateForm = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  void _navigateHome() => context.go('/loading-page');

  void _onGoogleTap() {
    // TODO: wire up google_sign_in
    _navigateHome();
  }

  void _onGitHubTap() {
    // TODO: wire up GitHub OAuth
    _navigateHome();
  }

  void _onCreateAccount() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: pink,
          content: const Text(
            'FILL ALL FIELDS!',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      );
      return;
    }
    // TODO: wire up real auth
    _navigateHome();
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                child: child,
              ),
          child: _showCreateForm ? _buildCreateForm() : _buildLanding(),
        ),
      ),
    );
  }

  // ─── Landing screen ──────────────────────────────────────────────────────────

  Widget _buildLanding() {
    return SingleChildScrollView(
      key: const ValueKey('landing'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skip button ────────────────────────────────────────────────────────
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: _navigateHome,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(3, 3)),
                  ],
                ),
                child: const Text(
                  'SKIP →',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
            ),
          ),

          const SizedBox(height: 36),

          // Hero badge ─────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: yellow,
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(4, 4)),
              ],
            ),
            child: const Text(
              'NEO-BRUTALIST WALLS',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
            ),
          ),

          const SizedBox(height: 16),

          // App title ──────────────────────────────────────────────────────────
          const Text(
            'BRUTAL\nWALLZ.',
            style: TextStyle(
              fontSize: 58,
              fontWeight: FontWeight.w900,
              height: 0.9,
              letterSpacing: -2,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: blue,
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(4, 4)),
              ],
            ),
            child: const Text(
              'High-voltage aesthetics for bold setups. Sign in to save favourites and sync across devices.',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),

          const SizedBox(height: 36),

          // OAuth buttons ──────────────────────────────────────────────────────
          _SocialButton(
            label: 'CONTINUE WITH GOOGLE',
            color: Colors.white,
            shadowOffset: 5,
            icon: _GoogleIcon(),
            onTap: _onGoogleTap,
          ),

          const SizedBox(height: 16),

          _SocialButton(
            label: 'CONTINUE WITH GITHUB',
            color: Colors.black,
            labelColor: Colors.white,
            shadowOffset: 5,
            icon: _GitHubIcon(color: Colors.white),
            onTap: _onGitHubTap,
          ),

          const SizedBox(height: 24),

          // Divider ────────────────────────────────────────────────────────────
          Row(
            children: const [
              Expanded(child: Divider(color: Colors.black, thickness: 2)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
              Expanded(child: Divider(color: Colors.black, thickness: 2)),
            ],
          ),

          const SizedBox(height: 24),

          // Create account button ───────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 58,
            child: BrutalButton(
              color: green,
              shadowOffset: 6,
              onTap: () => setState(() => _showCreateForm = true),
              child: const Center(
                child: Text(
                  'CREATE AN ACCOUNT',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Footer note ────────────────────────────────────────────────────────
          const Center(
            child: Text(
              'By continuing you agree to our Terms & Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Create-account form ─────────────────────────────────────────────────────

  Widget _buildCreateForm() {
    return SingleChildScrollView(
      key: const ValueKey('create'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + Skip row ────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _showCreateForm = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(3, 3)),
                    ],
                  ),
                  child: const Text(
                    '← BACK',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _navigateHome,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, offset: Offset(3, 3)),
                    ],
                  ),
                  child: const Text(
                    'SKIP →',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 36),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: orange,
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(4, 4)),
              ],
            ),
            child: const Text(
              'NEW ACCOUNT',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'JOIN\nBRUTAL.',
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.w900,
              height: 0.9,
              letterSpacing: -2,
            ),
          ),

          const SizedBox(height: 32),

          // Name field ─────────────────────────────────────────────────────────
          _BrutalTextField(
            controller: _nameController,
            label: 'YOUR NAME',
            hint: 'e.g. ALEX BRUTAL',
            prefixIcon: Icons.person_outline,
          ),

          const SizedBox(height: 16),

          // Email field ────────────────────────────────────────────────────────
          _BrutalTextField(
            controller: _emailController,
            label: 'EMAIL',
            hint: 'your@email.com',
            prefixIcon: Icons.alternate_email,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          // Password field ─────────────────────────────────────────────────────
          _BrutalTextField(
            controller: _passwordController,
            label: 'PASSWORD',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              child: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Submit button ──────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 60,
            child: BrutalButton(
              color: yellow,
              shadowOffset: 6,
              onTap: _onCreateAccount,
              child: const Center(
                child: Text(
                  'CREATE ACCOUNT →',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Already have account ───────────────────────────────────────────────
          Center(
            child: GestureDetector(
              onTap: () => setState(() => _showCreateForm = false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                child: const Text(
                  'Already have an account? SIGN IN',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          const Center(
            child: Text(
              'By creating an account you agree to our Terms & Privacy Policy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

/// A brutal-styled text field with a thick border and box shadow.
class _BrutalTextField extends StatelessWidget {
  const _BrutalTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(4, 4)),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: const TextStyle(fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Colors.black38,
                fontWeight: FontWeight.w600,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              prefixIcon: Icon(prefixIcon, color: Colors.black, size: 20),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}

/// OAuth / social login button with a brutal press effect.
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.shadowOffset,
    this.labelColor = Colors.black,
  });

  final String label;
  final Color color;
  final Color labelColor;
  final Widget icon;
  final VoidCallback onTap;
  final double shadowOffset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: BrutalButton(
        color: color,
        shadowOffset: shadowOffset,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              SizedBox(width: 28, height: 28, child: icon),
              const Spacer(),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: labelColor,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SVG-free icon widgets ────────────────────────────────────────────────────

/// Hand-drawn Google "G" using a CustomPainter (no SVG dependency needed).
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GooglePainter());
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.44;

    // Ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.13;

    // Blue arc (top → right)
    ringPaint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -1.57, // -90°
      1.57,  //  90°
      false,
      ringPaint,
    );

    // Red arc (left → top)
    ringPaint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -1.57 - 1.57,
      1.57,
      false,
      ringPaint,
    );

    // Yellow arc (bottom → left)
    ringPaint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      1.57,
      1.05,
      false,
      ringPaint,
    );

    // Green arc (right → bottom)
    ringPaint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      0,
      1.57,
      false,
      ringPaint,
    );

    // Horizontal bar of the "G"
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = size.width * 0.13
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + r, cy),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple GitHub Octocat silhouette using a CustomPainter.
class _GitHubIcon extends StatelessWidget {
  const _GitHubIcon({this.color = Colors.black});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GitHubPainter(color));
  }
}

class _GitHubPainter extends CustomPainter {
  const _GitHubPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final cx = size.width / 2;
    final cy = size.height / 2 - size.height * 0.05;
    final r = size.width * 0.38;

    // Head (circle)
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // Body (rounded rect below head)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + r + size.height * 0.14),
        width: size.width * 0.68,
        height: size.height * 0.4,
      ),
      Radius.circular(size.width * 0.1),
    );
    canvas.drawRRect(bodyRect, paint);

    // White cutout (eye area / face)
    final facePaint = Paint()..color = color == Colors.white ? Colors.black : Colors.white;
    canvas.drawCircle(Offset(cx, cy - size.height * 0.04), r * 0.45, facePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

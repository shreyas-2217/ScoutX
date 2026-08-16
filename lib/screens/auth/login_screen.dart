import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';
import '../shared/widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  late final AnimationController _controller;
  late final Animation<double> _opacityAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DSMotion.slow,
    );
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: DSMotion.easeOut));
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: DSMotion.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().signIn(
            _email.text,
            _password.text,
          );
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = context.watch<AuthProvider>().error;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: DSColors.bgGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                DSSpacing.xl,
                DSSpacing.lg,
                DSSpacing.xl,
                DSSpacing.xl,
              ),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnim.value,
                    child: Transform.translate(
                      offset: _slideAnim.value * 40,
                      child: Transform.scale(
                        scale: _scaleAnim.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHero(context),
                        const SizedBox(height: DSSpacing.md),
                        _buildCard(context, error),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.md,
        DSSpacing.xl,
        DSSpacing.md,
        DSSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: DSColors.volt,
        borderRadius: BorderRadius.circular(DSRadius.xxxl),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: DSColors.onBrand.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(DSRadius.xxl),
            ),
            child: Icon(
              DSIcons.flash_on_rounded,
              size: 38,
              color: DSColors.onBrand,
            ),
          ),
          SizedBox(height: DSSpacing.md),
          Text(
            'ScoutX',
            style: GoogleFonts.sora(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
              color: DSColors.onBrand,
            ),
          ),
          SizedBox(height: DSSpacing.sm),
          Text(
            AppConstants.tagline,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
              color: DSColors.onBrand.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String? error) {
    return DSCard(
      padding: const EdgeInsets.all(DSSpacing.xl),
      animate: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(DSIcons.envelope),
            ),
            validator: (v) => (v == null || !v.contains('@'))
                ? 'Enter a valid email'
                : null,
          ),
          SizedBox(height: DSSpacing.md),
          TextFormField(
            controller: _password,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(DSIcons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? DSIcons.eyeSlash
                      : DSIcons.eye,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) => (v == null || v.isEmpty)
                ? 'Enter your password'
                : null,
            onFieldSubmitted: (_) => _submit(),
          ),
          if (error != null) ...[
            SizedBox(height: DSSpacing.md),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DSColors.red,
              ),
            ),
          ],
          SizedBox(height: DSSpacing.xl),
          DSButton(
            label: 'Sign In',
            leadingIcon: DSIcons.login_rounded,
            loading: _loading,
            fullWidth: true,
            onPressed: _loading ? null : _submit,
          ),
          SizedBox(height: DSSpacing.lg),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DSSpacing.md),
                child: Text(
                  'new to ScoutX?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: DSColors.onSurfaceVariant,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          SizedBox(height: DSSpacing.lg),
          DSButton(
            label: 'Create an account',
            variant: DSButtonVariant.outlined,
            fullWidth: true,
            onPressed: _loading
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}

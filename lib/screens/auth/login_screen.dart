import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:scoutx/design_system.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
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
  bool _googleLoading = false;

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

  Future<void> _signInWithGoogle() async {
    if (_googleLoading || _loading) return;
    setState(() => _googleLoading = true);
    try {
      await context.read<AuthProvider>().signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential' &&
          e.credential != null) {
        final email = e.email ?? _email.text.trim();
        if (email.isNotEmpty && mounted) {
          await _showGoogleLinkDialog(email, e.credential!);
        }
      }
    } catch (_) {
      // error text is surfaced via AuthProvider.error
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _showGoogleLinkDialog(
    String email,
    AuthCredential googleCredential,
  ) async {
    final passwordController = TextEditingController();
    String? dialogError;
    bool linking = false;

    await showDialog(
      context: context,
      barrierDismissible: !linking,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: DSColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.card),
            side: const BorderSide(color: DSColors.outlineVariant),
          ),
          title: Text(
            'Connect Google sign-in',
            style: GoogleFonts.barlowCondensed(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.32,
              color: DSColors.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$email is already registered with a password. '
                'Enter it once to link Google sign-in to this account.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: DSColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: DSSpacing.md),
              TextField(
                controller: passwordController,
                obscureText: true,
                autofocus: true,
                style: GoogleFonts.inter(fontSize: 15, color: DSColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Your ScoutX password',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: DSColors.onSurfaceDisabled,
                  ),
                  filled: true,
                  fillColor: DSColors.surfaceContainer,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.md,
                    vertical: DSSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSRadius.input),
                    borderSide: const BorderSide(color: DSColors.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSRadius.input),
                    borderSide: const BorderSide(color: DSColors.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DSRadius.input),
                    borderSide: const BorderSide(color: DSColors.onSurface),
                  ),
                ),
              ),
              if (dialogError != null) ...[
                const SizedBox(height: DSSpacing.sm),
                Text(
                  dialogError!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: DSColors.red,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed:
                  linking ? null : () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: DSColors.onSurfaceVariant),
              ),
            ),
            FilledButton(
              onPressed: linking
                  ? null
                  : () async {
                      if (passwordController.text.isEmpty) return;
                      setDialogState(() {
                        linking = true;
                        dialogError = null;
                      });
                      try {
                        await context.read<AuthService>().linkGoogleCredential(
                              email,
                              passwordController.text,
                              googleCredential,
                            );
                        if (dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      } on FirebaseAuthException catch (e) {
                        setDialogState(() {
                          linking = false;
                          dialogError = e.code == 'wrong-password' ||
                                  e.code == 'invalid-credential'
                              ? 'Incorrect password. Try again.'
                              : 'Could not link accounts. Please try again.';
                        });
                      } catch (_) {
                        setDialogState(() {
                          linking = false;
                          dialogError =
                              'Something went wrong. Please try again.';
                        });
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: DSColors.onSurface,
                foregroundColor: DSColors.surface,
              ),
              child: linking
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: DSColors.surface,
                      ),
                    )
                  : Text(
                      'Link & sign in',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final error = context.watch<AuthProvider>().error;

    return Scaffold(
      backgroundColor: DSColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: DSSpacing.lg,
              vertical: DSSpacing.xxl,
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
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Text(
                        'SCOUTX',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.32,
                          color: DSColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xl),

                      // Sign In heading
                      Text(
                        'SIGN IN',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.32,
                          color: DSColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xxl),

                      // Email field
                      Text(
                        'EMAIL',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          color: DSColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: DSSpacing.sm),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: DSColors.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'coach@scoutx.com',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 16,
                            color: DSColors.onSurfaceDisabled,
                          ),
                          filled: true,
                          fillColor: DSColors.surfaceContainer,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: DSSpacing.md,
                            vertical: DSSpacing.md,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(DSRadius.input),
                            borderSide: const BorderSide(
                              color: DSColors.outlineVariant,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(DSRadius.input),
                            borderSide: const BorderSide(
                              color: DSColors.outlineVariant,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(DSRadius.input),
                            borderSide: const BorderSide(
                              color: DSColors.onSurface,
                              width: 1,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: DSSpacing.md),

                      // Password field
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PASSWORD',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                              color: DSColors.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              _obscure ? 'SHOW' : 'HIDE',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                color: DSColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: DSSpacing.sm),
                      TextFormField(
                        controller: _password,
                        obscureText: _obscure,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: DSColors.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 16,
                            color: DSColors.onSurfaceDisabled,
                          ),
                          filled: true,
                          fillColor: DSColors.surfaceContainer,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: DSSpacing.md,
                            vertical: DSSpacing.md,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(DSRadius.input),
                            borderSide: const BorderSide(
                              color: DSColors.outlineVariant,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(DSRadius.input),
                            borderSide: const BorderSide(
                              color: DSColors.outlineVariant,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(DSRadius.input),
                            borderSide: const BorderSide(
                              color: DSColors.onSurface,
                              width: 1,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure ? DSIcons.eyeSlash : DSIcons.eye,
                              color: DSColors.onSurfaceVariant,
                              size: 20,
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
                        const SizedBox(height: DSSpacing.md),
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: DSColors.red,
                          ),
                        ),
                      ],

                      const SizedBox(height: DSSpacing.xl),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                          ),
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: DSColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: DSSpacing.md),

                      // Sign In button
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: DSColors.onSurface,
                            foregroundColor: DSColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(DSRadius.button),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: DSColors.surface,
                                  ),
                                )
                              : Text(
                                  'SIGN IN',
                                  style: GoogleFonts.barlowCondensed(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.32,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xl),

                      // OR divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: DSColors.outlineVariant)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: DSSpacing.md),
                            child: Text(
                              'OR',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                                color: DSColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: DSColors.outlineVariant)),
                        ],
                      ),
                      const SizedBox(height: DSSpacing.xl),

                      // Continue with Google
                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed:
                              (_loading || _googleLoading) ? null : _signInWithGoogle,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: DSColors.surface,
                            foregroundColor: DSColors.onSurface,
                            side: const BorderSide(
                              color: DSColors.outlineVariant,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(DSRadius.button),
                            ),
                          ),
                          child: _googleLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: DSColors.onSurface,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.g_mobiledata, size: 24),
                                    const SizedBox(width: DSSpacing.sm),
                                    Text(
                                      'Continue with Google',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: DSColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: DSSpacing.xl),

                      // Create account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'New here? ',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: DSColors.onSurfaceVariant,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Create account',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: DSColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

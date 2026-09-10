import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/repositories/auth_repository.dart';
import 'widgets/auth_text_field.dart';

enum _AuthMode { signUp, logIn }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _authRepository = AuthRepository();

  _AuthMode _mode = _AuthMode.signUp;
  bool _isSubmitting = false;

  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _nicknameError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode(_AuthMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _nicknameError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
  }

  Future<void> _submit() async {
    final nickname = _nicknameController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _nicknameError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    if (nickname.isEmpty) {
      setState(() => _nicknameError = 'El nombre de usuario es obligatorio');
      return;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'La contraseña es obligatoria');
      return;
    }

    if (_mode == _AuthMode.signUp) {
      final confirmPassword = _confirmPasswordController.text;
      if (confirmPassword.isEmpty || confirmPassword != password) {
        setState(() => _confirmPasswordError = 'Las contraseñas no coinciden');
        return;
      }

      setState(() => _isSubmitting = true);
      try {
        final taken = await _authRepository.isUsernameTaken(nickname);
        if (taken) {
          setState(() => _nicknameError = 'Ese nombre de usuario ya existe');
          return;
        }
        await _authRepository.signUp(username: nickname, password: password);
      } on AuthWeakPasswordException {
        setState(
          () =>
              _passwordError = 'La contraseña debe tener al menos 6 caracteres',
        );
      } catch (_) {
        setState(() => _passwordError = 'No se pudo completar el registro');
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    } else {
      setState(() => _isSubmitting = true);
      try {
        await _authRepository.signIn(username: nickname, password: password);
      } on AuthException {
        setState(() => _passwordError = 'Usuario o contraseña incorrectos');
      } catch (_) {
        setState(() => _passwordError = 'Usuario o contraseña incorrectos');
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.signupNavbarBrown,
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 28,
              bottom: 28,
            ),
            child: Center(child: _MkwStatsLogo()),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AuthTab(
                        label: 'Sign Up',
                        isActive: _mode == _AuthMode.signUp,
                        onTap: () => _switchMode(_AuthMode.signUp),
                      ),
                      const SizedBox(width: 32),
                      _AuthTab(
                        label: 'Log In',
                        isActive: _mode == _AuthMode.logIn,
                        onTap: () => _switchMode(_AuthMode.logIn),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardBrown,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.08),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        AuthTextField(
                          label: 'Nickname',
                          controller: _nicknameController,
                          errorText: _nicknameError,
                        ),
                        const SizedBox(height: 16),
                        AuthTextField(
                          label: 'Password',
                          controller: _passwordController,
                          obscureText: true,
                          errorText: _passwordError,
                        ),
                        if (_mode == _AuthMode.signUp) ...[
                          const SizedBox(height: 16),
                          AuthTextField(
                            label: 'Confirmar contraseña',
                            controller: _confirmPasswordController,
                            obscureText: true,
                            errorText: _confirmPasswordError,
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 308,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.background,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : Text(
                                    _mode == _AuthMode.signUp
                                        ? 'Sign Up'
                                        : 'Log In',
                                    style: AppTextStyles.interMedium16(
                                      color: AppColors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AuthTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFFFDF2F2) : const Color(0xFF6B7280);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.interBold18(color: color)),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 60,
            color: isActive ? color : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _MkwStatsLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const text = 'MKWSTATS';
    final style = AppTextStyles.bangers(fontSize: 30, color: AppColors.white);
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.black,
          ),
        ),
        Text(text, style: style),
      ],
    );
  }
}

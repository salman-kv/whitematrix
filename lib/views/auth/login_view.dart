import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../core/app_colors.dart';
import '../../core/demo_accounts.dart';
import '../../core/routes.dart';
import '../../core/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_text_field.dart';

enum _LoginMode { email, phone }

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _passwordFocus = FocusNode();

  _LoginMode _mode = _LoginMode.email;
  bool _submitted = false; // switches on live validation after the first try
  String? _error; // wrong-credentials message

  late final _shake = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 450),
  );

  @override
  void initState() {
    super.initState();
    _identifier.addListener(_clearError);
    _password.addListener(_clearError);
  }

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    _passwordFocus.dispose();
    _shake.dispose();
    super.dispose();
  }

  /// Fills the form with a demo account (handy for reviewers).
  void _fillDemo(DemoAccount a) {
    setState(() {
      _identifier.text = _mode == _LoginMode.email ? a.email : a.phone;
      _password.text = a.password;
      _error = null;
    });
  }

  /// Bottom sheet listing every demo account.
  void _showAllAccounts() {
    final isEmail = _mode == _LoginMode.email;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 12, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Demo accounts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Each account has its own cart, wishlist and orders.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              for (final a in DemoAccounts.all)
                _AccountRow(
                  account: a,
                  isEmail: isEmail,
                  onUse: (acc) {
                    Navigator.pop(sheetContext);
                    _fillDemo(acc);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _setMode(_LoginMode m) {
    if (m == _mode) return;
    setState(() {
      _mode = m;
      _identifier.clear();
      _submitted = false;
    });
    _formKey.currentState?.reset();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      return;
    }
    final auth = context.read<AuthController>();
    final ok = await auth.login(_identifier.text, _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, Routes.shell);
    } else {
      HapticFeedback.heavyImpact();
      setState(() => _error = 'Incorrect email/phone or password');
      _shake.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.select<AuthController, bool>((a) => a.isLoading);
    final isEmail = _mode == _LoginMode.email;
    final auto = _submitted
        ? AutovalidateMode.onUserInteraction
        : AutovalidateMode.disabled;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 440),
                  child: AnimatedBuilder(
                    animation: _shake,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(
                        math.sin(_shake.value * math.pi * 5) *
                            10 *
                            (1 - _shake.value),
                        0,
                      ),
                      child: child,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 24),
                          AppLogo(size: 30),
                          SizedBox(height: 36),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: 'Welcome Back! '),
                                TextSpan(text: '👋'),
                              ],
                            ),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Sign in to continue your shopping journey',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 28),
                          _ModeToggle(mode: _mode, onChanged: _setMode),
                          SizedBox(height: 24),
                          AppTextField(
                            key: ValueKey(_mode),
                            label: isEmail ? 'Email address' : 'Phone number',
                            hint: isEmail
                                ? 'you@example.com'
                                : '10-digit mobile number',
                            controller: _identifier,
                            keyboardType: isEmail
                                ? TextInputType.emailAddress
                                : TextInputType.phone,
                            inputFormatters: isEmail
                                ? null
                                : [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                            prefix: isEmail
                                ? Icon(
                                    Icons.mail_outline_rounded,
                                    size: 20,
                                    color: AppColors.textSecondary,
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                      left: 14,
                                      right: 8,
                                    ),
                                    child: Center(
                                      widthFactor: 1,
                                      child: Text(
                                        '+91',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                            validator: isEmail
                                ? Validators.email
                                : Validators.phone,
                            autovalidateMode: auto,
                            onSubmitted: (_) => _passwordFocus.requestFocus(),
                          ),
                          SizedBox(height: 18),
                          AppTextField(
                            label: 'Password',
                            hint: 'Enter your password',
                            controller: _password,
                            focusNode: _passwordFocus,
                            obscure: true,
                            textInputAction: TextInputAction.done,
                            prefix: Icon(
                              Icons.lock_outline_rounded,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                            validator: Validators.password,
                            autovalidateMode: auto,
                            onSubmitted: (_) => _submit(),
                          ),
                          AnimatedSize(
                            duration: Duration(milliseconds: 200),
                            child: _error == null
                                ? SizedBox(width: double.infinity)
                                : _ErrorBanner(message: _error!),
                          ),
                          SizedBox(height: 24),
                          AppButton(
                            label: 'Login',
                            loading: loading,
                            onPressed: _submit,
                          ),
                          SizedBox(height: 22),
                          _DemoCard(
                            isEmail: isEmail,
                            onUse: _fillDemo,
                            onShowAll: _showAllAccounts,
                          ),
                          SizedBox(height: 24),
                        ],
                      ),
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
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, size: 19, color: AppColors.error),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows one demo account with a one-tap autofill, plus an icon that opens
/// a sheet listing every demo account.
class _DemoCard extends StatelessWidget {
  final bool isEmail;
  final ValueChanged<DemoAccount> onUse;
  final VoidCallback onShowAll;

  const _DemoCard({
    required this.isEmail,
    required this.onUse,
    required this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Demo account',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Show all demo accounts',
                visualDensity: VisualDensity.compact,
                onPressed: onShowAll,
                icon: const Icon(
                  Icons.groups_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          _AccountRow(
            account: DemoAccounts.salman,
            isEmail: isEmail,
            onUse: onUse,
          ),
        ],
      ),
    );
  }
}

/// One demo account: avatar, name, credentials, what data it has, and "Use".
class _AccountRow extends StatelessWidget {
  final DemoAccount account;
  final bool isEmail;
  final ValueChanged<DemoAccount> onUse;

  const _AccountRow({
    required this.account,
    required this.isEmail,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final a = account;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: a.accent,
            child: Text(
              a.name[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.name,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${isEmail ? a.email : a.phone}  •  ${a.password}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => onUse(a),
            child: const Text(
              'Use',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Email | Phone segmented control with an animated sliding pill.
class _ModeToggle extends StatelessWidget {
  final _LoginMode mode;
  final ValueChanged<_LoginMode> onChanged;

  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isEmail = mode == _LoginMode.email;
    return Container(
      height: 46,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: isEmail ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _tab(context, 'Email', _LoginMode.email, isEmail),
              _tab(context, 'Phone', _LoginMode.phone, !isEmail),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    String label,
    _LoginMode m,
    bool selected,
  ) => Expanded(
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(m),
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 200),
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
          child: Text(label),
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/fitness_repository.dart';
import '../../../../core/theme/app_colors.dart';

/// Authentication screen (Login / Register) that shows before onboarding.
/// Simplified: no real backend — pressing "Đăng nhập" or "Tạo tài khoản"
/// marks the auth as complete and proceeds to the onboarding / main app.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  bool _isLogin = true;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _fadeCtrl.reset();
    setState(() => _isLogin = !_isLogin);
    _fadeCtrl.forward();
  }

  Future<void> _submit() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    // Mark auth done — app proceeds to onboarding (handled by AppEntryGate)
    await fitnessRepository.markAuthComplete();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isLight ? AppColors.lightBg : AppColors.darkBg,
      body: Stack(
        children: [
          // Decorative gradient blobs
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryBlue.withValues(alpha: 0.18),
                    AppColors.primaryBlue.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.statusRecovery.withValues(alpha: 0.15),
                    AppColors.statusRecovery.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24, size.height * 0.04, 24, 40),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo & Brand
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Icon(Icons.fitness_center_rounded, size: 22),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VINCECORE',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: isLight
                                    ? AppColors.lightTextPrimary
                                    : AppColors.darkTextPrimary,
                              ),
                            ),
                            Text(
                              'Personal Fitness System',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isLight
                                    ? AppColors.lightTextMuted
                                    : AppColors.darkTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.07),

                    // Title
                    Text(
                      _isLogin ? 'Chào mừng\ntrở lại!' : 'Tạo tài khoản\nmới',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        color: isLight
                            ? AppColors.lightTextPrimary
                            : AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isLogin
                          ? 'Đăng nhập để tiếp tục hành trình\ncải thiện thể lực của bạn.'
                          : 'Đăng ký để bắt đầu theo dõi\nvà nâng cấp thể lực của bạn.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: isLight
                            ? AppColors.lightTextSecondary
                            : AppColors.darkTextSecondary,
                      ),
                    ),

                    SizedBox(height: size.height * 0.06),

                    // Form Fields
                    if (!_isLogin) ...[
                      _buildLabel('Họ và Tên', isLight),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _nameCtrl,
                        hint: 'Nguyễn Văn A',
                        icon: Icons.person_outline_rounded,
                        isLight: isLight,
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildLabel('Email', isLight),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _emailCtrl,
                      hint: 'example@email.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      isLight: isLight,
                    ),

                    const SizedBox(height: 16),

                    _buildLabel('Mật khẩu', isLight),
                    const SizedBox(height: 6),
                    _buildTextField(
                      controller: _passwordCtrl,
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                      obscure: _obscurePass,
                      onToggleObscure: () =>
                          setState(() => _obscurePass = !_obscurePass),
                      isLight: isLight,
                    ),

                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      _buildLabel('Xác nhận Mật khẩu', isLight),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _confirmCtrl,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        isPassword: true,
                        obscure: _obscureConfirm,
                        onToggleObscure: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        isLight: isLight,
                      ),
                    ],

                    if (_isLogin) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Quên mật khẩu?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isLight
                                  ? AppColors.primaryBlue
                                  : AppColors.primaryBlueLight,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Primary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _isLogin ? 'ĐĂNG NHẬP' : 'TẠO TÀI KHOẢN',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Social divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isLight
                                ? AppColors.lightBorder
                                : AppColors.darkBorder,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'hoặc tiếp tục với',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isLight
                                  ? AppColors.lightTextMuted
                                  : AppColors.darkTextMuted,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isLight
                                ? AppColors.lightBorder
                                : AppColors.darkBorder,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Social Auth Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _socialButton(
                            label: 'Google',
                            icon: '🅶',
                            onTap: _submit,
                            isLight: isLight,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _socialButton(
                            label: 'Apple',
                            icon: '🍎',
                            onTap: _submit,
                            isLight: isLight,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Toggle Login / Register
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? 'Chưa có tài khoản? '
                                : 'Đã có tài khoản? ',
                            style: TextStyle(
                              fontSize: 13,
                              color: isLight
                                  ? AppColors.lightTextSecondary
                                  : AppColors.darkTextSecondary,
                            ),
                          ),
                          InkWell(
                            onTap: _toggleMode,
                            child: Text(
                              _isLogin ? 'Đăng ký ngay' : 'Đăng nhập',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isLight
                                    ? AppColors.primaryBlue
                                    : AppColors.primaryBlueLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Skip for now button
                    Center(
                      child: TextButton(
                        onPressed: _submit,
                        child: Text(
                          'Bỏ qua, khám phá ngay →',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isLight
                                ? AppColors.lightTextMuted
                                : AppColors.darkTextMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isLight) => Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color:
              isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
        ),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isLight,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isLight ? 0.02 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscure : false,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color:
              isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 13,
            color: isLight ? AppColors.lightTextMuted : AppColors.darkTextMuted,
          ),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: isLight
                ? AppColors.lightTextSecondary
                : AppColors.darkTextSecondary,
          ),
          suffixIcon: isPassword && onToggleObscure != null
              ? IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: isLight
                        ? AppColors.lightTextSecondary
                        : AppColors.darkTextSecondary,
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _socialButton({
    required String label,
    required String icon,
    required VoidCallback onTap,
    required bool isLight,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isLight ? AppColors.lightSurface : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLight ? AppColors.lightBorder : AppColors.darkBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isLight
                    ? AppColors.lightTextPrimary
                    : AppColors.darkTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

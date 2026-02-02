import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  final void Function(String name, String email, String password) onSignup;
  final VoidCallback onBackToLogin;

  const SignupScreen({
    super.key,
    required this.onSignup,
    required this.onBackToLogin,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validateForm() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      _showError('お名前を入力してください');
      return false;
    }

    if (email.isEmpty) {
      _showError('メールアドレスを入力してください');
      return false;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      _showError('有効なメールアドレスを入力してください');
      return false;
    }

    if (password.isEmpty) {
      _showError('パスワードを入力してください');
      return false;
    }

    if (password.length < 8) {
      _showError('パスワードは8文字以上で入力してください');
      return false;
    }

    if (password != confirmPassword) {
      _showError('パスワードが一致しません');
      return false;
    }

    return true;
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    widget.onSignup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('アカウントが作成されました！')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Back Button
                  TextButton.icon(
                    onPressed: widget.onBackToLogin,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      'ログインに戻る',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Title
                  Center(
                    child: Column(
                      children: const [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.favorite, size: 40, color: Colors.blue),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'ヘルスケアアプリ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'アカウントを作成して始めましょう',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '新規登録',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _nameController,
                          label: 'お名前',
                          icon: Icons.person,
                        ),

                        _buildTextField(
                          controller: _emailController,
                          label: 'メールアドレス',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),

                        _buildPasswordField(
                          controller: _passwordController,
                          label: 'パスワード',
                          show: _showPassword,
                          onToggle: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),

                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: 'パスワード（確認）',
                          show: _showConfirmPassword,
                          onToggle: () => setState(() =>
                              _showConfirmPassword = !_showConfirmPassword),
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _isLoading
                                  ? 'アカウント作成中...'
                                  : 'アカウント作成',
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
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool show,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: !show,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(show ? Icons.visibility_off : Icons.visibility),
            onPressed: onToggle,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

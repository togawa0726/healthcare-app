import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const ForgotPasswordScreen({
    super.key,
    required this.onBackToLogin,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isEmailSent = false;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _validateEmail() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showError('メールアドレスを入力してください');
      return false;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      _showError('有効なメールアドレスを入力してください');
      return false;
    }

    return true;
  }

  Future<void> _handleSubmit() async {
    if (!_validateEmail()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isEmailSent = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('パスワードリセットメールを送信しました')),
      );
    }
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
              child: _isEmailSent
                  ? _buildSuccessView()
                  : _buildInputView(),
            ),
          ),
        ),
      ),
    );
  }

  /// =========================
  /// 成功画面
  /// =========================
  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: widget.onBackToLogin,
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          label: const Text(
            'ログインに戻る',
            style: TextStyle(color: Colors.white),
          ),
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'メールを確認してください',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'パスワードリセット用のリンクを\n'
                '${_emailController.text}\n'
                'に送信しました。',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'メールが届かない場合は、迷惑メールフォルダをご確認ください。',
                  style: TextStyle(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onBackToLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('ログインに戻る'),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  setState(() => _isEmailSent = false);
                },
                child: const Text('メールアドレスを変更する'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _buildDemoInfo('実際にはメールは送信されません'),
      ],
    );
  }

  /// =========================
  /// 入力画面
  /// =========================
  Widget _buildInputView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: widget.onBackToLogin,
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          label: const Text(
            'ログインに戻る',
            style: TextStyle(color: Colors.white),
          ),
        ),

        const SizedBox(height: 24),

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
                'パスワードをお忘れですか？',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '登録したメールアドレスを入力してください',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const Text(
                'パスワードリセット用のリンクをメールで送信します。',
                style: TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'メールアドレス',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
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
                    _isLoading ? '送信中...' : 'リセットリンクを送信',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: widget.onBackToLogin,
                child: const Text('ログイン'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        _buildDemoInfo('任意のメールアドレスを入力できます'),
      ],
    );
  }

  Widget _buildDemoInfo(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'デモモード',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

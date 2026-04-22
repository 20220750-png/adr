import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _guestController = TextEditingController(text: 'Guest');
  bool _obscure = true;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _guestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _userController,
                      decoration: const InputDecoration(labelText: 'Tài khoản'),
                      validator: (v) =>
                          (v == null || v.trim().length < 3) ? '>= 3 ký tự' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passController,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                      obscureText: _obscure,
                      validator: (v) =>
                          (v == null || v.length < 4) ? '>= 4 ký tự' : null,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              try {
                                await auth.loginOnline(
                                  username: _userController.text,
                                  password: _passController.text,
                                );
                                if (context.mounted) {
                                  Navigator.popUntil(
                                    context,
                                    ModalRoute.withName(AppRoutes.home),
                                  );
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                      child: Text(auth.isLoading ? 'Đang xử lý...' : 'Đăng nhập online'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.register),
                      child: const Text('Chưa có tài khoản? Đăng ký'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Chế độ offline (khách)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _guestController,
                    decoration: const InputDecoration(labelText: 'Tên hiển thị'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            await auth.loginOfflineGuest(
                              username: _guestController.text,
                            );
                            if (context.mounted) {
                              Navigator.popUntil(
                                context,
                                ModalRoute.withName(AppRoutes.home),
                              );
                            }
                          },
                    child: const Text('Vào chơi offline'),
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


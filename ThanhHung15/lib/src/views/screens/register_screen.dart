import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _pass2Controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    _pass2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pass2Controller,
                      decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu'),
                      obscureText: _obscure,
                      validator: (v) {
                        if (v == null || v.length < 4) return '>= 4 ký tự';
                        if (v != _passController.text) return 'Không khớp';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              try {
                                await auth.registerOnline(
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
                      child: Text(auth.isLoading ? 'Đang xử lý...' : 'Tạo tài khoản'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đã có tài khoản? Quay lại đăng nhập'),
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
}


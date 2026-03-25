import 'package:finly/data/repositories/auth_repository.dart';
import 'package:finly/ui/feature/auth/view_models/auth_viewmodel.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialIsLogin = true});

  final bool initialIsLogin;

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  late final AuthViewModel _viewModel;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = AuthViewModel(repository: AuthRepository());
    if (!widget.initialIsLogin) {
      _viewModel.toggleMode();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (_viewModel.isLogin) {
      await _viewModel.login(email: email, password: password);
    } else {
      await _viewModel.signup(email: email, password: password);
    }
    if (mounted && _viewModel.isAuthenticated) {
      Navigator.pop(context);
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(labelText: label);
  }

  Widget _buildTitle() {
    return Text(
      _viewModel.isLogin ? 'Login' : 'Sign Up',
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _buildInputDecoration('Email'),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: _buildInputDecoration('Password'),
    );
  }

  Widget _buildErrorMessage() {
    if (_viewModel.errorMessage == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        _viewModel.errorMessage!,
        style: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _viewModel.isLoading ? null : _submit,
        child: _viewModel.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                _viewModel.isLogin ? 'Login' : 'Sign Up',
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Widget _buildSwitchModeButton() {
    return TextButton(
      onPressed: _viewModel.toggleMode,
      child: Text(
        _viewModel.isLogin
            ? "Don't have an account? Sign Up"
            : 'Already have an account? Login',
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTitle(),
        const SizedBox(height: 32),
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildPasswordField(),
        _buildErrorMessage(),
        const SizedBox(height: 24),
        _buildSubmitButton(),
        const SizedBox(height: 16),
        _buildSwitchModeButton(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_viewModel.isLogin ? 'Login' : 'Sign Up')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListenableBuilder(
              listenable: _viewModel,
              builder: (context, _) {
                return _buildForm();
              },
            ),
          ),
        ),
      ),
    );
  }
}

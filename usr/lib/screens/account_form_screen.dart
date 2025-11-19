import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/account_data.dart';

class AccountFormScreen extends StatefulWidget {
  final AccountData? existingAccount;

  const AccountFormScreen({super.key, this.existingAccount});

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _websiteController;
  late TextEditingController _notesController;
  
  bool _isPasswordVisible = false;
  int _selectedColorIndex = 0;

  final List<Color> _accountColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    final account = widget.existingAccount;
    _titleController = TextEditingController(text: account?.title ?? '');
    _usernameController = TextEditingController(text: account?.username ?? '');
    _passwordController = TextEditingController(text: account?.password ?? '');
    _websiteController = TextEditingController(text: account?.website ?? '');
    _notesController = TextEditingController(text: account?.notes ?? '');
    _selectedColorIndex = account?.colorIndex ?? 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _generatePassword() {
    // Simple random password generator
    final chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final rnd = DateTime.now().millisecondsSinceEpoch;
    String password = '';
    for (int i = 0; i < 16; i++) {
      password += chars[(rnd + i * 13) % chars.length];
    }
    setState(() {
      _passwordController.text = password;
      _isPasswordVisible = true; // Show generated password
    });
  }

  void _saveAccount() {
    if (_formKey.currentState!.validate()) {
      final newAccount = AccountData(
        id: widget.existingAccount?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        website: _websiteController.text,
        notes: _notesController.text,
        colorIndex: _selectedColorIndex,
        updatedAt: DateTime.now(),
      );
      
      Navigator.pop(context, newAccount);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAccount != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '编辑账号' : '添加账号'),
        actions: [
          TextButton(
            onPressed: _saveAccount,
            child: const Text('保存', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Color Selector
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _accountColors.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColorIndex = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _accountColors[index],
                        shape: BoxShape.circle,
                        border: _selectedColorIndex == index
                            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3)
                            : null,
                      ),
                      child: _selectedColorIndex == index
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '服务名称 (如: Google, Github)',
                prefixIcon: Icon(Icons.label_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? '请输入名称' : null,
            ),
            const SizedBox(height: 16),

            // Username
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: '用户名 / 邮箱',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              decoration: InputDecoration(
                labelText: '密码',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      tooltip: '生成随机密码',
                      onPressed: _generatePassword,
                    ),
                    IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ],
                ),
              ),
              validator: (value) => value == null || value.isEmpty ? '请输入密码' : null,
            ),
            const SizedBox(height: 16),

            // Website
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: '网址 (可选)',
                prefixIcon: Icon(Icons.language),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '备注 (可选)',
                prefixIcon: Icon(Icons.note_alt_outlined),
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}

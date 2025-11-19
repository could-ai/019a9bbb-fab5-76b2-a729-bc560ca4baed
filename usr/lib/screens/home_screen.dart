import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/account_data.dart';
import 'account_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock data for initial display
  List<AccountData> _accounts = [
    AccountData(
      id: '1',
      title: 'Google',
      username: 'user@gmail.com',
      password: 'password123',
      website: 'google.com',
      colorIndex: 1,
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AccountData(
      id: '2',
      title: 'GitHub',
      username: 'dev_master',
      password: 'secure_password_99',
      website: 'github.com',
      notes: 'Personal access token inside',
      colorIndex: 7,
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  String _searchQuery = '';

  List<AccountData> get _filteredAccounts {
    if (_searchQuery.isEmpty) return _accounts;
    return _accounts.where((account) {
      return account.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             account.username.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _navigateToAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountFormScreen()),
    );

    if (result != null && result is AccountData) {
      setState(() {
        _accounts.add(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('账号已添加')),
      );
    }
  }

  void _navigateToEditScreen(AccountData account) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountFormScreen(existingAccount: account),
      ),
    );

    if (result != null && result is AccountData) {
      setState(() {
        final index = _accounts.indexWhere((a) => a.id == account.id);
        if (index != -1) {
          _accounts[index] = result;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('账号已更新')),
      );
    }
  }

  void _deleteAccount(String id) {
    setState(() {
      _accounts.removeWhere((a) => a.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('账号已删除')),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label 已复制'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.pink, Colors.indigo,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('密码管家'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: '搜索账号...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              elevation: WidgetStateProperty.all(1.0),
            ),
          ),
          
          // Account List
          Expanded(
            child: _filteredAccounts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? '暂无账号' : '未找到匹配项',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _filteredAccounts.length,
                    itemBuilder: (context, index) {
                      final account = _filteredAccounts[index];
                      final color = colors[account.colorIndex % colors.length];
                      
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _navigateToEditScreen(account),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          account.title.isNotEmpty ? account.title[0].toUpperCase() : '?',
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            account.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            account.username,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy_rounded, size: 20),
                                      tooltip: '复制密码',
                                      onPressed: () => _copyToClipboard(account.password, '密码'),
                                    ),
                                  ],
                                ),
                                if (account.website != null && account.website!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.link, size: 16, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Text(
                                        account.website!,
                                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddScreen,
        icon: const Icon(Icons.add),
        label: const Text('添加账号'),
      ),
    );
  }
}

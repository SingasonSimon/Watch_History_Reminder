import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/video_provider.dart';
import '../../services/firebase_service.dart';
import '../../services/vlc_integration_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final VlcIntegrationService _vlcService = VlcIntegrationService();
  bool _isDarkMode = false;
  bool _syncEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _syncEnabled = prefs.getBool('sync_enabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
    await prefs.setBool('sync_enabled', _syncEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final user = _firebaseService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          if (user == null) ...[
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Sign In'),
              subtitle: const Text('Sign in to sync across devices'),
              onTap: () => _showSignInDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Create Account'),
              onTap: () => _showSignUpDialog(context),
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(user.email ?? 'User'),
              subtitle: const Text('Signed in'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                await _firebaseService.signOut();
                setState(() {});
              },
            ),
          ],
          
          const Divider(),
          
          // Sync Section
          _buildSectionHeader('Sync'),
          SwitchListTile(
            secondary: const Icon(Icons.sync),
            title: const Text('Enable Sync'),
            subtitle: const Text('Sync your videos across devices'),
            value: _syncEnabled,
            onChanged: (value) {
              setState(() {
                _syncEnabled = value;
              });
              _saveSettings();
            },
          ),
          
          const Divider(),
          
          // Import/Export Section
          _buildSectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Import from VLC'),
            subtitle: const Text('Import your VLC watch history'),
            onTap: () => _importFromVlc(context),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Export Data'),
            subtitle: const Text('Export your videos as JSON'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Import Data'),
            subtitle: const Text('Import videos from JSON file'),
            onTap: () => _importData(context),
          ),
          
          const Divider(),
          
          // Appearance Section
          _buildSectionHeader('Appearance'),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              _saveSettings();
              // Note: Theme switching would need to be implemented in main.dart
            },
          ),
          
          const Divider(),
          
          // About Section
          _buildSectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showSignInDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _firebaseService.signInWithEmailAndPassword(
                  emailController.text,
                  passwordController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Signed in successfully')),
                  );
                  setState(() {});
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _showSignUpDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _firebaseService.createUserWithEmailAndPassword(
                  emailController.text,
                  passwordController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account created successfully')),
                  );
                  setState(() {});
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _importFromVlc(BuildContext context) async {
    final user = _firebaseService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first')),
      );
      return;
    }

    final exists = await _vlcService.checkVlcDatabaseExists();
    if (!exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('VLC database not found')),
      );
      return;
    }

    try {
      final entries = await _vlcService.importVlcHistory(user.uid);
      final provider = context.read<VideoProvider>();
      
      for (var entry in entries) {
        await provider.addVideo(entry);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${entries.length} videos')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _exportData(BuildContext context) async {
    // Implementation for exporting data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }

  Future<void> _importData(BuildContext context) async {
    // Implementation for importing data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Import feature coming soon')),
    );
  }
}


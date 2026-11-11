import 'dart:io';

import 'package:flutter/material.dart';
import 'package:otakuplanner/providers/category_provider.dart';
import 'package:otakuplanner/providers/task_provider.dart';
import 'package:otakuplanner/providers/theme_provider.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/editProfile.dart';
import 'package:otakuplanner/screens/normalMode/profile.dart';
import 'package:otakuplanner/screens/request.dart' show clearAuthToken;
import 'package:otakuplanner/widgets/bottomNavBar.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';
import 'package:provider/provider.dart';

/// Only settings that do something: the account, the page colour and
/// logging out.
class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _loggingOut = false;

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  /// Forgets the login token and everything loaded for this user, then
  /// goes back to the login screen.
  Future<void> _logOut() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final navigator = Navigator.of(context, rootNavigator: true);

    await clearAuthToken();
    await userProvider.logout();
    taskProvider.clearAllTasks();
    categoryProvider.clearCategories();

    if (!mounted) return;
    navigator.pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final dark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: const PlannerAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.page, Space.l, Space.page, Space.l),
        children: [
          Text('Settings', style: context.type.displaySmall),
          const SizedBox(height: Space.m),
          Panel(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _PanelLabel('Account'),
                _AccountRow(onTap: () => _open(const Profile())),
                const InkRule(),
                _LinkRow(
                  icon: Icons.photo_camera_outlined,
                  title: 'Profile photo',
                  onTap: () => _open(const EditProfile()),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.gutter),
          Panel(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _PanelLabel('Appearance'),
                _SwitchRow(
                  icon: dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  title: 'Dark mode',
                  subtitle: 'Cream ink on a night page',
                  value: dark,
                  onChanged: themeProvider.toggleTheme,
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.l),
          InkButton.secondary(
            label: 'Log out',
            icon: Icons.logout,
            expand: true,
            loading: _loggingOut,
            onPressed: _logOut,
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}

class _PanelLabel extends StatelessWidget {
  const _PanelLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.gutter, Space.gutter, Space.gutter, Space.xs),
      child: Kicker(text),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final user = Provider.of<UserProvider>(context);
    final name = user.fullName.isNotEmpty ? user.fullName : _capitalise(user.username);
    final path = user.profileImagePath;
    final hasImage = path.isNotEmpty && File(path).existsSync();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(Space.gutter),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: c.ink, width: Strokes.panel),
                borderRadius: Radii.controlAll,
                image: hasImage
                    ? DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover)
                    : null,
              ),
              child: hasImage
                  ? null
                  : Text(
                      user.username.isEmpty ? '?' : user.username[0].toUpperCase(),
                      style: context.type.titleLarge,
                    ),
            ),
            const SizedBox(width: Space.gutter),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isEmpty ? 'Your profile' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.titleMedium,
                  ),
                  if (user.email.isNotEmpty)
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.type.bodySmall,
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: c.ink),
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.gutter, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: c.ink),
            const SizedBox(width: Space.gutter),
            Expanded(child: Text(title, style: context.type.titleMedium)),
            Icon(Icons.chevron_right, color: c.ink),
          ],
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.gutter, Space.s, Space.s, Space.s),
          child: Row(
            children: [
              Icon(icon, size: 20, color: c.ink),
              const SizedBox(width: Space.gutter),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.type.titleMedium),
                    Text(subtitle, style: context.type.bodySmall),
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

String _capitalise(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';

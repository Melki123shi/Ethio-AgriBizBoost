import 'package:app/ui/profile/header.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  static const _userName = 'Favour Isechap';
  static const _userRole = 'Farmer';
  static const _userCity = 'Adis Ababa, Ethiopia';
  static const _avatarUrl = 'https://via.placeholder.com/150';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                children: [
                  _profileHeader(theme),
                  const SizedBox(height: 32),
                  _sectionHeader('Account', theme),
                  _settingsCard(theme, children: [
                    _settingsTile(theme, icon: Icons.person, label: 'Edit profile'),
                    _settingsTile(theme, icon: Icons.security, label: 'Security'),
                    _settingsTile(theme, icon: Icons.notifications, label: 'Notifications'),
                    _settingsTile(theme, icon: Icons.lock, label: 'Privacy'),
                  ]),
                  const SizedBox(height: 24),
                  _sectionHeader('Preference', theme),
                  _settingsCard(theme, children: [
                    _settingsTile(theme, icon: Icons.language, label: 'Language'),
                    _settingsTile(theme, icon: Icons.dark_mode, label: 'Darkmode'),
                  ]),
                  const SizedBox(height: 24),
                  _sectionHeader('Actions', theme),
                  _settingsCard(theme, children: [
                    _settingsTile(theme, icon: Icons.logout, label: 'Log out'),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileHeader(ThemeData theme) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 34),
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(_avatarUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_userName,
                        style: theme.textTheme.titleMedium!
                            .copyWith(color: Colors.white)),
                    Text(_userRole,
                        style: theme.textTheme.bodyMedium!
                            .copyWith(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(_userCity,
                              style: theme.textTheme.bodySmall!
                                  .copyWith(color: Colors.white70)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => debugPrint('Edit tapped'),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, ThemeData theme) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: theme.textTheme.bodySmall!.copyWith(
            color: theme.focusColor.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      );

  Widget _settingsCard(ThemeData theme, {required List<Widget> children}) =>
      Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: _addDividers(theme, children),
        ),
      );

  List<Widget> _addDividers(ThemeData theme, List<Widget> tiles) {
    final list = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      list.add(tiles[i]);
      if (i != tiles.length - 1) {
        list.add(Divider(height: 1, color: theme.dividerColor));
      }
    }
    return list;
  }

  Widget _settingsTile(ThemeData theme,
          {required IconData icon, required String label}) =>
      InkWell(
        onTap: () => debugPrint('$label tapped'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: theme.focusColor.withOpacity(0.7), size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: theme.focusColor),
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.focusColor.withOpacity(0.4), size: 20),
            ],
          ),
        ),
      );
}

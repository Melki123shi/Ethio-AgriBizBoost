import 'package:app/ui/profile/header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                children: [
                  _profileHeader(context, theme),
                  const SizedBox(height: 32),
                  _sectionHeader('Account', theme),
                  _settingsCard(theme, children: [
                    _settingsTile(context, theme,
                        icon: Icons.person, label: 'Edit profile'),
                    _settingsTile(context, theme,
                        icon: Icons.security, label: 'Security'),
                    _settingsTile(context, theme,
                        icon: Icons.notifications, label: 'Notifications'),
                  ]),
                  const SizedBox(height: 24),
                  _sectionHeader('Preference', theme),
                  _settingsCard(theme, children: [
                    _settingsTile(context, theme,
                        icon: Icons.language, label: 'Language'),
                    _settingsTile(context, theme,
                        icon: Icons.dark_mode, label: 'Darkmode'),
                  ]),
                  const SizedBox(height: 24),
                  _sectionHeader('Actions', theme),
                  _settingsCard(theme, children: [
                    _settingsTile(context, theme,
                        icon: Icons.logout, label: 'Log out'),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileHeader(BuildContext context, ThemeData theme) {
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
            onPressed: () {
              context.push('/editProfile');
            },
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

  Widget _settingsTile(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String label,
  }) {
    return InkWell(
      onTap: () {
        final routeMap = {
          'Edit profile': '/editProfile',
          'Security': '/security',
          'Notifications': '/notifications',
          'Language': '/language',
          'Darkmode': '/darkmode',
          'Log out': '/logout',
        };

        final route = routeMap[label];
        if (route != null) {
          context.push(route);
        } else {
          debugPrint('No route defined for $label');
        }
      },
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

  Widget _settingsCard(ThemeData theme, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _addDividers(theme, children),
      ),
    );
  }

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
}

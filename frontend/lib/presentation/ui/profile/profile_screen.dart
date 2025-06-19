import 'package:app/domain/entity/user_entity.dart';
import 'package:app/presentation/ui/profile/header.dart';
import 'package:app/presentation/utils/localization_extension.dart';
import 'package:app/services/local_storage/user_local_storage.dart';
import 'package:app/services/sync/user_sync_service.dart';
import 'package:app/services/api/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app/application/user/user_bloc.dart';
import 'package:app/application/user/user_state.dart';
import 'package:app/application/user/user_event.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserLocalStorage _localStorage = UserLocalStorage();
  late UserSyncService _syncService;
  bool _hasPendingSync = false;

  @override
  void initState() {
    super.initState();
    _syncService = UserSyncService(UserService());
    _syncService.startAutoSync();
    _checkPendingSync();
    context.read<UserBloc>().add(FetchUser());
  }

  @override
  void dispose() {
    _syncService.stopAutoSync();
    super.dispose();
  }

  void _checkPendingSync() {
    setState(() {
      _hasPendingSync = _localStorage.hasPendingSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          // Update sync status when user state changes
          if (state is UserLoaded) {
            _checkPendingSync();
          }
        },
        child: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserLoaded) {
              return _buildProfile(context, theme, state.user);
            } else if (state is UserError) {
              return Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(context.commonLocals.failed_to_fetch_user),
                  IconButton(
                      onPressed: () {
                        context.read<UserBloc>().add(FetchUser());
                      },
                      icon: const Icon(Icons.replay_outlined))
                ],
              ));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, ThemeData theme, UserEntity user) {
    return Column(
      children: [
        const Header(),
        if (_hasPendingSync) _buildSyncIndicator(context, theme),
        Expanded(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              children: [
                _profileHeader(context, theme, user),
                const SizedBox(height: 32),
                _settingsCard(theme, children: [
                  _settingsTile(context, theme,
                      icon: Icons.assessment_rounded,
                      label: context.commonLocals.expense_tracking),
                ]),
                const SizedBox(height: 24),
                _sectionHeader(context.commonLocals.account, theme),
                _settingsCard(theme, children: [
                  _settingsTile(context, theme,
                      icon: Icons.person,
                      label: context.commonLocals.edit_profile),
                  _settingsTile(context, theme,
                      icon: Icons.security,
                      label: context.commonLocals.security),
                ]),
                const SizedBox(height: 24),
                _sectionHeader(context.commonLocals.preference, theme),
                _settingsCard(theme, children: [
                  _settingsTile(context, theme,
                      icon: Icons.language,
                      label: context.commonLocals.language),
                  _settingsTile(context, theme,
                      icon: Icons.dark_mode,
                      label: context.commonLocals.darkmode),
                ]),
                const SizedBox(height: 24),
                _sectionHeader(context.commonLocals.actions, theme),
                _settingsCard(theme, children: [
                  _settingsTile(context, theme,
                      icon: Icons.logout, label: context.commonLocals.log_out),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileHeader(
      BuildContext context, ThemeData theme, UserEntity user) {
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
              CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(user.profilePictureUrl ??
                    'https://via.placeholder.com/150'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name ?? '---',
                        style: theme.textTheme.titleMedium!
                            .copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(context.commonLocals.farmer,
                        style: theme.textTheme.bodyMedium!
                            .copyWith(color: Colors.white70)),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(user.location ?? '---',
                              style: theme.textTheme.bodyMedium!
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
          context.commonLocals.expense_tracking: '/expense_tracking',
          context.commonLocals.edit_profile: '/editProfile',
          context.commonLocals.security: '/security',
          context.commonLocals.language: '/language',
          context.commonLocals.darkmode: '/darkmode',
          context.commonLocals.log_out: '/logout',
          context.commonLocals.delete: '/delete',
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

  Widget _buildSyncIndicator(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.sync, size: 20, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Profile changes pending sync',
              style: theme.textTheme.bodySmall!.copyWith(
                color: Colors.orange.shade700,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final result = await _syncService.manualSync();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result.message),
                    backgroundColor: result.success ? Colors.green : Colors.red,
                  ),
                );
                if (result.success) {
                  _checkPendingSync();
                  context.read<UserBloc>().add(FetchUser());
                }
              }
            },
            child: Text(
              'Sync Now',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

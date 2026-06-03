import 'package:flutter/material.dart';
import 'package:groove_app/api_DTOs/user_dto.dart';
import 'package:groove_app/api_service/admin_auth_api.dart';
import 'package:groove_app/api_service/api_user.dart';
import 'package:groove_app/app/groove_theme_extension.dart';
import 'package:groove_app/designs/colors.dart';
import 'package:groove_app/helper/admin_auth_navigation.dart';
import 'package:groove_app/features/admin/widgets/admin_ui_helpers.dart';
import 'package:groove_app/widgets/theme_mode_switch.dart';

class AdminScaffold extends StatefulWidget {
  final Widget child;
  final int selectedSidebarIndex;
  final ValueChanged<int> onSidebarSelected;
  final VoidCallback? onHomeTap;
  final VoidCallback? onScheduleTap;
  final VoidCallback? onRentalsTap;
  final void Function(String reportType)? onReportSelected;

  const AdminScaffold({
    super.key,
    required this.child,
    required this.selectedSidebarIndex,
    required this.onSidebarSelected,
    this.onHomeTap,
    this.onScheduleTap,
    this.onRentalsTap,
    this.onReportSelected,
  });

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  UserDto? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await fetchMyProfile();
      if (mounted) setState(() => _profile = profile);
    } catch (_) {}
  }

  Future<void> _logout(BuildContext context) async {
    await logoutAdmin();
    if (!context.mounted) return;
    await navigateToAdminAuth(context);
  }

  static const List<String> _sidebarTitles = [
    'Клиенты',
    'Абонементы',
    'Тренеры',
    'Направления',
    'Залы',
    'Покупки',
    'Новости',
    'Данные об орг.',
  ];

  static const List<IconData> _sidebarIcons = [
    Icons.people,
    Icons.credit_card,
    Icons.sports,
    Icons.music_note,
    Icons.meeting_room,
    Icons.shopping_cart,
    Icons.article,
    Icons.business,
  ];

  @override
  Widget build(BuildContext context) {
    final g = context.groove;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceMuted = g.onSurfaceSecondary;
    final initials = adminInitials(_profile?.familia_user, _profile?.name_user);
    final displayName = adminDisplayName(
      _profile?.familia_user,
      _profile?.name_user,
      null,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
              color: g.headerBackground,
              border: Border(bottom: BorderSide(color: g.border)),
            ),
            child: Row(
              children: [
                _buildHeaderItem(title: 'Главная', onTap: widget.onHomeTap ?? () {}),
                SizedBox(width: 30),
                _buildHeaderItem(
                  title: 'Расписание',
                  onTap: widget.onScheduleTap ?? () {},
                ),
                SizedBox(width: 30),
                _buildHeaderItem(title: 'Аренды', onTap: widget.onRentalsTap ?? () {}),
                SizedBox(width: 30),
                PopupMenuButton<String>(
                  color: Theme.of(context).cardColor,
                  offset: const Offset(0, 45),
                  child: Row(
                    children: [
                      Text('Отчеты', style: TextStyle(color: onSurface, fontSize: 16)),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, color: onSurface),
                    ],
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'finance',
                      child: Text('Финансы', style: TextStyle(color: onSurface)),
                    ),
                    PopupMenuItem(
                      value: 'trainers',
                      child: Text('Тренеры', style: TextStyle(color: onSurface)),
                    ),
                    PopupMenuItem(
                      value: 'attendance',
                      child: Text('Посещаемость', style: TextStyle(color: onSurface)),
                    ),
                  ],
                  onSelected: (value) => widget.onReportSelected?.call(value),
                ),
                const Spacer(),
                ThemeModeSwitch(),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 260,
                  color: g.menuPanel,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: MainPurple,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initials,
                                style: TextStyle(
                                  color: onSurface,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Администратор',
                                    style: TextStyle(
                                      color: onSurfaceMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      color: onSurface,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: OutlinedButton.icon(
                          onPressed: () => _logout(context),
                          icon: Icon(Icons.logout, size: 18, color: onSurfaceMuted),
                          label: Text('Выйти', style: TextStyle(color: onSurfaceMuted)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: g.border),
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          children: List.generate(_sidebarTitles.length, (index) {
                            return _buildSidebarItem(
                              icon: _sidebarIcons[index],
                              title: _sidebarTitles[index],
                              selected: widget.selectedSidebarIndex == index,
                              onTap: () => widget.onSidebarSelected(index),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderItem({required String title, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final g = context.groove;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: selected ? MainPurple.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? MainPurple : g.onSurfaceSecondary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? onSurface : g.onSurfaceSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

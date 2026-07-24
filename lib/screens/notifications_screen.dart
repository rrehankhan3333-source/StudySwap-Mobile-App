import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = "All";

  final List<String> _filters = ["All", "Messages", "Sales", "System"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 54,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: AppTheme.bgCard, 
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderMedium, width: 1.5),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 14),
              ),
            ),
          ),
        ),
        title: Text(
          "Notifications",
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              AppState.clearAllNotifications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("All notifications cleared!"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(Icons.delete_sweep_outlined, color: AppTheme.textDark, size: 24),
          ),
          const SizedBox(width: 12),
        ],
        shape: Border(bottom: BorderSide(color: AppTheme.borderMedium, width: 1.5)),
      ),
      body: Column(
        children: [
          // Filter pills row
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.borderMedium,
                        width: 1.5,
                      ),
                      boxShadow: isSelected ? AppTheme.shadowSmall : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textMedium,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Divider below filters
          Container(
            height: 1.5,
            color: AppTheme.borderMedium,
          ),
          // Notification Lists
          Expanded(
            child: ValueListenableBuilder<List<AppNotification>>(
              valueListenable: AppState.notificationsNotifier,
              builder: (context, notifs, child) {
                // Filter notifications
                final filteredNotifs = _selectedFilter == "All"
                    ? notifs
                    : notifs.where((n) => n.type == _selectedFilter).toList();

                if (filteredNotifs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPastel,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_off_outlined,
                            size: 40,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No notifications available.",
                          style: TextStyle(color: AppTheme.textMedium, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredNotifs.length,
                  itemBuilder: (context, index) {
                    final notif = filteredNotifs[index];
                    return Dismissible(
                      key: Key(notif.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xffFECACA),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xffFCA5A5), width: 1.5),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Color(0xffDC2626), size: 24),
                      ),
                      onDismissed: (direction) {
                        AppState.removeNotification(notif.id);
                      },
                      child: _buildNotifCard(notif),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifCard(AppNotification notif) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (notif.type) {
      case "Messages":
        icon = Icons.chat_bubble_outline_rounded;
        iconColor = AppTheme.primary;
        iconBg = const Color(0xffEEF2F6);
        break;
      case "Sales":
        icon = Icons.shopping_bag_outlined;
        iconColor = AppTheme.secondary;
        iconBg = const Color(0xffFAF5FF);
        break;
      default:
        icon = Icons.info_outline_rounded;
        iconColor = const Color(0xff0EA5E9);
        iconBg = const Color(0xffF0F9FF);
    }

    final isUnread = !notif.isRead;

    return GestureDetector(
      onTap: () {
        if (isUnread) {
          AppState.markNotificationAsRead(notif.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread
              ? (AppTheme.isDarkMode ? const Color(0xff2D3748) : const Color(0xffEEF2F6))
              : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUnread ? AppTheme.primary : AppTheme.borderMedium,
            width: 1.5,
          ),
          boxShadow: AppTheme.shadowSmall,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderMedium, width: 1.0),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: isUnread ? FontWeight.w900 : FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notif.time,
                        style: TextStyle(
                          color: isUnread ? AppTheme.primary : AppTheme.textLight,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notif.body,
                    style: TextStyle(
                      color: isUnread ? AppTheme.textDark : AppTheme.textMedium,
                      fontSize: 12.5,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

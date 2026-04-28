import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/common_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final items = provider.items;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Notifications', style: AppTextStyles.heading(size: 18)),
        actions: [
          TextButton(
            onPressed: provider.items.isEmpty ? null : () => provider.clearAll(),
            child: Text('Clear', style: AppTextStyles.caption()),
          )
        ],
        leading: const AppBackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: items.isEmpty
            ? Center(child: Text('No notifications', style: AppTextStyles.caption()))
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final n = items[i];
                  return ListTile(
                    tileColor: n.read ? AppColors.surface2 : null,
                    title: Text(n.title, style: AppTextStyles.bodyMedium()),
                    subtitle: Text(n.body, style: AppTextStyles.caption()),
                    trailing: n.read
                        ? null
                        : TextButton(
                            onPressed: () => provider.markRead(n.id),
                            child: Text('Mark', style: AppTextStyles.caption()),
                          ),
                    onTap: () {
                      provider.markRead(n.id);
                    },
                  );
                },
              ),
      ),
    );
  }
}

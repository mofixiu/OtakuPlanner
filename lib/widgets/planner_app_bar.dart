import 'dart:io';

import 'package:flutter/material.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/screens/normalMode/otakuPlannerAI.dart';
import 'package:otakuplanner/screens/normalMode/profile.dart';
import 'package:otakuplanner/shared/notifications.dart';
import 'package:otakuplanner/themes/tokens.dart';
import 'package:otakuplanner/widgets/mascot.dart';
import 'package:otakuplanner/widgets/speech_balloon.dart';
import 'package:provider/provider.dart';

/// The bar on every main tab: the logo mark (tap it to ask the planning
/// assistant), notifications and the profile picture.
class PlannerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PlannerAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  void _openAssistant(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const OtakuPlannerAIPage()));
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: Space.page,
      toolbarHeight: 56,
      title: Semantics(
        button: true,
        label: 'Ask the planning assistant',
        child: InkWell(
          onTap: () => _openAssistant(context),
          borderRadius: Radii.controlAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LogoMark(height: 32),
                const SizedBox(width: 6),
                SpeechBalloon(
                  padding: const EdgeInsets.fromLTRB(8, 2, 9, 3),
                  child: Text('Ask', style: context.type.labelMedium),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: const [
        _BellButton(),
        SizedBox(width: Space.s),
        _AvatarButton(),
        SizedBox(width: Space.page),
      ],
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton();

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    return Consumer<NotificationService>(
      builder: (context, service, _) {
        final unread = service.unreadCount;
        return Semantics(
          button: true,
          label: unread == 0 ? 'Notifications' : 'Notifications, $unread unread',
          child: InkWell(
            borderRadius: Radii.controlAll,
            onTap: () => showDialog(context: context, builder: (_) => const NotificationDropdown()),
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              decoration: BoxDecoration(
                border: Border.all(color: c.ink, width: Strokes.panel),
                borderRadius: Radii.controlAll,
                color: unread > 0 ? c.ink : Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    unread > 0 ? Icons.notifications : Icons.notifications_none,
                    size: 18,
                    color: unread > 0 ? c.paper : c.ink,
                  ),
                  if (unread > 0) ...[
                    const SizedBox(width: 3),
                    Text(
                      '$unread',
                      style: context.type.labelMedium?.copyWith(
                        color: c.paper,
                        fontWeight: FontWeight.w700,
                        fontFeatures: TypeScale.tabular,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton();

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final user = Provider.of<UserProvider>(context);
    final path = user.profileImagePath;
    final hasImage = path.isNotEmpty && File(path).existsSync();
    final initial = user.username.isEmpty ? '?' : user.username[0].toUpperCase();
    return Semantics(
      button: true,
      label: 'Profile',
      child: InkWell(
        borderRadius: Radii.controlAll,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Profile())),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            border: Border.all(color: c.ink, width: Strokes.panel),
            borderRadius: Radii.controlAll,
            image: hasImage
                ? DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover)
                : null,
          ),
          alignment: Alignment.center,
          child: hasImage
              ? null
              : Text(initial, style: context.type.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

/// A plain bar with a back arrow and a title, for pages opened from a tab.
class InkBackBar extends StatelessWidget implements PreferredSizeWidget {
  const InkBackBar({super.key, required this.title, this.actions, this.onBack});

  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 56,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      titleSpacing: 0,
      title: Text(title),
      actions: [...?actions, const SizedBox(width: Space.s)],
    );
  }
}

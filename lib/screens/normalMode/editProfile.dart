import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:otakuplanner/providers/user_provider.dart';
import 'package:otakuplanner/widgets/ink_kit.dart';
import 'package:provider/provider.dart';

/// Change or remove the profile photo. The photo stays on this phone; the
/// username and email come from the account and are shown, not edited,
/// because the server has no way to change them yet.
class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _picking = false;

  Future<void> _pickImage() async {
    if (_picking) return;
    setState(() => _picking = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) userProvider.setProfileImagePath(picked.path);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't open your photos. Check the app's photo access.")),
      );
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ink;
    final user = Provider.of<UserProvider>(context);
    final path = user.profileImagePath;
    final hasImage = path.isNotEmpty && File(path).existsSync();

    return Scaffold(
      appBar: const InkBackBar(title: 'Profile photo'),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(Space.page, Space.l, Space.page, Space.l),
                children: [
                  Center(
                    child: Container(
                      width: 168,
                      height: 168,
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
                          : Semantics(
                              label: 'No profile photo yet',
                              child: const MascotLine(height: 112),
                            ),
                    ),
                  ),
                  const SizedBox(height: Space.l),
                  Panel(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(
                            Space.gutter,
                            Space.gutter,
                            Space.gutter,
                            Space.xs,
                          ),
                          child: Kicker('Account'),
                        ),
                        if (user.fullName.isNotEmpty) ...[
                          _ReadOnlyRow(label: 'Name', value: user.fullName),
                          const InkRule(indent: Space.gutter),
                        ],
                        _ReadOnlyRow(label: 'Username', value: user.username),
                        const InkRule(indent: Space.gutter),
                        _ReadOnlyRow(label: 'Email', value: user.email),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, 0, Space.page, Space.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkButton(
                    label: hasImage ? 'Choose another photo' : 'Choose a photo',
                    icon: Icons.photo_library_outlined,
                    expand: true,
                    loading: _picking,
                    onPressed: _pickImage,
                  ),
                  if (hasImage) ...[
                    const SizedBox(height: Space.s),
                    InkButton.quiet(
                      label: 'Remove photo',
                      expand: true,
                      onPressed: () => user.setProfileImagePath(''),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.gutter, vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 88, child: Text(label, style: context.type.bodySmall)),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.type.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

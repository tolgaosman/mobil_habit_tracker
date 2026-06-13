import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/habit_provider.dart';
import '../../core/providers/theme_provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUpdatingPhoto = false;

  Future<void> _pickImage() async {
    setState(() => _isUpdatingPhoto = true);
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 85,
          maxWidth: 512,
          maxHeight: 512,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Photo'.tr(context),
              toolbarColor: AppColors.teal,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: true,
            ),
            IOSUiSettings(
              title: 'Crop Photo'.tr(context),
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
            ),
          ],
        );

        if (croppedFile != null && mounted) {
          await context.read<AuthProvider>().updateProfileImage(croppedFile.path);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile picture updated successfully!'.tr(context)),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${'Failed to update profile picture: '.tr(context)}$e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPhoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Profile'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildAvatarSection(user),
              const SizedBox(height: 32),
              _buildUserInfoCard(user),
              const SizedBox(height: 40),
              _buildLogoutButton(context),
              const SizedBox(height: 16),
              _buildClearDataButton(context),
              const SizedBox(height: 32),
              _buildPreferencesSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(dynamic user) {
    final hasImage =
        user.profileImagePath != null && user.profileImagePath!.isNotEmpty;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.teal, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: ClipOval(
                child: _isUpdatingPhoto
                    ? const Padding(
                        padding: EdgeInsets.all(36.0),
                        child: CircularProgressIndicator(color: AppColors.teal),
                      )
                    : hasImage
                        ? Image.file(
                            File(user.profileImagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          )
                        : _buildDefaultAvatar(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isUpdatingPhoto ? null : _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 500.ms)
            .scale(begin: const Offset(0.9, 0.9), duration: 500.ms),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          (user.email != null && user.email!.isNotEmpty)
              ? user.email!
              : (user.phoneNumber ?? ""),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.teal, AppColors.violet],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 54,
      ),
    );
  }

  Widget _buildUserInfoCard(dynamic user) {
    final List<Widget> items = [];

    items.add(_buildInfoRow(
      icon: Icons.person_outline_rounded,
      label: 'Name',
      value: user.name,
    ));

    if (user.email != null && user.email!.isNotEmpty) {
      items.add(_buildInfoRow(
        icon: Icons.email_outlined,
        label: 'Email',
        value: user.email!,
      ));
    }

    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
      items.add(_buildInfoRow(
        icon: Icons.phone_iphone_rounded,
        label: 'Phone Number',
        value: user.phoneNumber!,
      ));
    }

    final List<Widget> children = [];
    for (int i = 0; i < items.length; i++) {
      children.add(items[i]);
      if (i < items.length - 1) {
        children.add(Divider(
            height: 28,
            thickness: 1,
            color: Theme.of(context).dividerTheme.color));
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
          width: 1,
        ),
        boxShadow: context.softShadow,
      ),
      child: Column(
        children: children,
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.05, end: 0, delay: 200.ms, duration: 400.ms);
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.tealDim, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.tr(context),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text('Log Out'.tr(context)),
              content: Text('Are you sure you want to log out of your account?'
                  .tr(context)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel'.tr(context),
                      style: const TextStyle(color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Log Out'.tr(context),
                      style: const TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );

          if (confirm == true && mounted) {
            Navigator.pop(context); // Close profile screen
            await context.read<AuthProvider>().signOut();
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            const SizedBox(width: 10),
            Text(
              'Log Out'.tr(context),
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildClearDataButton(BuildContext context) {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text('Clear All Data'.tr(context),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Text(
                  'Are you sure you want to delete all habits and history? This cannot be undone.'
                      .tr(context)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('No'.tr(context),
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Yes'.tr(context),
                      style: const TextStyle(
                          color: AppColors.error, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );

          if (confirm == true && mounted) {
            HapticFeedback.heavyImpact();
            await context.read<HabitProvider>().clearAllData();
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('All data cleared successfully!'.tr(context)),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.delete_sweep_rounded,
                color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 10),
            Text(
              'Clear All Data'.tr(context),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
  }

  Widget _buildPreferencesSection(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final currentLang = langProvider.currentLanguage;
    final isDark = themeProvider.isDarkMode;

    const flags = {
      'en': '🇬🇧',
      'tr': '🇹🇷',
      'de': '🇩🇪',
      'fr': '🇫🇷',
      'it': '🇮🇹',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
          width: 1,
        ),
        boxShadow: context.softShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Language Dropdown
          Expanded(
            child: PopupMenuButton<String>(
              initialValue: currentLang,
              tooltip: 'Select Language'.tr(context),
              onSelected: (String newValue) {
                HapticFeedback.mediumImpact();
                langProvider.changeLanguage(newValue);
              },
              offset: const Offset(0, -280), // Forces the menu to open upwards
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Theme.of(context).cardTheme.color,
              elevation: 8,
              itemBuilder: (context) {
                return flags.entries.map((entry) {
                  return PopupMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Text(entry.value, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Text(
                          entry.key.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: entry.key == currentLang ? FontWeight.bold : FontWeight.w600,
                                color: entry.key == currentLang ? AppColors.teal : null,
                              ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(flags[currentLang] ?? '', style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Text(
                          currentLang.toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_drop_up_rounded, color: AppColors.tealDim, size: 28),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Theme toggle
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              context.read<ThemeProvider>().toggleTheme();
            },
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: AppColors.tealDim,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 400.ms)
        .slideY(begin: 0.05, end: 0, delay: 600.ms, duration: 400.ms);
  }
}

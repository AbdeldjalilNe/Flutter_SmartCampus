import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart' hide ToggleBiometric;
import '../../bloc/settings/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Appearance'),
                  _buildThemeSelector(context, state),
                  SizedBox(height: 24.h),
                  _buildSectionTitle('Language'),
                  _buildLanguageSelector(context, state),
                  SizedBox(height: 24.h),
                  _buildSectionTitle('Notifications'),
                  _buildNotificationSettings(context, state),
                  SizedBox(height: 24.h),
                  _buildSectionTitle('Security'),
                  _buildSecuritySettings(context, state),
                  SizedBox(height: 24.h),
                  _buildSectionTitle('Privacy'),
                  _buildPrivacySettings(context, state),
                  SizedBox(height: 24.h),
                  _buildSectionTitle('Storage'),
                  _buildStorageSettings(context, state),
                  SizedBox(height: 24.h),
                  _buildSectionTitle('About'),
                  _buildAboutSection(context),
                  SizedBox(height: 24.h),
                  _buildLogoutButton(context),
                ],
              ),
            );
          },
        ),
      );

  Widget _buildSectionTitle(String title) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.mediumColor,
          ),
        ),
      );

  Widget _buildThemeSelector(BuildContext context, SettingsState state) => Card(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildRadioTile(
                title: 'System Default',
                value: ThemeMode.system,
                groupValue: state.themeMode,
                onChanged: (value) {
                  context
                      .read<SettingsBloc>()
                      .add(ChangeThemeMode(mode: value!));
                },
              ),
              _buildRadioTile(
                title: 'Light',
                value: ThemeMode.light,
                groupValue: state.themeMode,
                onChanged: (value) {
                  context
                      .read<SettingsBloc>()
                      .add(ChangeThemeMode(mode: value!));
                },
              ),
              _buildRadioTile(
                title: 'Dark',
                value: ThemeMode.dark,
                groupValue: state.themeMode,
                onChanged: (value) {
                  context
                      .read<SettingsBloc>()
                      .add(ChangeThemeMode(mode: value!));
                },
              ),
            ],
          ),
        ),
      );

  Widget _buildRadioTile<T>({
    required String title,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) =>
      RadioListTile<T>(
        title: Text(title),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
        dense: true,
      );

  Widget _buildLanguageSelector(BuildContext context, SettingsState state) =>
      Card(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AppLanguage>(
              isExpanded: true,
              value: state.language,
              items: AppLanguage.values.map((language) => DropdownMenuItem(
                  value: language,
                  child: Text(language.displayName),
                ),).toList(),
              onChanged: (language) {
                if (language != null) {
                  context.read<SettingsBloc>().add(
                        ChangeLanguage(language: language),
                      );
                }
              },
            ),
          ),
        ),
      );

  Widget _buildNotificationSettings(
          BuildContext context, SettingsState state,) =>
      Card(
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Enable Notifications'),
              subtitle: const Text('Receive push notifications'),
              value: state.notificationsEnabled,
              onChanged: (value) {
                context.read<SettingsBloc>().add(
                      ToggleNotifications(enabled: value),
                    );
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Default Reminder'),
              subtitle: Text('${state.defaultReminderMinutes} minutes before'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showReminderPicker(context, state),
            ),
          ],
        ),
      );

  Widget _buildSecuritySettings(BuildContext context, SettingsState state) =>
      Card(
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Biometric Authentication'),
              subtitle: const Text('Use fingerprint or face recognition'),
              value: state.biometricEnabled,
              onChanged: (value) {
                context.read<SettingsBloc>().add(
                      ToggleBiometric(enabled: value),
                    );
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to change password
              },
            ),
          ],
        ),
      );

  Widget _buildPrivacySettings(BuildContext context, SettingsState state) =>
      Card(
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Analytics'),
              subtitle: const Text('Help improve the app'),
              value: state.analyticsEnabled,
              onChanged: (value) {
                context.read<SettingsBloc>().add(
                      ToggleAnalytics(enabled: value),
                    );
              },
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Location Sharing'),
              subtitle: const Text('Share location for better experience'),
              value: state.locationSharingEnabled,
              onChanged: (value) {
                context.read<SettingsBloc>().add(
                      ToggleLocationSharing(enabled: value),
                    );
              },
            ),
          ],
        ),
      );

  Widget _buildStorageSettings(BuildContext context, SettingsState state) =>
      Card(
        child: Column(
          children: [
            ListTile(
              title: const Text('Storage Used'),
              subtitle: Text(state.formattedStorageUsage),
              trailing: TextButton(
                onPressed: () {
                  context.read<SettingsBloc>().add(ClearCache());
                },
                child: const Text('Clear Cache'),
              ),
            ),
          ],
        ),
      );

  Widget _buildAboutSection(BuildContext context) => Card(
        child: Column(
          children: [
            const ListTile(
              title: Text('Version'),
              subtitle: Text(AppConstants.appVersion),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Terms of Service'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                // Open terms
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () {
                // Open privacy policy
              },
            ),
          ],
        ),
      );

  Widget _buildLogoutButton(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutRequested());
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor.withOpacity(0.1),
            foregroundColor: AppTheme.errorColor,
            elevation: 0,
          ),
          child: const Text('Logout'),
        ),
      );

  void _showReminderPicker(BuildContext context, SettingsState state) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Set Default Reminder',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...[5, 10, 15, 30, 60].map((minutes) => ListTile(
                  title: Text('$minutes minutes before'),
                  trailing: state.defaultReminderMinutes == minutes
                      ? const Icon(Icons.check, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    context.read<SettingsBloc>().add(
                          ChangeDefaultReminder(minutes: minutes),
                        );
                    Navigator.pop(context);
                  },
                ),),
          ],
        ),
      ),
    );
  }
}

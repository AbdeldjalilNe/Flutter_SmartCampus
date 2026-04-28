import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.goToEditProfile();
              },
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! Authenticated) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = state.user;

            return SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60.w,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.initials,
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(height: 16.h),

                  // Name
                  Text(
                    user.fullName,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkColor,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Email
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.mediumColor,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Info Cards
                  _buildInfoCard(
                    icon: Icons.badge,
                    title: 'Student ID',
                    value: user.studentId ?? 'Not provided',
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoCard(
                    icon: Icons.school,
                    title: 'Department',
                    value: user.department ?? 'Not provided',
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Member Since',
                    value: _formatDate(user.createdAt),
                  ),
                  SizedBox(height: 12.h),
                  _buildInfoCard(
                    icon: Icons.verified_user,
                    title: 'Role',
                    value: user.role.name.toUpperCase(),
                  ),
                  SizedBox(height: 32.h),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.errorColor),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) =>
      Card(
        child: ListTile(
          leading: Icon(icon, color: AppTheme.primaryColor),
          title: Text(title),
          subtitle: Text(value),
        ),
      );

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Logout',
                style: TextStyle(color: AppTheme.errorColor),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
          ],
        ),
    );
  }
}

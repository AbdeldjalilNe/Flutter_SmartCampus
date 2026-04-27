import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is! Authenticated || !state.user.isAdmin) {
              return const Center(
                child: Text('Access Denied'),
              );
            }

            return GridView.count(
              padding: EdgeInsets.all(16.w),
              crossAxisCount: 2,
              mainAxisSpacing: 16.w,
              crossAxisSpacing: 16.w,
              children: [
                _buildAdminCard(
                  icon: Icons.campaign,
                  title: 'Announcements',
                  subtitle: 'Manage campus announcements',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    // Navigate to announcement management
                  },
                ),
                _buildAdminCard(
                  icon: Icons.event,
                  title: 'Events',
                  subtitle: 'Manage campus events',
                  color: AppTheme.secondaryColor,
                  onTap: () {
                    // Navigate to event management
                  },
                ),
                _buildAdminCard(
                  icon: Icons.people,
                  title: 'Users',
                  subtitle: 'Manage user accounts',
                  color: AppTheme.infoColor,
                  onTap: () {
                    // Navigate to user management
                  },
                ),
                _buildAdminCard(
                  icon: Icons.analytics,
                  title: 'Analytics',
                  subtitle: 'View app usage statistics',
                  color: AppTheme.warningColor,
                  onTap: () {
                    // Navigate to analytics
                  },
                ),
                _buildAdminCard(
                  icon: Icons.settings,
                  title: 'Settings',
                  subtitle: 'App configuration',
                  color: AppTheme.mediumColor,
                  onTap: () {
                    // Navigate to app settings
                  },
                ),
                _buildAdminCard(
                  icon: Icons.report,
                  title: 'Reports',
                  subtitle: 'Generate reports',
                  color: AppTheme.errorColor,
                  onTap: () {
                    // Navigate to reports
                  },
                ),
              ],
            );
          },
        ),
      );

  Widget _buildAdminCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40.w,
                color: color,
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.mediumColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

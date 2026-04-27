import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';

class SafetyPage extends StatelessWidget {
  const SafetyPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Campus Safety'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emergency Banner
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppTheme.errorColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emergency,
                          color: AppTheme.errorColor,
                          size: 24.w,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Emergency Contacts',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _buildEmergencyContact(
                      'Campus Security',
                      '(555) 123-4567',
                      Icons.security,
                    ),
                    _buildEmergencyContact(
                      'Health Center',
                      '(555) 123-4568',
                      Icons.local_hospital,
                    ),
                    _buildEmergencyContact(
                      'Emergency Services',
                      '911',
                      Icons.emergency,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Safety Features
              Text(
                'Safety Features',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkColor,
                ),
              ),
              SizedBox(height: 12.h),
              _buildSafetyFeature(
                icon: Icons.location_on,
                title: 'Share My Location',
                subtitle: 'Share your real-time location with trusted contacts',
                onTap: () {
                  // Enable location sharing
                },
              ),
              _buildSafetyFeature(
                icon: Icons.notifications_active,
                title: 'Safety Alerts',
                subtitle: 'Receive important safety notifications',
                onTap: () {
                  // Configure safety alerts
                },
              ),
              _buildSafetyFeature(
                icon: Icons.phone_in_talk,
                title: 'Safe Walk',
                subtitle: 'Request a security escort on campus',
                onTap: () {
                  // Request safe walk
                },
              ),
              _buildSafetyFeature(
                icon: Icons.report_problem,
                title: 'Report Incident',
                subtitle: 'Report a safety concern or incident',
                onTap: () {
                  // Report incident
                },
              ),
              SizedBox(height: 24.h),

              // Safety Resources
              Text(
                'Safety Resources',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkColor,
                ),
              ),
              SizedBox(height: 12.h),
              _buildResourceLink('Campus Safety Guidelines'),
              _buildResourceLink('Emergency Procedures'),
              _buildResourceLink('Mental Health Resources'),
              _buildResourceLink('Sexual Assault Prevention'),
            ],
          ),
        ),
      );

  Widget _buildEmergencyContact(String title, String phone, IconData icon) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppTheme.errorColor),
        title: Text(title),
        subtitle: Text(phone),
        trailing: IconButton(
          icon: const Icon(Icons.phone),
          onPressed: () {
            // Make phone call
          },
        ),
      );

  Widget _buildSafetyFeature({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      Card(
        margin: EdgeInsets.only(bottom: 12.h),
        child: ListTile(
          leading: Icon(icon, color: AppTheme.primaryColor),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );

  Widget _buildResourceLink(String title) => Card(
        margin: EdgeInsets.only(bottom: 8.h),
        child: ListTile(
          title: Text(title),
          trailing: const Icon(Icons.open_in_new),
          onTap: () {
            // Open resource link
          },
        ),
      );
}

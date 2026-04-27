import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_theme.dart';

class TimetableCard extends StatelessWidget {
  const TimetableCard({
    super.key,
    required this.course,
    required this.code,
    required this.time,
    required this.room,
    required this.color,
    this.onTap,
  });
  final String course;
  final String code;
  final String time;
  final String room;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border(
              left: BorderSide(
                color: color,
                width: 4.w,
              ),
            ),
          ),
          child: Row(
            children: [
              // Time Column
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    Text(
                      time.split(' - ')[0],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      time.split(' - ')[1],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: color.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),

              // Course Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      code,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.mediumColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.room_outlined,
                          size: 14.w,
                          color: AppTheme.mediumColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          room,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.mediumColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: AppTheme.mediumColor,
                size: 24.w,
              ),
            ],
          ),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TimeActionsRow extends StatelessWidget {
  final String timeText;
  final VoidCallback? onMorePressed;

  const TimeActionsRow({
    Key? key,
    required this.timeText,
    this.onMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
      child: Row(
        children: [
          // Time
          Text(
            timeText,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(width: 4.w),
          // Action Icons
          Icon(
            Icons.diamond_outlined,
            color: Colors.blue[400],
            size: 22,
          ),
          SizedBox(width: 3.w),
          Icon(
            Icons.chat_bubble_outline,
            color: Colors.blue[400],
            size: 22,
          ),
          SizedBox(width: 3.w),
          Icon(
            Icons.share,
            color: Colors.blue[400],
            size: 22,
          ),
          Spacer(),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.grey[700],
              size: 24,
            ),
            onPressed: onMorePressed ??
                () {
                  // TODO: Abrir menu de opções
                },
          ),
        ],
      ),
    );
  }
}

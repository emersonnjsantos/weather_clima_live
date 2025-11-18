import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppBarSection extends StatelessWidget {
  final String locationText;
  final VoidCallback onSearchPressed;

  const AppBarSection({
    Key? key,
    required this.locationText,
    required this.onSearchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.75.h),
      child: Row(
        children: [
          Builder(builder: (context) {
            return IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.grey[700],
                size: 28,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          }),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              locationText,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.grey[700],
              size: 28,
            ),
            onPressed: onSearchPressed,
          ),
        ],
      ),
    );
  }
}

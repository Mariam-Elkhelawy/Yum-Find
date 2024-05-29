import 'package:CookEE/core/utils/app_colors.dart';
import 'package:CookEE/core/utils/app_strings.dart';
import 'package:CookEE/core/utils/styles.dart';
import 'package:CookEE/features/layout/nav_bar.dart';
import 'package:CookEE/features/tabs/presentation/pages/home_tab.dart';
import 'package:CookEE/features/tabs/presentation/pages/search_tab.dart';
import 'package:CookEE/features/tabs/presentation/pages/tab3.dart';
import 'package:CookEE/features/tabs/presentation/pages/tab4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

int tabIndex = 0;
int navIndex = 0;

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [
      HomeTab(
        tabIndex: tabIndex,
        onTap: (value) {
          setState(() {
            tabIndex = value;
          });
        },
      ),
      const SearchTab(),
      const Tab3(),
      const Tab4()
    ];
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      bottomNavigationBar: NavBar(
        index: navIndex,
        onTabChange: (value) {
          navIndex = value;
          setState(() {});
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 70.h),
              Text(AppStrings.hi, style: AppStyles.bodyM),
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: AppStrings.cook, style: AppStyles.bodyM),
                        TextSpan(
                            text: AppStrings.chef, style: AppStyles.italicText),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (navIndex != 1)
                    IconButton(
                      onPressed: () {
                        navIndex = 1;
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.search,
                        size: 30,
                        color: AppColor.primaryColor,
                      ),
                    )
                ],
              ),
              tabs[navIndex]
            ],
          ),
        ),
      ),
    );
  }
}

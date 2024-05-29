import 'dart:async';
import 'package:CookEE/core/components/reusable_components.dart';
import 'package:CookEE/core/utils/app_colors.dart';
import 'package:CookEE/core/utils/app_strings.dart';
import 'package:CookEE/core/utils/styles.dart';
import 'package:CookEE/features/tabs/data/models/SearchModel.dart';
import 'package:CookEE/features/tabs/presentation/search_cubit/search_cubit.dart';
import 'package:CookEE/features/tabs/presentation/widgets/quick_search.dart';
import 'package:CookEE/features/tabs/presentation/widgets/search_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  TextEditingController searchController = TextEditingController();
  Timer? debounce;

  String? searchedVal;

  @override
  void dispose() {
    debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      searchedVal = query;
      if (searchedVal != null && searchedVal!.isNotEmpty) {
        context.read<SearchCubit>().getSearchRecipes(searchedVal!);
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          SizedBox(
            height: 60.h,
            child: customTextFormField(
              controller: searchController,
              borderColor: const Color(0xFFebebea),
              hintText: AppStrings.searchHint,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
              fillColor: const Color(0xFFebebea),
              radius: 15.r,
              prefixIcon: const Icon(
                CupertinoIcons.search,
                color: AppColor.primaryColor,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (searchedVal == null || searchedVal!.isEmpty) ...[
            const QuickSearch(),
          ],
          if (searchedVal != null && searchedVal!.isNotEmpty) ...[
            BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state is SearchFailureState) {
                  return Center(
                    child: Text(
                      state.errorMessage,
                      style: AppStyles.bodyM,
                    ),
                  );
                }
                if (state is SearchSuccessState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 18.h),
                      Text(
                        '${state.searchModel.hits!.length} Results',
                        style: AppStyles.textButton
                            .copyWith(color: AppColor.textColor),
                      ),
                      SizedBox(
                        height: 800.h,
                        child: ListView.builder(
                          padding: EdgeInsets.only(bottom: 70.h,top: 12.h),
                          itemCount: state.searchModel.hits!.length,
                          itemBuilder: (context, index) {
                            final recipe =
                                state.searchModel.hits![index].recipe;
                            return SearchWidget(recipe: recipe??Recipe());
                          },
                        ),
                      ),
                    ],
                  );
                }
                return SizedBox(
                  width: 500.w,
                  height: 700.h,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  ),
                );
              },
            ),
          ]
        ],
      ),
    );
  }
}

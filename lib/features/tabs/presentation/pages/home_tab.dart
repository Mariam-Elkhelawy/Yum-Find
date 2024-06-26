import 'package:YumFind/core/components/reusable_components.dart';
import 'package:YumFind/core/locator/service_locator.dart';
import 'package:YumFind/core/utils/app_colors.dart';
import 'package:YumFind/core/utils/app_strings.dart';
import 'package:YumFind/core/utils/styles.dart';
import 'package:YumFind/features/tabs/data/models/SearchModel.dart';
import 'package:YumFind/features/tabs/data/repositories/search_repo_implement.dart';
import 'package:YumFind/features/tabs/presentation/search_cubit/search_cubit.dart';
import 'package:YumFind/features/tabs/presentation/widgets/dot_widget.dart';
import 'package:YumFind/features/tabs/presentation/widgets/home_recipe_widget.dart';
import 'package:YumFind/features/tabs/presentation/widgets/low_fat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key, required this.tabIndex, required this.onTap});
  final int tabIndex;
  final void Function(int)? onTap;

  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  late int currentTabIndex;
  late SearchCubit searchCubit;
  late SearchCubit dietCubit;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentTabIndex = widget.tabIndex;
    searchCubit = SearchCubit(getIt.get<SearchRepoImplement>());
    dietCubit = SearchCubit(getIt.get<SearchRepoImplement>());
    fetchRecipes();
    fetchDietRecipes();
  }

  @override
  void dispose() {
    searchCubit.close();
    dietCubit.close();
    super.dispose();
  }

  void fetchRecipes() {
    setState(() {
      isLoading = true;
    });
    searchCubit.getSearchRecipes(AppStrings.tabText[currentTabIndex]).then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void fetchDietRecipes() {
    setState(() {
      isLoading = true;
    });
    dietCubit.getSearchRecipes('low fat').then((_) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void handleCubitState(BuildContext context, SearchState state) {
    if (state is SearchLoadingState) {
      setState(() {
        isLoading = true;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  var favBox = Hive.box<Recipe>(AppStrings.favBox);

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SearchCubit, SearchState>(
          bloc: searchCubit,
          listener: handleCubitState,
        ),
        BlocListener<SearchCubit, SearchState>(
          bloc: dietCubit,
          listener: handleCubitState,
        ),
      ],
      child: ValueListenableBuilder(
        valueListenable: favBox.listenable(),
        builder: (context, Box<Recipe> box, _) {
          return Stack(
            children: [
              DefaultTabController(
                length: 4,
                child: RefreshIndicator(
                  color: AppColor.primaryColor,
                  backgroundColor: AppColor.whiteColor,
                  onRefresh: () async {
                    fetchRecipes();
                    fetchDietRecipes();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 28.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            RotatedBox(
                              quarterTurns: 3,
                              child: TabBar(
                                onTap: (index) {
                                  setState(() {
                                    currentTabIndex = index;
                                    fetchRecipes();
                                  });
                                  if (widget.onTap != null) {
                                    widget.onTap!(index);
                                  }
                                },
                                dividerColor: Colors.transparent,
                                isScrollable: true,
                                labelPadding:
                                EdgeInsets.symmetric(horizontal: 14.w),
                                tabAlignment: TabAlignment.start,
                                labelColor: AppColor.primaryColor,
                                unselectedLabelColor:
                                AppColor.secondaryColor,
                                indicatorColor: Colors.transparent,
                                tabs: [
                                  Tab(
                                    child: DotWidget(
                                      pageIndex: 0,
                                      text: AppStrings.breakFast,
                                      tabIndex: currentTabIndex,
                                    ),
                                  ),
                                  Tab(
                                    child: DotWidget(
                                      pageIndex: 1,
                                      text: AppStrings.lunch,
                                      tabIndex: currentTabIndex,
                                    ),
                                  ),
                                  Tab(
                                    child: DotWidget(
                                      pageIndex: 2,
                                      text: AppStrings.dinner,
                                      tabIndex: currentTabIndex,
                                    ),
                                  ),
                                  Tab(
                                    child: DotWidget(
                                      pageIndex: 3,
                                      text: AppStrings.snack,
                                      tabIndex: currentTabIndex,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 32.w),
                            BlocProvider.value(
                              value: searchCubit,
                              child: BlocBuilder<SearchCubit, SearchState>(
                                builder: (context, state) {
                                  if (state is SearchFailureState) {
                                    return customError(state.errorMessage);
                                  }
                                  if (state is SearchSuccessState) {
                                    return SizedBox(
                                      height: 350.h,
                                      width: 320.w,
                                      child: ListView.builder(
                                        clipBehavior: Clip.none,
                                        physics:
                                        const BouncingScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        itemCount: state
                                            .searchModel.hits!.length,
                                        itemBuilder: (context, index) {
                                          final recipe = state.searchModel
                                              .hits![index].recipe;
                                          return HomeRecipeWidget(
                                              recipe:
                                              recipe ?? Recipe(),
                                              index: index);
                                        },
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0.w),
                          child: Text(
                            AppStrings.lowFat,
                            style: AppStyles.generalText
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(height: 26.h),
                        BlocProvider.value(
                          value: dietCubit,
                          child: BlocBuilder<SearchCubit, SearchState>(
                            builder: (context, state) {
                              if (state is SearchFailureState) {
                                return Padding(
                                  padding: EdgeInsets.all(45.r),
                                  child: customError(state.errorMessage),
                                );
                              }
                              if (state is SearchSuccessState) {
                                return SizedBox(
                                  height: 235.h,
                                  width: 360.w,
                                  child: ListView.builder(
                                    clipBehavior: Clip.none,
                                    physics:
                                    const BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: state
                                        .searchModel.hits!.length,
                                    itemBuilder: (context, index) {
                                      final recipe = state.searchModel
                                          .hits![index].recipe;
                                      return LowFatWidget(
                                          recipe: recipe ?? Recipe());
                                    },
                                  ),
                                );
                              }

                              return const SizedBox();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isLoading)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 55.0.w),
                  child: Center(
                    child: customLoading(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

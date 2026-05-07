// features/product_details/presentation/screens/product_details_screen.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:veloura/core/services/secure_storage_services.dart';
import 'package:veloura/features/home/data/models/product_model.dart';
import 'package:veloura/features/product_details/data/add_review_remote_data_source.dart';
import 'package:veloura/features/product_details/presentation/cubits/reviews_cubit.dart';
import 'package:veloura/features/product_details/presentation/cubits/reviews_state.dart';
import 'package:veloura/features/product_details/presentation/widgets/add_review_bottom_sheet.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_primary_button.dart';
import '../widgets/product_features_list.dart';
import '../widgets/review_card.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  @override
  void initState() {
    super.initState();

    final id = widget.product.id;

    context.read<ReviewsCubit>().getReviews(id.toString());
  }

  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        widget.product.imageUrl,
                        height: 250.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            'https://i.pinimg.com/736x/86/95/7f/86957f18605edb09e7b75925147e60b1.jpg',
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator());
                        },
                      ),
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 8.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: colors.background,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Icons.arrow_back,
                                    size: 20.sp,
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  _buildCircleIcon(
                                    Icons.favorite_border,
                                    colors,
                                  ),
                                  SizedBox(width: 8.w),
                                  _buildCircleIcon(Icons.ios_share, colors),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 24.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.category,
                          style: textTheme.titleSmall,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          widget.product.name,
                          style: textTheme.headlineMedium,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          '\$${widget.product.price.toStringAsFixed(2)}',
                          style: textTheme.titleMedium,
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  Icons.star,
                                  color: colors.primary,
                                  size: 14.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text('(24 Reviews)', style: textTheme.bodySmall),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          widget.product.description,
                          style: textTheme.bodyLarge,
                        ),
                        SizedBox(height: 20.h),
                        const ProductFeaturesList(),
                        SizedBox(height: 32.h),
                        Divider(color: colors.border, thickness: 1),
                        SizedBox(height: 32.h),
                        Text('Reviews', style: textTheme.headlineSmall),
                        SizedBox(height: 20.h),
                        BlocBuilder<ReviewsCubit, ReviewsStates>(
                          builder: (context, state) {
                            if (state is ReviewsLoading) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (state is ReviewsFailure) {
                              return Text(state.message);
                            }
                            if (state is ReviewsSuccess) {
                              return Column(
                                children: state.reviews.map((review) {
                                  return ReviewCard(
                                    name: review["userName"] ?? "User",
                                    date: review["createdAt"] ?? "",
                                    rating: review["rating"] ?? 0,
                                    comment: review["comment"] ?? "",
                                  );
                                }).toList(),
                              );
                            }
                            return SizedBox();
                          },
                        ),
                        // const ReviewCard(
                        //   name: 'Eleanor V.',
                        //   date: 'Oct 12, 2023',
                        //   rating: 5,
                        //   comment:
                        //       'Absolutely exquisite. The silk has a substantial weight to it that drapes beautifully, and the colors are even richer in person than in the photos.',
                        // ),
                        // const ReviewCard(
                        //   name: 'Sophia L.',
                        //   date: 'Sep 28, 2023',
                        //   rating: 4,
                        //   comment:
                        //       'A lovely piece, though slightly smaller than I anticipated. The hand-rolled edges are a testament to the craftsmanship.',
                        // ),
                        SizedBox(height: 16.h),
                        CustomPrimaryButton(
                          onPressed: () {},
                          label: "Read All Reviews",
                          letterSpacing: 0.5,
                        ),
                        SizedBox(height: 20.h),
                        CustomPrimaryButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,

                              builder: (context) => AddReviewBottomSheet(
                                productId: widget.product.id.toString(),
                                parentContext: context,
                                addReviewRemoteDataSource:
                                    AddReviewRemoteDataSource(
                                      Dio(),
                                      SecureStorageServices(),
                                    ),
                              ),
                            );
                          },
                          label: "ADD REVIEW",
                          letterSpacing: 0.5,
                        ),
                        SizedBox(height: 20.h),
                        CustomPrimaryButton(
                          onPressed: () {},
                          label: "ADD TO CART",
                          letterSpacing: 0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon, MyColors colors) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: colors.background,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20.sp, color: colors.primary),
    );
  }
}

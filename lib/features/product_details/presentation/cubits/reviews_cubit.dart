// features/product_details/presentation/cubits/reviews_cubit.dart

import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:veloura/features/product_details/data/add_review_remote_data_source.dart';
import 'package:veloura/features/product_details/presentation/cubits/reviews_state.dart';

class ReviewsCubit extends Cubit<ReviewsStates> {
  final AddReviewRemoteDataSource dataSource;

  ReviewsCubit(this.dataSource) : super(ReviewsInitial());

  Future<void> getReviews(String productId) async {
    emit(ReviewsLoading());

    try {
      log('Fetching reviews for product: $productId');
      final reviews = await dataSource.getReviews(productId);

      emit(ReviewsSuccess(reviews));
    } catch (e) {
      emit(ReviewsFailure(e.toString()));
    }
  }
}

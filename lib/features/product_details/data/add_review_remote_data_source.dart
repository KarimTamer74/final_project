// features/product_details/data/add_review_remote_data_source.dart
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:veloura/core/services/secure_storage_services.dart';

class AddReviewRemoteDataSource {
  final Dio dio;
  final SecureStorageServices secureStorage;

  AddReviewRemoteDataSource(this.dio, this.secureStorage);

  Future<void> addReview({
    required String productId,
    required String comment,
    required int rating,
  }) async {
    final token = await secureStorage.getAccessToken();

    if (token == null) {
      throw Exception("No valid token found");
    }

    try {
      final response = await dio.post(
        'https://accessories-eshop.runasp.net/api/reviews/$productId',
        data: {"comment": comment, "rating": rating},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      print("ADD REVIEW RESPONSE => ${response.data}");
    } on DioException catch (e) {
      print("ERROR => ${e.response?.data}");
      throw Exception("Failed to add review: ${e.response?.data}");
    }
  }

  Future<List<dynamic>> getReviews(String productId) async {
    final token = await secureStorage.getAccessToken();

    if (token == null) {
      throw Exception("Please login first");
    }

    try {
      final response = await dio.get(
        'https://accessories-eshop.runasp.net/api/reviews/$productId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return response.data["reviews"]["items"];
    } on DioException catch (e) {
      log("ERROR => ${e.response?.data}");

      final data = e.response?.data;

      String errorMessage = "Something went wrong";

      if (data != null && data is Map<String, dynamic>) {
        final generalErrors = data["errors"]?["generalErrors"];

        if (generalErrors != null && generalErrors is List) {
          final firstError = generalErrors.first.toString();

          if (firstError.contains("Review.ProductNotFound")) {
            errorMessage = "No reviews found for this product";
          } else {
            errorMessage = firstError;
          }
        } else if (data["message"] != null) {
          errorMessage = data["message"];
        }
      }

      throw errorMessage;
    }
  }
}

// import 'package:dio/dio.dart';

// class AddReviewRemoteDataSource {
//   final Dio dio = Dio();

//   static const String _token =
//       'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwNDU5NjA0Yy1kMTk3LTQ5MGEtNmE5OC0wOGRlYTdlYzQ1MTEiLCJqdGkiOiI3NTdiNDc3NS03YmQzLTQwMTYtYTk3Ny1kYTRiNzA4NWNhNzYiLCJlbWFpbCI6ImVuZy5iYWRhd3k3N0BnbWFpbC5jb20iLCJuYW1lIjoiQWhtZWQgQmFkYXd5Iiwicm9sZXMiOiIiLCJwaWN0dXJlIjoiIiwiZXhwIjoxNzc3OTg3NTc0LCJpc3MiOiJlc2hvcC5uZXQiLCJhdWQiOiJlc2hvcC5uZXQifQ.i71XWuhuv9-BYC-znjNp0302cWbkYuuWtEIUzDqa7as';

//   Options get _options => Options(headers: {'Authorization': 'Bearer $_token'});

//   Future<void> addReview(
//     {required String productId,
//     required String comment,
//     required int rating,
//    }
//   ) async {
//     try {
//       final response = await dio.post(
//         'https://accessories-eshop.runasp.net/api/reviews/$productId',
//         data: {"productId": productId, "comment": comment, "rating": rating},
//         options: _options,
//       );
//       print("ADD REVIEW RESPONSE => ${response.data}");
//     } on DioException catch (e) {
//       print("ERROR => ${e.response?.data}");
//       throw Exception("Failed to add review");
//     }
//   }
// }

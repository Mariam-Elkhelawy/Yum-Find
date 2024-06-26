import 'package:YumFind/core/errors/failures.dart';
import 'package:YumFind/features/tabs/data/models/SearchModel.dart';
import 'package:dartz/dartz.dart';

abstract class SearchRepo{
 Future<Either<Failures,SearchModel>> searchRecipes(String searchQuery);
}
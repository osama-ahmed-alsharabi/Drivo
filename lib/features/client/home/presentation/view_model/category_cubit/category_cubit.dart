import 'package:bloc/bloc.dart';
import 'package:drivo_app/core/util/app_images.dart';
import 'package:drivo_app/features/client/home/data/model/category_model.dart';
import 'package:equatable/equatable.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit() : super(CategoryInitial());
  List<CategoryModel> categoryModel = [
    CategoryModel(
        image: AppImages.restaurantImage, title: "المطاعم", isActive: true),
    CategoryModel(
        image: AppImages.pharmacyImage, title: "الصيدليات", isActive: false),
    CategoryModel(
        image: AppImages.supermarketImage,
        title: "السوبر ماركت",
        isActive: false),
  ];
  bool hasLoaded = false;
  getCategory() {
    emit(CategorySuccess(
      categoryModel: categoryModel,
    ));
  }
}

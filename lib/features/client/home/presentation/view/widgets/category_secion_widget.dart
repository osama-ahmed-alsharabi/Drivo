import 'package:drivo_app/core/helpers/custom_snackbar.dart';
import 'package:drivo_app/features/client/home/data/model/category_model.dart';
import 'package:drivo_app/features/client/restaurant_list/presentation/view/restaurant_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icon_snackbar/flutter_icon_snackbar.dart';

class CategorySecionWidget extends StatelessWidget {
  final String title;
  final List<CategoryModel> categoryModel;
  const CategorySecionWidget(
      {super.key, required this.title, required this.categoryModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categoryModel.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (categoryModel[index].isActive) {
                    (Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const RestaurantListScreen())));
                  } else {
                    CustomSnackbar(
                        context: context,
                        snackBarType: SnackBarType.fail,
                        label: "قيد التطوير");
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(categoryModel[index].image),
                            fit: BoxFit.fill,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: !categoryModel[index].isActive
                                ? Colors.grey.withOpacity(0.6)
                                : null,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(categoryModel[index].title),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

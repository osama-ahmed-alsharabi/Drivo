import 'package:cached_network_image/cached_network_image.dart';
import 'package:drivo_app/features/service_provider/product/data/model/product_model.dart';
import 'package:drivo_app/features/service_provider/product/presetation/view/widgets/add_product_page.dart';
import 'package:drivo_app/features/service_provider/product/presetation/view_model/fetch_product_service_provider/fetch_product_service_provider_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 2,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: product.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(theme.primaryColor),
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          _buildPlaceholderIcon(),
                    )
                  : _buildPlaceholderIcon(),
            ),
          ),

          // Product Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: screenWidth < 350 ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Category
                if (product.category != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.category!,
                    style: TextStyle(
                      fontSize: screenWidth < 350 ? 10 : 12,
                      color: Colors.grey,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Price and Availability
                Row(
                  children: [
                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${product.price.toStringAsFixed(2)} ر.س',
                        style: TextStyle(
                          fontSize: screenWidth < 350 ? 12 : 14,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Availability
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: product.isAvailable
                            ? Colors.green.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            product.isAvailable
                                ? Icons.check_circle
                                : Icons.remove_circle,
                            size: 14,
                            color: product.isAvailable
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.isAvailable ? 'متوفر' : 'غير متوفر',
                            style: TextStyle(
                              fontSize: screenWidth < 350 ? 10 : 12,
                              color: product.isAvailable
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Action Buttons
                Row(
                  children: [
                    // Edit Button
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(
                          Icons.edit,
                          size: 16,
                          color: theme.primaryColor,
                        ),
                        label: const Text('تعديل'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddProductPage(product: product),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Delete Button
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.delete,
                          size: 16,
                          color: Colors.red,
                        ),
                        label: const Text('حذف'),
                        onPressed: () => _showDeleteDialog(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.fastfood, size: 40, color: Colors.grey),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: const Text('هل أنت متأكد من حذف هذا المنتج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              BlocProvider.of<FetchProductsServiceProviderCubit>(context)
                  .deleteProduct(product.id!);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

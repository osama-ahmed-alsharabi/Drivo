import 'package:drivo_app/core/helpers/luncher_helper_functions.dart';
import 'package:drivo_app/core/util/app_const.dart';
import 'package:drivo_app/core/util/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:drivo_app/features/client/profile/presentation/views/widgets/client_list_tile_widget.dart';

class ClientSupportSection extends StatelessWidget {
  const ClientSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ClientListTile(
            icon: IconlyBold.call,
            title: "اتصل بنا",
            onTap: () => LuncherHelperFunctions()
                .makePhoneCall(context, AppConst.appCallPhoneNumber),
          ),
          const Divider(height: 1),
          ClientListTile(
            icon: IconlyBold.message,
            title: "الدعم الفني",
            onTap: () => LuncherHelperFunctions()
                .openWhatsApp(context, AppConst.appCallPhoneNumber),
          ),
          const Divider(height: 1),
          ClientListTile(
            icon: IconlyBold.infoSquare,
            title: "عن التطبيق",
            onTap: () => _showAboutAppBottomSheet(context),
          ),
        ],
      ),
    );
  }

  void _showAboutAppBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            padding: const EdgeInsets.only(
              top: 24,
              left: 20,
              right: 20,
              bottom: 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Draggable handle
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),

                // App logo/icon
                Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40)),
                    child: SvgPicture.asset(AppImages.smallLogoSvg)),
                const SizedBox(height: 16),
                Text(
                  "عن تطبيق Drivo",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Description with better typography
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "تطبيق Drivo هو تطبيق رقمي متكامل يربط بين المستخدمين والمطاعم والسائقين عبر نظام ذكي ومتطور. يمكن للعملاء تصفح قوائم الطعام من خلال مجموعة واسعة من المطاعم، اختيار وجباتهم المفضلة، وتتبع طلباتهم لحظة بلحظة حتى يتم تسليمها بسرعة وكفاءة.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildFeatureItem(
                    Icons.delivery_dining, "توصيل سريع خلال 30 دقيقة"),
                _buildFeatureItem(Icons.credit_card, "دفع آمن عبر التطبيق"),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "حسناً",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            icon,
            color: Colors.green,
            size: 20,
          ),
        ],
      ),
    );
  }
}

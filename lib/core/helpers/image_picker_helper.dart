import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  static Future<XFile?> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      return await picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      return null;
    }
  }

  static Future<XFile?> pickImageFromCamera() async {
    try {
      // Check and request permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        return null;
      }

      final picker = ImagePicker();
      return await picker.pickImage(source: ImageSource.camera);
    } catch (e) {
      return null;
    }
  }
}

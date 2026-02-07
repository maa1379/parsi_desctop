
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  final picker = ImagePicker();

  String? filePath;

  Future<String> select() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
      imageQuality: 100,
    );
    print(await pickedFile?.length());
    if (pickedFile != null) {
      return pickedFile.path;
    } else {
      return throw ();
    }
  }
}

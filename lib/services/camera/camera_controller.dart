import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class CameraController {
  final ImagePicker _picker = ImagePicker();

  Future<File?> takeAndSavePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);

    if (photo != null) {
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String fileName = basename(photo.path);  // Get the file name from the path
      final File savedImage = await File(photo.path).copy('${appDirectory.path}/$fileName');
      
      return savedImage;
    } else {
      return null;
    }
  }
}

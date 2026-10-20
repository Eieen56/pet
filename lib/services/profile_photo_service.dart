import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePhotoService {
  ProfilePhotoService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<String?> pickPhoto(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    return image?.path;
  }

  Future<String> savePhoto({
    required String userId,
    required String sourcePath,
  }) async {
    final directory = await _directory();
    await directory.create(recursive: true);
    await deletePhoto(userId);
    final extension = _supportedExtension(sourcePath);
    final target = File(
      '${directory.path}${Platform.pathSeparator}$userId$extension',
    );
    await File(sourcePath).copy(target.path);
    return target.path;
  }

  Future<String?> findPhoto(String userId) async {
    final directory = await _directory();
    if (!await directory.exists()) {
      return null;
    }
    await for (final entity in directory.list()) {
      if (entity is File && _stem(entity.path) == userId) {
        return entity.path;
      }
    }
    return null;
  }

  Future<void> deletePhoto(String userId) async {
    final directory = await _directory();
    if (!await directory.exists()) {
      return;
    }
    await for (final entity in directory.list()) {
      if (entity is File && _stem(entity.path) == userId) {
        await entity.delete();
      }
    }
  }

  Future<Directory> _directory() async {
    final root = await getApplicationDocumentsDirectory();
    return Directory('${root.path}${Platform.pathSeparator}profile_photos');
  }

  String _supportedExtension(String path) {
    final fileName = path.split(RegExp(r'[/\\]')).last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) {
      return '.jpg';
    }
    final extension = fileName.substring(dotIndex).toLowerCase();
    return const ['.jpg', '.jpeg', '.png', '.webp'].contains(extension)
        ? extension
        : '.jpg';
  }

  String _stem(String path) {
    final fileName = path.split(RegExp(r'[/\\]')).last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex == -1 ? fileName : fileName.substring(0, dotIndex);
  }
}

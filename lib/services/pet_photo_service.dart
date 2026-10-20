import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PetPhotoService {
  PetPhotoService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<String?> pickPhoto(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    return image?.path;
  }

  Future<String> savePhoto({
    required String userId,
    required String petId,
    required String sourcePath,
  }) async {
    final directory = await _photoDirectory(userId);
    await directory.create(recursive: true);
    await deletePhoto(userId: userId, petId: petId);

    final extension = _supportedExtension(sourcePath);
    final target = File(
      '${directory.path}${Platform.pathSeparator}$petId$extension',
    );
    await File(sourcePath).copy(target.path);
    return target.path;
  }

  Future<String?> findPhoto({
    required String userId,
    required String petId,
  }) async {
    final directory = await _photoDirectory(userId);
    if (!await directory.exists()) {
      return null;
    }

    await for (final entity in directory.list()) {
      if (entity is File && _fileStem(entity.path) == petId) {
        return entity.path;
      }
    }
    return null;
  }

  Future<void> deletePhoto({
    required String userId,
    required String petId,
  }) async {
    final directory = await _photoDirectory(userId);
    if (!await directory.exists()) {
      return;
    }

    await for (final entity in directory.list()) {
      if (entity is File && _fileStem(entity.path) == petId) {
        await entity.delete();
      }
    }
  }

  Future<Directory> _photoDirectory(String userId) async {
    final root = await getApplicationDocumentsDirectory();
    return Directory(
      '${root.path}${Platform.pathSeparator}pet_photos'
      '${Platform.pathSeparator}$userId',
    );
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

  String _fileStem(String path) {
    final fileName = path.split(RegExp(r'[/\\]')).last;
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex == -1 ? fileName : fileName.substring(0, dotIndex);
  }
}

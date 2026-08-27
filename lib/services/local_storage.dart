import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class LocalStorage {
  LocalStorage._();

  static final instance = LocalStorage._();
  final _imagePicker = ImagePicker();

  Future<String?> chooseVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: false,
    );
    return result?.files.single.path;
  }

  Future<String?> choosePoster() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  Future<Directory> _folder(String name) async {
    final root = await getApplicationDocumentsDirectory();
    final folder = Directory(join(root.path, name));
    if (!folder.existsSync()) await folder.create(recursive: true);
    return folder;
  }

  Future<String> copyVideo(String sourcePath) async {
    final folder = await _folder('videos');
    final extension = extensionOf(sourcePath).isEmpty ? '.mp4' : extensionOf(sourcePath);
    final destination = join(folder.path, 'video_${DateTime.now().microsecondsSinceEpoch}$extension');
    return (await File(sourcePath).copy(destination)).path;
  }

  Future<String> copyPoster(String sourcePath) async {
    final folder = await _folder('posters');
    final extension = extensionOf(sourcePath).isEmpty ? '.jpg' : extensionOf(sourcePath);
    final destination = join(folder.path, 'poster_${DateTime.now().microsecondsSinceEpoch}$extension');
    return (await File(sourcePath).copy(destination)).path;
  }

  Future<String> createThumbnail(String videoPath) async {
    final folder = await _folder('thumbnails');
    final target = join(folder.path, 'thumb_${DateTime.now().microsecondsSinceEpoch}.jpg');
    final result = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: target,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 640,
      quality: 82,
    );
    if (result == null) throw StateError('Could not create a thumbnail');
    return result;
  }
}

String extensionOf(String value) => extension(value).toLowerCase();

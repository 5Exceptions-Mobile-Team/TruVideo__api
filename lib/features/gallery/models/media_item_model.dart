import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'media_item_model.g.dart';

@HiveType(typeId: 1)
class MediaItemModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fileName;

  @HiveField(2)
  String mediaType; // IMAGE, VIDEO, AUDIO, DOCUMENT

  @HiveField(3)
  Uint8List fileBytes;

  @HiveField(4)
  int fileSize;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime modifiedAt;

  MediaItemModel({
    required this.id,
    required this.fileName,
    required this.mediaType,
    required this.fileBytes,
    required this.fileSize,
    required this.createdAt,
    required this.modifiedAt,
  });

  String get fileExtension => fileName.split('.').last.toLowerCase();

  String get displayPath => 'web_media_$id';
}

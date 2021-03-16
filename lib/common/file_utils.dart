import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';

class FileUtils {
  static Future<PickedFile> getImage(
      {ImageSource source = ImageSource.gallery,
      double maxDimension = 300,
      int imageQuality = 69}) async {
    return await ImagePicker().getImage(
        source: source,
        maxHeight: maxDimension,
        maxWidth: maxDimension,
        imageQuality: imageQuality);
  }

  // Calculate dominant color from File
  static Future<Color> getImagePalette(File file) async {
    final paletteGenerator =
    await PaletteGenerator.fromImageProvider(FileImage(file));
    return paletteGenerator.dominantColor.color;
  }

  static Future<Size> getImageSize(File file) async {
    final decoded = await decodeImageFromList(file.readAsBytesSync());
    return Size(decoded.width.toDouble(), decoded.height.toDouble());
  }
}

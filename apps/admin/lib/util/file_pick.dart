import 'package:file_picker/file_picker.dart';

/// A restrictive `accept` filter makes mobile/tablet browsers jump straight
/// into the photo gallery and hide the file manager. Device detection was
/// unreliable for this (iPad Safari and some Android tablets report a desktop
/// user agent), so we simply never restrict the picker: every device gets the
/// full file manager (Files / Downloads / Drive / gallery). Callers validate
/// the extension and size after the pick, so allowing "any" stays safe.
Future<FilePickerResult?> pickUploadFiles({
  required List<String> allowedExtensions,
  bool allowMultiple = false,
}) {
  return FilePicker.platform.pickFiles(
    type: FileType.any,
    allowMultiple: allowMultiple,
    withData: true,
  );
}

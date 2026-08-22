import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// On phones and tablets a restrictive `accept` filter makes the mobile
/// browser jump straight into the photo gallery and hides the file manager.
/// Dropping the filter there lets editors choose Files / Downloads / Drive as
/// well as the gallery. Desktop keeps the extension filter for a tidy native
/// dialog. Callers still validate the extension after the pick, so allowing
/// "any" on mobile stays safe.
bool get _isMobilePlatform =>
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// Wrapper around [FilePicker.pickFiles] that opens the file manager (not just
/// the gallery) on mobile/tablet while keeping a filtered dialog on desktop.
Future<FilePickerResult?> pickUploadFiles({
  required List<String> allowedExtensions,
  bool allowMultiple = false,
}) {
  final mobile = _isMobilePlatform;
  return FilePicker.platform.pickFiles(
    type: mobile ? FileType.any : FileType.custom,
    allowedExtensions: mobile ? null : allowedExtensions,
    allowMultiple: allowMultiple,
    withData: true,
  );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../platform/wallpaper_service.dart';

part 'wallpaper_providers.g.dart';

@Riverpod(keepAlive: true)
WallpaperService wallpaperService(Ref ref) => WallpaperService();

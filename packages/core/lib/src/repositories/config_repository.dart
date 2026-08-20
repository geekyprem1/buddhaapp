import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/app_config.dart';
import '../models/home_layout.dart';
import '../utils/repo_guard.dart';

/// Reads/writes `config/*` (Architecture §6.2, PRD AR-7.1).
class ConfigRepository with RepoGuard {
  ConfigRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _config =>
      _firestore.collection(FirestoreCollections.config);

  DocumentReference<Map<String, dynamic>> get _appConfig =>
      _config.doc(ConfigDocIds.appConfig);

  DocumentReference<Map<String, dynamic>> get _homeLayout =>
      _config.doc(ConfigDocIds.homeLayout);

  AppConfig _fromSnap(DocumentSnapshot<Map<String, dynamic>> snap) {
    if (!snap.exists || snap.data() == null) return const AppConfig();
    return AppConfig.fromJson(snap.data()!);
  }

  HomeLayout _layoutFromSnap(DocumentSnapshot<Map<String, dynamic>> snap) {
    if (!snap.exists || snap.data() == null) return HomeLayout.defaults;
    return HomeLayout.fromJson(snap.data()!);
  }

  Stream<AppConfig> watchAppConfig() {
    return guardedStream(
      'config.watchAppConfig',
      _appConfig.snapshots().map(_fromSnap),
    );
  }

  Future<AppConfig> getAppConfig() {
    return guardedRead(
      'config.getAppConfig',
      () async => _fromSnap(await _appConfig.get()),
    );
  }

  Future<void> saveAppConfig(AppConfig config) {
    return guardedWrite('config.saveAppConfig', () {
      final data = config.toJson();
      data['updatedAt'] = DateTime.now();
      return _appConfig.set(data, SetOptions(merge: true));
    });
  }

  Stream<HomeLayout> watchHomeLayout() {
    return guardedStream(
      'config.watchHomeLayout',
      _homeLayout.snapshots().map(_layoutFromSnap),
    );
  }

  Future<HomeLayout> getHomeLayout() {
    return guardedRead(
      'config.getHomeLayout',
      () async => _layoutFromSnap(await _homeLayout.get()),
    );
  }

  Future<void> saveHomeLayout(HomeLayout layout) {
    return guardedWrite('config.saveHomeLayout', () {
      final data = layout.toJson();
      data['updatedAt'] = DateTime.now();
      return _homeLayout.set(data, SetOptions(merge: true));
    });
  }
}

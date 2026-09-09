import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/app_config.dart';
import '../models/home_layout.dart';
import '../models/premium_config.dart';
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

  DocumentReference<Map<String, dynamic>> get _premium =>
      _config.doc(ConfigDocIds.premium);

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

  PremiumConfig _premiumFromSnap(DocumentSnapshot<Map<String, dynamic>> snap) {
    if (!snap.exists || snap.data() == null) return const PremiumConfig();
    return PremiumConfig.fromJson(snap.data()!);
  }

  Stream<PremiumConfig> watchPremiumConfig() {
    return guardedStream(
      'config.watchPremiumConfig',
      _premium.snapshots().map(_premiumFromSnap),
    );
  }

  Future<PremiumConfig> getPremiumConfig() {
    return guardedRead(
      'config.getPremiumConfig',
      () async => _premiumFromSnap(await _premium.get()),
    );
  }

  Future<void> savePremiumConfig(PremiumConfig config) {
    return guardedWrite('config.savePremiumConfig', () {
      final data = config.toJson();
      data['updatedAt'] = DateTime.now();
      return _premium.set(data, SetOptions(merge: true));
    });
  }
}

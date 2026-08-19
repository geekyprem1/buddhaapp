import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_collections.dart';
import '../models/app_config.dart';
import '../models/home_layout.dart';

/// Reads/writes `config/*` (Architecture §6.2, PRD AR-7.1).
class ConfigRepository {
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
    return _appConfig.snapshots().map(_fromSnap);
  }

  Future<AppConfig> getAppConfig() async {
    return _fromSnap(await _appConfig.get());
  }

  Future<void> saveAppConfig(AppConfig config) {
    final data = config.toJson();
    data['updatedAt'] = DateTime.now();
    return _appConfig.set(data, SetOptions(merge: true));
  }

  Stream<HomeLayout> watchHomeLayout() {
    return _homeLayout.snapshots().map(_layoutFromSnap);
  }

  Future<HomeLayout> getHomeLayout() async {
    return _layoutFromSnap(await _homeLayout.get());
  }

  Future<void> saveHomeLayout(HomeLayout layout) {
    final data = layout.toJson();
    data['updatedAt'] = DateTime.now();
    return _homeLayout.set(data, SetOptions(merge: true));
  }
}

/// Firestore collection and subcollection path constants.
///
/// Centralised so the app and admin panel can never drift on a collection
/// name — a typo here is a compile-time reference error, not a silent
/// runtime bug that shows an empty list.
abstract class FirestoreCollections {
  FirestoreCollections._();

  static const users = 'users';
  static const teachers = 'teachers';
  static const categories = 'categories';

  static const wallpapers = 'wallpapers';
  static const ringtones = 'ringtones';
  static const songs = 'songs';
  static const meditations = 'meditations';
  static const chantings = 'chantings';
  static const statuses = 'statuses';
  static const prarthanas = 'prarthanas';

  static const idCardTemplates = 'idCardTemplates'; // Phase 2
  static const idCards = 'idCards'; // Phase 2

  static const config = 'config';
  static const staticPages = 'staticPages';
  static const notifications = 'notifications';
  static const adminUsers = 'adminUsers';
  static const auditLogs = 'auditLogs';
  static const contactMessages = 'contactMessages';
  static const events = 'events';
  static const deletionRequests = 'deletionRequests';

  // Subcollections of users/{uid}
  static const alarms = 'alarms';
  static const favourites = 'favourites';
  static const progress = 'progress';

  /// All seven content-type collections in one list — used by the generic
  /// content repository and by the admin `ContentTypeConfig` registry.
  static const List<String> contentCollections = [
    wallpapers,
    ringtones,
    songs,
    meditations,
    chantings,
    statuses,
    prarthanas,
  ];
}

/// Well-known document ids inside [FirestoreCollections.config].
abstract class ConfigDocIds {
  ConfigDocIds._();

  static const appConfig = 'app_config';
  static const homeLayout = 'home_layout';
  static const languages = 'languages';
  static const promo = 'promo';
}

/// Well-known document ids (slugs) inside [FirestoreCollections.staticPages].
abstract class StaticPageSlugs {
  StaticPageSlugs._();

  static const about = 'about';
  static const privacy = 'privacy';
  static const terms = 'terms';
  static const contact = 'contact';
  static const help = 'help';

  static const all = <String>[about, privacy, terms, contact, help];

  static String label(String slug) => switch (slug) {
        about => 'About',
        privacy => 'Privacy Policy',
        terms => 'Terms & Conditions',
        contact => 'Contact',
        help => 'Help',
        _ => slug,
      };
}

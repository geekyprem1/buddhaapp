/// English-only admin copy (Architecture §12). One place so screens don't
/// invent their own wording.
abstract class AdminStrings {
  AdminStrings._();

  static const deskName = 'Sangha Desk';
  static const appName = 'Dhamma Path';
  static const loginEyebrow = 'Authorised editors only';
  static const loginTitle = 'Sign in to the desk';
  static const loginBody =
      'Email and password. Phone and Google accounts from the mobile app cannot open this desk.';
  static const emailLabel = 'Email';
  static const passwordLabel = 'Password';
  static const signIn = 'Sign in';
  static const signOut = 'Sign out';
  static const sessionExpired = 'You were signed out after 12 hours idle.';
  static const notAnAdmin =
      'This account is not an admin. The desk is restricted to authorised staff.';
  static const accountInactive = 'This admin account has been deactivated.';
  static const badCredentials = 'Email or password is incorrect.';
  static const tooManyAttempts =
      'Too many attempts. Wait a minute and try again.';
  static const networkError =
      'Network failed. Check your connection and retry.';
  static const genericError = 'Could not sign in. Try again.';
  static const emailRequired = 'Enter your email.';
  static const emailInvalid = 'Enter a valid email.';
  static const passwordRequired = 'Enter your password.';
  static const reauthTitle = 'Confirm it is you';
  static const reauthBody =
      'This action is destructive. Enter your password to continue.';
  static const reauthConfirm = 'Confirm';
  static const cancel = 'Cancel';
  static const confirm = 'Confirm';

  static const dashboard = 'Dashboard';
  static const teachers = 'Teachers';
  static const categories = 'Categories';
  static const wallpapers = 'Wallpapers';
  static const ringtones = 'Ringtones';
  static const songs = 'Songs';
  static const meditations = 'Meditations';
  static const chantings = 'Chanting';
  static const statuses = 'Statuses';
  static const prarthanas = 'Prarthanas';
  static const users = 'Users';
  static const notifications = 'Notifications';
  static const config = 'App config';
  static const pages = 'Static pages';
  static const audit = 'Audit log';
  static const contact = 'Contact inbox';

  static const comingNext =
      'This module is scaffolded. CRUD lands in the next admin sprint.';
  static const kpiPending = 'Metrics arrive once event aggregation ships.';
  static const permissionDenied = 'Your role cannot open this page.';

  static const save = 'Save';
  static const create = 'Create';
  static const addNew = 'New';
  static const delete = 'Delete';
  static const archive = 'Archive';
  static const restore = 'Restore';
  static const publish = 'Publish';
  static const unpublish = 'Unpublish';
  static const search = 'Search';
  static const emptyList = 'Nothing here yet.';
  static const unsavedTitle = 'Discard unsaved changes?';
  static const unsavedBody =
      'If you leave now, edits on this page will be lost.';
  static const discard = 'Discard';
  static const saved = 'Saved.';
  static const deleted = 'Deleted.';
  static const titleRequired = 'Add a title in at least one language.';
  static const licenceHint = 'Licence provenance is required.';
  static const upload = 'Choose file';
  static const uploading = 'Uploading…';
  static const removeFile = 'Remove';
  static const english = 'English';
  static const hindi = 'हिन्दी';
  static const marathi = 'मराठी';
  static const active = 'Active';
  static const inactive = 'Inactive';
  static const featured = 'Featured';
  static const premium = 'Premium';
  static const source = 'Source';
  static const licence = 'Licence';
  static const sortOrder = 'Sort order';
  static const teachersField = 'Teachers';
  static const categoryField = 'Category';
  static const tagsField = 'Tags (comma separated)';
  static const statusField = 'Status';
  static const artistField = 'Artist';
  static const narratorField = 'Narrator';
  static const albumField = 'Album';
  static const lyricsField = 'Lyrics';
  static const durationField = 'Duration (seconds)';
  static const seriesField = 'Series id';
  static const partField = 'Part number';
  static const levelField = 'Level';
  static const orientationField = 'Orientation';
  static const recommendedTimeField = 'Recommended time (HH:MM)';
  static const descriptionField = 'Description';
  static const idCardPrefix = 'ID card prefix';
  static const moduleField = 'Module';
  static const nameField = 'Name';
  static const bioField = 'Bio';
  static const teacherUploadIdRequired =
      'Set an English name or id before uploading files.';
  static const portrait = 'Portrait';
  static const thumbnail = 'Thumbnail';
  static const signature = 'Signature';
  static const media = 'Media';
  static const confirmDeleteTitle = 'Delete this item?';
  static const confirmDeleteBody =
      'This cannot be undone from the desk. Prefer Archive unless you are sure.';
  static const confirmArchiveTitle = 'Archive this item?';
  static const confirmArchiveBody =
      'It will leave every published list in the app within a few seconds.';

  static const clone = 'Clone';
  static const cloned = 'Cloned as a new draft.';
  static const reorderHint =
      'Drag rows to reorder. Sort order updates immediately and clears '
      'when search or a status filter is active.';
  static const bulkUpload = 'Bulk upload';
  static const bulkChooseFiles = 'Choose files';
  static const bulkHint =
      'Pick many files at once. Each becomes a draft with its title taken '
      'from the filename. Thumbnails and durations are generated automatically; '
      'open each item afterwards to set teacher, category, source and licence.';
  static const bulkUploadAll = 'Upload all';
  static const bulkClear = 'Clear finished';
  static const bulkEmpty = 'No files chosen yet.';
  static const bulkQueued = 'Queued';
  static const bulkUploadingLabel = 'Uploading';
  static const bulkDoneLabel = 'Draft created';
  static const bulkFailedLabel = 'Failed';
  static const bulkTooLarge = 'File is larger than the allowed size.';
  static const bulkBadType = 'This file type is not allowed.';
  static const bulkRemove = 'Remove';
  static const bulkInProgress = 'Upload in progress…';

  static const statusLayout = 'Layout editor';
  static const statusLayoutTitle = 'Status layout';
  static const statusLayoutHint =
      'Drag the circle and the name box onto the base image, and drag the '
      'bottom-right handle to resize. Positions are saved as 0–1 coordinates '
      'so the mobile app composes the exact same layout at any resolution.';
  static const statusLayoutOpen = 'Open visual layout editor';
  static const statusLayoutSaveFirst =
      'Save the item once (with a base image) to open the visual layout editor.';
  static const statusSampleName = 'Sample name (preview only)';
  static const statusSamplePhoto = 'Choose sample photo';
  static const statusNoBase = 'Upload a base image first.';
  static const statusNameSize = 'Name size';
  static const statusNameAlign = 'Name alignment';
  static const statusWatermark = 'Show watermark';
  static const statusFestivalDate = 'Festival date (optional)';
  static const statusFestivalNone = 'Not set';

  static const auditEntity = 'Entity type';
  static const auditAllEntities = 'All entities';
  static const auditSearchHint = 'Search actor, id or action';
  static const auditRange = 'Time range';
  static const auditRangeAll = 'All time';
  static const auditRange24h = 'Last 24 hours';
  static const auditRange7d = 'Last 7 days';
  static const auditRange30d = 'Last 30 days';
  static const auditEmpty = 'No audit entries match these filters.';
  static const auditBy = 'by';
  static const auditSystem = 'system';
  static const auditBefore = 'Before';
  static const auditAfter = 'After';
  static const auditNoChange = 'No field-level detail recorded.';
  static const auditRefresh = 'Refresh';

  static const usersSearchHint = 'Search name, phone, email or uid';
  static const usersLanguage = 'Language';
  static const usersAllLanguages = 'All languages';
  static const usersStatus = 'Status';
  static const usersAllStatus = 'All';
  static const usersActiveOnly = 'Active';
  static const usersBlockedOnly = 'Blocked';
  static const usersEmpty = 'No users match these filters.';
  static const usersBlock = 'Block';
  static const usersUnblock = 'Unblock';
  static const usersBlockedBadge = 'Blocked';
  static const usersConfirmBlockTitle = 'Block this user?';
  static const usersConfirmBlockBody =
      'A blocked user is denied by security rules on every read and write, '
      'including signing in again. They keep no access until unblocked.';
  static const usersConfirmUnblockTitle = 'Unblock this user?';
  static const usersConfirmUnblockBody =
      'The user regains normal access immediately.';
  static const usersBlockFailed = 'Could not update this user.';
  static const usersTeachers = 'Teachers';
  static const usersPlatform = 'Platform';
  static const usersJoined = 'Joined';
  static const usersLastActive = 'Last active';
  static const usersNoName = '(no name)';
  static const usersNever = 'Never';
  static const usersExportCsv = 'Export CSV';
  static const usersExportPiiWarning =
      'This downloads every user\'s name, phone, email and device info as a '
      'CSV file. Handle it as sensitive personal data.';
  static const usersExportConfirm = 'Download CSV';
  static const usersExportFailed = 'Could not export users.';
  static const usersDeletionQueue = 'Deletion requests';
  static const usersDeletionEmpty = 'No pending deletion requests.';
  static const usersDeletionExecute = 'Execute deletion';
  static const usersDeletionConfirmTitle = 'Permanently delete this user?';
  static const usersDeletionConfirmBody =
      'This removes the user document, alarms, avatar and sign-in account. '
      'This cannot be undone.';
  static const usersDeletionDone = 'Deletion executed.';
  static const usersDeletionFailed = 'Could not execute this deletion.';
  static const usersDeletionCompleted = 'Completed';
  static const usersDeletionPending = 'Pending';
  static const usersDeletionRequestedAt = 'Requested';

  static const contactSearchHint = 'Search subject, message or uid';
  static const contactAllStatus = 'All';
  static const contactOpenOnly = 'Open';
  static const contactResolvedOnly = 'Resolved';
  static const contactEmpty = 'No contact messages match these filters.';
  static const contactMarkResolved = 'Mark resolved';
  static const contactReopen = 'Reopen';
  static const contactResolvedBadge = 'Resolved';
  static const contactFrom = 'From';
  static const contactActionFailed = 'Could not update this message.';

  static const composeNotification = 'Compose';
  static const saveDraft = 'Save draft';
  static const sendNow = 'Send now';
  static const scheduleSend = 'Schedule';
  static const cancelSchedule = 'Cancel schedule';
  static const sendTest = 'Send test';
  static const topicAccepted = 'Topic accepted';
  static const notifTitle = 'Title';
  static const notifBody = 'Body';
  static const notifImage = 'Image (optional)';
  static const notifAudience = 'Audience';
  static const notifAudienceAll = 'All users';
  static const notifAudienceLanguage = 'Language';
  static const notifAudienceTeacher = 'Teacher';
  static const notifAudiencePlatform = 'Platform';
  static const notifAudienceUser = 'One user';
  static const notifLanguage = 'Language';
  static const notifPlatform = 'Platform';
  static const notifUserId = 'User id';
  static const notifDeepLink = 'Tap target';
  static const notifLinkNone = 'Home';
  static const notifLinkModule = 'Module';
  static const notifLinkRoute = 'Route';
  static const notifLinkUrl = 'URL';
  static const notifRoute = 'App route';
  static const notifUrl = 'External URL';
  static const notifScheduleToggle = 'Schedule for later';
  static const notifScheduleHint =
      'Queued campaigns go out within 5 minutes of the scheduled time.';
  static const notifPickTime = 'Pick date and time';
  static const notifTestSend = 'Test on one device';
  static const notifTestToken = 'Device FCM token';
  static const notifTestTokenHint = 'Paste a token from the device logs.';
  static const notifPreview = 'Phone preview';
  static const notifPreviewPlaceholder = 'Notification body appears here.';
  static const notifTitleRequired = 'Add a title.';
  static const notifBodyRequired = 'Add a body.';
  static const notifAudienceRequired = 'Pick a valid audience.';
  static const notifRouteInvalid = 'Route must start with /.';
  static const notifUrlInvalid = 'Enter an http(s) URL.';
  static const notifScheduleInvalid =
      'Pick a time at least one minute from now.';
  static const notifTestTokenRequired = 'Paste a device token to send a test.';
  static const notifSent = 'Notification sent.';
  static const notifScheduled = 'Notification scheduled.';
  static const notifTestSent = 'Test notification sent.';
  static const notifScheduleCancelled =
      'Schedule cancelled. Campaign is a draft again.';
  static const notifStatsSent = 'Sent';
  static const notifFailed = 'Send failed. Edit and try again.';
  static const notifSending = 'Sending…';
  static const confirmSendTitle = 'Send this notification?';
  static const confirmSendBody = 'It will go to';
  static const confirmScheduleTitle = 'Schedule this notification?';
  static const confirmScheduleBody =
      'The function will send it at the chosen time.';
  static const confirmCancelScheduleTitle = 'Cancel the schedule?';
  static const confirmCancelScheduleBody =
      'The campaign stays as a draft and will not send.';

  static const configVersions = 'Versions';
  static const configMinVersion = 'Minimum supported version';
  static const configLatestVersion = 'Latest version';
  static const configVersionInvalid = 'Versions must look like 1.0.0.';
  static const configGates = 'App gates';
  static const configForceUpdate = 'Force update';
  static const configForceUpdateHint =
      'Blocks every install below the minimum version.';
  static const configForceConfirmTitle = 'Turn on force update?';
  static const configForceConfirmBody =
      'Users below the minimum version will be blocked until they update.';
  static const configForceOnHint =
      'Force update is on. Users below the minimum version are blocked.';
  static const configMaintenance = 'Maintenance mode';
  static const configMaintenanceHint =
      'Shows the maintenance screen to every signed-in user.';
  static const configMaintenanceConfirmTitle = 'Turn on maintenance mode?';
  static const configMaintenanceConfirmBody =
      'The mobile app will show the maintenance message and block the rest of the app.';
  static const configMaintenanceOnHint =
      'Maintenance mode is on for every user.';
  static const configBothGatesOn = 'Force update and maintenance are both on.';
  static const configMaintenanceMessage = 'Maintenance message';
  static const configMaintenanceMessageRequired =
      'Add a maintenance message in at least one language.';
  static const configLanguages = 'Languages';
  static const configLanguageRequired = 'Keep at least one language.';
  static const configLanguageFields = 'Fill code, name and native name.';
  static const configLanguageDuplicate =
      'That language code is already listed.';
  static const configLangCode = 'Code';
  static const configLangName = 'Name';
  static const configLangNative = 'Native name';
  static const configHomeModules = 'Home modules';
  static const configHomeModulesHint =
      'Drag to reorder. Hidden modules leave the home grid immediately.';
  static const configFlags = 'Phase 2 flags';
  static const configFlagsHint =
      'These features are not built yet. Leave them off for launch.';
  static const configAds = 'Ads enabled';
  static const configIdCard = 'ID card enabled';
  static const configLiveWallpaper = 'Live wallpaper enabled';
  static const configUpdatedAt = 'Last saved';
  static const configSaveFailed = 'Could not save.';

  static const pageTitle = 'Title';
  static const pageBody = 'Body';
  static const pageBodyHint =
      'Write the page. Use the buttons for bold, heading, list and links.';
  static const pagePreview = 'Preview';
  static const pagePreviewEmpty = 'Preview appears here.';
  static const pageNotAuthored = 'Not saved yet.';
  static const pageDraft = 'Empty';
  static const pageSaved = 'Saved';
}

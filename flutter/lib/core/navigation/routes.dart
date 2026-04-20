class Routes {
  Routes._();

  static const String feed = '/feed';
  static const String create = '/create';
  static const String liveHub = '/live';
  static const String trips = '/trips';
  static const String profile = '/profile';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String camera = '/camera';

  static const String startup = '/startup';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';

  static const String editor = '/trips/:id/edit';
  static const String liveCapture = '/trips/:id/live';
  static const String placeSearch = '/trips/:id/places/search';
  static const String citySearch = '/trips/:id/cities/search';
  static const String mediaUpload = '/trips/:tripId/places/:placeId/media';
  static const String exportStudio = '/trips/:id/export';
  static const String tripsExports = '/trips/exports';
  static const String tripDetail = '/trip/:id';
  static const String vault = '/vault';

  static String tripDetailPath(String id) => '/trip/$id';
  static String editorPath(String id) => '/trips/$id/edit';
  static String liveCapturePath(String id) => '/trips/$id/live';
  static String liveHubPath() => liveHub;
  static String placeSearchPath(String id) => '/trips/$id/places/search';
  static String citySearchPath(String id) => '/trips/$id/cities/search';
  static String mediaUploadPath(String tripId, String placeId) =>
      '/trips/$tripId/places/$placeId/media';
  static String exportStudioPath(String id) => '/trips/$id/export';
  static String tripsExportsPath() => '/trips/exports';
  static String cameraPath() => camera;
}

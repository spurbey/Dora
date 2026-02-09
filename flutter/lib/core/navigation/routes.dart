class Routes {
  Routes._();

  static const String feed = '/feed';
  static const String create = '/create';
  static const String trips = '/trips';
  static const String profile = '/profile';
  static const String search = '/search';
  static const String settings = '/settings';

  static const String login = '/login';
  static const String signup = '/signup';

  static const String editor = '/trips/:id/edit';
  static const String placeSearch = '/trips/:id/places/search';
  static const String tripDetail = '/trip/:id';

  static String tripDetailPath(String id) => '/trip/$id';
  static String editorPath(String id) => '/trips/$id/edit';
  static String placeSearchPath(String id) => '/trips/$id/places/search';
}

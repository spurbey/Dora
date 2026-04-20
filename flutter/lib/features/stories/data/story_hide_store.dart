import 'package:shared_preferences/shared_preferences.dart';

class StoryHideStore {
  static const _key = 'stories.hidden_ids.v1';

  Future<Set<String>> loadHiddenStoryIds() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_key) ?? const <String>[];
    return values.toSet();
  }

  Future<void> hideStory(String storyId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = (prefs.getStringList(_key) ?? const <String>[]).toSet();
    current.add(storyId);
    await prefs.setStringList(_key, current.toList(growable: false));
  }

  Future<void> clearStory(String storyId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = (prefs.getStringList(_key) ?? const <String>[]).toSet();
    if (current.remove(storyId)) {
      await prefs.setStringList(_key, current.toList(growable: false));
    }
  }
}

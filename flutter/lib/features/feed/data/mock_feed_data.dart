import 'package:dora/features/feed/data/models/public_trip.dart';
import 'package:dora/features/feed/data/models/trip_detail_data.dart';

class MockFeedData {
  static final DateTime _now = DateTime.now();

  static final List<PublicTrip> _trips = [
    _buildTrip(
      id: 'mock-iceland',
      name: 'Iceland Road Trip',
      description: 'Waterfalls, hot springs, and endless roads.',
      coverPhotoUrl:
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
      userId: 'user-iceland',
      placeCount: 12,
      duration: 8,
      tags: ['Adventure', 'Road Trip'],
      createdAt: _now.subtract(const Duration(days: 18)),
    ),
    _buildTrip(
      id: 'mock-tokyo',
      name: 'Tokyo in 3 Days',
      description: 'Street food, neon nights, and hidden temples.',
      coverPhotoUrl:
          'https://images.unsplash.com/photo-1503899036084-c55cdd92da26',
      userId: 'user-tokyo',
      placeCount: 8,
      duration: 3,
      tags: ['Food', 'City'],
      createdAt: _now.subtract(const Duration(days: 9)),
    ),
    _buildTrip(
      id: 'mock-paris',
      name: 'Paris Hidden Gems',
      description: 'Quiet streets, bakeries, and art corners.',
      coverPhotoUrl:
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34',
      userId: 'user-paris',
      placeCount: 10,
      duration: 5,
      tags: ['Culture', 'Relaxed'],
      createdAt: _now.subtract(const Duration(days: 25)),
    ),
    _buildTrip(
      id: 'mock-nyc',
      name: 'NYC Weekend Sprint',
      description: 'Skyline views, coffee runs, and Broadway.',
      coverPhotoUrl:
          'https://images.unsplash.com/photo-1468436139062-f60a71c5c892',
      userId: 'user-nyc',
      placeCount: 7,
      duration: 2,
      tags: ['Weekend', 'City'],
      createdAt: _now.subtract(const Duration(days: 5)),
    ),
    _buildTrip(
      id: 'mock-rome',
      name: 'Rome Classics',
      description: 'Ancient ruins and long dinners.',
      coverPhotoUrl:
          'https://images.unsplash.com/photo-1526481280695-3c687fd643ed',
      userId: 'user-rome',
      placeCount: 9,
      duration: 4,
      tags: ['History', 'Food'],
      createdAt: _now.subtract(const Duration(days: 32)),
    ),
    _buildTrip(
      id: 'mock-lisbon',
      name: 'Lisbon by Tram',
      description: 'Hills, tiles, and golden light.',
      coverPhotoUrl:
          'https://images.unsplash.com/photo-1508057198894-247b23fe5ade',
      userId: 'user-lisbon',
      placeCount: 6,
      duration: 3,
      tags: ['Relaxed', 'Coastal'],
      createdAt: _now.subtract(const Duration(days: 14)),
    ),
    _buildTrip(
      id: 'mock-bali',
      name: 'Bali Slow Travel',
      description: 'Rice terraces and warm mornings.',
      coverPhotoUrl:
          'https://images.unsplash.com/photo-1502082553048-f009c37129b9',
      userId: 'user-bali',
      placeCount: 11,
      duration: 7,
      tags: ['Nature', 'Wellness'],
      createdAt: _now.subtract(const Duration(days: 41)),
    ),
    _buildTrip(
      id: 'mock-oslo',
      name: 'Nordic Light',
      description: 'Minimalist cafes and fjord walks.',
      coverPhotoUrl:
          'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429',
      userId: 'user-oslo',
      placeCount: 5,
      duration: 3,
      tags: ['Calm', 'City'],
      createdAt: _now.subtract(const Duration(days: 21)),
    ),
    _buildTrip(
      id: 'mock-sydney',
      name: 'Sydney Coastal',
      description: 'Beaches, markets, and coastal runs.',
      coverPhotoUrl:
          'https://images.unsplash.com/photo-1506973035872-a4f23f5d3a8b',
      userId: 'user-sydney',
      placeCount: 10,
      duration: 6,
      tags: ['Coastal', 'Outdoors'],
      createdAt: _now.subtract(const Duration(days: 27)),
    ),
    _buildTrip(
      id: 'mock-patagonia',
      name: 'Patagonia Trek',
      description: 'Glaciers, camps, and wide skies.',
      coverPhotoUrl:
          'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
      userId: 'user-patagonia',
      placeCount: 9,
      duration: 9,
      tags: ['Adventure', 'Hiking'],
      createdAt: _now.subtract(const Duration(days: 52)),
    ),
  ];

  static final Map<String, TripDetailData> _details = {
    'mock-iceland': TripDetailData(
      trip: _trips[0],
      places: [
        TripPlace(
          id: 'place-iceland-1',
          name: 'Reykjavik City Center',
          latitude: 64.1466,
          longitude: -21.9426,
          notes: 'Start with coffee and a slow walk.',
          dayNumber: 1,
          orderIndex: 0,
          photoUrls: [
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
          ],
        ),
        TripPlace(
          id: 'place-iceland-2',
          name: 'Gullfoss Waterfall',
          latitude: 64.3271,
          longitude: -20.1218,
          notes: 'Mist and rainbows.',
          dayNumber: 1,
          orderIndex: 2,
          photoUrls: [
            'https://images.unsplash.com/photo-1501785888041-af3ef285b470',
          ],
        ),
      ],
      routes: [
        TripRoute(
          id: 'route-iceland-1',
          transportMode: 'car',
          distance: 65.0,
          duration: 75,
          dayNumber: 1,
        ),
      ],
    ),
    'mock-tokyo': TripDetailData(
      trip: _trips[1],
      places: [
        TripPlace(
          id: 'place-tokyo-1',
          name: 'Shibuya Crossing',
          latitude: 35.6595,
          longitude: 139.7005,
          notes: 'Golden hour photos.',
          dayNumber: 1,
          orderIndex: 0,
        ),
        TripPlace(
          id: 'place-tokyo-2',
          name: 'Tsukiji Outer Market',
          latitude: 35.6652,
          longitude: 139.7708,
          notes: 'Fresh breakfast.',
          dayNumber: 1,
          orderIndex: 1,
        ),
      ],
      routes: [
        TripRoute(
          id: 'route-tokyo-1',
          transportMode: 'walk',
          distance: 2.4,
          duration: 30,
          dayNumber: 1,
        ),
      ],
    ),
  };

  static bool isMockId(String id) => id.startsWith('mock-');

  static List<PublicTrip> getPublicTrips({
    int page = 1,
    int limit = 10,
  }) {
    final start = (page - 1) * limit;
    if (start >= _trips.length) {
      return [];
    }
    final end = (start + limit).clamp(0, _trips.length);
    return _trips.sublist(start, end);
  }

  static List<PublicTrip> searchTrips(String query) {
    final lower = query.toLowerCase();
    return _trips
        .where((trip) =>
            trip.name.toLowerCase().contains(lower) ||
            (trip.description?.toLowerCase().contains(lower) ?? false))
        .toList();
  }

  static TripDetailData? getTripDetail(String id) => _details[id];

  static PublicTrip _buildTrip({
    required String id,
    required String name,
    required String description,
    required String coverPhotoUrl,
    required String userId,
    required int placeCount,
    required int duration,
    required List<String> tags,
    required DateTime createdAt,
  }) {
    return PublicTrip(
      id: id,
      name: name,
      description: description,
      coverPhotoUrl: coverPhotoUrl,
      userId: userId,
      username: 'User-${userId.split('-').last}',
      placeCount: placeCount,
      duration: duration,
      tags: tags,
      visibility: 'public',
      viewCount: 0,
      createdAt: createdAt,
      localUpdatedAt: _now,
      serverUpdatedAt: _now,
      syncStatus: 'synced',
    );
  }
}

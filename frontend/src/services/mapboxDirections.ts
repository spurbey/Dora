import axios from 'axios';

const MAPBOX_API_URL = 'https://api.mapbox.com/directions/v5/mapbox';
const MAPBOX_TOKEN = import.meta.env.VITE_MAPBOX_TOKEN;

export type MapboxProfile = 'driving' | 'walking' | 'cycling';

export interface DirectionsResult {
  geojson: GeoJSON.LineString;
  distance_km: number;
  duration_mins: number;
}

export class MapboxDirectionsService {
  async getRoute(
    coordinates: Array<[number, number]>,
    profile: MapboxProfile = 'driving'
  ): Promise<DirectionsResult> {
    if (!MAPBOX_TOKEN) {
      throw new Error('Mapbox token missing');
    }

    const coords = coordinates.map((c) => `${c[0]},${c[1]}`).join(';');
    const url = `${MAPBOX_API_URL}/${profile}/${coords}`;

    const response = await axios.get(url, {
      params: {
        access_token: MAPBOX_TOKEN,
        geometries: 'geojson',
        overview: 'full',
      },
    });

    const route = response.data?.routes?.[0];
    if (!route?.geometry) {
      throw new Error('No route geometry returned');
    }

    return {
      geojson: route.geometry,
      distance_km: route.distance / 1000,
      duration_mins: Math.round(route.duration / 60),
    };
  }
}

export const mapboxDirections = new MapboxDirectionsService();

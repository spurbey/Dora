import mapboxgl from 'mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';

// Set Mapbox access token from environment
const token = import.meta.env.VITE_MAPBOX_TOKEN;
if (!token) console.error('VITE_MAPBOX_TOKEN is not set');
else mapboxgl.accessToken = token;

export { mapboxgl };

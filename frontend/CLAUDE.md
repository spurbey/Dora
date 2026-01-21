# Frontend Development Rules

## Structure
```
src/
├── main.tsx         # Entry point
├── App.tsx          # Routing
├── components/      # Reusable components
│   ├── ui/         # shadcn/ui components
│   ├── Map/        # Mapbox components
│   ├── Trip/       # Trip-specific
│   └── Place/      # Place-specific
├── pages/           # Route pages
├── hooks/           # Custom hooks
├── services/        # API clients
├── store/           # Zustand stores
├── types/           # TypeScript types
└── utils/           # Helper functions
```

## Patterns

### API Client
```typescript
// services/api.ts
import axios from 'axios';

export const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});
```

### React Query Hook
```typescript
// hooks/useTrips.ts
import { useQuery } from '@tanstack/react-query';

export function useTrips() {
  return useQuery({
    queryKey: ['trips'],
    queryFn: () => api.get('/trips').then(res => res.data)
  });
}
```

### Mapbox Integration
```typescript
// components/Map/MapView.tsx
import Map, { Marker } from 'react-map-gl';
import 'mapbox-gl/dist/mapbox-gl.css';

export function MapView({ places }) {
  return (
    <Map
      mapboxAccessToken={import.meta.env.VITE_MAPBOX_TOKEN}
      style={{ width: '100%', height: '100%' }}
      mapStyle="mapbox://styles/mapbox/streets-v12"
    >
      {places.map(place => (
        <Marker key={place.id} latitude={place.lat} longitude={place.lng} />
      ))}
    </Map>
  );
}
```

## Commands
```bash
# Run dev server
cd frontend && npm run dev

# Build
cd frontend && npm run build

# Type check
cd frontend && npm run type-check

# Lint
cd frontend && npm run lint
```

## Requirements
- Use Mapbox GL JS (NOT Google Maps)
- Use React Query for server state
- Use Zustand for global UI state
- Use Tailwind for styling
- All API calls through api.ts client
- TypeScript strict mode enabled
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
  baseURL: import.meta.env.VITE_API_BASE_URL,
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
import 'mapbox-gl/dist/mapbox-gl.css';
import { mapboxgl } from '@/lib/mapbox';

export function MapView({ places }) {
  const map = new mapboxgl.Map({
    container: 'map',
    style: 'mapbox://styles/mapbox/streets-v12',
  });
}
```

## Environment Variables
```
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_anon_key
VITE_MAPBOX_TOKEN=your_token_here
```

## Type Convention
- Use snake_case for all API-facing interfaces (match backend exactly)

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

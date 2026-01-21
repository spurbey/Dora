---
name: react-page
description: Create React page with Mapbox integration
arguments:
  - name: page_name
    description: Name of page (e.g., TripDetail, Dashboard)
---

# React Page Pattern

## Files to create:

1. Page: `frontend/src/pages/{PageName}.tsx`
2. Components: `frontend/src/components/{Feature}/{Component}.tsx`
3. Hook: `frontend/src/hooks/use{Feature}.ts`
4. Service: `frontend/src/services/{feature}Service.ts`

## Page structure:
```typescript
// pages/TripDetail.tsx
import { useParams } from 'react-router-dom';
import { MapView } from '@/components/Map/MapView';
import { useTrip } from '@/hooks/useTrip';

export function TripDetail() {
  const { id } = useParams();
  const { trip, isLoading } = useTrip(id);
  
  if (isLoading) return <div>Loading...</div>;
  
  return (
    <div className="h-screen">
      <MapView 
        places={trip.places}
        bounds={trip.bounds}
      />
    </div>
  );
}
```

## Hook pattern (React Query):
```typescript
// hooks/useTrip.ts
import { useQuery } from '@tanstack/react-query';
import { tripService } from '@/services/tripService';

export function useTrip(id: string) {
  return useQuery({
    queryKey: ['trip', id],
    queryFn: () => tripService.getById(id)
  });
}
```

## Service pattern:
```typescript
// services/tripService.ts
import { api } from './api';

export const tripService = {
  getById: (id: string) => 
    api.get(`/trips/${id}`).then(res => res.data),
  
  create: (data) => 
    api.post('/trips', data).then(res => res.data)
};
```

## Notes
- Use Mapbox GL JS for maps (not Google Maps)
- Use React Query for server state
- Use Zustand for global UI state
- Use Tailwind for styling
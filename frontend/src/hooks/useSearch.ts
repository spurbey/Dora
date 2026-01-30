import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { searchPlaces } from '@/services/searchService';
import { useDebounce } from './useDebounce';

export interface UseSearchOptions {
  initialLocation?: { lat: number; lng: number };
  radius_km?: number;
  limit?: number;
}

export function useSearch(options: UseSearchOptions = {}) {
  const [query, setQuery] = useState('');
  const [location, setLocation] = useState(
    options.initialLocation || { lat: 48.8566, lng: 2.3522 } // Default to Paris
  );

  const debouncedQuery = useDebounce(query, 300);

  const searchQuery = useQuery({
    queryKey: ['search', debouncedQuery, location.lat, location.lng],
    queryFn: () =>
      searchPlaces({
        query: debouncedQuery,
        lat: location.lat,
        lng: location.lng,
        radius_km: options.radius_km || 5,
        limit: options.limit || 10,
      }),
    enabled: debouncedQuery.length >= 2 && location.lat !== 0,
  });

  return {
    query,
    setQuery,
    location,
    setLocation,
    results: searchQuery.data?.results || [],
    count: searchQuery.data?.count || 0,
    isLoading: searchQuery.isLoading,
    error: searchQuery.error,
  };
}

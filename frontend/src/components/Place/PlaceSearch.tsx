import { useState, useRef, useEffect } from 'react';
import { Search, MapPin, ExternalLink } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Card } from '@/components/ui/card';
import { LoadingSpinner } from '@/components/Shared/LoadingSpinner';
import { cn } from '@/lib/utils';
import { useSearch } from '@/hooks/useSearch';
import type { SearchResult } from '@/types/search';

interface PlaceSearchProps {
  tripId?: string;
  initialLocation?: { lat: number; lng: number };
  onSelectPlace: (result: SearchResult) => void;
  placeholder?: string;
}

export function PlaceSearch({
  initialLocation,
  onSelectPlace,
  placeholder = 'Search for places...',
}: PlaceSearchProps) {
  const [isOpen, setIsOpen] = useState(false);
  const searchRef = useRef<HTMLDivElement>(null);
  const { query, setQuery, results, isLoading, setLocation } = useSearch({
    initialLocation,
    radius_km: 50,
    limit: 10,
  });

  useEffect(() => {
    if (initialLocation) {
      setLocation(initialLocation);
    }
  }, [initialLocation, setLocation]);

  // Close dropdown when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (searchRef.current && !searchRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleSelect = (result: SearchResult) => {
    onSelectPlace(result);
    setQuery('');
    setIsOpen(false);
  };

  const formatDistance = (meters: number): string => {
    if (meters < 1000) {
      return `${Math.round(meters)}m`;
    }
    return `${(meters / 1000).toFixed(1)}km`;
  };

  const showDropdown = isOpen && query.length >= 2;

  return (
    <div ref={searchRef} className="relative w-full">
      <div className="relative">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-white/40" />
        <Input
          type="text"
          value={query}
          onChange={(e) => {
            setQuery(e.target.value);
            setIsOpen(true);
          }}
          onFocus={() => query.length >= 2 && setIsOpen(true)}
          placeholder={placeholder}
          className="pl-10 pr-10 bg-white/5 border-white/10 text-white placeholder:text-white/40"
        />
        {isLoading && (
          <div className="absolute right-3 top-1/2 -translate-y-1/2">
            <LoadingSpinner size="sm" />
          </div>
        )}
      </div>

      {/* Results Dropdown */}
      {showDropdown && (
        <Card className="absolute left-0 right-0 top-full z-50 mt-2 max-h-96 overflow-y-auto border-white/10 bg-slate-900/95 backdrop-blur-sm">
          {results.length === 0 ? (
            <div className="p-4 text-center text-sm text-white/50">
              {isLoading ? 'Searching...' : 'No results found'}
            </div>
          ) : (
            <div className="py-2">
              {results.map((result, index) => (
                <button
                  key={`${result.source}-${result.id || index}`}
                  onClick={() => handleSelect(result)}
                  className="w-full px-4 py-3 text-left transition-colors hover:bg-white/5"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <h4 className="font-medium text-white truncate">{result.name}</h4>
                        {result.source === 'foursquare' && (
                          <ExternalLink className="h-3 w-3 text-white/30 flex-shrink-0" />
                        )}
                      </div>
                      {result.address && (
                        <p className="text-xs text-white/50 truncate">{result.address}</p>
                      )}
                      <div className="flex items-center gap-3 mt-1">
                        <span
                          className={cn(
                            'inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-medium',
                            result.source === 'local'
                              ? 'bg-emerald-500/20 text-emerald-300'
                              : 'bg-blue-500/20 text-blue-300'
                          )}
                        >
                          {result.source === 'local' ? 'Your Places' : 'Foursquare'}
                        </span>
                        <span className="flex items-center gap-1 text-xs text-white/40">
                          <MapPin className="h-3 w-3" />
                          {formatDistance(result.distance_m)} away
                        </span>
                      </div>
                    </div>
                  </div>
                </button>
              ))}
            </div>
          )}
        </Card>
      )}
    </div>
  );
}

import { useState, useRef, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Menu, Search, User, LogOut, Settings, ChevronDown, MapPin, ExternalLink } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card } from '@/components/ui/card';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { LoadingSpinner } from '@/components/Shared/LoadingSpinner';
import { PlaceForm } from '@/components/Place/PlaceForm';
import { useAuthStore } from '@/store/authStore';
import { useUIStore } from '@/store/uiStore';
import { useSearch } from '@/hooks/useSearch';
import { useTrips } from '@/hooks/useTrips';
import { useCreatePlace } from '@/hooks/usePlaces';
import { logout as authLogout } from '@/services/authService';
import { cn } from '@/lib/utils';
import type { SearchResult } from '@/types/search';
import type { PlaceCreate, PlaceUpdate } from '@/types/place';
import type { Trip } from '@/types/trip';

export function Navbar() {
  const navigate = useNavigate();
  const user = useAuthStore((state) => state.user);
  const logout = useAuthStore((state) => state.logout);
  const toggleSidebar = useUIStore((state) => state.toggleSidebar);

  const [isSearchOpen, setIsSearchOpen] = useState(false);
  const [selectedResult, setSelectedResult] = useState<SearchResult | null>(null);
  const [selectedTripId, setSelectedTripId] = useState<string>('');
  const [showTripSelector, setShowTripSelector] = useState(false);
  const [showPlaceForm, setShowPlaceForm] = useState(false);
  const searchRef = useRef<HTMLDivElement>(null);

  const { query, setQuery, results, isLoading } = useSearch();
  const { data: trips = [] } = useTrips();
  const createPlace = useCreatePlace();

  // Close dropdown when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (searchRef.current && !searchRef.current.contains(event.target as Node)) {
        setIsSearchOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleLogout = async () => {
    await authLogout();
    logout();
    navigate('/login');
  };

  const handleSearchResultSelect = (result: SearchResult) => {
    setSelectedResult(result);
    setIsSearchOpen(false);
    setQuery('');

    // If user has trips, show trip selector; otherwise go to create trip first
    if (trips.length > 0) {
      setShowTripSelector(true);
    } else {
      // Navigate to dashboard to create trip first
      navigate('/dashboard');
    }
  };

  const handleTripSelect = (tripId: string) => {
    setSelectedTripId(tripId);
    setShowTripSelector(false);
    setShowPlaceForm(true);
  };

  const handlePlaceFormSubmit = async (data: PlaceCreate | PlaceUpdate) => {
    try {
      // We only handle PlaceCreate from navbar search
      if ('trip_id' in data) {
        await createPlace.mutateAsync(data);
        setShowPlaceForm(false);
        setSelectedResult(null);
        setSelectedTripId('');
        // Navigate to the trip detail page
        navigate(`/trips/${data.trip_id}`);
      }
    } catch (error) {
      console.error('Failed to add place:', error);
    }
  };

  const formatDistance = (meters: number): string => {
    if (meters < 1000) {
      return `${Math.round(meters)}m`;
    }
    return `${(meters / 1000).toFixed(1)}km`;
  };

  const showDropdown = isSearchOpen && query.length >= 2;

  return (
    <header className="fixed left-0 right-0 top-0 z-50 border-b border-white/10 bg-gradient-to-r from-emerald-900 via-teal-900 to-slate-900 shadow-lg">
      <div className="flex h-16 items-center justify-between px-4">
        {/* Left: Menu + Logo */}
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="icon"
            className="text-white/70 hover:bg-white/10 hover:text-white lg:hidden"
            onClick={toggleSidebar}
          >
            <Menu className="h-5 w-5" />
          </Button>
          <Link to="/dashboard" className="flex items-center gap-2">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-emerald-500">
              <span className="text-lg font-bold text-white">T</span>
            </div>
            <span className="hidden text-lg font-semibold text-white sm:block">
              Travel Vault
            </span>
          </Link>
        </div>

        {/* Center: Search */}
        <div ref={searchRef} className="hidden max-w-md flex-1 px-8 md:block">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-white/40" />
            <Input
              type="search"
              placeholder="Search places..."
              value={query}
              onChange={(e) => {
                setQuery(e.target.value);
                setIsSearchOpen(true);
              }}
              onFocus={() => query.length >= 2 && setIsSearchOpen(true)}
              className="w-full border-white/20 bg-white/10 pl-10 pr-10 text-white placeholder:text-white/40 focus:border-emerald-400 focus:ring-emerald-400"
            />
            {isLoading && (
              <div className="absolute right-3 top-1/2 -translate-y-1/2">
                <LoadingSpinner size="sm" />
              </div>
            )}

            {/* Search Results Dropdown */}
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
                        onClick={() => handleSearchResultSelect(result)}
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
        </div>

        {/* Right: User Menu */}
        <div className="flex items-center gap-2">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="ghost"
                className="flex items-center gap-2 text-white/70 hover:bg-white/10 hover:text-white"
              >
                <div className="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-500/30">
                  <User className="h-4 w-4" />
                </div>
                <span className="hidden sm:block">{user?.username ?? 'User'}</span>
                <ChevronDown className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-48">
              <DropdownMenuItem disabled className="text-muted-foreground">
                <User className="mr-2 h-4 w-4" />
                Profile (Phase 5)
              </DropdownMenuItem>
              <DropdownMenuItem disabled className="text-muted-foreground">
                <Settings className="mr-2 h-4 w-4" />
                Settings (Phase 5)
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={handleLogout} className="text-red-500 focus:text-red-500">
                <LogOut className="mr-2 h-4 w-4" />
                Logout
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>

      {/* Trip Selector Dialog */}
      <Dialog open={showTripSelector} onOpenChange={setShowTripSelector}>
        <DialogContent className="bg-slate-900 border-white/10 text-white sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-xl">Add to Trip</DialogTitle>
            <p className="text-sm text-white/60">
              Select which trip to add {selectedResult?.name} to
            </p>
          </DialogHeader>
          <div className="space-y-2 max-h-96 overflow-y-auto">
            {trips.map((trip: Trip) => (
              <button
                key={trip.id}
                onClick={() => handleTripSelect(trip.id)}
                className="w-full rounded-lg border border-white/10 bg-white/5 p-4 text-left transition-colors hover:border-emerald-500/30 hover:bg-white/10"
              >
                <h4 className="font-semibold text-white">{trip.title}</h4>
                {trip.description && (
                  <p className="mt-1 text-sm text-white/60 line-clamp-1">{trip.description}</p>
                )}
              </button>
            ))}
          </div>
        </DialogContent>
      </Dialog>

      {/* Place Form Modal */}
      {selectedResult && selectedTripId && (
        <PlaceForm
          tripId={selectedTripId}
          initialData={selectedResult}
          isOpen={showPlaceForm}
          onClose={() => {
            setShowPlaceForm(false);
            setSelectedResult(null);
            setSelectedTripId('');
          }}
          onSubmit={handlePlaceFormSubmit}
          isLoading={createPlace.isPending}
        />
      )}
    </header>
  );
}

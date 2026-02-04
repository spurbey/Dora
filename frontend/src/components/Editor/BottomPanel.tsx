import { useEffect, useState } from 'react';
import { ChevronDown } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { useEditorStore } from '@/store/editorStore';
import { useRouteMetadata } from '@/hooks/useRouteMetadata';
import { usePlaceMetadata } from '@/hooks/usePlaceMetadata';
import { RouteMetadataForm } from '@/components/Editor/RouteMetadataForm';
import { PlaceMetadataForm } from '@/components/Editor/PlaceMetadataForm';
import { cn } from '@/lib/utils';

export function BottomPanel() {
  const {
    bottomPanelOpen,
    setBottomPanelOpen,
    selectedItem,
    selectedRoute,
    setSelectedItem,
    waypoints,
    places,
    trip,
    tripMetadata,
    placeMetadata: placeMetadataById,
    routeMetadata,
    setRouteMetadata,
  } = useEditorStore();
  const [tab, setTab] = useState('details');

  const routeId = selectedRoute?.id ?? '';
  const { data: metadataData } = useRouteMetadata(routeId);
  const selectedPlace =
    selectedItem?.type === 'place' ? places.find((item) => item.id === selectedItem.id) : null;
  const placeId = selectedPlace?.id ?? '';
  const {
    data: placeMetadataData,
    saveMetadata: savePlaceMetadata,
    isSaving: isSavingPlace,
  } = usePlaceMetadata(placeId);

  useEffect(() => {
    if (selectedItem) {
      setBottomPanelOpen(true);
    } else {
      setBottomPanelOpen(false);
    }
  }, [selectedItem, setBottomPanelOpen]);

  useEffect(() => {
    if (routeId && metadataData) {
      setRouteMetadata(routeId, metadataData);
    }
  }, [metadataData, routeId, setRouteMetadata]);

  const activeTab = selectedItem?.type === 'place' ? 'details' : tab;
  const metadata = routeId ? routeMetadata[routeId] ?? metadataData ?? null : null;
  const waypointCount = selectedRoute ? waypoints[selectedRoute.id]?.length ?? 0 : 0;
  const selectedPlaceMetadata = placeId
    ? placeMetadataById[placeId] ?? placeMetadataData ?? null
    : null;
  const tripIsPublic = trip?.visibility === 'public' && (tripMetadata?.is_discoverable ?? false);
  const formKey = selectedRoute ? `${selectedRoute.id}-${metadata?.updated_at ?? 'new'}` : 'route-form';

  return (
    <div
      className={cn(
        'fixed bottom-0 left-0 right-0 z-20 border-t border-white/10 bg-slate-950/85 backdrop-blur',
        bottomPanelOpen ? 'h-[40vh]' : 'h-12'
      )}
    >
      <div className="mx-auto flex h-full max-w-6xl flex-col px-4">
        <div className="flex items-center justify-between py-2">
          <div className="flex items-center gap-2 text-xs text-white/60">
            <span className="h-2 w-2 rounded-full bg-emerald-400" />
            {selectedItem?.type === 'route'
              ? `Route: ${selectedRoute?.name ?? 'Untitled'}`
              : selectedItem?.type === 'place'
                ? `Place: ${selectedPlace?.name ?? 'Untitled'}`
                : 'Component Details'}
          </div>
          <div className="flex items-center gap-2">
            {selectedItem && (
              <Button
                variant="ghost"
                size="sm"
                className="text-white/60 hover:bg-white/10"
                onClick={() => setSelectedItem(null)}
              >
                Close
              </Button>
            )}
            <Button
              variant="ghost"
              size="icon"
              className="text-white/60 hover:bg-white/10"
              onClick={() => setBottomPanelOpen(!bottomPanelOpen)}
            >
              <ChevronDown
                className={cn('h-4 w-4 transition-transform', bottomPanelOpen && 'rotate-180')}
              />
            </Button>
          </div>
        </div>

        {bottomPanelOpen && (
          <div className="flex-1 pb-4">
            {!selectedItem ? (
              <div className="rounded-xl border border-white/10 bg-white/5 p-3 text-sm text-white/70">
                Select a place or route to view details.
              </div>
            ) : (
              <Tabs value={activeTab} onValueChange={setTab} className="h-full">
                <TabsList className="bg-white/10 text-white/70">
                  <TabsTrigger value="details">Details</TabsTrigger>
                  {selectedItem.type === 'route' && (
                    <TabsTrigger value="metadata">Metadata</TabsTrigger>
                  )}
                  {selectedItem.type === 'place' && (
                    <TabsTrigger value="metadata">Metadata</TabsTrigger>
                  )}
                </TabsList>
                <TabsContent value="details" className="mt-4 space-y-3 text-sm text-white/70">
                  {selectedItem.type === 'route' && selectedRoute ? (
                    <div className="grid gap-3 sm:grid-cols-3">
                      <div className="rounded-xl border border-white/10 bg-white/5 p-3">
                        <p className="text-xs text-white/50">Distance</p>
                        <p className="text-lg text-white">
                          {selectedRoute.distance_km ? `${selectedRoute.distance_km.toFixed(1)} km` : 'N/A'}
                        </p>
                      </div>
                      <div className="rounded-xl border border-white/10 bg-white/5 p-3">
                        <p className="text-xs text-white/50">Duration</p>
                        <p className="text-lg text-white">
                          {selectedRoute.duration_mins ? `${selectedRoute.duration_mins} mins` : 'N/A'}
                        </p>
                      </div>
                      <div className="rounded-xl border border-white/10 bg-white/5 p-3">
                        <p className="text-xs text-white/50">Waypoints</p>
                        <p className="text-lg text-white">{waypointCount}</p>
                      </div>
                    </div>
                  ) : selectedPlace ? (
                    <div className="space-y-3">
                      <div className="rounded-xl border border-white/10 bg-white/5 p-3">
                        <p className="text-xs text-white/50">Place type</p>
                        <p className="text-lg text-white">{selectedPlace.place_type ?? 'Place'}</p>
                      </div>
                      <div className="grid gap-3 sm:grid-cols-2">
                        <div className="rounded-xl border border-white/10 bg-white/5 p-3">
                          <p className="text-xs text-white/50">Latitude</p>
                          <p className="text-lg text-white">{selectedPlace.lat.toFixed(4)}</p>
                        </div>
                        <div className="rounded-xl border border-white/10 bg-white/5 p-3">
                          <p className="text-xs text-white/50">Longitude</p>
                          <p className="text-lg text-white">{selectedPlace.lng.toFixed(4)}</p>
                        </div>
                      </div>
                      <div className="rounded-xl border border-white/10 bg-white/5 p-3">
                        <p className="text-xs text-white/50">Notes</p>
                        <p className="text-sm text-white/80">
                          {selectedPlace.user_notes || 'No notes yet.'}
                        </p>
                      </div>
                    </div>
                  ) : null}
                </TabsContent>
                {selectedItem.type === 'route' && selectedRoute && (
                  <TabsContent value="metadata" className="mt-4">
                    <RouteMetadataForm
                      key={formKey}
                      route={selectedRoute}
                      metadata={metadata}
                      onSaved={(saved) => setRouteMetadata(selectedRoute.id, saved)}
                      onCancel={() => setSelectedItem(null)}
                      tripIsPublic={tripIsPublic}
                    />
                  </TabsContent>
                )}
                {selectedItem.type === 'place' && selectedPlace && (
                  <TabsContent value="metadata" className="mt-4">
                    <PlaceMetadataForm
                      metadata={selectedPlaceMetadata}
                      isSaving={isSavingPlace}
                      tripIsPublic={tripIsPublic}
                      onSave={async (payload) => {
                        await savePlaceMetadata(payload);
                      }}
                      onCancel={() => setSelectedItem(null)}
                    />
                  </TabsContent>
                )}
              </Tabs>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

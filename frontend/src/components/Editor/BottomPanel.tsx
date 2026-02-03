import { useEffect, useState } from 'react';
import { ChevronDown } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { useEditorStore } from '@/store/editorStore';
import { useRouteMetadata } from '@/hooks/useRouteMetadata';
import { RouteMetadataForm } from '@/components/Editor/RouteMetadataForm';
import { cn } from '@/lib/utils';

export function BottomPanel() {
  const {
    bottomPanelOpen,
    setBottomPanelOpen,
    selectedRoute,
    setSelectedRoute,
    waypoints,
    routeMetadata,
    setRouteMetadata,
  } = useEditorStore();
  const [tab, setTab] = useState('details');

  const routeId = selectedRoute?.id ?? '';
  const { data: metadataData } = useRouteMetadata(routeId);

  useEffect(() => {
    if (selectedRoute) {
      setBottomPanelOpen(true);
    } else {
      setBottomPanelOpen(false);
    }
  }, [selectedRoute, setBottomPanelOpen]);

  useEffect(() => {
    if (routeId && metadataData) {
      setRouteMetadata(routeId, metadataData);
    }
  }, [metadataData, routeId, setRouteMetadata]);

  const metadata = routeId ? routeMetadata[routeId] ?? metadataData ?? null : null;
  const waypointCount = selectedRoute ? waypoints[selectedRoute.id]?.length ?? 0 : 0;
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
            {selectedRoute ? `Route: ${selectedRoute.name ?? 'Untitled'}` : 'Route Metadata'}
          </div>
          <div className="flex items-center gap-2">
            {selectedRoute && (
              <Button
                variant="ghost"
                size="sm"
                className="text-white/60 hover:bg-white/10"
                onClick={() => setSelectedRoute(null)}
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
            {!selectedRoute ? (
              <div className="rounded-xl border border-white/10 bg-white/5 p-3 text-sm text-white/70">
                Select a route to view metadata.
              </div>
            ) : (
              <Tabs value={tab} onValueChange={setTab} className="h-full">
                <TabsList className="bg-white/10 text-white/70">
                  <TabsTrigger value="details">Details</TabsTrigger>
                  <TabsTrigger value="metadata">Metadata</TabsTrigger>
                </TabsList>
                <TabsContent value="details" className="mt-4 space-y-3 text-sm text-white/70">
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
                </TabsContent>
                <TabsContent value="metadata" className="mt-4">
                  <RouteMetadataForm
                    key={formKey}
                    route={selectedRoute}
                    metadata={metadata}
                    onSaved={(saved) => setRouteMetadata(selectedRoute.id, saved)}
                    onCancel={() => setSelectedRoute(null)}
                  />
                </TabsContent>
              </Tabs>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

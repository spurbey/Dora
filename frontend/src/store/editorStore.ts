import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import type { Trip } from '@/types/trip';
import type { Place } from '@/types/place';
import type { Route, TempRoute } from '@/types/route';
import type { TempWaypoint, Waypoint } from '@/types/waypoint';
import type { RouteMetadata } from '@/types/routeMetadata';
import { getTrip } from '@/services/tripService';

export interface TimelineItem {
  type: 'place' | 'route';
  id: string;
  order: number;
  name?: string;
}

export interface MapViewport {
  lat: number;
  lng: number;
  zoom: number;
}

interface EditorState {
  // Trip Data
  trip: Trip | null;
  places: Place[];
  routes: Route[];
  waypoints: Record<string, Waypoint[]>;
  routeMetadata: Record<string, RouteMetadata>;
  timeline: TimelineItem[];

  // UI State
  selectedItem: { type: 'place' | 'route' | 'waypoint'; id: string } | null;
  selectedRoute: Route | null;
  editMode: 'view' | 'add-place' | 'draw-route' | 'add-waypoint';
  mapViewport: MapViewport;
  bottomPanelOpen: boolean;
  tempRoute: TempRoute | null;
  drawingTransportMode: 'car' | 'bike' | 'foot';
  tempWaypoint: TempWaypoint | null;

  // Unsaved Changes
  hasUnsavedChanges: boolean;
  isDirty: boolean;
  autoSaveEnabled: boolean;
  lastSavedAt: Date | null;

  // Actions
  loadTrip: (tripId: string) => Promise<void>;
  setTrip: (trip: Trip) => void;
  setPlaces: (places: Place[]) => void;
  setRoutes: (routes: Route[]) => void;
  setWaypoints: (routeId: string, waypoints: Waypoint[]) => void;
  addPlace: (place: Place) => void;
  addRoute: (route: Route) => void;
  updateItem: (type: 'place' | 'route', id: string, data: Partial<Place | Route>) => void;
  deleteItem: (type: 'place' | 'route', id: string) => void;
  reorderTimeline: (newOrder: TimelineItem[]) => void;
  setTimeline: (items: TimelineItem[]) => void;
  selectItem: (type: 'place' | 'route' | 'waypoint', id: string) => void;
  setSelectedRoute: (route: Route | null) => void;
  setRouteMetadata: (routeId: string, metadata: RouteMetadata) => void;
  setEditMode: (mode: EditorState['editMode']) => void;
  setBottomPanelOpen: (open: boolean) => void;
  setTempRoute: (route: TempRoute | null) => void;
  setDrawingTransportMode: (mode: 'car' | 'bike' | 'foot') => void;
  setTempWaypoint: (waypoint: TempWaypoint | null) => void;
  addWaypoint: (waypoint: Waypoint) => void;
  updateWaypoint: (waypoint: Waypoint) => void;
  removeWaypoint: (routeId: string, waypointId: string) => void;
  markSaved: () => void;
  setMapViewport: (viewport: MapViewport) => void;
}

const defaultViewport: MapViewport = {
  lat: 20.5937,
  lng: 78.9629,
  zoom: 4,
};

export const useEditorStore = create<EditorState>()(
  devtools(
    immer((set) => ({
      // Trip data
      trip: null,
      places: [],
      routes: [],
      waypoints: {},
      routeMetadata: {},
      timeline: [],

      // UI state
      selectedItem: null,
      selectedRoute: null,
      editMode: 'view',
      mapViewport: defaultViewport,
      bottomPanelOpen: true,
      tempRoute: null,
      drawingTransportMode: 'car',
      tempWaypoint: null,

      // Unsaved changes
      hasUnsavedChanges: false,
      isDirty: false,
      autoSaveEnabled: true,
      lastSavedAt: null,

      // Actions
      loadTrip: async (tripId: string) => {
        const trip = await getTrip(tripId);
        set((state) => {
          state.trip = trip;
          state.hasUnsavedChanges = false;
          state.isDirty = false;
        });
      },

      setTrip: (trip) => {
        set((state) => {
          state.trip = trip;
        });
      },

      setPlaces: (places) => {
        set((state) => {
          state.places = places;
        });
      },

      setRoutes: (routes) => {
        set((state) => {
          state.routes = routes;
        });
      },

      setWaypoints: (routeId, waypoints) => {
        set((state) => {
          state.waypoints[routeId] = waypoints;
        });
      },

      addPlace: (place) => {
        set((state) => {
          state.places.push(place);
          state.hasUnsavedChanges = true;
          state.isDirty = true;
        });
      },

      addRoute: (route) => {
        set((state) => {
          state.routes.push(route);
          state.hasUnsavedChanges = true;
          state.isDirty = true;
        });
      },

      updateItem: (type, id, data) => {
        set((state) => {
          if (type === 'place') {
            state.places = state.places.map((place: Place) =>
              place.id === id ? { ...place, ...data } as Place : place
            );
          } else {
            state.routes = state.routes.map((route: Route) =>
              route.id === id ? { ...route, ...data } as Route : route
            );
          }
          state.hasUnsavedChanges = true;
          state.isDirty = true;
        });
      },

      deleteItem: (type, id) => {
        set((state) => {
          if (type === 'place') {
            state.places = state.places.filter((place: Place) => place.id !== id);
          } else {
            state.routes = state.routes.filter((route: Route) => route.id !== id);
          }
          state.hasUnsavedChanges = true;
          state.isDirty = true;
        });
      },

      reorderTimeline: (newOrder) => {
        set((state) => {
          state.timeline = newOrder;
          state.hasUnsavedChanges = true;
          state.isDirty = true;
        });
      },

      setTimeline: (items) => {
        set((state) => {
          state.timeline = items;
        });
      },

      selectItem: (type, id) => {
        set((state) => {
          state.selectedItem = { type, id };
        });
      },

      setSelectedRoute: (route) => {
        set((state) => {
          state.selectedRoute = route;
        });
      },

      setRouteMetadata: (routeId, metadata) => {
        set((state) => {
          state.routeMetadata[routeId] = metadata;
        });
      },

      setEditMode: (mode) => {
        set((state) => {
          state.editMode = mode;
        });
      },

      setBottomPanelOpen: (open) => {
        set((state) => {
          state.bottomPanelOpen = open;
        });
      },

      setTempRoute: (route) => {
        set((state) => {
          state.tempRoute = route;
        });
      },

      setDrawingTransportMode: (mode) => {
        set((state) => {
          state.drawingTransportMode = mode;
        });
      },

      setTempWaypoint: (waypoint) => {
        set((state) => {
          state.tempWaypoint = waypoint;
        });
      },

      addWaypoint: (waypoint) => {
        set((state) => {
          if (!state.waypoints[waypoint.route_id]) {
            state.waypoints[waypoint.route_id] = [];
          }
          state.waypoints[waypoint.route_id].push(waypoint);
        });
      },

      updateWaypoint: (waypoint) => {
        set((state) => {
          const routeWaypoints = state.waypoints[waypoint.route_id];
          if (!routeWaypoints) return;
          const index = routeWaypoints.findIndex((item) => item.id === waypoint.id);
          if (index >= 0) {
            routeWaypoints[index] = waypoint;
          }
        });
      },

      removeWaypoint: (routeId, waypointId) => {
        set((state) => {
          state.waypoints[routeId] = (state.waypoints[routeId] || []).filter(
            (item) => item.id !== waypointId
          );
        });
      },

      markSaved: () => {
        set((state) => {
          state.hasUnsavedChanges = false;
          state.isDirty = false;
          state.lastSavedAt = new Date();
        });
      },

      setMapViewport: (viewport) => {
        set((state) => {
          state.mapViewport = viewport;
        });
      },
    })),
    { name: 'editor-store' }
  )
);

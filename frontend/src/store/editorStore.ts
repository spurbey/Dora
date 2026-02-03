import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import type { Trip } from '@/types/trip';
import type { Place } from '@/types/place';
import type { Route } from '@/types/route';
import type { Waypoint } from '@/types/waypoint';
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
  waypoints: Waypoint[];
  timeline: TimelineItem[];

  // UI State
  selectedItem: { type: 'place' | 'route' | 'waypoint'; id: string } | null;
  editMode: 'view' | 'add-place' | 'draw-route' | 'add-waypoint';
  mapViewport: MapViewport;
  bottomPanelOpen: boolean;

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
  setWaypoints: (waypoints: Waypoint[]) => void;
  addPlace: (place: Place) => void;
  addRoute: (route: Route) => void;
  updateItem: (type: 'place' | 'route', id: string, data: Partial<Place | Route>) => void;
  deleteItem: (type: 'place' | 'route', id: string) => void;
  reorderTimeline: (newOrder: TimelineItem[]) => void;
  setTimeline: (items: TimelineItem[]) => void;
  selectItem: (type: 'place' | 'route' | 'waypoint', id: string) => void;
  setEditMode: (mode: EditorState['editMode']) => void;
  setBottomPanelOpen: (open: boolean) => void;
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
      waypoints: [],
      timeline: [],

      // UI state
      selectedItem: null,
      editMode: 'view',
      mapViewport: defaultViewport,
      bottomPanelOpen: true,

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

      setWaypoints: (waypoints) => {
        set((state) => {
          state.waypoints = waypoints;
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

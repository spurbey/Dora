import { create } from 'zustand';
import type { Trip } from '@/types/trip';

interface TripState {
  trips: Trip[];
  currentTrip: Trip | null;
  isLoading: boolean;

  setTrips: (trips: Trip[]) => void;
  setCurrentTrip: (trip: Trip | null) => void;
  addTrip: (trip: Trip) => void;
  updateTrip: (id: string, trip: Trip) => void;
  removeTrip: (id: string) => void;
  setLoading: (loading: boolean) => void;
}

export const useTripStore = create<TripState>((set) => ({
  trips: [],
  currentTrip: null,
  isLoading: false,

  setTrips: (trips) => set({ trips }),

  setCurrentTrip: (trip) => set({ currentTrip: trip }),

  addTrip: (trip) =>
    set((state) => ({
      trips: [trip, ...state.trips],
    })),

  updateTrip: (id, updatedTrip) =>
    set((state) => ({
      trips: state.trips.map((trip) => (trip.id === id ? updatedTrip : trip)),
      currentTrip: state.currentTrip?.id === id ? updatedTrip : state.currentTrip,
    })),

  removeTrip: (id) =>
    set((state) => ({
      trips: state.trips.filter((trip) => trip.id !== id),
      currentTrip: state.currentTrip?.id === id ? null : state.currentTrip,
    })),

  setLoading: (isLoading) => set({ isLoading }),
}));

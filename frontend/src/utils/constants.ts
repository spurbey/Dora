export const API_ENDPOINTS = {
  AUTH: {
    ME: '/auth/me',
  },
  TRIPS: {
    LIST: '/trips',
    CREATE: '/trips',
    DETAIL: (id: string) => `/trips/${id}`,
    UPDATE: (id: string) => `/trips/${id}`,
    DELETE: (id: string) => `/trips/${id}`,
  },
  PLACES: {
    LIST: '/places',
    CREATE: '/places',
    DETAIL: (id: string) => `/places/${id}`,
    UPDATE: (id: string) => `/places/${id}`,
    DELETE: (id: string) => `/places/${id}`,
  },
  SEARCH: {
    PLACES: '/search/places',
  },
  MEDIA: {
    UPLOAD: '/media/upload',
    DETAIL: (id: string) => `/media/${id}`,
    DELETE: (id: string) => `/media/${id}`,
  },
  ROUTES: {
    LIST: (tripId: string) => `/trips/${tripId}/routes`,
    CREATE: (tripId: string) => `/trips/${tripId}/routes`,
    DETAIL: (id: string) => `/routes/${id}`,
    UPDATE: (id: string) => `/routes/${id}`,
    DELETE: (id: string) => `/routes/${id}`,
  },
  COMPONENTS: {
    LIST: (tripId: string) => `/trips/${tripId}/components`,
    DETAIL: (tripId: string, componentId: string) =>
      `/trips/${tripId}/components/${componentId}`,
    REORDER: (tripId: string) => `/trips/${tripId}/components/reorder`,
  },
};

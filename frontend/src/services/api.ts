import axios, { AxiosError } from 'axios';
import type { AxiosInstance, AxiosRequestConfig, InternalAxiosRequestConfig } from 'axios';
import { supabase } from '@/lib/supabase';

const apiClient: AxiosInstance = axios.create({
  baseURL: import.meta.env.VITE_API_BASE_URL,
});

apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

let isRefreshing = false;
let failedQueue: Array<{
  resolve: (value?: unknown) => void;
  reject: (reason?: unknown) => void;
}> = [];

const processQueue = (error: Error | null = null) => {
  failedQueue.forEach((prom) => {
    if (error) {
      prom.reject(error);
    } else {
      prom.resolve();
    }
  });
  failedQueue = [];
};

apiClient.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const originalRequest = error.config as InternalAxiosRequestConfig & { _retry?: boolean };
    const status = error.response?.status;

    if (status === 401 && !originalRequest._retry) {
      if (isRefreshing) {
        // Wait for the token refresh to complete
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject });
        })
          .then(() => {
            const token = localStorage.getItem('token');
            if (token && originalRequest.headers) {
              originalRequest.headers.Authorization = `Bearer ${token}`;
            }
            return apiClient(originalRequest);
          })
          .catch((err) => Promise.reject(err));
      }

      originalRequest._retry = true;
      isRefreshing = true;

      try {
        // Try to refresh the session using Supabase
        const { data, error: refreshError } = await supabase.auth.refreshSession();

        if (refreshError || !data.session) {
          throw new Error('Session refresh failed');
        }

        const newToken = data.session.access_token;
        localStorage.setItem('token', newToken);

        // Update the authorization header
        if (originalRequest.headers) {
          originalRequest.headers.Authorization = `Bearer ${newToken}`;
        }

        processQueue();
        isRefreshing = false;

        // Retry the original request with the new token
        return apiClient(originalRequest);
      } catch (refreshError) {
        // Session refresh failed - user needs to login again
        processQueue(new Error('Session expired'));
        isRefreshing = false;
        localStorage.removeItem('token');

        if (window.location.pathname !== '/login') {
          window.location.assign('/login');
        }
        return Promise.reject(refreshError);
      }
    }

    const message =
      (error.response?.data as { detail?: string } | undefined)?.detail ??
      error.message ??
      'Unexpected error';
    return Promise.reject(new Error(message));
  },
);

export const api = {
  get: async <T>(url: string, config?: AxiosRequestConfig) => {
    const response = await apiClient.get<T>(url, config);
    return response.data;
  },
  post: async <T, D = unknown>(url: string, data?: D, config?: AxiosRequestConfig) => {
    const response = await apiClient.post<T>(url, data, config);
    return response.data;
  },
  patch: async <T, D = unknown>(url: string, data?: D, config?: AxiosRequestConfig) => {
    const response = await apiClient.patch<T>(url, data, config);
    return response.data;
  },
  delete: async <T>(url: string, config?: AxiosRequestConfig) => {
    const response = await apiClient.delete<T>(url, config);
    return response.data;
  },
};

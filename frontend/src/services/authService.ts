import { api } from '@/services/api';
import { API_ENDPOINTS } from '@/utils/constants';
import { supabase } from '@/lib/supabase';
import type { AuthSession, MeResponse, User } from '@/types/user';

async function fetchMe(token?: string): Promise<User> {
  const headers = token ? { Authorization: `Bearer ${token}` } : undefined;
  const response = await api.get<MeResponse>(API_ENDPOINTS.AUTH.ME, { headers });
  return response.user;
}

export async function login(email: string, password: string): Promise<AuthSession> {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    throw new Error(error.message);
  }

  if (!data.session) {
    throw new Error('No session returned from Supabase');
  }

  const token = data.session.access_token;
  localStorage.setItem('token', token);

  const user = await fetchMe(token);

  return {
    user,
    token,
  };
}

export async function register(
  email: string,
  username: string,
  password: string,
): Promise<AuthSession> {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: { username },
    },
  });

  if (error) {
    throw new Error(error.message);
  }

  if (!data.session) {
    return {
      user: null,
      token: null,
      requires_email_confirmation: true,
    };
  }

  const token = data.session.access_token;
  localStorage.setItem('token', token);

  const user = await fetchMe(token);

  return {
    user,
    token,
  };
}

export async function getCurrentUser(): Promise<User> {
  const token = localStorage.getItem('token') ?? undefined;
  return fetchMe(token);
}

export async function logout(): Promise<void> {
  try {
    await supabase.auth.signOut();
  } finally {
    localStorage.removeItem('token');
  }
}

export function getToken(): string | null {
  return localStorage.getItem('token');
}

export function setToken(token: string): void {
  localStorage.setItem('token', token);
}

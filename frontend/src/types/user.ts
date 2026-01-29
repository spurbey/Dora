export interface User {
  id: string;
  email: string;
  username: string;
  full_name?: string | null;
  avatar_url?: string | null;
  bio?: string | null;
  is_premium: boolean;
  is_verified: boolean;
  created_at: string;
}

export interface MeResponse {
  user: User;
  trip_count: number;
  place_count: number;
}

export interface AuthSession {
  user: User | null;
  token: string | null;
  requires_email_confirmation?: boolean;
}

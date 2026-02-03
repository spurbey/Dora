import { useEffect } from 'react';
import { Navigate, Route, Routes } from 'react-router-dom';
import { Login } from '@/pages/Login';
import { Register } from '@/pages/Register';
import { Dashboard } from '@/pages/Dashboard';
import { TripDetail } from '@/pages/TripDetail';
import { TripEditor } from '@/pages/TripEditor';
import { ProtectedRoute } from '@/components/Auth/ProtectedRoute';
import { FEATURES } from '@/utils/features';
import { supabase } from '@/lib/supabase';

export default function App() {
  useEffect(() => {
    // Listen for auth state changes and sync token with localStorage
    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.access_token) {
        localStorage.setItem('token', session.access_token);
      } else {
        localStorage.removeItem('token');
      }
    });

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />

      <Route element={<ProtectedRoute />}>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/trips/:id" element={<TripDetail />} />
        {FEATURES.EDITOR && <Route path="/trips/:id/edit" element={<TripEditor />} />}
      </Route>

      <Route path="/" element={<Navigate to="/dashboard" />} />
      <Route path="*" element={<Navigate to="/dashboard" />} />
    </Routes>
  );
}

import { Navigate, Route, Routes } from 'react-router-dom';
import { Login } from '@/pages/Login';
import { Register } from '@/pages/Register';
import { Dashboard } from '@/pages/Dashboard';
import { TripDetail } from '@/pages/TripDetail';
import { TripEditor } from '@/pages/TripEditor';
import { ProtectedRoute } from '@/components/Auth/ProtectedRoute';
import { FEATURES } from '@/utils/features';

export default function App() {
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

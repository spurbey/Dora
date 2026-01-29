import { useEffect, useRef, useReducer } from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuthStore } from '@/store/authStore';
import { Spinner } from '@/components/Shared/Spinner';
import { getCurrentUser } from '@/services/authService';

type AuthCheckState = {
  isHydrated: boolean;
  isCheckingUser: boolean;
};

type AuthCheckAction =
  | { type: 'HYDRATED' }
  | { type: 'CHECK_START' }
  | { type: 'CHECK_END' };

function authCheckReducer(state: AuthCheckState, action: AuthCheckAction): AuthCheckState {
  switch (action.type) {
    case 'HYDRATED':
      return { ...state, isHydrated: true };
    case 'CHECK_START':
      return { ...state, isCheckingUser: true };
    case 'CHECK_END':
      return { ...state, isCheckingUser: false };
    default:
      return state;
  }
}

export function ProtectedRoute() {
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);
  const setUser = useAuthStore((state) => state.setUser);
  const logout = useAuthStore((state) => state.logout);
  const hydrate = useAuthStore((state) => state.hydrate);

  const [authState, dispatch] = useReducer(authCheckReducer, {
    isHydrated: false,
    isCheckingUser: false,
  });

  const hasHydrated = useRef(false);
  const hasCheckedUser = useRef(false);

  // Hydrate auth state from localStorage (runs once)
  useEffect(() => {
    if (hasHydrated.current) return;
    hasHydrated.current = true;
    hydrate();
    dispatch({ type: 'HYDRATED' });
  }, [hydrate]);

  // Verify user with backend (runs once when authenticated)
  useEffect(() => {
    if (!authState.isHydrated || !isAuthenticated || hasCheckedUser.current) return;
    hasCheckedUser.current = true;

    let isMounted = true;
    dispatch({ type: 'CHECK_START' });

    getCurrentUser()
      .then((user) => {
        if (isMounted) setUser(user);
      })
      .catch(() => {
        if (isMounted) logout();
      })
      .finally(() => {
        if (isMounted) {
          dispatch({ type: 'CHECK_END' });
        }
      });

    return () => {
      isMounted = false;
    };
  }, [authState.isHydrated, isAuthenticated, logout, setUser]);

  // Show loading spinner while hydrating or checking user
  if (!authState.isHydrated || authState.isCheckingUser) {
    return (
      <div className="flex h-screen items-center justify-center bg-slate-950">
        <Spinner size={32} />
      </div>
    );
  }

  // Redirect to login if not authenticated
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
}

import { LoginForm } from '@/components/Auth/LoginForm';

export function Login() {
  return (
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden bg-gradient-to-br from-emerald-900 via-teal-900 to-slate-900 px-4">
      <div className="pointer-events-none absolute -left-20 top-10 h-64 w-64 rounded-full bg-emerald-500/20 blur-3xl" />
      <div className="pointer-events-none absolute -bottom-24 right-10 h-72 w-72 rounded-full bg-cyan-400/20 blur-3xl" />
      <LoginForm />
    </div>
  );
}

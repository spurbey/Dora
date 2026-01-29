import { RegisterForm } from '@/components/Auth/RegisterForm';

export function Register() {
  return (
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden bg-gradient-to-br from-emerald-900 via-teal-900 to-slate-900 px-4">
      <div className="pointer-events-none absolute -left-16 bottom-10 h-72 w-72 rounded-full bg-emerald-500/20 blur-3xl" />
      <div className="pointer-events-none absolute -top-20 right-10 h-64 w-64 rounded-full bg-cyan-400/20 blur-3xl" />
      <RegisterForm />
    </div>
  );
}

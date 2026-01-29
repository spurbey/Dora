import { useMemo, useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { z } from 'zod';
import { zodResolver } from '@hookform/resolvers/zod';
import { register } from '@/services/authService';
import { useAuth } from '@/hooks/useAuth';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '@/components/ui/card';
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';

const schema = z
  .object({
    email: z.string().email('Enter a valid email'),
    username: z.string().min(3, 'Username must be at least 3 characters').max(20),
    password: z.string().min(8, 'Password must be at least 8 characters'),
    confirmPassword: z.string().min(8, 'Confirm your password'),
  })
  .refine((values) => values.password === values.confirmPassword, {
    message: 'Passwords do not match',
    path: ['confirmPassword'],
  });

type RegisterValues = z.infer<typeof schema>;

function getPasswordStrength(password: string) {
  let score = 0;
  if (password.length >= 8) score += 1;
  if (/[A-Z]/.test(password)) score += 1;
  if (/[a-z]/.test(password)) score += 1;
  if (/[0-9]/.test(password)) score += 1;
  if (/[^A-Za-z0-9]/.test(password)) score += 1;

  const labels = ['Weak', 'Fair', 'Good', 'Strong', 'Excellent'];
  const label = labels[Math.max(score - 1, 0)] ?? 'Weak';

  return { score, label };
}

export function RegisterForm() {
  const navigate = useNavigate();
  const { setToken, setUser } = useAuth();
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [infoMessage, setInfoMessage] = useState<string | null>(null);

  const form = useForm<RegisterValues>({
    resolver: zodResolver(schema),
    defaultValues: {
      email: '',
      username: '',
      password: '',
      confirmPassword: '',
    },
  });

  const password = form.watch('password');
  const strength = useMemo(() => getPasswordStrength(password), [password]);

  const onSubmit = async (values: RegisterValues) => {
    setErrorMessage(null);
    setInfoMessage(null);
    try {
      const response = await register(values.email, values.username, values.password);
      if (response.requires_email_confirmation || !response.token || !response.user) {
        setInfoMessage('Account created. Please check your email to confirm before signing in.');
        return;
      }
      setToken(response.token);
      setUser(response.user);
      navigate('/dashboard');
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Registration failed';
      setErrorMessage(message);
    }
  };

  return (
    <Card className="w-full max-w-md border-white/20 bg-white/10 text-white shadow-xl backdrop-blur">
      <CardHeader>
        <CardTitle className="text-2xl">Create your account</CardTitle>
        <CardDescription className="text-white/70">
          Start building your travel memory vault.
        </CardDescription>
      </CardHeader>
      <CardContent>
        {infoMessage ? (
          <Alert className="mb-4 border-emerald-300/40 bg-emerald-500/10 text-emerald-100">
            <AlertTitle>Confirm your email</AlertTitle>
            <AlertDescription>{infoMessage}</AlertDescription>
          </Alert>
        ) : null}
        {errorMessage ? (
          <Alert className="mb-4 border-rose-400/40 bg-rose-500/10 text-rose-100">
            <AlertTitle>Registration failed</AlertTitle>
            <AlertDescription>{errorMessage}</AlertDescription>
          </Alert>
        ) : null}
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <FormField
              control={form.control}
              name="email"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Email</FormLabel>
                  <FormControl>
                    <Input
                      placeholder="you@example.com"
                      type="email"
                      autoComplete="email"
                      className="border-white/20 bg-white/10 text-white placeholder:text-white/40"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="username"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Username</FormLabel>
                  <FormControl>
                    <Input
                      placeholder="traveler123"
                      type="text"
                      autoComplete="username"
                      className="border-white/20 bg-white/10 text-white placeholder:text-white/40"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="password"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Password</FormLabel>
                  <FormControl>
                    <Input
                      placeholder="••••••••"
                      type="password"
                      autoComplete="new-password"
                      className="border-white/20 bg-white/10 text-white placeholder:text-white/40"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <div className="rounded-lg border border-white/10 bg-white/5 px-3 py-2 text-xs text-white/70">
              Password strength: <span className="font-semibold text-white">{strength.label}</span>
              <div className="mt-2 h-1.5 w-full rounded-full bg-white/10">
                <div
                  className="h-1.5 rounded-full bg-emerald-300 transition-all"
                  style={{ width: `${Math.min(strength.score, 5) * 20}%` }}
                />
              </div>
            </div>
            <FormField
              control={form.control}
              name="confirmPassword"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Confirm password</FormLabel>
                  <FormControl>
                    <Input
                      placeholder="••••••••"
                      type="password"
                      autoComplete="new-password"
                      className="border-white/20 bg-white/10 text-white placeholder:text-white/40"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <Button
              type="submit"
              className="w-full bg-emerald-500/90 text-white hover:bg-emerald-400"
              disabled={form.formState.isSubmitting}
            >
              {form.formState.isSubmitting ? 'Creating account...' : 'Create account'}
            </Button>
          </form>
        </Form>
      </CardContent>
      <CardFooter className="justify-center text-sm text-white/70">
        Already have an account?
        <Link className="ml-2 text-emerald-200 hover:text-white" to="/login">
          Sign in
        </Link>
      </CardFooter>
    </Card>
  );
}

import { Component, type ErrorInfo, type ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught an error:', error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }
      return (
        <div className="flex min-h-screen flex-col items-center justify-center bg-slate-950 p-8 text-white">
          <h1 className="mb-4 text-2xl font-bold text-red-400">Something went wrong</h1>
          <pre className="max-w-xl overflow-auto rounded bg-slate-800 p-4 text-sm text-red-300">
            {this.state.error?.message}
          </pre>
          <button
            onClick={() => window.location.reload()}
            className="mt-6 rounded bg-emerald-600 px-4 py-2 text-white hover:bg-emerald-500"
          >
            Reload Page
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}

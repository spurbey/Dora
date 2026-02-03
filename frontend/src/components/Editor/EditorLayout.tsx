import type { ReactNode } from 'react';
import { cn } from '@/lib/utils';

interface EditorLayoutProps {
  children: ReactNode;
  className?: string;
}

interface EditorContentProps {
  children: ReactNode;
  className?: string;
}

export function EditorLayout({ children, className }: EditorLayoutProps) {
  return (
    <div
      className={cn(
        'min-h-screen w-full bg-slate-950 text-slate-100',
        'bg-[radial-gradient(circle_at_top,rgba(20,184,166,0.15),transparent_45%),radial-gradient(circle_at_bottom,rgba(14,116,144,0.18),transparent_40%)]',
        className
      )}
    >
      {children}
    </div>
  );
}

export function EditorContent({ children, className }: EditorContentProps) {
  return (
    <div
      className={cn(
        'flex flex-1 gap-4 px-4 pb-4 pt-2',
        'max-xl:flex-col max-xl:pb-28',
        className
      )}
    >
      {children}
    </div>
  );
}

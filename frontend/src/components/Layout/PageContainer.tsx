import { cn } from '@/lib/utils';
import { useUIStore } from '@/store/uiStore';

interface PageContainerProps {
  children: React.ReactNode;
  className?: string;
}

export function PageContainer({ children, className }: PageContainerProps) {
  const collapsed = useUIStore((state) => state.sidebarCollapsed);

  return (
    <main
      className={cn(
        'min-h-screen bg-slate-950 pt-16 transition-all duration-300',
        collapsed ? 'lg:pl-16' : 'lg:pl-64',
        className
      )}
    >
      <div className="mx-auto max-w-7xl px-4 py-6 sm:px-6 lg:px-8">{children}</div>
    </main>
  );
}

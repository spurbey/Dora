import { Link, useLocation } from 'react-router-dom';
import { LayoutDashboard, Map, Search, User, ChevronLeft, ChevronRight } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { useUIStore } from '@/store/uiStore';

interface NavItem {
  label: string;
  href: string;
  icon: React.ElementType;
  disabled?: boolean;
  badge?: string;
}

const navItems: NavItem[] = [
  { label: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { label: 'My Trips', href: '/dashboard', icon: Map },
  { label: 'Search', href: '/search', icon: Search, disabled: true, badge: 'Phase 3' },
  { label: 'Profile', href: '/profile', icon: User, disabled: true, badge: 'Phase 5' },
];

export function Sidebar() {
  const location = useLocation();
  const collapsed = useUIStore((state) => state.sidebarCollapsed);
  const toggleSidebar = useUIStore((state) => state.toggleSidebar);

  return (
    <>
      {/* Mobile overlay */}
      {!collapsed && (
        <div
          className="fixed inset-0 z-40 bg-black/50 lg:hidden"
          onClick={toggleSidebar}
        />
      )}

      {/* Sidebar */}
      <aside
        className={cn(
          'fixed bottom-0 left-0 top-16 z-40 flex flex-col border-r border-white/10 bg-slate-900 transition-all duration-300',
          collapsed ? '-translate-x-full lg:translate-x-0 lg:w-16' : 'w-64'
        )}
      >
        <nav className="flex-1 space-y-1 p-3">
          {navItems.map((item) => {
            const isActive = location.pathname === item.href;
            const Icon = item.icon;

            if (item.disabled) {
              return (
                <div
                  key={item.label}
                  className={cn(
                    'flex items-center gap-3 rounded-lg px-3 py-2 text-white/40',
                    collapsed && 'justify-center'
                  )}
                  title={collapsed ? item.label : undefined}
                >
                  <Icon className="h-5 w-5 shrink-0" />
                  {!collapsed && (
                    <>
                      <span className="flex-1">{item.label}</span>
                      {item.badge && (
                        <span className="rounded bg-white/10 px-1.5 py-0.5 text-xs">
                          {item.badge}
                        </span>
                      )}
                    </>
                  )}
                </div>
              );
            }

            return (
              <Link
                key={item.label}
                to={item.href}
                className={cn(
                  'flex items-center gap-3 rounded-lg px-3 py-2 transition-colors',
                  isActive
                    ? 'bg-emerald-500/20 text-emerald-400'
                    : 'text-white/70 hover:bg-white/10 hover:text-white',
                  collapsed && 'justify-center'
                )}
                title={collapsed ? item.label : undefined}
              >
                <Icon className="h-5 w-5 shrink-0" />
                {!collapsed && <span>{item.label}</span>}
              </Link>
            );
          })}
        </nav>

        {/* Collapse toggle - desktop only */}
        <div className="hidden border-t border-white/10 p-3 lg:block">
          <Button
            variant="ghost"
            size="sm"
            className="w-full justify-center text-white/70 hover:bg-white/10 hover:text-white"
            onClick={toggleSidebar}
          >
            {collapsed ? (
              <ChevronRight className="h-4 w-4" />
            ) : (
              <>
                <ChevronLeft className="mr-2 h-4 w-4" />
                Collapse
              </>
            )}
          </Button>
        </div>
      </aside>
    </>
  );
}

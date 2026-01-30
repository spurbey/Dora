import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Menu, Search, User, LogOut, Settings, ChevronDown } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { useAuthStore } from '@/store/authStore';
import { useUIStore } from '@/store/uiStore';
import { logout as authLogout } from '@/services/authService';

export function Navbar() {
  const navigate = useNavigate();
  const user = useAuthStore((state) => state.user);
  const logout = useAuthStore((state) => state.logout);
  const toggleSidebar = useUIStore((state) => state.toggleSidebar);
  const [searchQuery, setSearchQuery] = useState('');

  const handleLogout = async () => {
    await authLogout();
    logout();
    navigate('/login');
  };

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    // Search functionality will be implemented in Phase 3
    console.log('Search:', searchQuery);
  };

  return (
    <header className="fixed left-0 right-0 top-0 z-50 border-b border-white/10 bg-gradient-to-r from-emerald-900 via-teal-900 to-slate-900 shadow-lg">
      <div className="flex h-16 items-center justify-between px-4">
        {/* Left: Menu + Logo */}
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="icon"
            className="text-white/70 hover:bg-white/10 hover:text-white lg:hidden"
            onClick={toggleSidebar}
          >
            <Menu className="h-5 w-5" />
          </Button>
          <Link to="/dashboard" className="flex items-center gap-2">
            <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-emerald-500">
              <span className="text-lg font-bold text-white">T</span>
            </div>
            <span className="hidden text-lg font-semibold text-white sm:block">
              Travel Vault
            </span>
          </Link>
        </div>

        {/* Center: Search */}
        <form onSubmit={handleSearch} className="hidden max-w-md flex-1 px-8 md:block">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-white/40" />
            <Input
              type="search"
              placeholder="Search places... (coming in Phase 3)"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full border-white/20 bg-white/10 pl-10 text-white placeholder:text-white/40 focus:border-emerald-400 focus:ring-emerald-400"
              disabled
            />
          </div>
        </form>

        {/* Right: User Menu */}
        <div className="flex items-center gap-2">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="ghost"
                className="flex items-center gap-2 text-white/70 hover:bg-white/10 hover:text-white"
              >
                <div className="flex h-8 w-8 items-center justify-center rounded-full bg-emerald-500/30">
                  <User className="h-4 w-4" />
                </div>
                <span className="hidden sm:block">{user?.username ?? 'User'}</span>
                <ChevronDown className="h-4 w-4" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-48">
              <DropdownMenuItem disabled className="text-muted-foreground">
                <User className="mr-2 h-4 w-4" />
                Profile (Phase 5)
              </DropdownMenuItem>
              <DropdownMenuItem disabled className="text-muted-foreground">
                <Settings className="mr-2 h-4 w-4" />
                Settings (Phase 5)
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={handleLogout} className="text-red-500 focus:text-red-500">
                <LogOut className="mr-2 h-4 w-4" />
                Logout
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  );
}

import { ArrowLeft, Search, Save, Share2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

interface TopBarProps {
  title?: string;
  onSave?: () => void;
  onExit?: () => void;
}

export function TopBar({ title = 'Trip Editor', onSave, onExit }: TopBarProps) {
  return (
    <header className="sticky top-0 z-20 border-b border-white/10 bg-slate-950/80 backdrop-blur">
      <div className="flex flex-col gap-3 px-4 py-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-3">
          {onExit && (
            <Button
              variant="ghost"
              size="icon"
              className="h-9 w-9 border border-white/10 text-white/70 hover:bg-white/10"
              onClick={onExit}
              title="Exit editor"
            >
              <ArrowLeft className="h-4 w-4" />
            </Button>
          )}
          <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-500/15 text-emerald-300">
            <span className="text-sm font-semibold">TV</span>
          </div>
          <div>
            <p className="text-xs uppercase tracking-[0.2em] text-emerald-300/70">Editor Mode</p>
            <h1 className="text-lg font-semibold text-white">{title}</h1>
          </div>
        </div>

        <div className="flex flex-1 items-center gap-3 sm:max-w-xl">
          <div className="relative w-full">
            <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-white/50" />
            <Input
              placeholder="Search places, routes, notes..."
              className="w-full border-white/10 bg-white/5 pl-10 text-white placeholder:text-white/40"
            />
          </div>
          <Button variant="outline" className="border-emerald-500/40 text-emerald-200 hover:bg-emerald-500/10">
            <Share2 className="mr-2 h-4 w-4" />
            Share
          </Button>
          <Button onClick={onSave} className="bg-emerald-600 text-white hover:bg-emerald-500">
            <Save className="mr-2 h-4 w-4" />
            Save
          </Button>
        </div>
      </div>
    </header>
  );
}

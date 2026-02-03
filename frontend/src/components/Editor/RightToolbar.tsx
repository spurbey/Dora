import { Building2, MapPin, Route, PenLine, Layers, Navigation } from 'lucide-react';
import { Button } from '@/components/ui/button';

const tools = [
  { id: 'city', label: 'Add City', icon: Building2 },
  { id: 'place', label: 'Add Place', icon: MapPin },
  { id: 'route', label: 'Draw Route', icon: Route },
  { id: 'note', label: 'Annotate', icon: PenLine },
  { id: 'layers', label: 'Layers', icon: Layers },
  { id: 'nav', label: 'Navigate', icon: Navigation },
];

export function RightToolbar() {
  return (
    <aside className="flex w-full flex-row gap-2 rounded-2xl border border-white/10 bg-white/5 p-3 max-xl:order-3 xl:w-20 xl:flex-col">
      {tools.map((tool) => {
        const Icon = tool.icon;
        return (
          <Button
            key={tool.id}
            variant="ghost"
            className="h-12 w-full flex-1 rounded-xl border border-white/10 bg-white/5 text-white/70 hover:bg-emerald-500/15 hover:text-emerald-100 xl:h-12 xl:w-12 xl:flex-none"
            title={tool.label}
          >
            <Icon className="h-5 w-5" />
          </Button>
        );
      })}
    </aside>
  );
}

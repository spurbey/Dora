import { ChevronUp } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useEditorStore } from '@/store/editorStore';
import { cn } from '@/lib/utils';

export function BottomPanel() {
  const { bottomPanelOpen, setBottomPanelOpen } = useEditorStore();

  return (
    <div
      className={cn(
        'fixed bottom-0 left-0 right-0 z-20 border-t border-white/10 bg-slate-950/85 backdrop-blur',
        bottomPanelOpen ? 'h-40' : 'h-12'
      )}
    >
      <div className="mx-auto flex h-full max-w-6xl flex-col px-4">
        <div className="flex items-center justify-between py-2">
          <div className="flex items-center gap-2 text-xs text-white/60">
            <span className="h-2 w-2 rounded-full bg-emerald-400" />
            Details Panel
          </div>
          <Button
            variant="ghost"
            size="icon"
            className="text-white/60 hover:bg-white/10"
            onClick={() => setBottomPanelOpen(!bottomPanelOpen)}
          >
            <ChevronUp className={cn('h-4 w-4 transition-transform', !bottomPanelOpen && 'rotate-180')} />
          </Button>
        </div>

        {bottomPanelOpen && (
          <div className="grid flex-1 grid-cols-1 gap-4 pb-4 text-sm text-white/70 sm:grid-cols-3">
            <div className="rounded-xl border border-white/10 bg-white/5 p-3">
              Select a component to view details.
            </div>
            <div className="rounded-xl border border-white/10 bg-white/5 p-3">
              Notes, media, and tags appear here.
            </div>
            <div className="rounded-xl border border-white/10 bg-white/5 p-3">
              This panel becomes interactive in Phase D/E.
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

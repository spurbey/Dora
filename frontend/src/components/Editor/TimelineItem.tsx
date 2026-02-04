import type { ReactNode } from 'react';
import { GripVertical } from 'lucide-react';
import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { cn } from '@/lib/utils';

interface TimelineItemProps {
  id: string;
  isSelected: boolean;
  isHighlighted: boolean;
  onClick: () => void;
  onHover: () => void;
  onHoverOut: () => void;
  children: ReactNode;
}

export function TimelineItem({
  id,
  isSelected,
  isHighlighted,
  onClick,
  onHover,
  onHoverOut,
  children,
}: TimelineItemProps) {
  const { attributes, listeners, setNodeRef, transform, transition, isDragging } = useSortable({ id });
  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  return (
    <div
      ref={setNodeRef}
      style={style}
      className={cn(
        'group relative rounded-xl border border-white/10 bg-white/5 p-3 text-white/80 shadow-sm transition',
        isSelected && 'border-emerald-400/60 bg-emerald-500/10',
        isHighlighted && !isSelected && 'border-emerald-200/50 bg-emerald-500/5',
        isDragging && 'opacity-70'
      )}
      onClick={onClick}
      onMouseEnter={onHover}
      onMouseLeave={onHoverOut}
    >
      <button
        type="button"
        className="absolute left-2 top-3 hidden cursor-grab text-white/40 group-hover:flex"
        {...attributes}
        {...listeners}
      >
        <GripVertical className="h-4 w-4" />
      </button>
      <div className="pl-5">{children}</div>
    </div>
  );
}

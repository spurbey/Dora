interface RouteDrawerProps {
  isDrawing: boolean;
  isLoading: boolean;
}

export function RouteDrawer({ isDrawing, isLoading }: RouteDrawerProps) {
  if (!isDrawing && !isLoading) return null;

  return (
    <>
      {isDrawing && (
        <div className="pointer-events-none absolute left-4 top-4 rounded-full border border-white/10 bg-black/40 px-3 py-1 text-xs text-white/80">
          Click to add route points
        </div>
      )}
      {isLoading && (
        <div className="absolute right-4 top-4 rounded-full border border-white/10 bg-black/40 px-3 py-1 text-xs text-white/80">
          Calculating route...
        </div>
      )}
    </>
  );
}

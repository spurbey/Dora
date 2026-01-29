export function Spinner({ size = 24 }: { size?: number }) {
  return (
    <div
      className="inline-block animate-spin rounded-full border-2 border-emerald-400 border-t-transparent"
      style={{ width: size, height: size }}
      aria-label="Loading"
      role="status"
    />
  );
}

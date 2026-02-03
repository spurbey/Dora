export type ToastVariant = 'default' | 'destructive';

export interface ToastInput {
  title: string;
  description?: string;
  variant?: ToastVariant;
}

export function useToast() {
  const toast = ({ title, description }: ToastInput) => {
    const message = description ? `${title}: ${description}` : title;
    // Placeholder implementation; replace with UI toast later.
    console.info(message);
  };

  return { toast };
}

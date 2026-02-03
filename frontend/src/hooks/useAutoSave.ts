import { useEffect } from 'react';
import { useEditorStore } from '@/store/editorStore';

export function useAutoSave(onSave: () => void | Promise<void>, interval = 30000) {
  const { hasUnsavedChanges, autoSaveEnabled } = useEditorStore();

  useEffect(() => {
    if (!autoSaveEnabled || !hasUnsavedChanges) return;

    const timer = setInterval(() => {
      void onSave();
    }, interval);

    return () => clearInterval(timer);
  }, [autoSaveEnabled, hasUnsavedChanges, onSave, interval]);
}

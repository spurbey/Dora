import { useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { EditorLayout, EditorContent } from '@/components/Editor/EditorLayout';
import { TopBar } from '@/components/Editor/TopBar';
import { LeftTimeline } from '@/components/Editor/LeftTimeline';
import { CenterMap } from '@/components/Editor/CenterMap';
import { RightToolbar } from '@/components/Editor/RightToolbar';
import { BottomPanel } from '@/components/Editor/BottomPanel';
import { useEditorStore } from '@/store/editorStore';
import { useAutoSave } from '@/hooks/useAutoSave';
import { useEditorTrip, useEditorComponents, useSaveTrip } from '@/hooks/useEditor';
import { usePlaces } from '@/hooks/usePlaces';
import { useRoutes } from '@/hooks/useRoutes';
import type { TripUpdate } from '@/types/trip';

export function TripEditor() {
  const { id } = useParams();
  const navigate = useNavigate();
  const {
    trip,
    setTrip,
    setPlaces,
    setRoutes,
    setTimeline,
    markSaved,
  } = useEditorStore();

  const tripId = id ?? '';
  const { data: tripData } = useEditorTrip(tripId);
  const { data: componentData } = useEditorComponents(tripId);
  const { data: placesData } = usePlaces(tripId);
  const { data: routesData } = useRoutes(tripId);
  const saveTripMutation = useSaveTrip();

  const handleSave = async () => {
    if (!trip) return;
    const payload: TripUpdate = {
      title: trip.title,
      description: trip.description ?? undefined,
      start_date: trip.start_date ?? undefined,
      end_date: trip.end_date ?? undefined,
      visibility: trip.visibility,
      cover_photo_url: trip.cover_photo_url ?? undefined,
    };
    await saveTripMutation.mutateAsync({ id: trip.id, payload });
    markSaved();
  };

  useAutoSave(handleSave);

  useEffect(() => {
    if (tripData) {
      setTrip(tripData);
    }
  }, [tripData, setTrip]);

  useEffect(() => {
    if (placesData) {
      setPlaces(placesData);
    }
  }, [placesData, setPlaces]);

  useEffect(() => {
    if (routesData) {
      setRoutes(routesData);
    }
  }, [routesData, setRoutes]);

  useEffect(() => {
    if (componentData) {
      const timeline = componentData.components
        .slice()
        .sort((a, b) => a.order_in_trip - b.order_in_trip)
        .map((component) => ({
          type: component.component_type,
          id: component.id,
          order: component.order_in_trip,
          name: component.name,
        }));
      setTimeline(timeline);
    }
  }, [componentData, setTimeline]);

  return (
    <EditorLayout>
      <TopBar
        title={trip?.title ?? 'Trip Editor'}
        onSave={() => void handleSave()}
        onExit={() => navigate('/dashboard')}
      />
      <EditorContent>
        <LeftTimeline />
        <CenterMap />
        <RightToolbar />
      </EditorContent>
      <BottomPanel />
    </EditorLayout>
  );
}

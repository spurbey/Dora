import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { MapPin, Clock, Image } from 'lucide-react';
import { Navbar } from '@/components/Layout/Navbar';
import { Sidebar } from '@/components/Layout/Sidebar';
import { PageContainer } from '@/components/Layout/PageContainer';
import { TripHeader } from '@/components/Trip/TripHeader';
import { TripForm } from '@/components/Trip/TripForm';
import { TripTimeline } from '@/components/Trip/TripTimeline';
import { EmptyState } from '@/components/Shared/EmptyState';
import { LoadingPage } from '@/components/Shared/LoadingSpinner';
import { ConfirmDialog } from '@/components/Shared/ConfirmDialog';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { useTrip, useUpdateTrip, useDeleteTrip } from '@/hooks/useTrips';
import { usePlaces } from '@/hooks/usePlaces';
import type { TripUpdate } from '@/types/trip';

export function TripDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { data: trip, isLoading, error } = useTrip(id ?? '');
  const { data: places = [] } = usePlaces(id ?? '');
  const updateTrip = useUpdateTrip();
  const deleteTrip = useDeleteTrip();

  const [formOpen, setFormOpen] = useState(false);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [activeTab, setActiveTab] = useState('timeline');

  // Calculate center location from first place, or default to Paris
  const centerLocation =
    places.length > 0
      ? { lat: places[0].lat, lng: places[0].lng }
      : { lat: 48.8566, lng: 2.3522 };

  const handleEditSubmit = async (data: TripUpdate) => {
    if (!id) return;
    try {
      await updateTrip.mutateAsync({ id, data });
      setFormOpen(false);
    } catch (err) {
      console.error('Failed to update trip:', err);
    }
  };

  const handleDeleteConfirm = async () => {
    if (!id) return;
    try {
      await deleteTrip.mutateAsync(id);
      navigate('/dashboard');
    } catch (err) {
      console.error('Failed to delete trip:', err);
    }
  };

  if (isLoading) {
    return (
      <>
        <Navbar />
        <Sidebar />
        <PageContainer>
          <LoadingPage />
        </PageContainer>
      </>
    );
  }

  if (error || !trip) {
    return (
      <>
        <Navbar />
        <Sidebar />
        <PageContainer>
          <div className="flex min-h-[400px] flex-col items-center justify-center text-center">
            <h2 className="mb-2 text-xl font-semibold text-white">Trip not found</h2>
            <p className="mb-4 text-white/60">
              The trip you're looking for doesn't exist or you don't have access to it.
            </p>
            <button
              onClick={() => navigate('/dashboard')}
              className="text-emerald-400 hover:text-emerald-300"
            >
              Back to Dashboard
            </button>
          </div>
        </PageContainer>
      </>
    );
  }

  return (
    <>
      <Navbar />
      <Sidebar />
      <PageContainer>
        <TripHeader
          trip={trip}
          onEdit={() => setFormOpen(true)}
          onDelete={() => setDeleteDialogOpen(true)}
        />

        {/* Tabs */}
        <Tabs value={activeTab} onValueChange={setActiveTab} className="mt-6">
          <TabsList className="border-b border-white/10 bg-transparent">
            <TabsTrigger
              value="timeline"
              className="data-[state=active]:border-b-2 data-[state=active]:border-emerald-400 data-[state=active]:text-emerald-400"
            >
              <Clock className="mr-2 h-4 w-4" />
              Timeline
            </TabsTrigger>
            <TabsTrigger
              value="map"
              disabled
              className="text-white/40"
            >
              <MapPin className="mr-2 h-4 w-4" />
              Map (Phase 4)
            </TabsTrigger>
            <TabsTrigger
              value="photos"
              disabled
              className="text-white/40"
            >
              <Image className="mr-2 h-4 w-4" />
              Photos (Phase 4)
            </TabsTrigger>
          </TabsList>

          <TabsContent value="timeline" className="mt-6">
            <TripTimeline tripId={id ?? ''} centerLocation={centerLocation} />
          </TabsContent>

          <TabsContent value="map" className="mt-6">
            <EmptyState
              icon={MapPin}
              title="Map coming soon"
              description="Visualize all your places on an interactive map."
            />
          </TabsContent>

          <TabsContent value="photos" className="mt-6">
            <EmptyState
              icon={Image}
              title="Photos coming soon"
              description="All your trip photos in one beautiful gallery."
            />
          </TabsContent>
        </Tabs>

        {/* Edit Trip Modal */}
        <TripForm
          trip={trip}
          open={formOpen}
          onOpenChange={setFormOpen}
          onSubmit={handleEditSubmit}
          isLoading={updateTrip.isPending}
        />

        {/* Delete Confirmation Dialog */}
        <ConfirmDialog
          open={deleteDialogOpen}
          onOpenChange={setDeleteDialogOpen}
          title="Delete Trip"
          description="Are you sure you want to delete this trip? This action cannot be undone and all associated places will be removed."
          confirmLabel="Delete"
          onConfirm={handleDeleteConfirm}
          variant="destructive"
          isLoading={deleteTrip.isPending}
        />
      </PageContainer>
    </>
  );
}

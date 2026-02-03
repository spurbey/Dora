import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Plus } from 'lucide-react';
import { Navbar } from '@/components/Layout/Navbar';
import { Sidebar } from '@/components/Layout/Sidebar';
import { PageContainer } from '@/components/Layout/PageContainer';
import { TripCard } from '@/components/Trip/TripCard';
import { TripForm } from '@/components/Trip/TripForm';
import { EmptyState } from '@/components/Shared/EmptyState';
import { LoadingPage } from '@/components/Shared/LoadingSpinner';
import { ConfirmDialog } from '@/components/Shared/ConfirmDialog';
import { Button } from '@/components/ui/button';
import { useTrips, useCreateTrip, useUpdateTrip, useDeleteTrip } from '@/hooks/useTrips';
import type { Trip, TripCreate, TripUpdate } from '@/types/trip';
import { FEATURES } from '@/utils/features';

export function Dashboard() {
  const navigate = useNavigate();
  const { data: trips, isLoading, error, refetch } = useTrips();
  const createTrip = useCreateTrip();
  const updateTrip = useUpdateTrip();
  const deleteTrip = useDeleteTrip();

  const [formOpen, setFormOpen] = useState(false);
  const [editingTrip, setEditingTrip] = useState<Trip | undefined>(undefined);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [tripToDelete, setTripToDelete] = useState<string | null>(null);

  const handleFormOpenChange = (open: boolean) => {
    setFormOpen(open);
    if (!open) {
      // Reset editing state when form closes
      setEditingTrip(undefined);
    }
  };

  const handleCreateClick = () => {
    setEditingTrip(undefined);
    setFormOpen(true);
  };

  const handleEditClick = (trip: Trip) => {
    setEditingTrip(trip);
    setFormOpen(true);
  };

  const handleDeleteClick = (id: string) => {
    setTripToDelete(id);
    setDeleteDialogOpen(true);
  };

  const handleFormSubmit = async (data: TripCreate | TripUpdate) => {
    try {
      if (editingTrip) {
        await updateTrip.mutateAsync({ id: editingTrip.id, data: data as TripUpdate });
      } else {
        await createTrip.mutateAsync(data as TripCreate);
      }
      setFormOpen(false);
    } catch (err) {
      // Error is handled by React Query
      console.error('Failed to save trip:', err);
    }
  };

  const handleDeleteConfirm = async () => {
    if (!tripToDelete) return;
    try {
      await deleteTrip.mutateAsync(tripToDelete);
      setDeleteDialogOpen(false);
      setTripToDelete(null);
    } catch (err) {
      console.error('Failed to delete trip:', err);
    }
  };

  const handleEditV2Click = (trip: Trip) => {
    navigate(`/trips/${trip.id}/edit`);
  };

  return (
    <>
      <Navbar />
      <Sidebar />
      <PageContainer>
        {/* Page Header */}
        <div className="mb-8 flex items-center justify-between">
          <div>
            <h1 className="text-2xl font-bold text-white sm:text-3xl">My Trips</h1>
            <p className="mt-1 text-white/60">
              {trips?.length
                ? `${trips.length} trip${trips.length === 1 ? '' : 's'}`
                : 'Start your first adventure'}
            </p>
          </div>
          <Button onClick={handleCreateClick} className="bg-emerald-600 hover:bg-emerald-500">
            <Plus className="mr-2 h-4 w-4" />
            Create Trip
          </Button>
        </div>

        {/* Content */}
        {isLoading ? (
          <LoadingPage />
        ) : error ? (
          <div className="rounded-lg border border-red-500/30 bg-red-500/10 p-6 text-center">
            <p className="text-red-400">Failed to load trips. Please try again.</p>
            <Button
              variant="outline"
              onClick={() => refetch()}
              className="mt-4 border-red-500/30 text-red-400 hover:bg-red-500/10"
            >
              Retry
            </Button>
          </div>
        ) : !trips || trips.length === 0 ? (
          <EmptyState
            title="No trips yet"
            description="Create your first trip to start documenting your travel memories and building your personal journey map."
            actionLabel="Create Trip"
            onAction={handleCreateClick}
          />
        ) : (
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {trips.map((trip) => (
              <TripCard
                key={trip.id}
                trip={trip}
                onEdit={handleEditClick}
                onDelete={handleDeleteClick}
                onEditV2={FEATURES.EDITOR ? handleEditV2Click : undefined}
              />
            ))}
          </div>
        )}

        {/* Trip Form Modal */}
        <TripForm
          trip={editingTrip}
          open={formOpen}
          onOpenChange={handleFormOpenChange}
          onSubmit={handleFormSubmit}
          isLoading={createTrip.isPending || updateTrip.isPending}
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

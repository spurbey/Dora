import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Button } from '@/components/ui/button';
import type { Trip, TripCreate, TripUpdate } from '@/types/trip';

const tripSchema = z
  .object({
    title: z.string().min(1, 'Title is required').max(200, 'Title is too long'),
    description: z.string().max(1000, 'Description is too long').optional(),
    start_date: z.string().optional(),
    end_date: z.string().optional(),
    visibility: z.enum(['private', 'unlisted', 'public']),
  })
  .refine(
    (data) => {
      if (data.start_date && data.end_date) {
        return new Date(data.end_date) >= new Date(data.start_date);
      }
      return true;
    },
    {
      message: 'End date must be after start date',
      path: ['end_date'],
    }
  );

type TripFormValues = z.infer<typeof tripSchema>;

interface TripFormProps {
  trip?: Trip;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onSubmit: (data: TripCreate | TripUpdate) => void;
  isLoading?: boolean;
}

export function TripForm({ trip, open, onOpenChange, onSubmit, isLoading }: TripFormProps) {
  const isEditing = !!trip;

  const form = useForm<TripFormValues>({
    resolver: zodResolver(tripSchema),
    defaultValues: {
      title: trip?.title ?? '',
      description: trip?.description ?? '',
      start_date: trip?.start_date ?? '',
      end_date: trip?.end_date ?? '',
      visibility: trip?.visibility ?? 'private',
    },
  });

  const handleSubmit = (values: TripFormValues) => {
    const data: TripCreate | TripUpdate = {
      title: values.title,
      description: values.description || undefined,
      start_date: values.start_date || undefined,
      end_date: values.end_date || undefined,
      visibility: values.visibility,
    };
    onSubmit(data);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="border-white/10 bg-slate-900 sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle className="text-white">
            {isEditing ? 'Edit Trip' : 'Create New Trip'}
          </DialogTitle>
          <DialogDescription className="text-white/60">
            {isEditing
              ? 'Update your trip details below.'
              : 'Fill in the details to create a new trip.'}
          </DialogDescription>
        </DialogHeader>

        <Form {...form}>
          <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-4">
            <FormField
              control={form.control}
              name="title"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-white">Title</FormLabel>
                  <FormControl>
                    <Input
                      placeholder="Paris Summer 2025"
                      className="border-white/20 bg-white/10 text-white placeholder:text-white/40"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="description"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-white">Description (optional)</FormLabel>
                  <FormControl>
                    <Textarea
                      placeholder="Two weeks exploring France..."
                      className="min-h-[80px] border-white/20 bg-white/10 text-white placeholder:text-white/40"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="grid grid-cols-2 gap-4">
              <FormField
                control={form.control}
                name="start_date"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-white">Start Date</FormLabel>
                    <FormControl>
                      <Input
                        type="date"
                        className="border-white/20 bg-white/10 text-white [color-scheme:dark]"
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <FormField
                control={form.control}
                name="end_date"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel className="text-white">End Date</FormLabel>
                    <FormControl>
                      <Input
                        type="date"
                        className="border-white/20 bg-white/10 text-white [color-scheme:dark]"
                        {...field}
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
            </div>

            <FormField
              control={form.control}
              name="visibility"
              render={({ field }) => (
                <FormItem>
                  <FormLabel className="text-white">Visibility</FormLabel>
                  <Select onValueChange={field.onChange} defaultValue={field.value}>
                    <FormControl>
                      <SelectTrigger className="border-white/20 bg-white/10 text-white">
                        <SelectValue placeholder="Select visibility" />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent>
                      <SelectItem value="private">Private - Only you</SelectItem>
                      <SelectItem value="unlisted">Unlisted - Anyone with link</SelectItem>
                      <SelectItem value="public">Public - Visible to everyone</SelectItem>
                    </SelectContent>
                  </Select>
                  <FormMessage />
                </FormItem>
              )}
            />

            <DialogFooter className="gap-2 sm:gap-0">
              <Button
                type="button"
                variant="ghost"
                onClick={() => onOpenChange(false)}
                className="text-white/70 hover:bg-white/10 hover:text-white"
              >
                Cancel
              </Button>
              <Button
                type="submit"
                disabled={isLoading}
                className="bg-emerald-600 hover:bg-emerald-500"
              >
                {isLoading ? 'Saving...' : isEditing ? 'Save Changes' : 'Create Trip'}
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}

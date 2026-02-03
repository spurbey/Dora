export interface RouteMetadata {
  route_id: string;
  route_quality?: 'scenic' | 'fastest' | 'offbeat';
  road_condition?: 'excellent' | 'good' | 'poor' | 'offroad';
  scenic_rating?: number;
  safety_rating: number;
  solo_safe: boolean;
  fuel_cost?: number;
  toll_cost?: number;
  highlights?: string[];
  is_public: boolean;
  created_at: string;
  updated_at: string;
}

export interface RouteMetadataCreate {
  route_quality?: 'scenic' | 'fastest' | 'offbeat';
  road_condition?: 'excellent' | 'good' | 'poor' | 'offroad';
  scenic_rating?: number;
  safety_rating?: number;
  solo_safe?: boolean;
  fuel_cost?: number;
  toll_cost?: number;
  highlights?: string[];
  is_public?: boolean;
}

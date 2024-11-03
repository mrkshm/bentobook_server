Geocoder.configure(
  # Use PostGIS for distance calculations
  distances: :spherical,
  units: :km,
  distance_query_name: 'ST_Distance',
  geometry_factory: 'ST_MakePoint',
  geographic_factory: 'ST_SetSRID',
  coordinates_factory: 'ST_GeomFromText',
  lookup: :google,
  api_key: ENV['GOOGLE_MAPS_API_KEY']
)

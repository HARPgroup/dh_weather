CREATE OR REPLACE VIEW dh_timeseries_weather_varkey as (
  SELECT a.varkey, b.*, extract(DOY from to_timestamp(tsendtime)) as jday,
    extract(year from to_timestamp(tsendtime)) as yr,
    extract(month from to_timestamp(tsendtime)) as mo,
    extract(day from to_timestamp(tsendtime)) as da,
    extract(hour from to_timestamp(tsendtime)) as hr
  FROM dh_timeseries_weather b
  LEFT JOIN dh_variabledefinition a 
  ON a.hydroid = b.varid
);
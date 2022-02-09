-- SQL feature summaries from NOAA raster in dh_timeseries_weather
-- monthly summary 
\set target_id 256846
select hydroid, name, mo, max(nml) as max_nml_precip_in, sum(obs) as obs, sum(nml) as nml_precip_in 
from (
  select a.hydroid, a.name, 
    to_timestamp(c.tstime), 
    to_timestamp(c.tsendtime), 
    extract(month from to_timestamp(c.tstime)) as mo, 
    (ST_summarystats(st_clip(c.rast, b.dh_geofield_geom), 1, TRUE)).mean as obs, 
    (ST_summarystats(st_clip(c.rast, b.dh_geofield_geom), 2, TRUE)).mean as nml, 
    (ST_summarystats(st_clip(c.rast, b.dh_geofield_geom), 2, TRUE)).count as num
    from dh_feature as a 
    left outer join field_data_dh_geofield as b 
    on (
      entity_id = a.hydroid   
        and b.entity_type = 'dh_feature' 
    )
    left outer join dh_timeseries_weather as c 
    on ( 
      c.varid in (select hydroid from dh_variabledefinition where varkey = 'noaa_precip_raster' ) 
    )
    -- do for NOVA and Shenandoah drought regions
    -- Point of Rocks region is 437177 for testing
    -- NOVA 256846 
    -- Shenandoah 256848
--    where a.hydroid = 437177
    where a.hydroid = :target_id
    and c.featureid in (
      select hydroid 
      from dh_feature 
      where hydrocode = 'vahydro_nws_precip_grid' 
        and bundle = 'landunit' 
        and ftype = 'nws_precip_grid' 
    ) 
    and (ST_summarystats(st_clip(c.rast, b.dh_geofield_geom), 2, TRUE)).min >= 0
  -- test single raster date for 2018-11-07
  --  and c.tid = 29352595 
    and c.tstime >= extract(epoch from '2020-10-01'::timestamp)
    and c.tstime <= extract(epoch from '2021-09-30'::timestamp)
  order by c.tstime
) as foo 
group by hydroid, name, mo
order by hydroid, mo
;

select hydroid, name, observed_date, varid, round(nml::numeric,2) as nml, round(obs::numeric,2) as obs, round(mini::numeric) as mini, round(pct::numeric,2) as pct
from (
  select a.hydroid, a.name, c.varid,
    to_timestamp(c.tstime), 
    to_timestamp(c.tsendtime) as observed_date, 
    extract(month from to_timestamp(c.tstime)) as mo, 
    (ST_summarystats(st_clip(c.rast, b.dh_geofield_geom), 1, TRUE)).mean as obs, 
	(ST_summarystats(st_clip(c.rast, b.dh_geofield_geom), 2, TRUE)).min as mini,
    (ST_summarystats(st_clip(c.rast, b.dh_geofield_geom), 2, TRUE)).mean as nml, 
    (ST_summarystats(st_clip(c.rast, b.dh_geofield_geom), 2, TRUE)).count as num, 
    (ST_summarystats(st_clip(c.rast, b.dh_geofield_geom), 4, TRUE)).mean as pct
    from dh_feature as a 
    left outer join field_data_dh_geofield as b 
    on (
      entity_id = a.hydroid   
        and b.entity_type = 'dh_feature' 
    )
    left outer join dh_timeseries_weather as c 
    on ( 
      c.varid in (select hydroid from dh_variabledefinition where varkey = 'noaa_precip_raster' ) 
    )
    -- do for NOVA and Shenandoah drought regions
    -- Point of Rocks region is 437177 for testing
    -- NOVA 256846 
    -- Shenandoah 256848
--    where a.hydroid = 437177
    where a.hydroid = :target_id
    and c.featureid in (
      select hydroid 
      from dh_feature 
      where hydrocode = 'vahydro_nws_precip_grid' 
        and bundle = 'landunit' 
        and ftype = 'nws_precip_grid' 
    ) 
    and (ST_summarystats(st_clip(c.rast, b.dh_geofield_geom), 2, TRUE)).min >= 0
  -- test single raster date for 2018-11-07
  --  and c.tid = 29352595 
    and c.tstime >= extract(epoch from '2020-10-01'::timestamp)
    and c.tstime <= extract(epoch from '2021-09-30'::timestamp)
  order by c.tstime
) as foo 
order by hydroid, observed_date, mo
;


-- test
select varkey, to_timestamp(tstime), (stats).* from (
  select b.varkey, a.tstime, st_summarystats(rast, 2, TRUE) as stats
  from dh_timeseries_weather as a 
  left outer join dh_variabledefinition as b 
  on (a.varid = b.hydroid)
  where a.tid = 67418320
) as foo;

 count |       sum        |       mean        |       stddev       |        min         |        max
-------+------------------+-------------------+--------------------+--------------------+-------------------
 17295 | 1981.97349366546 | 0.114598062657731 | 0.0108370834623551 | 0.0811154916882515 | 0.195446193218231
(1 row)



-- do a whole water year for whole coverage
select varkey, to_timestamp(tsendtime), to_timestamp(tstime), obs, nml, (obs - nml) as diff_inches
from (
  select b.varkey, a.tstime, a.tsendtime, 
  (st_summarystats(rast, 1, TRUE)).mean as obs,
  (st_summarystats(rast, 2, TRUE)).mean as nml
  from dh_timeseries_weather as a 
  left outer join dh_variabledefinition as b 
  on (a.varid = b.hydroid)
  where b.varkey = 'precip_obs_wy2date'
  and a.tstime >= extract(epoch from '2020-10-01'::timestamp)
  and a.tstime <= extract(epoch from '2021-09-30'::timestamp)
) as foo
order by tsendtime;

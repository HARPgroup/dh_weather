-- single cell summary
\set cell_hydrocode '952-491'
select 'dh_feature', foo.hydroid, var.hydroid as varid, count(*),
  1601524800, 1643691600, 
  CASE
  WHEN SUM(nml) > 0 
  THEN 100.0 * SUM(obs) / sum(nml)
  ELSE 0   
  END as pct_normal  
  from dh_variabledefinition as var 
  left outer join (  
    select a.hydrocode, to_timestamp(tstime), a.hydroid, 
    st_astext(b.dh_geofield_geom),
    CASE
    WHEN ST_Value(rast, 1, b.dh_geofield_geom) is null THEN 0
    ELSE ST_Value(rast, 1, b.dh_geofield_geom)  
    END as obs,
    CASE
    WHEN ST_Value(rast, 2, b.dh_geofield_geom) is null THEN 0 
    ELSE ST_Value(rast, 2, b.dh_geofield_geom)   
    END as nml,
   and a.hydrocode = :'cell_hydrocode'
) as foo  on (1 = 1)  where var.varkey = 'precip_pct_2wy2date'
and foo.hydroid is not null
group by var.hydroid, foo.hydroid;
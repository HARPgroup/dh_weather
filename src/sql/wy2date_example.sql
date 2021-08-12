-- Import NOAA observed
-- Import NOAA wytd if available 

-- 2020/10/01 to 2021/08/07 
\set stime 1601524800 
\set etime 1628308800

-- 2020/10/01 to 2021/05/07 
\set stime 1601524800
\set etime 1620360000 
 
 insert into dh_timeseries_weather (entity_type, featureid, varid, tstime, tsendtime, rain)  


 select 'dh_feature', foo.hydroid, var.hydroid as varid, :stime, :etime,    
 CASE
 WHEN SUM(nml) > 0 THEN 100.0 * SUM(obs) / sum(nml)
 ELSE 0
 END as pct_normal
 from dh_variabledefinition as var 
 left outer join (   
   select a.hydrocode, to_timestamp(tstime),
   a.hydroid, st_astext(b.dh_geofield_geom),  
   CASE
   WHEN ST_Value(rast, 1, b.dh_geofield_geom) is null THEN 0  
   ELSE ST_Value(rast, 1, b.dh_geofield_geom)     
   END as obs,      
   CASE     
   WHEN ST_Value(rast, 2, b.dh_geofield_geom) is null THEN 0   
   ELSE ST_Value(rast, 2, b.dh_geofield_geom)     
   END as nml,    
   CASE    
   WHEN ST_Value(rast, 4, b.dh_geofield_geom) is null THEN 0   
   ELSE ST_Value(rast, 4, b.dh_geofield_geom)    
   END as pct   
   from dh_feature as a 
   left outer join field_data_dh_geofield as b   
   on (
    entity_id = a.hydroid    
    and b.entity_type = 'dh_feature'  
   ) 
   left outer join dh_timeseries_weather as c 
   on (    
	 c.varid in (select hydroid from dh_variabledefinition where varkey = 'precip_obs_wy2date' )    
   )  
   where a.bundle = 'weather_sensor'    
   and c.featureid in (   
	   select hydroid      
	   from dh_feature       
	   where hydrocode = 'vahydro_nws_precip_grid' 
	   and bundle = 'landunit'      
	   and ftype = 'nws_precip_grid'  
   )  
   and c.entity_type = 'dh_feature'  
   and a.ftype = 'nws_precip'
   and varid in (
     select hydroid from dh_variabledefinition where varkey = 'precip_obs_wy2date' 
   )      
   and c.tstime = :stime 
   and c.tsendtime = :etime  
) as foo  
on (1 = 1)  
where var.varkey = 'precip_pct_wy2date'  
group by var.hydroid, foo.hydroid;


274608
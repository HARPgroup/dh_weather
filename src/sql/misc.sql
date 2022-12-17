-- summarize variables and record counts for a given recent date range

select to_timestamp(a.tstime), to_timestamp(a.tsendtime), b.varkey,count(a.*)
from dh_timeseries_weather as a
left outer join dh_variabledefinition as b
on (a.varid = b.hydroid)
where a.tsendtime >= extract(epoch from '2021/08/05'::timestamp)
group by a.tstime, a.tsendtime, b.varkey
order by a.tstime;


-- summarize variables and record counts for a given recent date range
select to_timestamp(a.tstime), to_timestamp(a.tsendtime), 
  a.featureid, b.varkey, st_bandmetadata(a.rast,2)
from dh_timeseries_weather as a 
left outer join dh_variabledefinition as b 
on (a.varid = b.hydroid) 
where a.tsendtime >= extract(epoch from '2021/05/05'::timestamp) 
and b.varkey = 'precip_obs_wy2date'
order by a.tsendtime;

-- precip_obs_wy2date : source data from NOAA 
-- precip_pct_wy2date  : derived from NOAA source data by dividing obs / nml for period in question 
-- summarize variables and record counts for a given recent date range

select a.tstime, b.varkey,count(a.*) 
from dh_timeseries_weather as a 
left outer join dh_variabledefinition as b 
on (a.varid = b.hydroid) 
where a.tstime >= extract(epoch from '2021/08/05'::timestamp) 
group by a.tstime, b.varkey  
order by a.tstime;


-- show rain data 
select a.tstime, b.varkey, a.featureid, rain 
from dh_timeseries_weather as a 
left outer join dh_variabledefinition as b 
on (a.varid = b.hydroid) 
where a.tstime >= extract(epoch from '2021/07/05'::timestamp) 
order by a.tstime;


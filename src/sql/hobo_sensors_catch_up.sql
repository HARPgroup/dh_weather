COPY (
select a.hydroid, b.propcode, c.propcode,
  min(ceil((extract(epoch from now()) - tsw.tstime)/86400)) as days_behind
from dh_properties as b 
left outer join dh_feature as a 
on (
  a.hydroid = b.featureid) 
left outer join dh_properties as c 
on (
  c.featureid = b.featureid 
  and c.propname = 'hobo_userid' 
  and c.entity_type = 'dh_feature'
) 
left outer join dh_timeseries_weather as tsw 
on (
  tsw.featureid = a.hydroid
  and tsw.entity_type = 'dh_feature'
  and tsw.varid in (select hydroid from dh_variabledefinition where varkey = 'weather_obs')
)
where b.entity_type = 'dh_feature' 
and b.propname = 'hobo_logger'
group by a.hydroid, b.propcode, c.propcode
) to '/tmp/hobo_devices.txt' with CSV
;

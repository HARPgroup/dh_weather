-- jhust a single sensor (not blocks)

select met.varid, sensor.hydroid as sensor, met.yr, met.mo,  
	count(met.tid),  
	sum(met.rain) * 0.0393701 as rain_in
FROM dh_feature as sensor 
left outer join dh_timeseries_weather_varkey as met
on (
    met.featureid = sensor.hydroid 
	and met.varkey = 'weather_obs'
	)
where sensor.hydroid = 7702
group by met.varid, met.yr, met.mo, sensor.hydroid
order by met.varid, met.yr, met.mo, sensor.hydroid
;


select met.varid, block.hydroid as block, sensor.hydroid as sensor, met.yr, met.mo,  
	count(met.tid),  
	sum(met.rain) * 0.0393701 as rain_in
FROM dh_feature as farm 
LEFT OUTER JOIN field_data_dh_link_facility_mps as link_block
on (
  farm.hydroid = link_block.dh_link_facility_mps_target_id 
  AND link_block.entity_type = 'dh_feature'
)
LEFT OUTER JOIN dh_feature as block 
ON (
  link_block.entity_id = block.hydroid
  and block.bundle = 'landunit'
)

LEFT OUTER JOIN field_data_dh_link_station_sensor as link_sensor
ON (
  farm.hydroid = link_sensor.dh_link_station_sensor_target_id 
  AND link_sensor.entity_type = 'dh_feature'
)
LEFT OUTER JOIN dh_feature as sensor 
ON (
   link_sensor.entity_id = sensor.hydroid
)
left outer join dh_timeseries_weather_varkey as met
on (
    met.featureid = sensor.hydroid 
	and met.varkey = 'weather_obs'
	)
where farm.hydroid = 146
group by met.varid, met.yr, met.mo, block.hydroid, sensor.hydroid
order by met.varid, met.yr, met.mo, block.hydroid, sensor.hydroid
;

select met.varid, block.hydroid as block, sensor.hydroid as sensor, met.yr, met.mo,  
	count(met.tid),  
	sum(met.rain) * 0.0393701 as rain_in
FROM dh_feature as farm 
LEFT OUTER JOIN field_data_dh_link_facility_mps as link_block
on (
  farm.hydroid = link_block.dh_link_facility_mps_target_id 
  AND link_block.entity_type = 'dh_feature'
)
LEFT OUTER JOIN dh_feature as block 
ON (
  link_block.entity_id = block.hydroid
  and block.bundle = 'landunit'
)

LEFT OUTER JOIN field_data_dh_link_station_sensor as link_sensor
ON (
  farm.hydroid = link_sensor.dh_link_station_sensor_target_id 
  AND link_sensor.entity_type = 'dh_feature'
)
LEFT OUTER JOIN dh_feature as sensor 
ON (
   link_sensor.entity_id = sensor.hydroid
)
left outer join dh_timeseries_weather_varkey as met
on (
    met.featureid = sensor.hydroid 
	and met.varkey = 'weather_obs'
	)
where sensor.hydroid = 7702
group by met.varid, met.yr, met.mo, block.hydroid, sensor.hydroid
order by met.varid, met.yr, met.mo, block.hydroid, sensor.hydroid
;


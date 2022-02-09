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

library("rjson")
site = "https://webservice.hobolink.com"

client_info <- rjson::fromJSON(file="/opt/model/config.private")
username <- as.character(client_info$onset_client_id)
userpass <- as.character(client_info$onset_client_secret)

# Get Credentials
# command line
# curl -i -H "Content-type: application/x-www-form-urlencoded" -H "Accept: application/json" -d "grant_type=client_credentials" -d "client_id=nita24_WS" -d "client_secret=20d84f367498bc440b37191a1259e0b16178afe6" --data-urlencode -X POST https://webservice.hobolink.com/ws/auth/token
token_inputs <- list(
  client_id = username,
  client_secret = userpass,
  grant_type = 'client_credentials'
)
token_rest <- httr::POST(
  paste0(site, "/","ws/auth/token"),
  encode = "form",
  httr::content_type("application/x-www-form-urlencoded"),
  query = token_inputs
  
);

hobo_response <- httr::content(token_rest)
access_token <- hobo_response$access_token


# get data
# cmd line: /ws/data/file/{format}/user/{userId}?loggers={loggerList}&start_date_time={startTime}&end_date_time={endTime}
userid = 7451 # Miz account id
start_date = '2022-01-01 00:00:00'
end_date = '2022-01-01 23:59:59'
inputs <- list(
  loggers = "20622331", # MtAlto serial num
  start_date_time = start_date,
  end_date_time = end_date,
  only_new_data = 0
#  Bearer=access_token,
#  client_secret=access_token
)
get_url = paste(site,"ws/data/file", "json", "user", userid, sep="/")
#get_url = paste(site,"file", "json", "user", userid, sep="/")
hobo_rest <- httr::GET(
  get_url,
  encode = "application/json",
  query = inputs,
  config = list(token = access_token),
#  httr::add_headers("token" = access_token),
  httr::add_headers(Authorization=paste("bearer", access_token)),
  httr::verbose()
);
hobo_rest
raw_data = httr::content(hobo_rest)$observation_list
fid = 99 # placeholder for featureid of weather sensor
rbd = FALSE
for (r in raw_data) {
  thisrec <- list(
    featureid = fid,
    varkey = r$sensor_measurement_type,
    entity_type = 'dh_properties',
    tstime = r$timestamp,
    tsvalue = r$si_value
  )
  if (is.logical(rbd)) {
    rbd = as.data.frame(thisrec)
  } else {
    rbd <- rbind(rbd, as.data.frame(thisrec))
  }
}
rbdnb <- sqldf::sqldf(
  "
    select a.featureid, a.tstime, 'weather_obs' as varkey, 
      a.tsvalue as tempr, 
      wet.tsvalue as wet, 
      dpt.tsvalue as dpt, 
      wind.tsvalue as wind, 
      rain.tsvalue as rain, 
      rad.tsvalue as rad
    from rbd as a 
    left outer join rbd as wet 
    on (
      a.tstime = wet.tstime
      and wet.varkey = 'Wetness'
    )
    left outer join rbd as wind 
    on (
      a.tstime = wind.tstime
      and wind.varkey = 'Wind Speed'
    )
    left outer join rbd as dpt 
    on (
      a.tstime = dpt.tstime
      and dpt.varkey = 'Dew Point'
    )
    left outer join rbd as rain 
    on (
      a.tstime = rain.tstime
      and rain.varkey = 'Rain'
    )
    left outer join rbd as rad 
    on (
      a.tstime = rad.tstime
      and rad.varkey = 'Solar Radiation'
    )
    where a.varkey = 'Temperature'

  "
)

rbdnb
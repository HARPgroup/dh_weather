library("rjson")
# get command args

argst <- commandArgs(trailingOnly=T)
if (is.na(argst[1])) {
  message("Use: Rscript get_licor_ts.R featureid entity_type hobo_userid hobo_logger start_date end_date outfile")
  message("Ex: Rscript get_licor_ts.R 6919 dh_feature 7451 20622331 \"2022-01-01 00:00:00\" \"2022-01-01 23:59:59\" /tmp/dhw_test.txt")
  q("no")
}
f_id <- as.integer(argst[1])
e_type <- argst[2]
userid <- as.integer(argst[3])
logger <- as.integer(argst[4])
start_date <- argst[5]
end_date <- argst[6]
if (argst[6] == 'now') {
  end_date <- format(Sys.time(),"%Y-%m-%d %H:%M:%S")
}
outfile <- argst[7]
# test dataset
# f_id = 6920
# e_type = 'dh_feature'
# userid = 7451 # Miz account id
# start_date = '2025-02-27 00:00:00'
# end_date = '2025-02-27 23:59:59'
# logger = "20622331"


# declare/load the base info
site = "https://api.licor.cloud"
client_info <- rjson::fromJSON(file="/opt/model/config.private")
access_token <- as.character(client_info$licor_token)

# get data
# cmd line: /ws/data/file/{format}/user/{userId}?loggers={loggerList}&start_date_time={startTime}&end_date_time={endTime}
inputs <- list(
  loggers = logger, # MtAlto serial num
  start_date_time = start_date,
  end_date_time = end_date,
  only_new_data = 0
)
get_url = paste(site,"v1/data",sep="/")
licor_rest <- httr::GET(
  get_url,
  encode = "application/json",
  query = inputs,
  config = list(token = access_token),
  httr::add_headers(Authorization=paste("bearer", access_token)),
  httr::verbose()
) 
#licor_rest
raw_data = httr::content(licor_rest)$data

rbd = FALSE
for (r in raw_data) {
  thisrec <- list(
    featureid = f_id,
    varkey = r$sensor_measurement_type,
    entity_type = e_type,
    tstime = r$timestamp,
    tsvalue = r$value
  )
  if (is.logical(rbd)) {
    rbd = as.data.frame(thisrec)
  } else {
    rbd <- rbind(rbd, as.data.frame(thisrec))
  }
}
# note we assume a 5 minute interval here for wetness
# this is due to a unit shift when switching to hobo
# note we convert the si_value in display but all are stored as SI 
rbdnb <- sqldf::sqldf(
  "
    select a.featureid, a.tstime, 'weather_obs' as varkey, 
      'dh_feature' as entity_type,
      a.tsvalue as temp, 
      wet.tsvalue as wet_pct, 
      dpt.tsvalue as dpt, 
      wind.tsvalue as wind, 
      rain.tsvalue as rain, 
      rad.tsvalue as rad, 
      rh.tsvalue as rh
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
    left outer join rbd as rh 
    on (
      a.tstime = rh.tstime
      and rh.varkey = 'RH'
    )
    where a.varkey = 'Temperature'

  "
)



origin <- "1970-01-01"
rbdnb$hour <- format(as.POSIXct(rbdnb$tstime, origin="UTC"), "%H")
rbdnb$day <- format(as.POSIXct(rbdnb$tstime, origin="UTC"), "%d")
rbdnb$month <- format(as.POSIXct(rbdnb$tstime, origin="UTC"), "%m")
rbdnb$year <- format(as.POSIXct(rbdnb$tstime, origin="UTC"), "%Y")

# transform to hourly to save space and 
# also t oconvert wet_pct to wet_duration
db_hr <- sqldf::sqldf(
  "
    select a.year, a.month, a.day, a.hour, a.featureid, 
    a.entity_type, a.varkey,
    60.0 * (0.01 * sum(a.wet_pct)) / count(a.tstime) as wet_time,
    avg(rh) as rh,
    avg(temp) as temp, 
    avg(dpt) as dpt, 
    avg(wind) as wind, 
    avg(rad) as rad, 
    sum(rain) as rain
    from rbdnb as a
    group by a.year, a.month, a.day, a.hour, 
    a.featureid, a.entity_type, a.varkey
  "
)
db_hr$tstime <- paste0(
  db_hr$year,"-",db_hr$month, "-", db_hr$day,
  " ", db_hr$hour, ":00:00"
)
db_hr$tstime <-as.numeric(as.POSIXlt(db_hr$tstime, tz="GMT"))
#as.POSIXct(db_hr$tstime[224], origin="1960-01-01")

dh_cols = c(
  'tstime','entity_type', 'featureid', 
  'rain', 'wind', 'rad', 'wet_time',
  'rh', 'temp', 'dpt', 'varkey'
)
db_hr <- db_hr[dh_cols]

write.table(db_hr, outfile, row.names=FALSE, sep='\t')
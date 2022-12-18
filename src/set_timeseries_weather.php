#!/user/bin/env drush
<?php
module_load_include('module', 'dh_weather');

$args = array();
while ($arg = drush_shift()) {
  $args[] = $arg;
}
$use_msg = "Usage: php set_timeseries_weather.php query_type entity_type featureid varkey propname propvalue propcode [extras as urlenc key1=val1&key2=val2...] ";
error_log("Import TIMESEREIS");
if (count($args) < 1) {
  error_log($use_msg);
  die;
}
error_log("Args:" . print_r($args,1));
/*
$query_type = $args[0];
$data = array();
if ($query_type == 'cmd') {
  error_log("cmd mode not yet enabled.  Use file import only.")
  error_log("$use_msg");
  die;
  if (count($args) >= 6) {
    $vars = array();
    $vars['entity_type'] = $args[1];
    $vars['featureid'] = $args[2];
    $vars['varkey']= $args[3];
    $vars['propname'] = $args[4];
    $vars['propvalue'] = $args[5];
    $vars['propcode'] = $args[6];
    $vars['extras'] = $args[7];
    $data[] = $vars;
  } else {
    error_log("Usage: php om_setprop.php query_type entity_type featureid varkey propname propvalue propcode [extras as urlenc key1=val1&key2=val2...] ");
    die;
  }
} else {
  $filepath = $args[1];
  error_log("File requested: $filepath");
  $file = fopen($filepath, 'r');
  $header = fgetcsv($file, 0, "\t");
  if (count($header) == 0) {
    $header = fgetcsv($file, 0, "\t");
  }
  while ($line = fgetcsv($file, 0, "\t")) {
    $data[] = array_combine($header,$line);
  }
  error_log("File opened with records: " . count($data));
  error_log("Header: " . print_r($header,1));
  error_log("Record 1: " . print_r($data[0],1));
}



foreach ($data as $element) {

  error_log(print_r($element,1));
  
  $tsw_result = dh_update_timeseries_weather($element);
  if ($tsw_result === FALSE) {
    error_log("Problem adding weather data" . print_r($element,1)); 
  } else {
    error_log("Added tid = $tsw_result");
  }
}
*/
?>
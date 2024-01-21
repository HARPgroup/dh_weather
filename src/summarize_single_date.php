#!/user/bin/env drush
<?php
module_load_include('module', 'dh_weather');

$args = array();
while ($arg = drush_shift()) {
  $args[] = $arg;
}
$use_msg = "Usage: php sumarize_single_date.php entity_type featureid thisdate ";
if (count($args) < 3) {
  error_log($use_msg);
  die;
}
error_log("arg 1:" . $args[1]);
$entity_type = $args[2];
$featureid = $args[3];
$thisdate = $args[4];

$sumvar = array_shift(dh_varkey2varid('weather_obs_daily_sum'));
$values = array(
  'featureid' => $featureid,
  'entity_type' => 'dh_feature',
  'tstime' => $thisdate,
  'varid' => $sumvar
);
echo "Updating $featureid - $thisdate for varid = $sumvar \n";
dh_update_timeseries_weather($values, 'tstime_date_singular');

?>
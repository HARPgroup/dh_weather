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
$entity_type = $args[1];
$featureid = $args[2];
$thisdate = $args[3];

$sumvar = array_shift(dh_varkey2varid('weather_obs_daily_sum'));
$values = array(
  'featureid' => $sensor,
  'entity_type' => 'dh_feature',
  'tstime' => $thisdate,
  'varid' => $sumvar
);
echo "Updating $sensor - $thisdate for varid = $sumvar \n";
dh_update_timeseries_weather($values, 'tstime_date_singular');

?>
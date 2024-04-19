#!/user/bin/env drush
<?php
module_load_include('module', 'dh_weather');

$args = array();
while ($arg = drush_shift()) {
  $args[] = $arg;
}
$use_msg = "Usage: php summarise_last24.php entity_type featureid ";
error_log("Doing last 24 hour summary");
if (count($args) < 2) {
  error_log($use_msg);
  die;
}
error_log("Args:" . print_r($args,1));
$entity_type = $args[0];
$featureid = $args[1];

$values = array(
  'featureid' => $featureid,
  'entity_type' => $entity_type,
  'tstime' => date('Y-m-d'), // this will be overwritten by the plugin as there is only 1
  'varid' => 'weather_pd_last24hrs'
);
$tid = dh_update_timeseries_weather($values, 'singular');
echo "Updated $sensor - $thisdate for varid = weather_pd_last24hrs = tid $tid\n";

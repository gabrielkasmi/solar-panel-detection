-- Before running this query:
-- 1. Create DB with database/solar_db.sql
-- 2. Create osm_repd_closest table with db/osm-repd/find-closest-repd-to-osm.sql

drop table if exists match_rule_9_results;
drop table if exists temp_table;

select
  osm_repd_closest.osm_id,
  osm_repd_id_mapping.repd_id as osm_repd_id,
  osm_repd_closest.closest_geo_match_from_repd_repd_id,
  osm_repd_closest.closest_geo_match_from_repd_co_location_repd_id,
  osm_repd_closest.site_name,
  osm_repd_closest.distance_meters
into temp_table
from osm_repd_closest
left join osm_repd_id_mapping on osm_repd_closest.osm_id = osm_repd_id_mapping.osm_id
where osm_repd_closest.distance_meters < 500;

select *
into repd_copy
from repd;

select
  CONCAT  (osm.objtype, '/', temp_table.osm_id) AS "osm",
  temp_table.closest_geo_match_from_repd_repd_id as repd_id,
  temp_table.closest_geo_match_from_repd_co_location_repd_id as co_repd,
  temp_table.site_name as r_name,
  temp_table.osm_repd_id,
  repd_copy.site_name as or_name,
  temp_table.distance_meters as d,
  -- osm.objtype,
  -- osm.time_created,
  -- osm.area,
  -- osm.latitude as o_lat,
  -- osm.longitude as o_lon,
  repd.latitude as r_lat,
  repd.longitude as r_lon,
  repd_copy.latitude as or_lat,
  repd_copy.longitude as or_lot
  -- osm.located
into match_rule_9_results
from temp_table, osm, repd, repd_copy
where temp_table.osm_id = osm.osm_id
and (temp_table.closest_geo_match_from_repd_repd_id = repd.repd_id -- use this to display other repd fields
  or temp_table.closest_geo_match_from_repd_co_location_repd_id = repd.repd_id)
and temp_table.osm_repd_id = repd_copy.repd_id -- use this do display other REPD fields for the REPD tagged in OSM
and temp_table.osm_repd_id != temp_table.closest_geo_match_from_repd_repd_id
and repd.operational is not null;

drop table temp_table;
drop table repd_copy;

select * from match_rule_9_results;

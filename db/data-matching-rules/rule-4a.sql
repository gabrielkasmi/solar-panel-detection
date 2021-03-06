-- Match rule 4a (see doc/matching.md)
\echo -n Performing match rule 4a...

insert into matches
select '4a', repd_non_operational.master_repd_id, osm.master_osm_id
  from osm_repd_neighbours, osm, repd_non_operational
  -- Table linking:
  where osm_repd_neighbours.osm_id = osm.osm_id
  and osm_repd_neighbours.closest_geo_match_from_repd_repd_id = repd_non_operational.repd_id
  and osm.osm_id = osm.master_osm_id
  and repd_non_operational.repd_id = repd_non_operational.master_repd_id
  -- Not matches already found:
  and not exists (
    select
    from matches
    where matches.master_repd_id = repd_non_operational.master_repd_id
    or matches.master_osm_id = osm.master_osm_id
  )
  -- Matching relevant:
  and osm.objtype = 'node'
  and repd_non_operational.site_name like '%Scheme%'
  and osm_repd_neighbours.distance_meters < 5000;

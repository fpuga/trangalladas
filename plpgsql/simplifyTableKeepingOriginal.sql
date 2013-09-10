-- bck schema name is hardcoded to 'original'
-- gid is hardcoded as a serial primary key
-- sequence name for gid field is hardcoded as <schema>.<tablename>_gid_seq
-- geometry field name is hardcoded as 'geom'
-- triggers are not copied
-- TODO: Check if using INCLUDING INDEXES in create table instead of INCLUDE ALL handles correctly the sequences
-- TODO: A better function will create different basic tables from the original one with statistics
--       about the reduction and the lost of precision
CREATE OR REPLACE FUNCTION simplifyTableKeepingOriginal(schema text, tablename text, tolerance integer) RETURNS void AS $function$
	DECLARE
		seq_name text := schema || '.' || tablename || '_gid_seq';

		BEGIN

			IF (SELECT true FROM public.geometry_columns WHERE f_table_schema = schema AND f_table_name = tablename AND type = 'POINT') THEN
				RAISE NOTICE 'Geometry type is POINT. Exiting';
				RETURN ;
			END IF;
			IF NOT EXISTS (SELECT 1  FROM pg_catalog.pg_namespace where nspname = 'original')  THEN
				CREATE SCHEMA original;
				CREATE TABLE original.differences (
					tablename TEXT,
					original_gid INTEGER,
					total_size FLOAT,
					per_size FLOAT,
					points_original INTEGER,
					points_actual INTEGER
				);
			END IF;
		-- EXECUTE 'ALTER TABLE ' || schema || '.' || tablename || ' SET SCHEMA original;';
		EXECUTE format('ALTER TABLE %I.%I SET SCHEMA original', schema, tablename);
		EXECUTE 'CREATE TABLE ' || schema || '.' || tablename || '(LIKE original.' || tablename || ' INCLUDING ALL);';
		EXECUTE 'ALTER TABLE ' || schema || '.' || tablename || ' ALTER gid DROP DEFAULT;';
		EXECUTE 'CREATE SEQUENCE ' || seq_name || ' OWNED BY ' || schema || '.' || tablename || '.gid;' ;
		EXECUTE 'INSERT INTO ' || schema || '.' || tablename || ' SELECT * FROM original.' || tablename;
		-- ST_Multi is used because st_simplify can reduce multipolygons to polygons and this violates the table constraints
		EXECUTE 'UPDATE ' || schema || '.' || tablename || ' SET geom=ST_Multi(ST_SimplifyPreserveTopology(geom, ' || tolerance || '));';
		EXECUTE 'SELECT setval($$' || seq_name || '$$ , (SELECT max(gid) FROM ' || schema || '.' || tablename || '), true);';
		EXECUTE 'ALTER TABLE ' || schema || '.' || tablename || ' ALTER gid SET DEFAULT nextval($$' || seq_name || '$$);';

		IF (SELECT true FROM public.geometry_columns WHERE f_table_schema = schema AND f_table_name = tablename AND type like '%LINESTRING%') THEN
					EXECUTE 'INSERT INTO original.differences SELECT $$' || tablename || '$$, original.gid, ST_Length(ST_SymDifference(original.geom, actual.geom)) AS total, ST_Length(ST_SymDifference(original.geom, actual.geom))/ST_Length(original.geom) AS per, st_npoints(actual.geom)/st_npoints(original.geom)::float AS per_points FROM original.' || tablename || ' AS original JOIN ' || schema || '.' || tablename || ' AS actual ON original.gid = actual.gid ;';
		ELSE
		EXECUTE 'INSERT INTO original.differences SELECT $$' || tablename || '$$, original.gid, ST_Area(ST_SymDifference(original.geom, actual.geom)) AS total, ST_Area(ST_SymDifference(original.geom, actual.geom))/ST_Area(original.geom) AS per, st_npoints(original.geom), st_npoints(actual.geom) FROM original.' || tablename || ' AS original JOIN ' || schema || '.' || tablename || ' AS actual ON original.gid = actual.gid ;';
			END IF;
	END;
$function$ LANGUAGE plpgsql;

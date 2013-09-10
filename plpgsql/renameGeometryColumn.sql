-- Renames 'the_geom' to 'geom' making the appropiate changes in geometry_columns table. The rename operation includes:
--   + gist index, if it has the name tablename_the_geom_idx or tablename_the_geom_gist
--   + constraints if they have the default names: enforce_srid_the_geom, enforce_geotype_the_geom, enforce_dims_the_geom
--     constraints are dropped and the added with the new name. This can be a heavy operation
-- If SRID is provided that srid is used for the constraints

-- To iterate over a schema something like this can be done
-- select 'select renamegeometrycolumn(''c_base'', ''' || tablename || ''', 32616)' from pg_tables where schemaname='c_base';
CREATE OR REPLACE FUNCTION renameGeometryColumn(schema text, tablename text, srid integer default -1) RETURNS void AS $BODY$

	BEGIN
		IF (SELECT true FROM information_schema.columns WHERE table_schema=schema AND table_name=tablename AND column_name='the_geom') THEN
			EXECUTE format('ALTER TABLE %I.%I RENAME the_geom TO geom', schema, tablename);
		END IF;
		EXECUTE format('ALTER TABLE %I.%I DROP CONSTRAINT IF EXISTS enforce_srid_the_geom', schema, tablename);
		EXECUTE format('ALTER TABLE %I.%I DROP CONSTRAINT IF EXISTS enforce_geotype_the_geom', schema, tablename);
		EXECUTE format('ALTER TABLE %I.%I DROP CONSTRAINT IF EXISTS enforce_dims_the_geom', schema, tablename);

		IF (SELECT true FROM pg_class WHERE relname=tablename || '_the_geom_gist' AND relkind='i' ) THEN

			EXECUTE format('ALTER INDEX %I.%s_the_geom_gist RENAME TO %s_geom_idx', schema, tablename, tablename);
		END IF;

		IF (SELECT true FROM pg_class WHERE relname=tablename || '_the_geom_idx' AND relkind='i' ) THEN
			EXECUTE format('ALTER INDEX %I.%s_the_geom_idx RENAME TO %s_geom_idx', schema, tablename,
 tablename);
		END IF;

		EXECUTE format('SELECT Populate_Geometry_Columns($$%s.%s$$::regclass)', schema, tablename);
		DELETE FROM public.geometry_columns WHERE f_geometry_column='the_geom' AND f_table_schema=schema AND f_table_name=tablename;
		IF srid <> -1 THEN
			PERFORM updategeometrysrid(schema, tablename, 'geom', srid);
		END IF;
END;
$BODY$ LANGUAGE plpgsql;

-- cantones 10
-- carreteras 5

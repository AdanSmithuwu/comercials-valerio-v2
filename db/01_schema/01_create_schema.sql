CREATE DATABASE cv_comercial_valerio;

CREATE SCHEMA cv;
SELECT schema_name FROM information_schema.schemata;
ALTER DATABASE cv_comercial_valerio
SET search_path TO cv, public;

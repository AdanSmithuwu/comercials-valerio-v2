CREATE DATABASE cv_ventas_v2;

CREATE SCHEMA cv;
SELECT schema_name FROM information_schema.schemata;
ALTER DATABASE cv_ventas_v2
SET search_path TO cv, public;

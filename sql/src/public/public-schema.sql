/**
 *  Create a user/role
 */

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='testuser') THEN
    CREATE ROLE testuser WITH LOGIN;
  END IF;
END$$;

/**
 *  Public Schema
 */
DO $$
BEGIN
  -- public schema
  IF EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'public') THEN
    RAISE NOTICE 'Schema ''public'' already exists. Dropping cascade.';
    DROP SCHEMA public CASCADE;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'public') THEN
    CREATE SCHEMA public AUTHORIZATION postgres;
  END IF;

  GRANT USAGE ON SCHEMA public TO testuser;
END$$;

/**
 *  Sign up table
 */
DROP TABLE IF EXISTS complex;

CREATE TABLE IF NOT EXISTS complex (
  "real" int NOT NULL,
  imaginary int NOT NULL,
  CONSTRAINT "complex_PK" PRIMARY KEY ("real", imaginary)
);

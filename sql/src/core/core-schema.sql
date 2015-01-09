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
 *  Core Schema
 */
DO $$
BEGIN
  -- core schema
  IF EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'core') THEN
    RAISE NOTICE 'Schema ''core'' already exists. Dropping cascade.';
    DROP SCHEMA public CASCADE;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'core') THEN
    CREATE SCHEMA core AUTHORIZATION postgres;
  END IF;

  GRANT USAGE ON SCHEMA core TO testuser;
END$$;

/**
 *  Sign up table
 */
DROP TABLE IF EXISTS core.complex;

CREATE TABLE IF NOT EXISTS core.complex (
  "real" int NOT NULL,
  imaginary int NOT NULL,
  CONSTRAINT "complex_PK" PRIMARY KEY ("real", imaginary)
);

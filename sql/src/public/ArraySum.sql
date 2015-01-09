------------------------------------------------------------------------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION ArraySum(IN _numbers complex[] DEFAULT ARRAY[]::complex[],
                                    OUT result int) AS $$
DECLARE
  _number complex%ROWTYPE;
BEGIN
  FOREACH _number IN ARRAY _complex LOOP
    result := result + _number.real;
  END LOOP;
END;
$$ LANGUAGE plpgsql STRICT VOLATILE
SECURITY DEFINER
SET search_path = public, pg_temp;

REVOKE ALL ON FUNCTION ArraySum(complex[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION ArraySum(complex[]) TO testuser;
--COMMIT;
------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------
--BEGIN;
CREATE OR REPLACE FUNCTION core.ArraySum(IN _numbers core.complex[] DEFAULT ARRAY[]::core.complex[],
                                         OUT retval bigint) AS $$
DECLARE
  _number core.complex%ROWTYPE;
BEGIN
  retval := 0;
  FOREACH _number IN ARRAY _numbers LOOP
    retval := retval + _number.real;
  END LOOP;
END;
$$ LANGUAGE plpgsql STRICT VOLATILE
SECURITY DEFINER
SET search_path = public, pg_temp;

REVOKE ALL ON FUNCTION core.ArraySum(core.complex[]) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION core.ArraySum(core.complex[]) TO testuser;
--COMMIT;
------------------------------------------------------------------------------------------------------------------------------


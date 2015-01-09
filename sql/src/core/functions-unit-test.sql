BEGIN;
SELECT * FROM core.arraysum(ARRAY[
    row(0,0)::complex,
    row(1,1)::complex,
    row(2,2)::complex,
    row(3,3)::complex,
    row(4,4)::complex
  ]::complex[]);
COMMIT;
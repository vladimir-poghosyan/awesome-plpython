-- An aggregate for computing all permutations of TEXT values using PL/Python.
--
-- Collects input values into an array (state) and returns all permutations as JSONB.
--
-- Notes:
-- - Uses Python's standard library `itertools.permutations`, which is not available in plain SQL.
-- - Returns a single JSONB value instead of SETOF rows (required for aggregates).
-- - Handles NULL input values by ignoring them during aggregation.
-- - Factorial growth: output size grows extremely quickly with the number of elements.
-- - Can be used as a window function, but recomputation for sliding frames can be expensive.
-- - For a pure SQL/PLpgSQL approach (more complex), see:
--       https://wiki.postgresql.org/wiki/Permutations
--
-- Usage examples:
--   -- Simple aggregation
--   SELECT permutations(val) FROM (VALUES ('a'), ('b'), ('c')) AS tmp(val);
--
--   -- Window function example (full partition)
--   SELECT val, permutations(val) OVER () AS perms FROM (VALUES ('a'), ('b'), ('c')) AS tmp(val);
CREATE OR REPLACE FUNCTION permutations_sfunc(state TEXT[], value TEXT)
    RETURNS TEXT[]
AS $$
    current_state = [] if state is None else state

    if value is not None:
        current_state.append(value)

    return current_state
$$ LANGUAGE plpython3u IMMUTABLE;


CREATE OR REPLACE FUNCTION permutations_final(state TEXT[])
    RETURNS JSONB
AS $$
    from itertools import permutations
    from json import dumps


    return dumps(tuple(permutations(state))) if state else '[]'
$$ LANGUAGE plpython3u IMMUTABLE;


CREATE AGGREGATE permutations(TEXT) (
    SFUNC = permutations_sfunc,
    STYPE = TEXT[],
    FINALFUNC = permutations_final
);

-- A simple text comparison function based on Python's "difflib" module.
--
-- Compares two text values and returns either:
--   • a line-by-line diff (default, using ndiff)
--   • an HTML table representation (if as_html = TRUE)
--
-- Notes:
-- - Uses Python's standard library (difflib), which is not available in plain SQL.
-- - Intended for debugging, inspection, or small-scale comparisons (not bulk processing).
-- - Returns NULL if any input is NULL (PostgreSQL-style null propagation).
--
-- Usage examples:
--   SELECT diff('foo', 'bar');
--   SELECT diff('foo', 'bar', TRUE);
CREATE OR REPLACE FUNCTION diff(a TEXT, b TEXT, as_html BOOLEAN DEFAULT FALSE)
    RETURNS TEXT
AS $$
    from difflib import ndiff, HtmlDiff
    from textwrap import dedent


    # return NULL if any input is NULL
    if a is None or b is None:
        return None

    # split text into lines while preserving line endings
    # this ensures accurate and readable diff output
    a_lines = a.splitlines(keepends=True)
    b_lines = b.splitlines(keepends=True)

    if as_html:
        result = dedent(HtmlDiff().make_table(a_lines, b_lines))
    else:
        result = '\n'.join(ndiff(a_lines, b_lines))

    return result
$$ LANGUAGE plpython3u IMMUTABLE;

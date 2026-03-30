-- The simplest sentiment analysis directly inside PostgreSQL using PL/Python.
--
-- Creates:
--   • reviews table → stores user reviews and derived sentiment data
--   • analyze_sentiment trigger → automatically analyzes sentiment on INSERT/UPDATE
--
-- Behavior:
-- - Uses Python's "textblob" library to compute sentiment polarity.
-- - Polarity is a float in range [-1.0, 1.0]:
--     • > 0  → positive
--     • < 0  → negative
--     • = 0  → neutral
-- - Automatically populates:
--     • polarity  → numeric sentiment score
--     • reaction  → 'positive' | 'negative' | 'neutral'
--
-- Notes:
-- - Runs as a BEFORE INSERT OR UPDATE trigger (modifies incoming row).
-- - If review is NULL or empty, sentiment is not computed.
-- - Intended for simple use cases and demonstrations, not large-scale NLP workloads.
--
-- Requirements:
-- - Python "textblob" package must be installed in the PostgreSQL environment.
--
-- Usage example:
--   INSERT INTO reviews(email, review) VALUES ('user@example.com', 'Great app!');
--   SELECT * FROM reviews;
--
-- Example output:
--   review → "Great app!"
--   polarity → 0.8
--   reaction → "positive"
CREATE TABLE IF NOT EXISTS reviews (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    email TEXT,
    review TEXT,
    reaction TEXT,
    polarity FLOAT,
    created TIMESTAMP WITHOUT TIME ZONE DEFAULT now()
);

CREATE OR REPLACE FUNCTION analyze_sentiment()
    RETURNS trigger
AS $$
    from textblob import TextBlob


    if review := TD['new']['review']:
        polarity = TextBlob(review).sentiment.polarity
        TD['new']['polarity'] = polarity

        if polarity > 0:
            TD['new']['reaction'] = 'positive'
        elif polarity < 0:
            TD['new']['reaction'] = 'negative'
        else:
            TD['new']['reaction'] = 'neutral'

    return "MODIFY"
$$ LANGUAGE plpython3u;

CREATE TRIGGER tg_analyze_sentiment BEFORE INSERT OR UPDATE ON reviews
    FOR EACH ROW EXECUTE FUNCTION analyze_sentiment();

INSERT INTO reviews(email, review) VALUES
    ('john.dow@domain.org', 'I am really pleased with how your application works. Thank you!'),
    ('jane.dow@domain.org', 'I tried to use the app, but there are too many errors!'),
    ('', 'I absolutely hate it. Nothing works...');

SELECT * FROM reviews;

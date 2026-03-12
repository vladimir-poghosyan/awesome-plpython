-- The simplest sentiment analysis right inside the database
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

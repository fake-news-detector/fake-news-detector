ALTER TABLE votes ADD COLUMN clickbait_title BOOLEAN NULL;
UPDATE votes SET clickbait_title = TRUE WHERE category_id = (SELECT id FROM categories WHERE name = 'Click Bait');

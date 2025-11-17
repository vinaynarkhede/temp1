-- =====================================================
-- Views for Complex Queries
-- =====================================================

CREATE VIEW posts_with_details AS
SELECT p.id, p.title, p.content, p.published, p.created_at, p.updated_at, p.user_id,
       u.full_name AS author_name, u.email AS author_email, COUNT(c.id) AS comment_count
FROM posts p
JOIN users u ON p.user_id = u.id
LEFT JOIN comments c ON c.post_id = p.id
GROUP BY p.id, u.id, u.full_name, u.email;

GRANT SELECT ON posts_with_details TO web_anon, authenticated;

CREATE VIEW user_stats AS
SELECT u.id, u.full_name, u.email, u.created_at,
       COUNT(DISTINCT p.id) AS total_posts,
       COUNT(DISTINCT CASE WHEN p.published THEN p.id END) AS published_posts,
       COUNT(DISTINCT c.id) AS total_comments
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
LEFT JOIN comments c ON c.user_id = u.id
GROUP BY u.id, u.full_name, u.email, u.created_at;

GRANT SELECT ON user_stats TO authenticated;

CREATE VIEW recent_activity AS
SELECT 'post' AS activity_type, p.id AS activity_id, p.title AS activity_title,
       p.content AS activity_content, p.user_id, u.full_name AS user_name, p.created_at
FROM posts p JOIN users u ON p.user_id = u.id WHERE p.published = true
UNION ALL
SELECT 'comment' AS activity_type, c.id AS activity_id, NULL AS activity_title,
       c.content AS activity_content, c.user_id, u.full_name AS user_name, c.created_at
FROM comments c JOIN users u ON c.user_id = u.id
JOIN posts p ON c.post_id = p.id WHERE p.published = true
ORDER BY created_at DESC LIMIT 50;

GRANT SELECT ON recent_activity TO web_anon, authenticated;

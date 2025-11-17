-- =====================================================
-- Row-Level Security (RLS) Policies
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- Users Policies
-- =====================================================

CREATE POLICY "Users can view their own data"
    ON users FOR SELECT
    TO authenticated
    USING (id = (current_setting('request.jwt.claims', true)::json->>'user_id')::uuid);

CREATE POLICY "Users can update their own data"
    ON users FOR UPDATE
    TO authenticated
    USING (id = (current_setting('request.jwt.claims', true)::json->>'user_id')::uuid)
    WITH CHECK (id = (current_setting('request.jwt.claims', true)::json->>'user_id')::uuid);

-- =====================================================
-- Posts Policies
-- =====================================================

CREATE POLICY "Public can view published posts"
    ON posts FOR SELECT
    TO web_anon, authenticated
    USING (published = true);

CREATE POLICY "Users can view own unpublished posts"
    ON posts FOR SELECT
    TO authenticated
    USING (user_id = (current_setting('request.jwt.claims', true)::json->>'user_id')::uuid);

CREATE POLICY "Users can create posts"
    ON posts FOR INSERT
    TO authenticated
    WITH CHECK (user_id = (current_setting('request.jwt.claims', true)::json->>'user_id')::uuid);

CREATE POLICY "Users can update own posts"
    ON posts FOR UPDATE
    TO authenticated
    USING (user_id = (current_setting('request.jwt.claims', true)::json->>'user_id')::uuid)
    WITH CHECK (user_id = (current_setting('request.jwt.claims', true)::json->>'user_id')::uuid);

CREATE POLICY "Users can delete own posts"
    ON posts FOR DELETE
    TO authenticated
    USING (user_id = (current_setting('request.jwt.claims', true)::json->>'user_id')::uuid);

-- =====================================================
-- Comments Policies
-- =====================================================

CREATE POLICY "Public can view comments on published posts"
    ON comments FOR SELECT
    TO web_anon, authenticated
    USING (EXISTS (
        SELECT 1 FROM posts
        WHERE posts.id = comments.post_id
        AND posts.published = true
    ));

CREATE POLICY "Authenticated users can create comments"
    ON comments FOR INSERT
    TO authenticated
    WITH CHECK (user_id = (current_setting('request.jwt.claims', true)::json->>'user_id')::uuid);

CREATE POLICY "Users can delete own comments"
    ON comments FOR DELETE
    TO authenticated
    USING (user_id = (current_setting('request.jwt.claims', true)::json->>'user_id')::uuid);

-- =====================================================
-- Verify RLS is enabled
-- =====================================================

SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY tablename;

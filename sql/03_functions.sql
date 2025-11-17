-- =====================================================
-- Business Logic Functions
-- =====================================================

CREATE OR REPLACE FUNCTION register_user(
    p_email TEXT,
    p_password TEXT,
    p_full_name TEXT
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID;
    v_password_hash TEXT;
BEGIN
    IF p_email !~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RETURN json_build_object('success', false, 'message', 'Invalid email format');
    END IF;
    IF LENGTH(p_password) < 8 THEN
        RETURN json_build_object('success', false, 'message', 'Password must be at least 8 characters');
    END IF;
    v_password_hash := crypt(p_password, gen_salt('bf', 8));
    INSERT INTO users (email, password_hash, full_name)
    VALUES (p_email, v_password_hash, p_full_name)
    RETURNING id INTO v_user_id;
    RETURN json_build_object('success', true, 'user_id', v_user_id, 'message', 'User registered successfully');
EXCEPTION
    WHEN unique_violation THEN
        RETURN json_build_object('success', false, 'message', 'Email already exists');
    WHEN OTHERS THEN
        RETURN json_build_object('success', false, 'message', 'Registration failed: ' || SQLERRM);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION register_user TO web_anon;

CREATE OR REPLACE FUNCTION login(p_email TEXT, p_password TEXT)
RETURNS JSON AS $$
DECLARE
    v_user RECORD;
BEGIN
    SELECT id, email, full_name, password_hash INTO v_user FROM users WHERE email = p_email;
    IF NOT FOUND OR v_user.password_hash != crypt(p_password, v_user.password_hash) THEN
        RETURN json_build_object('success', false, 'message', 'Invalid email or password');
    END IF;
    RETURN json_build_object('success', true, 'user_id', v_user.id, 'email', v_user.email, 'full_name', v_user.full_name, 'role', 'authenticated');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION login TO web_anon;

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_timestamp BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER update_posts_timestamp BEFORE UPDATE ON posts FOR EACH ROW EXECUTE FUNCTION update_updated_at();

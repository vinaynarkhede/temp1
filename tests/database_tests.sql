-- Database Test Suite
BEGIN;

\echo '=== Test 1: Table Existence ==='
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users')
  THEN 'PASS: users table exists' ELSE 'FAIL: users table does not exist' END AS test_result;
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'posts')
  THEN 'PASS: posts table exists' ELSE 'FAIL: posts table does not exist' END AS test_result;
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'comments')
  THEN 'PASS: comments table exists' ELSE 'FAIL: comments table does not exist' END AS test_result;

\echo '=== Test 2: Required Columns ==='
SELECT CASE WHEN COUNT(*) = 6 THEN 'PASS: users table has all required columns' ELSE 'FAIL: users table missing columns' END AS test_result
FROM information_schema.columns WHERE table_name = 'users' AND column_name IN ('id', 'email', 'password_hash', 'full_name', 'created_at', 'updated_at');

\echo '=== Test 3: Unique Constraints ==='
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.table_constraints WHERE table_name = 'users' AND constraint_type = 'UNIQUE' AND constraint_name LIKE '%email%')
  THEN 'PASS: email unique constraint exists' ELSE 'FAIL: email unique constraint missing' END AS test_result;

\echo '=== Test 4: Extensions ==='
SELECT CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'uuid-ossp')
  THEN 'PASS: uuid-ossp extension installed' ELSE 'FAIL: uuid-ossp extension not installed' END AS test_result;
SELECT CASE WHEN EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto')
  THEN 'PASS: pgcrypto extension installed' ELSE 'FAIL: pgcrypto extension not installed' END AS test_result;

\echo '=== Test 5: Database Roles ==='
SELECT CASE WHEN EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'web_anon')
  THEN 'PASS: web_anon role exists' ELSE 'FAIL: web_anon role does not exist' END AS test_result;
SELECT CASE WHEN EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated')
  THEN 'PASS: authenticated role exists' ELSE 'FAIL: authenticated role does not exist' END AS test_result;

\echo '=== Test 6: Row-Level Security ==='
SELECT CASE WHEN rowsecurity = true THEN 'PASS: RLS enabled on ' || tablename ELSE 'FAIL: RLS not enabled on ' || tablename END AS test_result
FROM pg_tables WHERE schemaname = 'public' AND tablename IN ('users', 'posts', 'comments') ORDER BY tablename;

\echo '=== Test 7: Security Policies ==='
SELECT COUNT(*) AS policy_count, CASE WHEN COUNT(*) >= 10 THEN 'PASS: All security policies exist' ELSE 'FAIL: Missing security policies' END AS test_result
FROM pg_policies WHERE schemaname = 'public';

\echo '=== Test 8: Business Logic Functions ==='
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'register_user' AND routine_schema = 'public')
  THEN 'PASS: register_user function exists' ELSE 'FAIL: register_user function missing' END AS test_result;
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'login' AND routine_schema = 'public')
  THEN 'PASS: login function exists' ELSE 'FAIL: login function missing' END AS test_result;

\echo '=== Test 9: Views ==='
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'posts_with_details' AND table_schema = 'public')
  THEN 'PASS: posts_with_details view exists' ELSE 'FAIL: posts_with_details view missing' END AS test_result;
SELECT CASE WHEN EXISTS (SELECT 1 FROM information_schema.views WHERE table_name = 'user_stats' AND table_schema = 'public')
  THEN 'PASS: user_stats view exists' ELSE 'FAIL: user_stats view missing' END AS test_result;

\echo '=== All tests completed! ==='
ROLLBACK;

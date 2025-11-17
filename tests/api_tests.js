const BASE_URL = 'http://localhost:3000';

async function test(name, fn) {
  try { await fn(); console.log(`✓ ${name}`); return true; }
  catch (error) { console.error(`✗ ${name}`); console.error(`  ${error.message}`); return false; }
}

function assert(condition, message) { if (!condition) throw new Error(message || 'Assertion failed'); }

async function testPostgRESTRunning() {
  const response = await fetch(`${BASE_URL}/`);
  assert(response.status === 200, 'PostgREST should be running on port 3000');
}

async function testPublicAccessToPosts() {
  const response = await fetch(`${BASE_URL}/posts?published=eq.true`);
  assert(response.status === 200, 'Public access to published posts should work');
  const data = await response.json();
  assert(Array.isArray(data), 'Response should be an array');
}

async function testUserRegistration() {
  const email = 'test_' + new Date().getTime() + '@example.com';
  const response = await fetch(`${BASE_URL}/rpc/register_user`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ p_email: email, p_password: 'testpassword123', p_full_name: 'Test User' })
  });
  assert(response.status === 200, 'Registration request should succeed');
  const data = await response.json();
  assert(data.success === true, 'Registration should be successful');
}

async function testInvalidEmailFormat() {
  const response = await fetch(`${BASE_URL}/rpc/register_user`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ p_email: 'invalid-email', p_password: 'password123', p_full_name: 'Test User' })
  });
  const data = await response.json();
  assert(data.success === false, 'Invalid email should fail');
}

async function runAllTests() {
  console.log('\n========================================');
  console.log('Running API Integration Tests');
  console.log('========================================\n');
  const tests = [
    ['PostgREST is running', testPostgRESTRunning],
    ['Public can access published posts', testPublicAccessToPosts],
    ['User registration succeeds', testUserRegistration],
    ['Invalid email format is rejected', testInvalidEmailFormat]
  ];
  let passed = 0, failed = 0;
  for (const [name, fn] of tests) {
    const result = await test(name, fn);
    if (result) passed++; else failed++;
  }
  console.log('\n========================================');
  console.log('Total: ' + (passed + failed) + ' | Passed: ' + passed + ' | Failed: ' + failed);
  console.log('========================================\n');
  process.exit(failed > 0 ? 1 : 0);
}

runAllTests().catch(error => { console.error('Fatal error:', error); process.exit(1); });

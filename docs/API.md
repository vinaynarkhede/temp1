# API Documentation

Complete API reference for the PostgreSQL + PostgREST application.

## Base URL

```
http://localhost:3000
```

## Authentication

### JWT Token Format
```json
{
  "user_id": "uuid",
  "email": "user@example.com",
  "role": "authenticated"
}
```

### Headers
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

---

## 🔐 Authentication Endpoints

### Register User

**Endpoint:** `POST /rpc/register_user`

**Description:** Create a new user account

**Request Body:**
```json
{
  "p_email": "user@example.com",
  "p_password": "password123",
  "p_full_name": "John Doe"
}
```

**Response (Success):**
```json
{
  "success": true,
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "message": "User registered successfully"
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "Email already exists"
}
```

**Validation Rules:**
- Email must be valid format
- Password must be at least 8 characters
- Full name is optional

---

### Login

**Endpoint:** `POST /rpc/login`

**Description:** Authenticate user and get credentials

**Request Body:**
```json
{
  "p_email": "user@example.com",
  "p_password": "password123"
}
```

**Response (Success):**
```json
{
  "success": true,
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "full_name": "John Doe",
  "role": "authenticated"
}
```

**Response (Error):**
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

---

## 📝 Posts Endpoints

### Get Published Posts

**Endpoint:** `GET /posts?published=eq.true`

**Description:** Retrieve all published posts (public access)

**Query Parameters:**
- `published=eq.true` - Filter published posts
- `order=created_at.desc` - Sort by date (newest first)
- `limit=10` - Limit results
- `offset=20` - Pagination offset

**Response:**
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "title": "My First Post",
    "content": "Post content here...",
    "published": true,
    "created_at": "2025-11-17T13:00:00Z",
    "updated_at": "2025-11-17T13:00:00Z"
  }
]
```

---

### Get User's Own Posts

**Endpoint:** `GET /posts`

**Headers:** `Authorization: Bearer <JWT_TOKEN>`

**Description:** Retrieve authenticated user's posts (including drafts)

**Response:**
```json
[
  {
    "id": "uuid",
    "user_id": "uuid",
    "title": "My Draft",
    "content": "Draft content...",
    "published": false,
    "created_at": "2025-11-17T13:00:00Z",
    "updated_at": "2025-11-17T13:00:00Z"
  }
]
```

---

### Create Post

**Endpoint:** `POST /posts`

**Headers:** `Authorization: Bearer <JWT_TOKEN>`

**Description:** Create a new post (authenticated users only)

**Request Body:**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "My New Post",
  "content": "Post content here...",
  "published": true
}
```

**Response:** `201 Created`
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "title": "My New Post",
  "content": "Post content here...",
  "published": true,
  "created_at": "2025-11-17T13:00:00Z",
  "updated_at": "2025-11-17T13:00:00Z"
}
```

---

### Update Post

**Endpoint:** `PATCH /posts?id=eq.<post_id>`

**Headers:** `Authorization: Bearer <JWT_TOKEN>`

**Description:** Update user's own post

**Request Body:**
```json
{
  "title": "Updated Title",
  "content": "Updated content...",
  "published": true
}
```

**Response:** `200 OK`

---

### Delete Post

**Endpoint:** `DELETE /posts?id=eq.<post_id>`

**Headers:** `Authorization: Bearer <JWT_TOKEN>`

**Description:** Delete user's own post

**Response:** `204 No Content`

---

## 💬 Comments Endpoints

### Get Comments for Post

**Endpoint:** `GET /comments?post_id=eq.<post_id>`

**Description:** Get all comments for a published post (public access)

**Response:**
```json
[
  {
    "id": "uuid",
    "post_id": "uuid",
    "user_id": "uuid",
    "content": "Great post!",
    "created_at": "2025-11-17T13:00:00Z"
  }
]
```

---

### Create Comment

**Endpoint:** `POST /comments`

**Headers:** `Authorization: Bearer <JWT_TOKEN>`

**Description:** Add a comment to a post

**Request Body:**
```json
{
  "post_id": "uuid",
  "user_id": "uuid",
  "content": "This is my comment"
}
```

**Response:** `201 Created`

---

### Delete Comment

**Endpoint:** `DELETE /comments?id=eq.<comment_id>`

**Headers:** `Authorization: Bearer <JWT_TOKEN>`

**Description:** Delete user's own comment

**Response:** `204 No Content`

---

## 📊 Views Endpoints

### Posts with Details

**Endpoint:** `GET /posts_with_details?published=eq.true`

**Description:** Get posts with author info and comment count

**Response:**
```json
[
  {
    "id": "uuid",
    "title": "My Post",
    "content": "Content...",
    "published": true,
    "created_at": "2025-11-17T13:00:00Z",
    "updated_at": "2025-11-17T13:00:00Z",
    "user_id": "uuid",
    "author_name": "John Doe",
    "author_email": "john@example.com",
    "comment_count": 5
  }
]
```

---

### User Statistics

**Endpoint:** `GET /user_stats`

**Headers:** `Authorization: Bearer <JWT_TOKEN>`

**Description:** Get statistics for all users

**Response:**
```json
[
  {
    "id": "uuid",
    "full_name": "John Doe",
    "email": "john@example.com",
    "created_at": "2025-11-17T13:00:00Z",
    "total_posts": 10,
    "published_posts": 7,
    "total_comments": 25
  }
]
```

---

### Recent Activity

**Endpoint:** `GET /recent_activity?limit=10`

**Description:** Get recent posts and comments (public)

**Response:**
```json
[
  {
    "activity_type": "post",
    "activity_id": "uuid",
    "activity_title": "My Post",
    "activity_content": "Content...",
    "user_id": "uuid",
    "user_name": "John Doe",
    "created_at": "2025-11-17T13:00:00Z"
  },
  {
    "activity_type": "comment",
    "activity_id": "uuid",
    "activity_title": null,
    "activity_content": "Great post!",
    "user_id": "uuid",
    "user_name": "Jane Smith",
    "created_at": "2025-11-17T12:55:00Z"
  }
]
```

---

## 🔍 Query Operators

PostgREST provides powerful query operators:

### Comparison Operators

```
?column=eq.value       # Equals
?column=gt.10          # Greater than
?column=gte.10         # Greater than or equal
?column=lt.100         # Less than
?column=lte.100        # Less than or equal
?column=neq.value      # Not equal
```

### Pattern Matching

```
?column=like.*value*   # SQL LIKE
?column=ilike.*value*  # Case-insensitive LIKE
?column=in.(val1,val2) # IN list
```

### Null Checks

```
?column=is.null        # IS NULL
?column=not.is.null    # IS NOT NULL
```

### Ordering

```
?order=column.asc      # Ascending
?order=column.desc     # Descending
?order=col1.asc,col2.desc  # Multiple columns
```

### Pagination

```
?limit=10              # Limit results
?offset=20             # Skip first N results
?limit=10&offset=20    # Page 3 (10 per page)
```

### Column Selection

```
?select=id,title       # Select specific columns
?select=*              # Select all columns
?select=id,title,user:users(full_name)  # Join with users
```

---

## 🔐 Security Policies

### Public Access (web_anon)
- ✅ View published posts
- ✅ View comments on published posts
- ✅ View recent activity
- ✅ Register user
- ✅ Login

### Authenticated Users
- ✅ All public access
- ✅ View own profile
- ✅ Update own profile
- ✅ View own unpublished posts
- ✅ Create posts
- ✅ Update own posts
- ✅ Delete own posts
- ✅ Create comments
- ✅ Delete own comments
- ✅ View user statistics

### Blocked Actions
- ❌ View other users' unpublished posts
- ❌ Update other users' posts
- ❌ Delete other users' posts
- ❌ Delete other users' comments
- ❌ View other users' private data

---

## 📋 Response Codes

| Code | Meaning |
|------|---------|
| 200  | Success |
| 201  | Created |
| 204  | No Content (successful delete) |
| 400  | Bad Request |
| 401  | Unauthorized |
| 403  | Forbidden (RLS policy violation) |
| 404  | Not Found |
| 409  | Conflict (e.g., duplicate email) |
| 500  | Internal Server Error |

---

## 📝 Examples

### JavaScript Fetch

```javascript
// Register
const response = await fetch('http://localhost:3000/rpc/register_user', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    p_email: 'user@example.com',
    p_password: 'password123',
    p_full_name: 'John Doe'
  })
});

// Login and get token
const loginData = await fetch('http://localhost:3000/rpc/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    p_email: 'user@example.com',
    p_password: 'password123'
  })
}).then(r => r.json());

// Create post with authentication
const token = generateJWT(loginData); // You need to implement JWT generation
await fetch('http://localhost:3000/posts', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`
  },
  body: JSON.stringify({
    user_id: loginData.user_id,
    title: 'My Post',
    content: 'Content here',
    published: true
  })
});

// Get published posts
const posts = await fetch('http://localhost:3000/posts?published=eq.true&order=created_at.desc')
  .then(r => r.json());
```

### cURL Examples

```bash
# Register
curl -X POST http://localhost:3000/rpc/register_user \
  -H "Content-Type: application/json" \
  -d '{"p_email":"user@example.com","p_password":"password123","p_full_name":"John Doe"}'

# Login
curl -X POST http://localhost:3000/rpc/login \
  -H "Content-Type: application/json" \
  -d '{"p_email":"user@example.com","p_password":"password123"}'

# Get published posts with filtering
curl "http://localhost:3000/posts?published=eq.true&order=created_at.desc&limit=10"

# Get posts with details
curl "http://localhost:3000/posts_with_details?published=eq.true&select=id,title,author_name,comment_count"

# Create post (with JWT token)
curl -X POST http://localhost:3000/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"user_id":"uuid","title":"My Post","content":"Content","published":true}'
```

---

## 🔗 Additional Resources

- [PostgREST Documentation](https://postgrest.org/en/stable/)
- [PostgREST API Reference](https://postgrest.org/en/stable/references/api.html)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

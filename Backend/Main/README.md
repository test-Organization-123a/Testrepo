# Rock Climbing Webshop Backend

A full-featured backend for a Rock Climbing Webshop, built with:

- Node.js + Express
- TypeScript
- Prisma ORM
- PostgreSQL
- Docker + Docker Compose

This service powers the webshop API, providing endpoints for managing products, categories, orders, routes, and locations.  
It’s designed for modularity, scalability, and seamless integration with a Flutter frontend.

---

## Features

- RESTful API for:
    - Categories
    - Products
    - Orders
    - Routes
    - Locations
    - Users & Authentication (Admin/User roles)
- Type-safe API using TypeScript
- Prisma ORM with PostgreSQL
- Built-in seeding for local and acceptance databases
- Role-based access control middleware
- Clean architecture (controllers, services, middleware)
- Auto-generated Swagger documentation

---

## Tech Stack

| Component | Technology |
|------------|-------------|
| Runtime | Node.js 20 |
| Language | TypeScript |
| ORM | Prisma |
| Database | PostgreSQL |
| Authentication | JWT |
| Containerization | Docker & Docker Compose |
| Documentation | Swagger (via `swagger-ui-express`) |

---

## Local Development

### Requirements

- Docker
- Docker Compose
- (Optional) Node.js 20+ for running scripts locally

---

### Start Development Environment

From the project root, run:

```bash
docker compose up --build
```
### Credentials
- for Admin
"email": "admin@example.com"
"password": "adminpass"
- for User
"email": "bob@example.com"
"password": "password123"
## Environment Variables

Create a `.env` file in the project root with the following variables:

```env
# Database connection
DATABASE_URL=postgresql://postgres:postgres@db:5432/rockshop

# Application port
PORT=3000

# JWT secret for signing tokens
JWT_SECRET=supersecretkey
```

## The backend will be available at:
- http://localhost:3000

## API Documentation can be accessed on
- http://localhost:3000/api/docs

## License

### MIT License

Copyright (c) 2025 ClimbEasy

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


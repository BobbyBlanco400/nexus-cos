# node-auth-api

A simple Node.js authentication API using Express and MongoDB, suitable for Hostinger VPS deployment.

## Endpoints

- `POST /api/register` — Register a new user (`username`, `password`, `email`)
- `POST /api/login` — Login (`username`, `password`)
- `POST /api/forgot-password` — Request a password reset token (`username`)
- `POST /api/reset-password` — Reset password (`username`, `token`, `newPassword`)

## Setup

1. Clone the repo
2. Run `npm install`
3. Make sure MongoDB is running (local or cloud)
4. Start the app: `node app.js`

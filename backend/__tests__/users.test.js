const request = require('supertest');
const app = require('../app');

describe('GET /api/users', () => {
  it('should return 200 OK', async () => {
    const res = await request(app).get('/api/users');
    expect(res.statusCode).toBe(200);
    // expect(Array.isArray(res.body)).toBe(true); // Uncomment if your API returns an array
  });
});

import { seed } from "../src/prisma/seed";
import request from "supertest";
import app from "../src/app";

const baseUrl = process.env.API_BASE_URL || "";
const api = baseUrl ? request(baseUrl) : request(app);
let adminToken: string;
let userToken: string;

beforeAll(async () => {
    if (!baseUrl) {
        await seed();
    }

    // Login as admin
    const adminRes = await api.post("/auth/login").send({
        email: "admin@example.com",
        password: "adminpass",
    });

    if (adminRes.status !== 200) {
        throw new Error(`Failed to login as admin: ${adminRes.status} ${adminRes.text}`);
    }
    adminToken = adminRes.body.token;

    // Login as regular user
    const userRes = await api.post("/auth/login").send({
        email: "alice@example.com",
        password: "password123",
    });

    if (userRes.status !== 200) {
        throw new Error(`Failed to login as user: ${userRes.status} ${userRes.text}`);
    }
    userToken = userRes.body.token;
});

export { adminToken, userToken, api };

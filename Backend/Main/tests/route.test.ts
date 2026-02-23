import { api, adminToken, userToken } from "./setupTestDB";

describe("Route API", () => {
    it("should return all routes (authenticated user)", async () => {
        const res = await api
            .get("/routes")
            .set("Authorization", `Bearer ${userToken}`);

        expect(res.status).toBe(200);
        expect(Array.isArray(res.body)).toBe(true);
        expect(res.body.length).toBeGreaterThan(0);
    });

    it("should return a route by ID (authenticated user)", async () => {
        const listRes = await api
            .get("/routes")
            .set("Authorization", `Bearer ${userToken}`);
        expect(listRes.status).toBe(200);
        const route = listRes.body[0];
        expect(route).toBeTruthy();

        const res = await api
            .get(`/routes/${route.id}`)
            .set("Authorization", `Bearer ${userToken}`);

        expect(res.status).toBe(200);
        expect(res.body.name).toBe(route.name);
    });

    it("should require authentication for listing routes", async () => {
        const res = await api.get("/routes");
        expect(res.status).toBe(401);
    });

    it("should create a new route (admin only)", async () => {
        // get any location to associate the route
        const locRes = await api
            .get("/locations")
            .set("Authorization", `Bearer ${adminToken}`);
        expect(locRes.status).toBe(200);
        const location = locRes.body[0];
        expect(location).toBeTruthy();

        const res = await api
            .post("/routes")
            .set("Authorization", `Bearer ${adminToken}`)
            .send({
                name: "Test Admin Route",
                grade: "6c",
                description: "Created in tests",
                locationId: location.id,
            });

        expect(res.status).toBe(201);
        expect(res.body.name).toBe("Test Admin Route");

        // verify via API, not Prisma
        const verifyRes = await api
            .get(`/routes/${res.body.id}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(verifyRes.status).toBe(200);
        expect(verifyRes.body.name).toBe("Test Admin Route");
    });

    it("should forbid non-admins from creating a route", async () => {
        const locRes = await api
            .get("/locations")
            .set("Authorization", `Bearer ${userToken}`);
        const location = locRes.body[0];

        const res = await api
            .post("/routes")
            .set("Authorization", `Bearer ${userToken}`)
            .send({
                name: "Unauthorized Route",
                grade: "6b",
                description: "Should not be created",
                locationId: location.id,
            });

        expect(res.status).toBe(403);
    });

    it("should update a route (admin only)", async () => {
        const listRes = await api
            .get("/routes")
            .set("Authorization", `Bearer ${adminToken}`);
        const route = listRes.body[0];
        expect(route).toBeTruthy();

        const res = await api
            .put(`/routes/${route.id}`)
            .set("Authorization", `Bearer ${adminToken}`)
            .send({
                name: "Updated Route Name",
                grade: "7a",
                description: "Updated description",
            });

        expect(res.status).toBe(200);
        expect(res.body.name).toBe("Updated Route Name");

        const verifyRes = await api
            .get(`/routes/${route.id}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(verifyRes.body.grade).toBe("7a");
    });

    it("should prevent non-admins from updating a route", async () => {
        const listRes = await api
            .get("/routes")
            .set("Authorization", `Bearer ${userToken}`);
        const route = listRes.body[0];
        expect(route).toBeTruthy();

        const res = await api
            .put(`/routes/${route.id}`)
            .set("Authorization", `Bearer ${userToken}`)
            .send({ name: "Should Fail", grade: "6c" });

        expect(res.status).toBe(403);
    });

    it("should delete a route (admin only)", async () => {
        // create one first
        const locRes = await api
            .get("/locations")
            .set("Authorization", `Bearer ${adminToken}`);
        const location = locRes.body[0];

        const createRes = await api
            .post("/routes")
            .set("Authorization", `Bearer ${adminToken}`)
            .send({
                name: "Temp Delete Route",
                grade: "5c",
                description: "To be deleted",
                locationId: location.id,
            });
        expect(createRes.status).toBe(201);

        const res = await api
            .delete(`/routes/${createRes.body.id}`)
            .set("Authorization", `Bearer ${adminToken}`);

        expect(res.status).toBe(204);

        const checkRes = await api
            .get(`/routes/${createRes.body.id}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(checkRes.status).toBe(404);
    });

    it("should prevent non-admins from deleting routes", async () => {
        const listRes = await api
            .get("/routes")
            .set("Authorization", `Bearer ${userToken}`);
        const route = listRes.body[0];

        const res = await api
            .delete(`/routes/${route.id}`)
            .set("Authorization", `Bearer ${userToken}`);

        expect(res.status).toBe(403);
    });

    it("should return 404 for non-existent route ID", async () => {
        const res = await api
            .get("/routes/11111111-1111-1111-1111-111111111111")
            .set("Authorization", `Bearer ${userToken}`);
        expect(res.status).toBe(404);
    });

    it("should allow authenticated user to rate a route", async () => {
        const listRes = await api
            .get("/routes")
            .set("Authorization", `Bearer ${userToken}`);
        const route = listRes.body[0];

        const res = await api
            .post(`/routes/${route.id}/rate`)
            .set("Authorization", `Bearer ${userToken}`)
            .send({ grade: "7a+" });

        expect(res.status).toBe(200);
        expect(res.body.message).toBe("Rating submitted");
    });

    it("should not allow rating without authentication", async () => {
        const listRes = await api.get("/routes").set("Authorization", `Bearer ${userToken}`);
        const route = listRes.body[0];

        const res = await api
            .post(`/routes/${route.id}/rate`)
            .send({ grade: "6b" });
        expect(res.status).toBe(401);
    });

    it("should not allow invalid grade data", async () => {
        const listRes = await api
            .get("/routes")
            .set("Authorization", `Bearer ${userToken}`);
        const route = listRes.body[0];

        const res = await api
            .post(`/routes/${route.id}/rate`)
            .set("Authorization", `Bearer ${userToken}`)
            .send({ grade: 123 }); // invalid type

        expect(res.status).toBe(400);
    });
});

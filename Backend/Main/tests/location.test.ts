import { api, adminToken, userToken } from "./setupTestDB";

describe("Location API", () => {
    it("should return all locations (authenticated user)", async () => {
        const res = await api
            .get("/locations")
            .set("Authorization", `Bearer ${userToken}`);

        expect(res.status).toBe(200);
        expect(Array.isArray(res.body)).toBe(true);
        expect(res.body.length).toBeGreaterThan(0);
    });

    it("should not allow access without authentication", async () => {
        const res = await api.get("/locations");
        expect(res.status).toBe(401);
    });

    it("should return a location by ID (authenticated user)", async () => {
        const listRes = await api
            .get("/locations")
            .set("Authorization", `Bearer ${userToken}`);
        expect(listRes.status).toBe(200);
        const location = listRes.body[0];
        expect(location).toBeTruthy();

        const res = await api
            .get(`/locations/${location.id}`)
            .set("Authorization", `Bearer ${userToken}`);

        expect(res.status).toBe(200);
        expect(res.body.name).toBe(location.name);
    });

    it("should return 404 for a non-existing location ID", async () => {
        const fakeId = "11111111-1111-1111-1111-111111111111";
        const res = await api
            .get(`/locations/${fakeId}`)
            .set("Authorization", `Bearer ${userToken}`);

        expect(res.status).toBe(404);
    });

    it("should create a new location (admin only)", async () => {
        const res = await api
            .post("/locations")
            .set("Authorization", `Bearer ${adminToken}`)
            .field("name", "Test Climb Center")
            .field("description", "Indoor gym created by tests")
            .field("address", "123 Testing Blvd");

        expect(res.status).toBe(201);
        expect(res.body.name).toBe("Test Climb Center");

        // Verify through API
        const verifyRes = await api
            .get(`/locations/${res.body.id}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(verifyRes.status).toBe(200);
        expect(verifyRes.body.name).toBe("Test Climb Center");
    });

    it("should forbid non-admin users from creating a location", async () => {
        const res = await api
            .post("/locations")
            .set("Authorization", `Bearer ${userToken}`)
            .field("name", "Unauthorized Location")
            .field("description", "Should fail")
            .field("address", "Nowhere");

        expect(res.status).toBe(403);
    });

    it("should deny creation when unauthenticated", async () => {
        const res = await api
            .post("/locations")
            .field("name", "Unauthorized Location")
            .field("description", "Should fail")
            .field("address", "Nowhere");

        expect(res.status).toBe(401);
    });

    it("should update an existing location (admin only)", async () => {
        const listRes = await api
            .get("/locations")
            .set("Authorization", `Bearer ${adminToken}`);
        const location = listRes.body[0];
        expect(location).toBeTruthy();

        const res = await api
            .put(`/locations/${location.id}`)
            .set("Authorization", `Bearer ${adminToken}`)
            .field("name", "Updated Location Name")
            .field("description", "Updated test description")
            .field("address", "456 Updated St");

        expect(res.status).toBe(200);
        expect(res.body.name).toBe("Updated Location Name");

        // Verify via API
        const verifyRes = await api
            .get(`/locations/${location.id}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(verifyRes.status).toBe(200);
        expect(verifyRes.body.name).toBe("Updated Location Name");
    });

    it("should forbid non-admin users from updating a location", async () => {
        const listRes = await api
            .get("/locations")
            .set("Authorization", `Bearer ${userToken}`);
        const location = listRes.body[0];

        const res = await api
            .put(`/locations/${location.id}`)
            .set("Authorization", `Bearer ${userToken}`)
            .field("name", "Should Not Update");

        expect(res.status).toBe(403);
    });

    it("should delete a location (admin only)", async () => {
        // Create a temporary location to delete
        const createRes = await api
            .post("/locations")
            .set("Authorization", `Bearer ${adminToken}`)
            .field("name", "Temporary Location")
            .field("description", "To be deleted")
            .field("address", "Somewhere temporary");
        expect(createRes.status).toBe(201);

        const locationId = createRes.body.id;

        const deleteRes = await api
            .delete(`/locations/${locationId}`)
            .set("Authorization", `Bearer ${adminToken}`);

        expect(deleteRes.status).toBe(204);

        // Verify deletion via API
        const checkRes = await api
            .get(`/locations/${locationId}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(checkRes.status).toBe(404);
    });

    it("should forbid non-admin users from deleting a location", async () => {
        const listRes = await api
            .get("/locations")
            .set("Authorization", `Bearer ${adminToken}`);
        const location = listRes.body[0];

        const res = await api
            .delete(`/locations/${location.id}`)
            .set("Authorization", `Bearer ${userToken}`);

        expect(res.status).toBe(403);
    });
});

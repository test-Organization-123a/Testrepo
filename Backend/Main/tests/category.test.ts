import { api, adminToken, userToken } from "./setupTestDB";

describe("Category API (secured)", () => {
    it("should reject unauthenticated requests", async () => {
        const res = await api.get("/categories");
        expect(res.status).toBe(401);
    });

    it("should return a list of categories (user token)", async () => {
        const res = await api
            .get("/categories")
            .set("Authorization", `Bearer ${userToken}`);

        expect(res.status).toBe(200);
        expect(Array.isArray(res.body)).toBe(true);
        expect(res.body.length).toBeGreaterThan(0);
    });

    it("should return a single category by ID (user token)", async () => {
        const listRes = await api
            .get("/categories")
            .set("Authorization", `Bearer ${userToken}`);
        expect(listRes.status).toBe(200);
        const category = listRes.body[0];
        expect(category).toBeTruthy();

        const res = await api
            .get(`/categories/${category.id}`)
            .set("Authorization", `Bearer ${userToken}`);

        expect(res.status).toBe(200);
        expect(res.body.name).toBe(category.name);
    });

    it("should not allow non-admin to create a category", async () => {
        const res = await api
            .post("/categories")
            .set("Authorization", `Bearer ${userToken}`)
            .send({
                name: "User Attempt",
                description: "Should fail",
            });

        expect(res.status).toBe(403);
    });

    it("should create a new category (admin only)", async () => {
        const res = await api
            .post("/categories")
            .set("Authorization", `Bearer ${adminToken}`)
            .send({
                name: "Ropes",
                description: "Dynamic and static ropes",
            });

        expect(res.status).toBe(201);
        expect(res.body.name).toBe("Ropes");

        // Verify existence via API
        const verifyRes = await api
            .get(`/categories/${res.body.id}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(verifyRes.status).toBe(200);
        expect(verifyRes.body.name).toBe("Ropes");
    });

    it("should update an existing category (admin only)", async () => {
        const listRes = await api
            .get("/categories")
            .set("Authorization", `Bearer ${adminToken}`);
        expect(listRes.status).toBe(200);
        const category = listRes.body[0];
        expect(category).toBeTruthy();

        const res = await api
            .put(`/categories/${category.id}`)
            .set("Authorization", `Bearer ${adminToken}`)
            .send({
                name: "Updated Category Name",
                description: "Updated description",
            });

        expect(res.status).toBe(200);
        expect(res.body.name).toBe("Updated Category Name");

        const verifyRes = await api
            .get(`/categories/${category.id}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(verifyRes.status).toBe(200);
        expect(verifyRes.body.name).toBe("Updated Category Name");
    });

    it("should prevent non-admin from updating a category", async () => {
        const listRes = await api
            .get("/categories")
            .set("Authorization", `Bearer ${adminToken}`);
        const category = listRes.body[0];

        const res = await api
            .put(`/categories/${category.id}`)
            .set("Authorization", `Bearer ${userToken}`)
            .send({
                name: "Hacked Name",
                description: "User shouldn't do this",
            });

        expect(res.status).toBe(403);
    });

    it("should delete a category (admin only)", async () => {
        // Create temporary category to delete
        const createRes = await api
            .post("/categories")
            .set("Authorization", `Bearer ${adminToken}`)
            .send({
                name: "Temp Category",
                description: "To be deleted",
            });
        expect(createRes.status).toBe(201);
        const categoryId = createRes.body.id;

        const deleteRes = await api
            .delete(`/categories/${categoryId}`)
            .set("Authorization", `Bearer ${adminToken}`);

        expect(deleteRes.status).toBe(204);

        // Verify via API
        const checkRes = await api
            .get(`/categories/${categoryId}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(checkRes.status).toBe(404);
    });

    it("should prevent deleting category with products", async () => {
        // Find a category that has products
        const listRes = await api
            .get("/categories")
            .set("Authorization", `Bearer ${adminToken}`);
        interface Category {
            id: string;
            name: string;
            description?: string;
            products?: { id: string }[];
        }

        const catWithProducts = (listRes.body as Category[]).find(
            (c) => Array.isArray(c.products) && c.products.length > 0
        );

        if (!catWithProducts) {
            console.warn("No category with products found — skipping test");
            return;
        }

        const res = await api
            .delete(`/categories/${catWithProducts.id}`)
            .set("Authorization", `Bearer ${adminToken}`);

        expect(res.status).toBeGreaterThanOrEqual(400);
        expect(res.body.error || res.body.message).toContain("Cannot delete");
    });
});

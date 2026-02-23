import { api, adminToken, userToken } from "./setupTestDB";

describe("Product API", () => {
    it("should return a list of products (authenticated user)", async () => {
        const res = await api
            .get("/products")
            .set("Authorization", `Bearer ${userToken}`);

        expect(res.status).toBe(200);
        expect(Array.isArray(res.body)).toBe(true);
        expect(res.body.length).toBeGreaterThan(0);
    });

    it("should not allow access without authentication", async () => {
        const res = await api.get("/products");
        expect(res.status).toBe(401);
    });

    it("should return a product by ID (authenticated user)", async () => {
        const listRes = await api
            .get("/products")
            .set("Authorization", `Bearer ${userToken}`);
        expect(listRes.status).toBe(200);
        const product = listRes.body[0];
        expect(product).toBeTruthy();

        const res = await api
            .get(`/products/${product.id}`)
            .set("Authorization", `Bearer ${userToken}`);

        expect(res.status).toBe(200);
        expect(res.body.name).toBe(product.name);
    });

    it("should create a new product (admin only)", async () => {
        // get a valid category first
        const catRes = await api
            .get("/categories")
            .set("Authorization", `Bearer ${adminToken}`);
        expect(catRes.status).toBe(200);
        const category = catRes.body[0];
        expect(category).toBeTruthy();

        const res = await api
            .post("/products")
            .set("Authorization", `Bearer ${adminToken}`)
            .field("name", "Test Product")
            .field("description", "Created by test")
            .field("price", "99.99")
            .field("stock", "5")
            .field("categoryId", category.id);

        expect(res.status).toBe(201);
        expect(res.body.name).toBe("Test Product");

        // Verify product exists via API
        const verifyRes = await api
            .get(`/products/${res.body.id}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(verifyRes.status).toBe(200);
        expect(verifyRes.body.name).toBe("Test Product");
    });

    it("should forbid non-admin users from creating a product", async () => {
        const catRes = await api
            .get("/categories")
            .set("Authorization", `Bearer ${userToken}`);
        const category = catRes.body[0];

        const res = await api
            .post("/products")
            .set("Authorization", `Bearer ${userToken}`)
            .field("name", "Unauthorized Product")
            .field("description", "Should fail")
            .field("price", "50.00")
            .field("stock", "2")
            .field("categoryId", category.id);

        expect(res.status).toBe(403);
    });

    it("should update an existing product (admin only)", async () => {
        const listRes = await api
            .get("/products")
            .set("Authorization", `Bearer ${adminToken}`);
        const product = listRes.body[0];
        expect(product).toBeTruthy();

        const res = await api
            .put(`/products/${product.id}`)
            .set("Authorization", `Bearer ${adminToken}`)
            .field("name", "Updated Product Name")
            .field("description", "Updated description")
            .field("price", "120.50")
            .field("stock", "3")
            .field("categoryId", product.categoryId);

        expect(res.status).toBe(200);
        expect(res.body.name).toBe("Updated Product Name");

        // Verify via API
        const verifyRes = await api
            .get(`/products/${product.id}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(Number(verifyRes.body.price)).toBeCloseTo(120.5);
    });

    it("should prevent non-admins from updating a product", async () => {
        const listRes = await api
            .get("/products")
            .set("Authorization", `Bearer ${userToken}`);
        const product = listRes.body[0];

        const res = await api
            .put(`/products/${product.id}`)
            .set("Authorization", `Bearer ${userToken}`)
            .field("name", "Should Fail Update");

        expect(res.status).toBe(403);
    });

    it("should delete a product (admin only)", async () => {
        const catRes = await api
            .get("/categories")
            .set("Authorization", `Bearer ${adminToken}`);
        const category = catRes.body[0];

        const createRes = await api
            .post("/products")
            .set("Authorization", `Bearer ${adminToken}`)
            .field("name", "Delete Me")
            .field("description", "To be deleted")
            .field("price", "10.00")
            .field("stock", "1")
            .field("categoryId", category.id);

        expect(createRes.status).toBe(201);

        const deleteRes = await api
            .delete(`/products/${createRes.body.id}`)
            .set("Authorization", `Bearer ${adminToken}`);

        expect(deleteRes.status).toBe(204);

        const checkRes = await api
            .get(`/products/${createRes.body.id}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(checkRes.status).toBe(404);
    });

    it("should prevent non-admins from deleting a product", async () => {
        const listRes = await api
            .get("/products")
            .set("Authorization", `Bearer ${userToken}`);
        const product = listRes.body[0];

        const res = await api
            .delete(`/products/${product.id}`)
            .set("Authorization", `Bearer ${userToken}`);

        expect(res.status).toBe(403);
    });

    it("should return 404 for non-existent product ID", async () => {
        const res = await api
            .get("/products/11111111-1111-1111-1111-111111111111")
            .set("Authorization", `Bearer ${userToken}`);
        expect(res.status).toBe(404);
    });
});

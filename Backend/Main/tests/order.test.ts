import { api, adminToken, userToken } from "./setupTestDB";

describe("Order API", () => {
    it("should list all orders (admin only)", async () => {
        const res = await api
            .get("/orders")
            .set("Authorization", `Bearer ${adminToken}`);

        expect(res.status).toBe(200);
        expect(Array.isArray(res.body)).toBe(true);
        expect(res.body.length).toBeGreaterThan(0);
    });

    it("should forbid normal users from listing all orders", async () => {
        const res = await api
            .get("/orders")
            .set("Authorization", `Bearer ${userToken}`);

        expect(res.status).toBe(403);
    });

    it("should deny access when unauthenticated", async () => {
        const res = await api.get("/orders");
        expect(res.status).toBe(401);
    });

    it("should return a single order by ID (admin or owner)", async () => {
        // Admin gets list of orders
        const listRes = await api
            .get("/orders")
            .set("Authorization", `Bearer ${adminToken}`);
        expect(listRes.status).toBe(200);
        const order = listRes.body[0];
        expect(order).toBeTruthy();

        // Admin can always access
        const resAdmin = await api
            .get(`/orders/${order.id}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(resAdmin.status).toBe(200);
        expect(resAdmin.body.id).toBe(order.id);

        // User (owner) should be able to access their own order
        const userOrders = await api
            .get("/orders/my")
            .set("Authorization", `Bearer ${userToken}`);

        if (userOrders.status === 200 && userOrders.body.length > 0) {
            const userOrder = userOrders.body[0];
            const resUser = await api
                .get(`/orders/${userOrder.id}`)
                .set("Authorization", `Bearer ${userToken}`);
            expect(resUser.status).toBe(200);
            expect(resUser.body.id).toBe(userOrder.id);
        }
    });

    it("should return 403 if a user tries to access another user's order", async () => {
        // Get all orders (admin)
        const listRes = await api
            .get("/orders")
            .set("Authorization", `Bearer ${adminToken}`);
        expect(listRes.status).toBe(200);

        // Take an order that doesn’t belong to the current user
        interface Order {
            id: string;
            customer?: { email?: string };
            items?: { productId: string; quantity: number }[];
        }
        const otherOrder = (listRes.body as Order[]).find(
            (o) => o.customer?.email !== "alice@example.com"
        );
        if (!otherOrder) {
            console.warn("No other user's order found — skipping this test");
            return;
        }

        // Alice tries to access someone else’s order
        const res = await api
            .get(`/orders/${otherOrder.id}`)
            .set("Authorization", `Bearer ${userToken}`);
        expect(res.status).toBe(403);
    });

    it("should return 404 for non-existent order ID", async () => {
        const res = await api
            .get("/orders/11111111-1111-1111-1111-111111111111")
            .set("Authorization", `Bearer ${adminToken}`);
        expect(res.status).toBe(404);
    });

    it("should create a new order (user only)", async () => {
        // Get any product to order
        const prodRes = await api
            .get("/products")
            .set("Authorization", `Bearer ${userToken}`);
        expect(prodRes.status).toBe(200);
        const product = prodRes.body[0];
        expect(product).toBeTruthy();

        const res = await api
            .post("/orders")
            .set("Authorization", `Bearer ${userToken}`)
            .send({
                items: [{ productId: product.id, quantity: 2 }],
            });

        expect(res.status).toBe(201);
        expect(Array.isArray(res.body.items)).toBe(true);
        expect(res.body.items[0].productId).toBe(product.id);
    });

    it("should not allow unauthenticated users to create orders", async () => {
        const prodRes = await api
            .get("/products")
            .set("Authorization", `Bearer ${adminToken}`);
        const product = prodRes.body[0];

        const res = await api.post("/orders").send({
            items: [{ productId: product.id, quantity: 1 }],
        });

        expect(res.status).toBe(401);
    });

    it("should allow admin to update an order", async () => {
        const listRes = await api
            .get("/orders")
            .set("Authorization", `Bearer ${adminToken}`);
        const order = listRes.body[0];
        expect(order).toBeTruthy();

        const prodRes = await api
            .get("/products")
            .set("Authorization", `Bearer ${adminToken}`);
        interface Product {
            id: string;
            name: string;
        }
        const product = (prodRes.body as Product[]).find(
            (p) => p.id !== order.items?.[0]?.productId
        ) || (prodRes.body as Product[])[0];

        const res = await api
            .put(`/orders/${order.id}`)
            .set("Authorization", `Bearer ${adminToken}`)
            .send({
                items: [{ productId: product.id, quantity: 5 }],
            });

        expect(res.status).toBe(200);
        expect(res.body.items[0].quantity).toBe(5);
        expect(res.body.items[0].productId).toBe(product.id);
    });

    it("should forbid normal users from updating orders they don't own", async () => {
        const listRes = await api
            .get("/orders")
            .set("Authorization", `Bearer ${adminToken}`);
        const order = listRes.body[0];
        const prodRes = await api
            .get("/products")
            .set("Authorization", `Bearer ${userToken}`);
        const product = prodRes.body[0];

        const res = await api
            .put(`/orders/${order.id}`)
            .set("Authorization", `Bearer ${userToken}`)
            .send({
                items: [{ productId: product.id, quantity: 1 }],
            });

        expect(res.status).toBe(403);
    });

    it("should delete an order (admin only)", async () => {
        // Create an order to delete
        const prodRes = await api
            .get("/products")
            .set("Authorization", `Bearer ${userToken}`);
        const product = prodRes.body[0];

        const createRes = await api
            .post("/orders")
            .set("Authorization", `Bearer ${userToken}`)
            .send({
                items: [{ productId: product.id, quantity: 1 }],
            });
        expect(createRes.status).toBe(201);

        const orderId = createRes.body.id;

        const deleteRes = await api
            .delete(`/orders/${orderId}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(deleteRes.status).toBe(204);

        const checkRes = await api
            .get(`/orders/${orderId}`)
            .set("Authorization", `Bearer ${adminToken}`);
        expect(checkRes.status).toBe(404);
    });

    it("should forbid normal users from deleting orders", async () => {
        const listRes = await api
            .get("/orders")
            .set("Authorization", `Bearer ${adminToken}`);
        const order = listRes.body[0];

        const res = await api
            .delete(`/orders/${order.id}`)
            .set("Authorization", `Bearer ${userToken}`);

        expect(res.status).toBe(403);
    });
});

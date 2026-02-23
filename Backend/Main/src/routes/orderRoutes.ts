import express from "express";
import {
    getAllOrders,
    getOrderById,
    createOrder,
    updateOrder,
    deleteOrder
} from "../controllers/orderController";
import { authenticate, authorize } from "../middleware/authMiddleware";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Orders
 *   description: Manage customer orders
 */

// Require authentication for all order routes
router.use(authenticate);

/**
 * @swagger
 * /orders:
 *   get:
 *     summary: Get all orders (admin only)
 *     description: Returns a list of all customer orders. Only accessible by admins.
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successfully retrieved all orders
 *       401:
 *         description: Unauthorized (missing or invalid token)
 *       403:
 *         description: Forbidden (admin only)
 */
router.get("/", authorize(["ADMIN"]), getAllOrders);

/**
 * @swagger
 * /orders/{id}:
 *   get:
 *     summary: Get a specific order by ID
 *     description: Returns a specific order. Accessible by the owning user or an admin.
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The order ID
 *     responses:
 *       200:
 *         description: Successfully retrieved order
 *       401:
 *         description: Unauthorized (missing or invalid token)
 *       403:
 *         description: Forbidden (not your order)
 *       404:
 *         description: Order not found
 */
router.get("/:id", authorize(["USER", "ADMIN"]), getOrderById);

/**
 * @swagger
 * /orders:
 *   post:
 *     summary: Create a new order
 *     description: Allows a user or admin to create a new order with one or more products.
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               items:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     productId:
 *                       type: string
 *                     quantity:
 *                       type: integer
 *                       minimum: 1
 *             example:
 *               items:
 *                 - productId: "123e4567-e89b-12d3-a456-426614174000"
 *                   quantity: 2
 *                 - productId: "223e4567-e89b-12d3-a456-426614174000"
 *                   quantity: 1
 *     responses:
 *       201:
 *         description: Order successfully created
 *       400:
 *         description: Invalid request body
 *       401:
 *         description: Unauthorized (missing or invalid token)
 */
router.post("/", authorize(["USER", "ADMIN"]), createOrder);

/**
 * @swagger
 * /orders/{id}:
 *   put:
 *     summary: Update an order (admin only)
 *     description: Allows an admin to modify order items. All items are replaced with the new list.
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The order ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               items:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     productId:
 *                       type: string
 *                     quantity:
 *                       type: integer
 *                       minimum: 1
 *             example:
 *               items:
 *                 - productId: "123e4567-e89b-12d3-a456-426614174000"
 *                   quantity: 3
 *     responses:
 *       200:
 *         description: Order successfully updated
 *       400:
 *         description: Invalid data
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (admin only)
 *       404:
 *         description: Order not found
 */
router.put("/:id", authorize(["ADMIN"]), updateOrder);

/**
 * @swagger
 * /orders/{id}:
 *   delete:
 *     summary: Delete an order (admin only)
 *     description: Allows an admin to permanently delete an order.
 *     tags: [Orders]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The order ID
 *     responses:
 *       204:
 *         description: Order successfully deleted
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (admin only)
 *       404:
 *         description: Order not found
 */
router.delete("/:id", authorize(["ADMIN"]), deleteOrder);

export default router;

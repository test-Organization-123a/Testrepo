import express from "express";
import {
    getAllRoutes,
    getRouteById,
    createRoute,
    updateRoute,
    deleteRoute,
    rateRoute
} from "../controllers/routeController";
import { authenticate, authorize } from "../middleware/authMiddleware";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Routes
 *   description: Manage climbing routes in gyms and outdoor locations
 */

// Require authentication for all routes
router.use(authenticate);

/**
 * @swagger
 * /routes:
 *   get:
 *     summary: Get all climbing routes
 *     description: Returns all climbing routes available in the system. Requires a valid user or admin token.
 *     tags: [Routes]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successfully retrieved all climbing routes
 *       401:
 *         description: Unauthorized (missing or invalid token)
 */
router.get("/", authorize(["ADMIN", "USER"]), getAllRoutes);

/**
 * @swagger
 * /routes/{id}:
 *   get:
 *     summary: Get a specific climbing route by ID
 *     description: Returns details for a single climbing route. Requires a valid user or admin token.
 *     tags: [Routes]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The climbing route ID
 *     responses:
 *       200:
 *         description: Successfully retrieved route
 *       401:
 *         description: Unauthorized (missing or invalid token)
 *       404:
 *         description: Route not found
 */
router.get("/:id", authorize(["ADMIN", "USER"]), getRouteById);

/**
 * @swagger
 * /routes:
 *   post:
 *     summary: Create a new climbing route (admin only)
 *     description: Allows an admin to create a new climbing route linked to a location.
 *     tags: [Routes]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               grade:
 *                 type: string
 *               description:
 *                 type: string
 *               locationId:
 *                 type: string
 *             required:
 *               - name
 *               - grade
 *               - locationId
 *             example:
 *               name: "Overhang Beast"
 *               grade: "7a"
 *               description: "A powerful route with a steep overhang"
 *               locationId: "123e4567-e89b-12d3-a456-426614174000"
 *     responses:
 *       201:
 *         description: Route successfully created
 *       400:
 *         description: Invalid route data
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (admin only)
 */
router.post("/", authorize(["ADMIN"]), createRoute);

/**
 * @swagger
 * /routes/{id}:
 *   put:
 *     summary: Update a climbing route (admin only)
 *     description: Allows an admin to update the name, grade, or description of an existing climbing route.
 *     tags: [Routes]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The route ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               grade:
 *                 type: string
 *               description:
 *                 type: string
 *             example:
 *               name: "Updated Overhang Beast"
 *               grade: "7a+"
 *               description: "Now with an extra dynamic start"
 *     responses:
 *       200:
 *         description: Route successfully updated
 *       400:
 *         description: Invalid data
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (admin only)
 *       404:
 *         description: Route not found
 */
router.put("/:id", authorize(["ADMIN"]), updateRoute);

/**
 * @swagger
 * /routes/{id}:
 *   delete:
 *     summary: Delete a climbing route (admin only)
 *     description: Deletes a climbing route from the system. Admins only.
 *     tags: [Routes]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The route ID
 *     responses:
 *       204:
 *         description: Route successfully deleted
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (admin only)
 *       404:
 *         description: Route not found
 */
router.delete("/:id", authorize(["ADMIN"]), deleteRoute);

/**
 * @swagger
 * /routes/{id}/rate:
 *   post:
 *     summary: Submit or update your rating for a climbing route
 *     description: Allows a logged-in user to submit or update their personal difficulty rating for a specific route.
 *     tags: [Routes]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The route ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               grade:
 *                 type: string
 *                 description: The user’s perceived grade for the route (e.g., 6a, 6b+, 7a)
 *             example:
 *               grade: "6b+"
 *     responses:
 *       200:
 *         description: Rating successfully submitted or updated
 *       400:
 *         description: Invalid or missing grade
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Route not found
 */
router.post("/:id/rate", authorize(["ADMIN", "USER"]), rateRoute);

export default router;

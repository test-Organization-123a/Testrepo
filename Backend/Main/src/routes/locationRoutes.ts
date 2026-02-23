import express from "express";
import {
    getAllLocations,
    getLocationById,
    createLocation,
    updateLocation,
    deleteLocation
} from "../controllers/locationController";
import { authenticate, authorize } from "../middleware/authMiddleware";
import { locationUpload } from "../middleware/upload";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Locations
 *   description: Manage climbing gym or outdoor locations
 */

// Require authentication for all routes
router.use(authenticate);

/**
 * @swagger
 * /locations:
 *   get:
 *     summary: Get all climbing locations
 *     description: Returns all available locations. Requires a valid user or admin token.
 *     tags: [Locations]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successfully retrieved locations
 *       401:
 *         description: Unauthorized (missing or invalid token)
 */
router.get("/", authorize(["ADMIN", "USER"]), getAllLocations);

/**
 * @swagger
 * /locations/{id}:
 *   get:
 *     summary: Get a climbing location by ID
 *     description: Returns a specific climbing location by its ID. Requires a valid user or admin token.
 *     tags: [Locations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The location ID
 *     responses:
 *       200:
 *         description: Successfully retrieved location
 *       401:
 *         description: Unauthorized (missing or invalid token)
 *       404:
 *         description: Location not found
 */
router.get("/:id", authorize(["ADMIN", "USER"]), getLocationById);

/**
 * @swagger
 * /locations:
 *   post:
 *     summary: Create a new climbing location (admin only)
 *     description: Allows an admin to create a new climbing location with optional images.
 *     tags: [Locations]
 *     consumes:
 *       - multipart/form-data
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               description:
 *                 type: string
 *               address:
 *                 type: string
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *             required:
 *               - name
 *               - description
 *               - address
 *             example:
 *               name: "Boulder Planet"
 *               description: "Indoor climbing gym"
 *               address: "123 Climb St, Amsterdam"
 *     responses:
 *       201:
 *         description: Location successfully created
 *       400:
 *         description: Invalid data
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (admin only)
 */
router.post(
    "/",
    authorize(["ADMIN"]),
    locationUpload.array("images", 5),
    createLocation
);

/**
 * @swagger
 * /locations/{id}:
 *   put:
 *     summary: Update a climbing location (admin only)
 *     description: Allows an admin to update location details and replace images.
 *     tags: [Locations]
 *     consumes:
 *       - multipart/form-data
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The location ID
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               description:
 *                 type: string
 *               address:
 *                 type: string
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *             example:
 *               name: "Updated Gym"
 *               description: "Renovated climbing center"
 *               address: "456 New Rock Rd"
 *     responses:
 *       200:
 *         description: Successfully updated location
 *       400:
 *         description: Invalid data
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (admin only)
 *       404:
 *         description: Location not found
 */
router.put(
    "/:id",
    authorize(["ADMIN"]),
    locationUpload.array("images", 5),
    updateLocation
);

/**
 * @swagger
 * /locations/{id}:
 *   delete:
 *     summary: Delete a climbing location (admin only)
 *     description: Deletes a climbing location and all its related routes and images. Admin only.
 *     tags: [Locations]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The location ID
 *     responses:
 *       204:
 *         description: Location successfully deleted
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (admin only)
 *       404:
 *         description: Location not found
 */
router.delete("/:id", authorize(["ADMIN"]), deleteLocation);

export default router;

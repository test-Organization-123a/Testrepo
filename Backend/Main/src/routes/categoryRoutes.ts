import express from "express";
import {
    getAllCategories,
    getCategoryById,
    createCategory,
    updateCategory,
    deleteCategory
} from "../controllers/categoryController";
import { authenticate, authorize } from "../middleware/authMiddleware";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Categories
 *   description: Manage product categories
 */

/**
 * Apply authentication to all category routes.
 */
router.use(authenticate);

/**
 * @swagger
 * /categories:
 *   get:
 *     summary: Get all categories
 *     description: Returns a list of all categories. Requires a valid user or admin token.
 *     tags: [Categories]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successfully retrieved categories
 *       401:
 *         description: Unauthorized (missing or invalid token)
 */
router.get("/", authorize(["ADMIN", "USER"]), getAllCategories);

/**
 * @swagger
 * /categories/{id}:
 *   get:
 *     summary: Get a category by ID
 *     description: Returns details of a specific category by its ID. Requires a valid user or admin token.
 *     tags: [Categories]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The category ID
 *     responses:
 *       200:
 *         description: Category details
 *       401:
 *         description: Unauthorized (missing or invalid token)
 *       404:
 *         description: Category not found
 */
router.get("/:id", authorize(["ADMIN", "USER"]), getCategoryById);

/**
 * @swagger
 * /categories:
 *   post:
 *     summary: Create a new category
 *     description: Allows an admin to create a new category.
 *     tags: [Categories]
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
 *               description:
 *                 type: string
 *             required:
 *               - name
 *               - description
 *             example:
 *               name: "Ropes"
 *               description: "Dynamic and static climbing ropes"
 *     responses:
 *       201:
 *         description: Category successfully created
 *       400:
 *         description: Invalid input data
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (only admins allowed)
 */
router.post("/", authorize(["ADMIN"]), createCategory);

/**
 * @swagger
 * /categories/{id}:
 *   put:
 *     summary: Update a category
 *     description: Allows an admin to update category details.
 *     tags: [Categories]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Category ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               description:
 *                 type: string
 *             example:
 *               name: "Updated Category"
 *               description: "Updated description text"
 *     responses:
 *       200:
 *         description: Category successfully updated
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (only admins allowed)
 *       404:
 *         description: Category not found
 */
router.put("/:id", authorize(["ADMIN"]), updateCategory);

/**
 * @swagger
 * /categories/{id}:
 *   delete:
 *     summary: Delete a category
 *     description: Deletes a category if it does not contain any products. Admin only.
 *     tags: [Categories]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Category ID
 *     responses:
 *       204:
 *         description: Category successfully deleted
 *       400:
 *         description: Cannot delete category with existing products
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (only admins allowed)
 *       404:
 *         description: Category not found
 */
router.delete("/:id", authorize(["ADMIN"]), deleteCategory);

export default router;

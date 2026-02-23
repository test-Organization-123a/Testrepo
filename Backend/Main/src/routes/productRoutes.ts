import express from "express";
import {
    getAllProducts,
    getProductById,
    createProduct,
    updateProduct,
    deleteProduct
} from "../controllers/productController";
import { authenticate, authorize } from "../middleware/authMiddleware";
import { upload } from "../middleware/upload";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Products
 *   description: Manage products sold in the store
 */

// Require authentication for all routes
router.use(authenticate);

/**
 * @swagger
 * /products:
 *   get:
 *     summary: Get all products
 *     description: Returns a list of all products in the store. Requires a valid user or admin token.
 *     tags: [Products]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Successfully retrieved list of products
 *       401:
 *         description: Unauthorized (missing or invalid token)
 */
router.get("/", authorize(["ADMIN", "USER"]), getAllProducts);

/**
 * @swagger
 * /products/{id}:
 *   get:
 *     summary: Get a product by ID
 *     description: Returns detailed information about a specific product. Requires a valid user or admin token.
 *     tags: [Products]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The product ID
 *     responses:
 *       200:
 *         description: Successfully retrieved product
 *       401:
 *         description: Unauthorized (missing or invalid token)
 *       404:
 *         description: Product not found
 */
router.get("/:id", authorize(["ADMIN", "USER"]), getProductById);

/**
 * @swagger
 * /products:
 *   post:
 *     summary: Create a new product (admin only)
 *     description: Allows an admin to create a new product and upload up to 5 images.
 *     tags: [Products]
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
 *               price:
 *                 type: number
 *                 format: float
 *               stock:
 *                 type: integer
 *               categoryId:
 *                 type: string
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *             required:
 *               - name
 *               - description
 *               - price
 *               - stock
 *               - categoryId
 *             example:
 *               name: "Dynamic Rope 60m"
 *               description: "Durable dynamic climbing rope"
 *               price: 149.99
 *               stock: 50
 *               categoryId: "123e4567-e89b-12d3-a456-426614174000"
 *     responses:
 *       201:
 *         description: Product successfully created
 *       400:
 *         description: Invalid product data
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (admin only)
 */
router.post(
    "/",
    authorize(["ADMIN"]),
    upload.array("images", 5),
    createProduct
);

/**
 * @swagger
 * /products/{id}:
 *   put:
 *     summary: Update a product (admin only)
 *     description: Allows an admin to update product details and replace product images.
 *     tags: [Products]
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
 *         description: Product ID
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
 *               price:
 *                 type: number
 *               stock:
 *                 type: integer
 *               categoryId:
 *                 type: string
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: binary
 *             example:
 *               name: "Updated Rope 70m"
 *               description: "New longer version of the dynamic rope"
 *               price: 169.99
 *               stock: 40
 *               categoryId: "123e4567-e89b-12d3-a456-426614174000"
 *     responses:
 *       200:
 *         description: Product successfully updated
 *       400:
 *         description: Invalid data
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (admin only)
 *       404:
 *         description: Product not found
 */
router.put(
    "/:id",
    authorize(["ADMIN"]),
    upload.array("images", 5),
    updateProduct
);

/**
 * @swagger
 * /products/{id}:
 *   delete:
 *     summary: Delete a product (admin only)
 *     description: Deletes a product from the catalog. Returns an error if the product is linked to an order.
 *     tags: [Products]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: The product ID
 *     responses:
 *       204:
 *         description: Product successfully deleted
 *       400:
 *         description: Cannot delete a product linked to an order
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden (admin only)
 *       404:
 *         description: Product not found
 */
router.delete("/:id", authorize(["ADMIN"]), deleteProduct);

export default router;
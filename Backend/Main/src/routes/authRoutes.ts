import express from "express";
import { register, login } from "../controllers/authController";

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Auth
 *   description: User authentication
 */

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Register a new user
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *               name:
 *                 type: string
 *             example:
 *               email: "climber@example.com"
 *               password: "mypassword"
 *               name: "John Climber"
 *     responses:
 *       201:
 *         description: User registered
 *       400:
 *         description: Invalid input
 */
router.post("/register", register);

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Login a user and return a JWT
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *             example:
 *               email: "climber@example.com"
 *               password: "mypassword"
 *     responses:
 *       200:
 *         description: JWT token
 *       401:
 *         description: Unauthorized
 */
router.post("/login", login);

export default router;

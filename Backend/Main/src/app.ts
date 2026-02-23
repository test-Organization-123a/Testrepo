import express from 'express';
import dotenv from 'dotenv';
import path from 'path';
import cors from 'cors';

import categoryRoutes from './routes/categoryRoutes';
import productRoutes from './routes/productRoutes';
import orderRoutes from './routes/orderRoutes';
import authRoutes from './routes/authRoutes';
import locationRoutes from "./routes/locationRoutes";
import routeRoutes from "./routes/routeRoutes";
import { setupSwagger } from "./swagger";

dotenv.config();

const app = express();

app.use(cors({ origin: "*" }));
app.use(express.json());
setupSwagger(app);

app.use('/api/auth', authRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);
app.use("/api/locations", locationRoutes);
app.use("/api/routes", routeRoutes);
app.get("/api/health", (_req, res) => res.json({ status: "ok" }));
app.use("/api/uploads", express.static(path.join(__dirname, "..", "uploads")));

export default app;

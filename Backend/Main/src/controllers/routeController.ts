import { Request, Response } from "express";
import prisma from "../prisma/client";
import { AuthRequest } from "../middleware/authMiddleware";

export const getAllRoutes = async (_req: Request, res: Response) => {
    const routes = await prisma.route.findMany({ include: { location: true, createdBy: true } });
    res.json(routes);
};

export const getRouteById = async (req: Request, res: Response) => {
    const route = await prisma.route.findUnique({
        where: { id: req.params.id },
        include: { location: true, createdBy: true },
    });
    if (!route) return res.status(404).json({ error: "Route not found" });
    return res.json(route);
};

export const createRoute = async (req: AuthRequest, res: Response) => {
    const { name, grade, description, locationId } = req.body;
    if (!req.user) return res.status(401).json({ error: "Unauthorized" });

    const route = await prisma.route.create({
        data: {
            name,
            grade,
            description,
            locationId,
            createdById: req.user.userId,
        },
    });
    return res.status(201).json(route);
};

export const updateRoute = async (req: Request, res: Response) => {
    const { name, grade, description } = req.body;
    try {
        const route = await prisma.route.update({
            where: { id: req.params.id },
            data: { name, grade, description },
        });
        res.json(route);
    } catch {
        res.status(404).json({ error: "Route not found" });
    }
};

export const deleteRoute = async (req: Request, res: Response) => {
    try {
        await prisma.route.delete({ where: { id: req.params.id } });
        res.status(204).send();
    } catch {
        res.status(404).json({ error: "Route not found" });
    }
};

export const rateRoute = async (req: AuthRequest, res: Response) => {
    const { grade } = req.body;
    const routeId = req.params.id;

    if (!req.user) {
        return res.status(401).json({ error: "Unauthorized" });
    }

    if (!grade || typeof grade !== "string") {
        return res.status(400).json({ error: "Grade is required" });
    }

    try {
        // Upsert user's rating
        await prisma.routeRating.upsert({
            where: {
                userId_routeId: {
                    userId: req.user.userId,
                    routeId,
                },
            },
            update: {
                grade,
            },
            create: {
                userId: req.user.userId,
                routeId,
                grade,
            },
        });

        return res.json({ message: "Rating submitted" });
    } catch (error) {
        console.error(error);
        return res.status(500).json({ error: "Failed to rate route" });
    }
};

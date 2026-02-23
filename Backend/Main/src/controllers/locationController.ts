import { Request, Response } from "express";
import prisma from "../prisma/client";

export const getAllLocations = async (_req: Request, res: Response) => {
    const locations = await prisma.location.findMany({ 
        include: { 
            routes: true,
            images: true 
        } 
    });
    res.json(locations);
};

export const getLocationById = async (req: Request, res: Response) => {
    const location = await prisma.location.findUnique({
        where: { id: req.params.id },
        include: { 
            routes: true,
            images: true 
        },
    });
    if (!location) return res.status(404).json({ error: "Location not found" });
    return res.json(location);
};

export const createLocation = async (req: Request, res: Response) => {
    const { name, description, address } = req.body;
    const files = req.files as Express.Multer.File[];

    try {
        const location = await prisma.location.create({
            data: { name, description, address },
        });

        if (files && files.length > 0) {
            await prisma.locationImage.createMany({
                data: files.map(file => ({
                    url: `/uploads/locations/${file.filename}`,
                    locationId: location.id,
                })),
            });
        }

        const fullLocation = await prisma.location.findUnique({
            where: { id: location.id },
            include: {
                routes: true,
                images: true,
            },
        });

        return res.status(201).json(fullLocation);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: "Failed to create location" });
    }
};

export const updateLocation = async (req: Request, res: Response) => {
    try {
        const { id } = req.params;
        const files = req.files as Express.Multer.File[];
        const { name, description, address } = req.body;

        await prisma.location.update({
            where: { id },
            data: { name, description, address },
        });

        if (files && files.length > 0) {
            await prisma.locationImage.deleteMany({ where: { locationId: id } });

            await prisma.locationImage.createMany({
                data: files.map((file) => ({
                    url: `/uploads/locations/${file.filename}`,
                    locationId: id,
                })),
            });
        }

        const fullLocation = await prisma.location.findUnique({
            where: { id },
            include: { 
                routes: true, 
                images: true 
            },
        });

        return res.json(fullLocation);
    } catch (error) {
        console.error("Update location failed:", error);
        return res.status(500).json({ error: "Failed to update location" });
    }
};

export const deleteLocation = async (req: Request, res: Response) => {
    try {
        const locationId = req.params.id;

        const routeCount = await prisma.route.count({ where: { locationId } });
        if (routeCount > 0) {
            return res
                .status(400)
                .json({ error: "Cannot delete location that has associated routes." });
        }

        await prisma.locationImage.deleteMany({ where: { locationId } });
        await prisma.location.delete({ where: { id: locationId } });

        return res.status(204).send();
    } catch {
        return res.status(404).json({ error: "Location not found" });
    }
};

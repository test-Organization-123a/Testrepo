import { Request, Response } from "express";
import prisma from "../prisma/client";

export const getAllCategories = async (_req: Request, res: Response) => {
    const categories = await prisma.category.findMany({ include: { products: true } });
    res.json(categories);
};

export const getCategoryById = async (req: Request, res: Response) => {
    const category = await prisma.category.findUnique({
        where: { id: req.params.id },
        include: { products: true },
    });
    if (!category) return res.status(404).json({ error: "Not found" });
    return res.json(category);
};

export const createCategory = async (req: Request, res: Response) => {
    const category = await prisma.category.create({ data: req.body });
    res.status(201).json(category);
};

export const updateCategory = async (req: Request, res: Response) => {
    try {
        const category = await prisma.category.update({
            where: { id: req.params.id },
            data: req.body,
        });
        res.json(category);
    } catch {
        res.status(404).json({ error: "Not found" });
    }
};

export const deleteCategory = async (req: Request, res: Response) => {
    try {
        const productCount = await prisma.product.count({
            where: { categoryId: req.params.id },
        });

        if (productCount > 0) {
            return res
                .status(400)
                .json({ error: "Cannot delete category that still contains products." });
        }

        await prisma.category.delete({ where: { id: req.params.id } });
        return res.status(204).send();
    } catch {
        return res.status(404).json({ error: "Category not found" });
    }
};
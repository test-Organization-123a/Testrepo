import { Request, Response } from "express";
import prisma from "../prisma/client";

export const getAllProducts = async (_req: Request, res: Response) => {
    const products = await prisma.product.findMany({
        include: {
            category: true,
            images: true,
        },
    });
    return res.json(products);
};

export const getProductById = async (req: Request, res: Response) => {
    const product = await prisma.product.findUnique({
        where: { id: req.params.id },
        include: {
            category: true,
            images: true,
        },
    });

    if (!product) return res.status(404).json({ error: "Product not found" });
    return res.json(product);
};

export const createProduct = async (req: Request, res: Response) => {
    const { name, description, price, stock, categoryId } = req.body;
    const files = req.files as Express.Multer.File[];

    try {
        const product = await prisma.product.create({
            data: {
                name,
                description,
                price: parseFloat(price),
                stock: parseInt(stock),
                categoryId,
            },
        });

        if (files && files.length > 0) {
            await prisma.productImage.createMany({
                data: files.map(file => ({
                    url: `/uploads/products/${file.filename}`,
                    productId: product.id,
                })),
            });
        }

        const fullProduct = await prisma.product.findUnique({
            where: { id: product.id },
            include: {
                category: true,
                images: true,
            },
        });

        return res.status(201).json(fullProduct);
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: "Failed to create product" });
    }
};

export const updateProduct = async (req: Request, res: Response) => {
    try {
        console.log(req.body);
        const { id } = req.params;
        const files = req.files as Express.Multer.File[]; // new files if uploaded
        const { name, description, price, stock, categoryId } = req.body;

        // Update base product info
        await prisma.product.update({
            where: { id },
            data: {
                name,
                description,
                price: parseFloat(price),
                stock: parseInt(stock),
                categoryId,
            },
        });

        // Handle new images (if any)
        if (files && files.length > 0) {
            // Delete existing images first (optional, or keep based on UX)
            await prisma.productImage.deleteMany({ where: { productId: id } });

            await prisma.productImage.createMany({
                data: files.map((file) => ({
                    url: `/uploads/products/${file.filename}`,
                    productId: id,
                })),
            });
        }

        const fullProduct = await prisma.product.findUnique({
            where: { id },
            include: { category: true, images: true },
        });

        return res.json(fullProduct);
    } catch (error) {
        console.error("Update product failed:", error);
        return res.status(500).json({ error: "Failed to update product" });
    }
};

export const deleteProduct = async (req: Request, res: Response) => {
    try {
        const productId = req.params.id;

        const references = await prisma.orderItem.count({ where: { productId } });
        if (references > 0) {
            return res
                .status(400)
                .json({ error: "Cannot delete product linked to an existing order." });
        }

        await prisma.productImage.deleteMany({ where: { productId } });
        await prisma.product.delete({ where: { id: productId } });

        return res.status(204).send();
    } catch (err) {
        console.error("Delete product failed:", err);
        return res.status(404).json({ error: "Product not found" });
    }
};
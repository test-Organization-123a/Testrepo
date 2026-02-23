import { Response } from "express";
import prisma from "../prisma/client";
import { AuthRequest } from "../middleware/authMiddleware";

export const getAllOrders = async (_req: AuthRequest, res: Response) => {
    const orders = await prisma.order.findMany({ include: { items: { include: { product: true } }, customer: true } });
    res.json(orders);
};

export const getOrderById = async (req: AuthRequest, res: Response) => {
    const order = await prisma.order.findUnique({
        where: { id: req.params.id },
        include: { items: { include: { product: true } }, customer: true },
    });

    if (!order) return res.status(404).json({ error: "Not found" });

    if (req.user?.role !== "ADMIN" && order.customerId !== req.user?.userId) {
        return res.status(403).json({ error: "Forbidden" });
    }

    return res.json(order);
};
interface OrderItemInput {
    productId: string;
    quantity: number;
}
export const createOrder = async (req: AuthRequest, res: Response) => {
    const { items } = req.body as { items: OrderItemInput[] };

    if (!req.user) return res.status(401).json({ error: "Unauthorized" });

    const order = await prisma.order.create({
        data: {
            customerId: req.user.userId,
            items: {
                create: items.map((i: OrderItemInput) => ({
                    productId: i.productId,
                    quantity: i.quantity,
                })),
            },
        },
        include: { items: { include: { product: true } } },
    });

    return res.status(201).json(order);
};

export const updateOrder = async (req: AuthRequest, res: Response) => {
    const { items } = req.body;

    if (!items || !Array.isArray(items)) {
        return res.status(400).json({ error: "Invalid or missing 'items'" });
    }

    try {
        const existingOrder = await prisma.order.findUnique({
            where: { id: req.params.id },
        });

        if (!existingOrder) {
            return res.status(404).json({ error: "Order not found" });
        }

        if (req.user?.role !== "ADMIN" && existingOrder.customerId !== req.user?.userId) {
            return res.status(403).json({ error: "Unauthorized to update this order" });
        }

        await prisma.orderItem.deleteMany({
            where: { orderId: req.params.id },
        });

        const updatedOrder = await prisma.order.update({
            where: { id: req.params.id },
            data: {
                items: {
                    create: items.map((item: { productId: string; quantity: number }) => ({
                        productId: item.productId,
                        quantity: item.quantity,
                    })),
                },
            },
            include: {
                items: true,
            },
        });

        return res.json(updatedOrder);
    } catch (error) {
        console.error(error);
        return res.status(500).json({ error: "Failed to update order" });
    }
};

export const deleteOrder = async (req: AuthRequest, res: Response) => {
    try {
        await prisma.order.delete({ where: { id: req.params.id } });
        return res.status(204).send();
    } catch {
        return res.status(404).json({ error: "Not found" });
    }
};

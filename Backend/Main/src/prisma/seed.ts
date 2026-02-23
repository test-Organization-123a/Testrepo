import prisma from "./client";
import fs from "fs";
import path from "path";
import bcrypt from "bcrypt";

interface SeedData {
    users: { email: string; password: string; name: string; role: "USER" | "ADMIN" }[];
    categories: { name: string; description: string }[];
    products: { name: string; description: string; price: number; stock: number; category: string; images?: string[] }[];
    orders: { customer: string; products: string[] }[];
    locations?: { name: string; description: string; address: string; images?: string[] }[];
    routes?: { name: string; grade: string; description: string; location: string; createdBy: string }[];
}

export async function seed() {
    console.log("Starting seed...");

    const filePath = path.join(__dirname, "data.json");
    const data: SeedData = JSON.parse(fs.readFileSync(filePath, "utf-8"));

    await prisma.routeRating.deleteMany();
    await prisma.route.deleteMany();
    await prisma.locationImage.deleteMany();
    await prisma.location.deleteMany();
    await prisma.orderItem.deleteMany();
    await prisma.order.deleteMany();
    await prisma.productImage.deleteMany();
    await prisma.product.deleteMany();
    await prisma.category.deleteMany();
    await prisma.user.deleteMany();

    // Seed Users
    const userMap: Record<string, string> = {};
    for (const u of data.users) {
        const hashedPassword = await bcrypt.hash(u.password, 10);
        const user = await prisma.user.create({
            data: {
                email: u.email,
                passwordHash: hashedPassword,
                name: u.name,
                role: u.role,
            },
        });
        userMap[u.email] = user.id;
    }

    // Seed Categories
    const categoryMap: Record<string, string> = {};
    for (const c of data.categories) {
        const category = await prisma.category.create({
            data: {
                name: c.name,
                description: c.description,
            },
        });
        categoryMap[c.name] = category.id;
    }

    // Seed Products
    const productMap: Record<string, string> = {};
    const uploadDir = path.join(__dirname, "..", "..", "uploads", "products");

    // Ensure upload directory exists
    if (!fs.existsSync(uploadDir)) {
        fs.mkdirSync(uploadDir, { recursive: true });
    }

    for (const p of data.products) {
        // Create the product
        const product = await prisma.product.create({
            data: {
                name: p.name,
                description: p.description,
                price: p.price,
                stock: p.stock,
                categoryId: categoryMap[p.category],
            },
        });
        productMap[p.name] = product.id;

        if (p.images && p.images.length > 0) {
            const imageData: { url: string; productId: string }[] = [];

            for (const img of p.images) {
                const srcPath = path.join(__dirname, "images", path.basename(img));

                const uniqueFilename = `${Date.now()}-${path.basename(img)}`;

                const destPath = path.join(uploadDir, uniqueFilename);

                if (fs.existsSync(srcPath)) {
                    fs.copyFileSync(srcPath, destPath);

                    imageData.push({
                        url: `/uploads/products/${uniqueFilename}`,
                        productId: product.id,
                    });
                } else {
                    console.warn(`Missing image file: ${srcPath}`);
                }
            }

            // Create many images in DB (same as controller)
            if (imageData.length > 0) {
                await prisma.productImage.createMany({ data: imageData });
            }
        }
    }

    // Seed Orders
    for (const order of data.orders) {
        const customerId = userMap[order.customer];
        if (!customerId) {
            console.warn(`Skipping order: customer ${order.customer} not found`);
            continue;
        }

        await prisma.order.create({
            data: {
                customerId,
                items: {
                    create: order.products.map((prodName) => {
                        const productId = productMap[prodName];
                        if (!productId) throw new Error(`Product not found: ${prodName}`);
                        return { productId, quantity: 1 };
                    }),
                },
            },
        });
    }

    // Seed locations
    const locationMap: Record<string, string> = {};
    const locationUploadDir = path.join(__dirname, "..", "..", "uploads", "locations");

    // Ensure location upload directory exists
    if (!fs.existsSync(locationUploadDir)) {
        fs.mkdirSync(locationUploadDir, { recursive: true });
    }

    if (data.locations) {
        for (const loc of data.locations) {
            const location = await prisma.location.create({
                data: {
                    name: loc.name,
                    description: loc.description,
                    address: loc.address,
                },
            });
            locationMap[loc.name] = location.id;

            if (loc.images && loc.images.length > 0) {
                const imageData: { url: string; locationId: string }[] = [];

                for (const img of loc.images) {
                    const srcPath = path.join(__dirname, "images", path.basename(img));
                    const uniqueFilename = `${Date.now()}-${path.basename(img)}`;
                    const destPath = path.join(locationUploadDir, uniqueFilename);

                    if (fs.existsSync(srcPath)) {
                        fs.copyFileSync(srcPath, destPath);

                        imageData.push({
                            url: `/uploads/locations/${uniqueFilename}`,
                            locationId: location.id,
                        });
                    } else {
                        console.warn(`Missing location image file: ${srcPath}`);
                    }
                }

                if (imageData.length > 0) {
                    await prisma.locationImage.createMany({ data: imageData });
                }
            }
        }
    }

    // Seed routes
    if (data.routes) {
        for (const route of data.routes) {
            const createdById = userMap[route.createdBy];
            const locationId = locationMap[route.location];
            if (!createdById || !locationId) continue;

            await prisma.route.create({
                data: {
                    name: route.name,
                    grade: route.grade,
                    description: route.description,
                    locationId,
                    createdById,
                },
            });
        }
    }

    console.log("Seed complete!");
}

if (require.main === module) {
    seed()
        .catch((err) => {
            console.error(" Seed failed:", err);
            process.exit(1);
        })
        .finally(async () => {
            await prisma.$disconnect();
        });
}

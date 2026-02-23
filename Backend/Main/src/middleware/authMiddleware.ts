import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";

const JWT_SECRET = process.env.JWT_SECRET || "supersecret";

export interface AuthRequest extends Request {
    user?: { userId: string; role: "USER" | "ADMIN" };
}

export const authenticate = (req: AuthRequest, res: Response, next: NextFunction) => {
    const authHeader = req.headers["authorization"];
    if (!authHeader) {
        return res.status(401).json({ error: "No token provided" });
    }

    // Expect "Bearer <token>"
    const parts = authHeader.split(" ");
    if (parts.length !== 2 || parts[0] !== "Bearer") {
        return res.status(401).json({ error: "Malformed token" });
    }

    const token = parts[1];

    try {
        const payload = jwt.verify(token, JWT_SECRET) as { userId: string; role: "USER" | "ADMIN" };
        req.user = payload;
        return next();
    } catch {
        return res.status(401).json({ error: "Invalid or expired token" });
    }
};

export const authorize =
    (roles: ("USER" | "ADMIN")[]) =>
        (req: AuthRequest, res: Response, next: NextFunction) => {
            if (!req.user) {
                return res.status(401).json({ error: "Unauthorized" });
            }
            if (!roles.includes(req.user.role)) {
                return res.status(403).json({ error: "Forbidden" });
            }
            return next();
        };

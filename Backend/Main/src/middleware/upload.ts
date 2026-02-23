import multer from "multer";
import fs from "fs";

const createStorage = (folder: string) => multer.diskStorage({
    destination: (_req, _file, cb) => {
        const uploadDir = `uploads/${folder}`;
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (_req, file, cb) => {
        const unique = `${Date.now()}-${file.originalname}`;
        cb(null, unique);
    },
});

export const upload = multer({ storage: createStorage("products") });
export const locationUpload = multer({ storage: createStorage("locations") });

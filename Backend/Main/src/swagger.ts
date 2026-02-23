import swaggerJsdoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-express";
import { Express } from "express";

const options: swaggerJsdoc.Options = {
    definition: {
        openapi: "3.0.0",
        info: {
            title: "ClimbEasy API",
            version: "1.0.0",
            description: "API documentation for ClimbEasy backend",
        },
        servers: [
            {
                url: "https://staging.climbeasy.saxion.online/api/",
                description: "Acceptance API",
            },
            {
                url: "https://climbeasy.saxion.online/api",
                description: "Production API",
            },
        ],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: "http",
                    scheme: "bearer",
                    bearerFormat: "JWT",
                },
            },
        },
        security: [{ bearerAuth: [] }],
    },
    apis: [
        "./src/routes/*.ts",
        "./dist/routes/*.js"
    ],
};

const swaggerSpec = swaggerJsdoc(options);

export function setupSwagger(app: Express) {
    app.use(
        "/api/docs",
        swaggerUi.serve,
        swaggerUi.setup(swaggerSpec, {
            swaggerOptions: {
                docExpansion: "none",
                operationsSorter: "alpha",
                tagsSorter: "alpha"
            }
        })
    );
}

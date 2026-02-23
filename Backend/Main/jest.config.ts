import type { Config } from "jest";

const config: Config = {
    preset: "ts-jest",
    testEnvironment: "node",
    testMatch: ["**/__tests__/**/*.test.ts", "**/tests/**/*.test.ts"],
    moduleFileExtensions: ["ts", "js", "json"],
    clearMocks: true,
    verbose: true,
    maxWorkers: 1,
    forceExit: true,
    detectOpenHandles: true,
    setupFilesAfterEnv: ["./tests/setupTestDB.ts"],
    transform: {
        "^.+\\.tsx?$": [
            "ts-jest",
            {
                tsconfig: "./tsconfig.test.json",
            },
        ],
    },

};

export default config;

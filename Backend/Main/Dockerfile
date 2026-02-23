# 1. Base stage
FROM node:20 AS base
WORKDIR /app
COPY package*.json tsconfig.json ./
COPY prisma ./prisma

# 2. Development stage
FROM base AS development
RUN npm install
RUN npm install -g ts-node-dev
RUN npx prisma generate
CMD ["ts-node-dev", "--respawn", "--transpile-only", "src/index.ts"]

# 3. Build stage
FROM base AS build
RUN npm install --production=false
COPY . .
RUN npx prisma generate
RUN npm run build   # compiles TS -> dist/

# 4. Production stage
FROM node:20-slim AS production
WORKDIR /app
RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*
COPY package*.json ./
RUN npm install --only=production
COPY --from=build /app/dist ./dist
COPY --from=build /app/prisma ./prisma
COPY --from=build /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=build /app/dist/prisma ./dist/prisma
COPY --from=build /app/src/prisma/data.json ./dist/prisma/data.json
COPY --from=build /app/src/prisma/images ./dist/prisma/images
ENV NODE_ENV=production
CMD ["sh", "-c", "npx prisma db seed && node dist/index.js"]

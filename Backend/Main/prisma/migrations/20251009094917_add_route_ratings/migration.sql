/*
  Warnings:

  - You are about to drop the column `stars` on the `Route` table. All the data in the column will be lost.
  - Made the column `description` on table `Location` required. This step will fail if there are existing NULL values in that column.
  - Made the column `address` on table `Location` required. This step will fail if there are existing NULL values in that column.
  - Made the column `description` on table `Route` required. This step will fail if there are existing NULL values in that column.
  - Made the column `name` on table `User` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "public"."Location" ALTER COLUMN "description" SET NOT NULL,
ALTER COLUMN "address" SET NOT NULL;

-- AlterTable
ALTER TABLE "public"."Route" DROP COLUMN "stars",
ALTER COLUMN "description" SET NOT NULL;

-- AlterTable
ALTER TABLE "public"."User" ALTER COLUMN "name" SET NOT NULL;

-- CreateTable
CREATE TABLE "public"."RouteRating" (
    "id" TEXT NOT NULL,
    "grade" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT NOT NULL,
    "routeId" TEXT NOT NULL,

    CONSTRAINT "RouteRating_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "RouteRating_userId_routeId_key" ON "public"."RouteRating"("userId", "routeId");

-- AddForeignKey
ALTER TABLE "public"."RouteRating" ADD CONSTRAINT "RouteRating_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."RouteRating" ADD CONSTRAINT "RouteRating_routeId_fkey" FOREIGN KEY ("routeId") REFERENCES "public"."Route"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

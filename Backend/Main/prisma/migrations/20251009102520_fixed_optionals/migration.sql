/*
  Warnings:

  - Made the column `description` on table `Category` required. This step will fail if there are existing NULL values in that column.
  - Made the column `description` on table `Product` required. This step will fail if there are existing NULL values in that column.

*/
-- AlterTable
ALTER TABLE "public"."Category" ALTER COLUMN "description" SET NOT NULL;

-- AlterTable
ALTER TABLE "public"."Product" ALTER COLUMN "description" SET NOT NULL;

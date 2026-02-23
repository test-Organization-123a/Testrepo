-- CreateTable
CREATE TABLE "public"."LocationImage" (
    "id" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "locationId" TEXT NOT NULL,

    CONSTRAINT "LocationImage_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "public"."LocationImage" ADD CONSTRAINT "LocationImage_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "public"."Location"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

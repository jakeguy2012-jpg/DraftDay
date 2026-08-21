import { PrismaClient } from "@prisma/client";
const globalForPrisma=globalThis as unknown as {prisma?:PrismaClient};
export function getDb(){if(!process.env.STORAGE_DATABASE_URL)throw new Error("Database storage is not configured for this deployment.");const client=globalForPrisma.prisma??new PrismaClient({log:process.env.NODE_ENV==="development"?["warn","error"]:["error"]});if(process.env.NODE_ENV!=="production")globalForPrisma.prisma=client;return client;}

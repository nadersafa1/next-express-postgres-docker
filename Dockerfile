# Use Node.js image
FROM oven/bun:1.2.2-slim AS base

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app
COPY package.json bun.lock* ./
COPY apps/web/package.json ./apps/web/
COPY apps/server/package.json ./apps/server/
RUN bun install --frozen-lockfile

# Build the source code
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build both apps using Turbo
RUN bun run build

# Production image for web
FROM base AS web
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=3001
COPY --from=builder /app/apps/web/.next/standalone ./
COPY --from=builder /app/apps/web/.next/static ./apps/web/.next/static
# COPY --from=builder /app/apps/web/public ./apps/web/public
EXPOSE 3001
CMD ["node", "apps/web/server.js"]

# Production image for server
FROM base AS server
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/apps/server/dist ./apps/server/dist
COPY --from=builder /app/apps/server/package.json ./apps/server/
COPY --from=builder /app/apps/server/drizzle.config.ts ./apps/server/
COPY --from=builder /app/node_modules ./node_modules

# Copy existing migrations from src/db/migrations/
COPY --from=builder /app/apps/server/src/db/migrations ./apps/server/src/db/migrations

WORKDIR /app/apps/server
EXPOSE 3000

# Run migrations and start server
CMD ["sh", "-c", "bun run db:migrate && bun run start"]

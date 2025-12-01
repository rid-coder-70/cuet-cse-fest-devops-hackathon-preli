
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./


RUN npm install


COPY . .


RUN npm run build


RUN npm prune --production


FROM node:20-alpine


RUN apk add --no-cache dumb-init

WORKDIR /app


RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001


COPY --from=builder --chown=nodejs:nodejs /app/package*.json ./
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules


COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist

USER nodejs

EXPOSE 3847


HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3847/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"


ENTRYPOINT ["dumb-init", "--"]


CMD ["npm", "start"]

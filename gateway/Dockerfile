
FROM node:20-alpine


RUN apk add --no-cache dumb-init


WORKDIR /app


RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001


COPY package*.json ./

RUN npm install --production


COPY --chown=nodejs:nodejs . .


USER nodejs


EXPOSE 5921


HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
    CMD node -e "require('http').get('http://localhost:5921/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"


ENTRYPOINT ["dumb-init", "--"]


CMD ["npm", "start"]

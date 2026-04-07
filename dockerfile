# ---------- FRONTEND BUILD ----------
FROM node:20-alpine AS frontend-builder

WORKDIR /app

# Copy only package files first (better caching)
COPY ./Frontend/package*.json ./
RUN npm install

# Then copy rest
COPY ./Frontend ./

RUN npm run build


# ---------- BACKEND BUILD ----------
FROM node:20

WORKDIR /app

# Copy only package files first
COPY ./Backend/package*.json ./

# Install with build tools and rebuild leveldown from source
RUN npm install && \
    npm uninstall leveldown && \
    npm install leveldown --build-from-source

# Then copy backend source
COPY ./Backend ./

# Copy frontend build into backend public
COPY --from=frontend-builder /app/dist /app/public

EXPOSE 3000

CMD ["node", "server.js"]
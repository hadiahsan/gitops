# --- Stage 1: Build Stage ---
FROM node:20-slim AS build-env
WORKDIR /app

# Copy package files first to leverage Docker layer caching
COPY package*.json ./
RUN npm install

# Copy source code and build the application
COPY . .
RUN npm run build

# --- Stage 2: Runtime Stage ---
# Using the unprivileged image to run as a non-root user by default
FROM nginxinc/nginx-unprivileged:stable-alpine

# Set labels for better image metadata management
LABEL maintainer="devops-team"
LABEL version="1.0"

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy build artifacts from the build-env stage
COPY --from=build-env /app/dist /usr/share/nginx/html

# Expose a non-privileged port (8080 instead of 80)
EXPOSE 8080

# Healthcheck to ensure the container is responding
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8080/ || exit 1

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

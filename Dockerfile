FROM node:18-alpine

WORKDIR /app

# Install dependencies (production only to keep image small)
COPY package*.json ./
RUN npm ci --only=production || true

# Copy source
COPY . .

# Default command (no server; runs something harmless)
CMD ["node", "src/calculator.js"]

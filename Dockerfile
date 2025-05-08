FROM node:18-alpine

WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy the rest of the application
COPY . .

# Expose the port that the application will run on
EXPOSE 3000

# Add environment variable for production
ENV NODE_ENV=production

# Start the application
CMD ["npm", "start"]
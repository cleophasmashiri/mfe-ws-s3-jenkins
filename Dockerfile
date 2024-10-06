# Use Node.js 16.18 as the base image
FROM node:18.20-bullseye

# Set the working directory
WORKDIR /app

# Install Cypress dependencies (libgtk2.0 is required for Cypress)
RUN apt-get update && apt-get install -y \
    chromium \
    libgtk2.0-0 \
    libnotify-dev \
    libgconf-2-4 \
    libnss3 \
    libxss1 \
    libasound2 \
    xvfb

# Install Angular CLI globally
RUN npm install -g @angular/cli nx@19.0.2 --force

# Copy project files
COPY . .

# Install project dependencies (including Cypress)
# RUN npm install --force

# Install Cypress binary
RUN npx cypress install --force

# Command to run Cypress e2e tests
CMD ["npx", "cypress", "run"]



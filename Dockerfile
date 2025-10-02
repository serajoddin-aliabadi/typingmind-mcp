# Use an official Node.js runtime as a parent image (slim variant for better security)
FROM node:lts


# Install Python, pip, and other dependencies
RUN apt-get update && \
    apt-get install -y \
    python3 python3-pip \
    dpkg \
    wget \ 
    && \
    # Download the Chrome .deb directly and install with dpkg
    wget -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i /tmp/google-chrome-stable_current_amd64.deb || true && \
    # Fix missing dependencies if dpkg reported any
    apt-get -fy install && \
    # Clean up apt-get cache and temporary .deb to reduce image size
    rm -rf /var/lib/apt/lists/* /tmp/google-chrome-stable_current_amd64.deb
    

# Install uv via pip
RUN pip3 install uv --break-system-packages 

# Set the working directory in the container
WORKDIR /app

# Install pnpm globally
RUN npm install -g pnpm

# Copy package.json and pnpm-lock.yaml first to leverage Docker cache
COPY package.json pnpm-lock.yaml ./

# Install only production dependencies
RUN pnpm install --prod

# Copy the rest of the application source code
COPY . .

# Set the default port the app will run on
ENV PORT=50880

# Make port 50880 available to the world outside this container
EXPOSE 50880

# Define the command to run the app
CMD ["node", "bin/index.js"]

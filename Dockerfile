# Use a slim JDK image
FROM openjdk:17-jdk-slim

# Set working directory
WORKDIR /app

# Install curl and download Minecraft server JAR (1.20.1)
RUN apt-get update && apt-get install -y curl && \
    curl -o server.jar https://launcher.mojang.com/v1/objects/1ecba774f3c1ddda5aeb41e9c76a97cb396c29a0/server.jar && \
    echo "eula=true" > eula.txt && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Expose the Minecraft server port
EXPOSE 25565

# Launch the server
CMD ["java", "-Xmx1024M", "-Xms1024M", "-jar", "server.jar", "nogui"]

#!/bin/bash
# Reset Docker environment for clean testing

echo "Starting Docker environment reset..."

# Change to the ZZZ directory
cd /home/turtle_wolfe/repos/two_Tubes/ZZZ

# Stop all containers and remove volumes
echo "Stopping containers and removing volumes..."
docker-compose down -v

# Prune all Docker artifacts
echo "Pruning Docker images, containers, and volumes..."
docker system prune -a --volumes -f

# Restart the environment
echo "Restarting Docker environment..."
./setup.sh

echo "Docker environment has been reset and restarted."
echo "You can now deploy and test the plugin."
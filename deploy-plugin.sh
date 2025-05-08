#!/bin/bash
set -e

# Deploy RPG-Suite plugin to the ZZZ environment
# Usage: ./deploy-plugin.sh [site_name]
# Example: ./deploy-plugin.sh geolarp

# Default site is geolarp if not specified
SITE_NAME=${1:-"geolarp"}
PLUGIN_NAME="rpg-suite"
PLUGIN_DIR="/home/turtle_wolfe/repos/two_Tubes/RPG-Suite"
ZZZ_DIR="/home/turtle_wolfe/repos/two_Tubes/ZZZ"

echo "Deploying $PLUGIN_NAME to $SITE_NAME..."

# Check if the site container exists
if ! docker ps | grep -q "wp_${SITE_NAME}"; then
    echo "Error: Container wp_${SITE_NAME} not found. Make sure the ZZZ environment is running."
    echo "Try running: cd ${ZZZ_DIR} && ./setup.sh"
    exit 1
fi

# Create a temporary directory for the plugin
TEMP_DIR=$(mktemp -d)
echo "Creating temporary directory: $TEMP_DIR"

# Copy plugin files to temporary directory
echo "Copying plugin files..."
cp -r "$PLUGIN_DIR"/* "$TEMP_DIR/"

# Remove components directory to force recreation
echo "Removing dynamic component files to force recreation..."
rm -rf "$TEMP_DIR/src/Core/Components"

# Copy the plugin to the WordPress container
echo "Copying plugin to container wp_${SITE_NAME}..."
docker cp "$TEMP_DIR" "wp_${SITE_NAME}:/var/www/html/wp-content/plugins/$PLUGIN_NAME"

# Fix permissions in the container
echo "Setting correct permissions..."
docker exec "wp_${SITE_NAME}" chown -R www-data:www-data "/var/www/html/wp-content/plugins/$PLUGIN_NAME"

# Activate the plugin
echo "Activating plugin..."
docker exec "wp_${SITE_NAME}" wp plugin activate "$PLUGIN_NAME" --allow-root

# Clean up the temporary directory
echo "Cleaning up temporary directory..."
rm -rf "$TEMP_DIR"

echo "Deployment complete! Plugin $PLUGIN_NAME has been deployed to $SITE_NAME."
echo "You can access WordPress at http://localhost:8002"
echo "Admin username: admin, password: admin_password"
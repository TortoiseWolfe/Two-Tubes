# Development Workflow for RPG-Suite & ZZZ Integration

This document outlines the development workflow for integrating the RPG-Suite WordPress plugin with the ZZZ containerized environment.

## Step 1: Start the ZZZ Environment

First, we need to start the ZZZ environment which runs WordPress with BuddyPress in Docker containers:

```bash
cd /home/turtle_wolfe/repos/two_Tubes/ZZZ
./setup.sh
```

This script will:
- Build and start all Docker containers
- Set up WordPress with BuddyPress
- Configure the BuddyX theme with vapvarun child theme
- Initialize the geolarp site

## Step 2: Initialize Site Content

After the environment is running, initialize the site content for better testing:

```bash
cd /home/turtle_wolfe/repos/two_Tubes/ZZZ
./content-scripts/geolarp/initialize.sh
```

This will set up:
- Admin user profile with avatar
- Site theme colors
- Cover image

## Step 3: Deploy the RPG-Suite Plugin

Use the deployment script to install and activate the RPG-Suite plugin:

```bash
cd /home/turtle_wolfe/repos/two_Tubes
./deploy-plugin.sh geolarp
```

This script:
- Copies the plugin files to the WordPress container
- Sets the correct file permissions
- Activates the plugin in WordPress

## Step 4: Access the WordPress Admin

Log in to WordPress admin to work with the plugin:

- URL: http://localhost:8002/wp-admin
- Username: admin
- Password: admin_password

## Step 5: Make Changes to the Plugin

1. Edit the plugin files in `/home/turtle_wolfe/repos/two_Tubes/RPG-Suite/`
2. When ready to test, redeploy the plugin:
   ```bash
   ./deploy-plugin.sh geolarp
   ```

## Step 6: Debug and Test

For debugging issues:

### View container logs
```bash
docker logs wp_geolarp
```

### Access WordPress shell
```bash
docker exec -it wp_geolarp bash
```

### Check plugin status
```bash
docker exec wp_geolarp wp plugin status --allow-root
```

### Test database tables
```bash
docker exec wp_geolarp wp db query "SHOW TABLES LIKE '%rpg%';" --allow-root
```

## BuddyPress Integration Testing

To specifically test BuddyPress integration:

1. Create a test character through WordPress admin at http://localhost:8002/wp-admin/post-new.php?post_type=rpg_character
2. View the BuddyPress profile at http://localhost:8002/members/admin/
3. Check if the character appears correctly in the profile

## Implementation Status

### Completed Tasks ✅

1. **Core plugin structure with proper global access**
   - Implemented global `$rpg_suite` variable for consistent access
   - Created global accessor function `rpg_suite()`
   - Set up primary plugin class with public properties

2. **Character Manager functionality**
   - Implemented character post type with metadata fields
   - Added support for multiple characters per player
   - Created character ownership relationship
   - Added active character selection system

3. **BuddyPress profile integration**
   - Implemented character display in BuddyPress profiles
   - Created dynamic component generation system
   - Fixed positioning to place character inside profile card
   - Added BuddyX theme-specific styling

### Current Issues 🐛

1. **Character Editing Bug (CRITICAL)**
   - Admin users receive "You attempted to edit an item that doesn't exist. Perhaps it was deleted?" error
   - Characters exist but cannot be edited
   - Requires investigation of post type registration and capabilities
   - Priority task for next development session

### Next Implementation Tasks 🔄

1. **Experience System with GamiPress**
   - Integrate with existing GamiPress installation
   - Create custom point types for character experience
   - Implement feature unlocking based on achievements
   - Design progression visualization UI

2. **Health Subsystem**
   - Implement character HP tracking
   - Create health status effects
   - Add visual health representation

## Adding New Subsystems

To implement a new subsystem:

1. Create the necessary class files in `/home/turtle_wolfe/repos/two_Tubes/RPG-Suite/src/[Subsystem]/`
2. Follow the structure in the existing Core and Health subsystems
3. Update the main plugin class to load the new subsystem
4. Deploy and test in the ZZZ environment

## Feature Implementation Progression

Per the character management progression model:

1. Implement basic character creation for all users
2. Add experience points (XP) tracking
3. Add feature unlocking based on XP levels:
   - Character editing (1,000 XP)
   - Character respawn (2,500 XP)
   - Multiple characters (5,000 XP)
   - Character switching (7,500 XP)
   - Advanced customization (10,000 XP)

This progression system provides natural onboarding and engagement.
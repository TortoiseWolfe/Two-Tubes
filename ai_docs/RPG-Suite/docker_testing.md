# Docker Testing Environment for RPG-Suite

This document outlines the process for testing the RPG-Suite plugin in a Docker environment.

## Environment Setup

The testing environment uses Docker Compose to create a complete WordPress installation with BuddyPress and other required plugins.

### Preparation Steps

1. Clean up any existing containers and volumes:
   ```bash
   cd /home/turtle_wolfe/repos/two_Tubes/ZZZ
   docker-compose down -v
   docker system prune -a --volumes -f
   ```

2. Start the ZZZ environment:
   ```bash
   cd /home/turtle_wolfe/repos/two_Tubes/ZZZ
   ./setup.sh
   ```

3. Verify the containers are running:
   ```bash
   docker ps
   ```

   You should see these containers:
   - nginx
   - wp_geolarp
   - redis
   - db_geolarp

## Plugin Deployment

Use the deploy-plugin.sh script to deploy the RPG-Suite plugin to the Docker environment:

```bash
cd /home/turtle_wolfe/repos/two_Tubes
./deploy-plugin.sh
```

### Deployment Process

The deploy-plugin.sh script will:
1. Create a temporary directory for the plugin
2. Copy plugin files to the temporary directory
3. Copy the plugin to the WordPress container
4. Set correct permissions
5. Activate the plugin using WP-CLI

## Testing Process

### 1. Create a "My Characters" Page

Create a WordPress page with the character list shortcode:

```bash
docker exec wp_geolarp wp post create --post_type=page --post_title="My Characters" --post_content="[rpg_character_list]" --post_status=publish --allow-root
```

### 2. Create Test Characters

Create test characters with different classes:

```bash
# Create first character
docker exec wp_geolarp wp post create --post_type=rpg_character --post_title="Sir Lancelot" --post_status=publish --meta_input='{"character_class":"paladin","character_level":"5"}' --allow-root

# Set owner and active status
docker exec wp_geolarp wp post meta update CHAR_ID player_id 1 --allow-root
docker exec wp_geolarp wp post meta update CHAR_ID is_active 1 --allow-root
docker exec wp_geolarp wp user meta update 1 rpg_active_character CHAR_ID --allow-root

# Create second character
docker exec wp_geolarp wp post create --post_type=rpg_character --post_title="Merlin" --post_status=publish --meta_input='{"character_class":"mage","character_level":"7"}' --allow-root

# Set owner (but not active)
docker exec wp_geolarp wp post meta update CHAR_ID player_id 1 --allow-root
```

Replace CHAR_ID with the actual ID returned from the post creation command.

### 3. Verify Shortcode Rendering

Check if the shortcode is rendering correctly:

```bash
curl -s http://localhost:8002/my-characters/ | grep -A 20 "rpg-character-list"
```

### 4. Test BuddyPress Integration

Verify character display in BuddyPress profiles:

```bash
curl -s http://localhost:8002/members/admin/ | grep -A 20 "rpg-character"
```

## Troubleshooting

### Check Plugin Status

```bash
docker exec wp_geolarp wp plugin list --allow-root
```

### Check Logs

```bash
docker exec wp_geolarp tail /var/www/html/wp-content/debug.log
```

### Enable Debugging

If debug.log doesn't exist, enable WordPress debugging:

```bash
docker exec wp_geolarp bash -c "echo \"define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);\" >> /var/www/html/wp-config.php"
```

### Check Meta Values

```bash
# Check character meta
docker exec wp_geolarp wp post meta get CHAR_ID player_id --allow-root
docker exec wp_geolarp wp post meta get CHAR_ID is_active --allow-root

# Check user meta
docker exec wp_geolarp wp user meta get 1 rpg_active_character --allow-root
```

## Common Issues and Solutions

### Shortcode Not Rendering

If the shortcode shows as plain text:
- Verify the shortcode is registered on init hook with priority 120
- Ensure the global $rpg_suite variable is accessible
- Check for PHP errors in debug.log

### Character Post Type Issues

If the character post type isn't registered:
- Ensure the post type is registered with capability_type => 'post' and map_meta_cap => true
- Verify it's registered on init hook after text domains are loaded
- Check if admin users have proper capabilities

### BuddyPress Integration Not Working

If character doesn't show in BuddyPress profile:
- Verify BuddyPress is active using function_exists('buddypress')
- Check if integration hooks into bp_init with priority 20
- Test with multiple hook points for different themes

### Meta Keys Inconsistency

If character management doesn't work properly:
- Verify player_id is used for character ownership
- Ensure is_active is used for active character status
- Confirm rpg_active_character is used for user's active character
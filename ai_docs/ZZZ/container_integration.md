# ZZZ Container Integration Guide

This document provides detailed information about integrating custom plugins (like RPG-Suite) into the ZZZ container system.

## Container Architecture Overview

The ZZZ system uses Docker containers with the following structure:

1. **NGINX Container**: Reverse proxy handling routing for all sites
2. **WordPress Containers**: One container per site with PHP-FPM
3. **Database Containers**: One MySQL database per WordPress site
4. **Redis Container**: Shared caching service for performance
5. **Bot Container**: Optional container for automation and API interactions

## WordPress Container Structure

Each WordPress container follows this internal structure:

```
/var/www/html/               # WordPress installation root
├── .site_name                # Site identity file
├── .site_url                 # Site URL identity file
├── wp-content/
│   ├── mu-plugins/           # Must-use plugins loaded automatically
│   │   ├── buddypress-enforcer.php
│   │   ├── gamipress-configuration.php
│   │   ├── performance-optimizations.php
│   │   ├── redis-configuration.php
│   │   ├── site-network-widget.php
│   │   ├── special-elite-font.php
│   │   └── yoast-configuration.php
│   ├── plugins/              # Standard WordPress plugins
│   │   ├── buddypress/
│   │   ├── redis-cache/
│   │   ├── yoast-seo/
│   │   └── gamipress/
│   ├── themes/
│   │   ├── buddyx/           # Parent theme
│   │   └── vapvarun/         # Child theme
```

## Plugin Integration Methods

There are three methods for integrating plugins like RPG-Suite into the ZZZ containers:

### 1. Script-Based Deployment (Recommended)

This method uses existing scripts to copy plugin files:

```bash
# Example script structure
./scripts/deploy-plugin.sh <plugin_name> <site_name>

# Examples for RPG-Suite
./scripts/deploy-plugin.sh rpg-suite geolarp
./scripts/deploy-plugin.sh rpg-suite scripthammer
```

**Advantages:**
- Avoids permission issues
- Works with container restarts
- No need to modify docker-compose.yml
- Clean separation between repositories

**Implementation Steps:**
1. Create a deploy script that copies files from the RPG-Suite directory to the container's plugin directory
2. Restart the WordPress container to load the new plugin
3. Activate the plugin through the WordPress admin or via WP-CLI

### 2. Volume Mounting (Development Only)

Direct volume mounting can be used during development:

```yaml
# Example docker-compose.yml modification
services:
  wp_geolarp:
    volumes:
      - ./RPG-Suite:/var/www/html/wp-content/plugins/rpg-suite
```

**Advantages:**
- Live code changes without restarting containers
- Direct editing of plugin code

**Disadvantages:**
- Permission issues between host and container
- Can break when containers are recreated
- Not recommended for production

### 3. Custom Container Build (Production)

For production, include the plugin in the container build:

```dockerfile
# Add to WordPress Dockerfile
COPY ./RPG-Suite /var/www/html/wp-content/plugins/rpg-suite
RUN chown -R www-data:www-data /var/www/html/wp-content/plugins/rpg-suite
```

**Advantages:**
- Most stable for production
- Proper file ownership
- Container immutability

**Disadvantages:**
- Requires container rebuild for every code change
- Tighter coupling between repositories

## WordPress Containers Initialization

ZZZ WordPress containers initialize through:

1. **Entrypoint Script**: `/usr/local/bin/entrypoint.sh`
   - Validates site identity
   - Waits for database
   - Configures WordPress
   - Sets up BuddyPress and themes

2. **MU-Plugins**: Loaded automatically for essential functionality
   - Redis configuration
   - BuddyPress enforcement
   - Base system settings

## Container Identity Verification

Each site container performs identity checks during startup:

1. Reads `.site_name` and `.site_url` files
2. Compares with environment variables
3. Validates database connection parameters
4. Ensures BuddyPress is properly configured

This prevents cross-site contamination and ensures containers retain their identity.

## Integration Security Considerations

When integrating RPG-Suite:

1. **File Permissions**: All plugin files should be owned by `www-data:www-data`
2. **API Authentication**: Use JWT authentication for API requests
3. **Database Access**: RPG-Suite should only access its own database tables
4. **Cross-Site Prevention**: Respect container boundaries and site isolation

## Container Communication

WordPress container exposes PHP-FPM on port 9000, which NGINX proxies requests to:

```
WordPress Container (PHP-FPM:9000) <-- NGINX Container <-- Internet
```

Custom tables for RPG-Suite are created in the site's database:

```
WordPress Container <-- MySQL Database
                     (site_rpg_tables)
```

## Environmental Considerations

ZZZ supports two environments:

### Development Environment
- Local domain names with ports (localhost:8001-8004)
- WordPress debugging enabled
- Direct plugin volume mounting possible

### Production Environment
- Public domain names (crudGAMES.com, geoLARP.com, etc.)
- SSL/TLS enabled
- No direct volume mounting
- Script-based or container build deployment only

Use `./scripts/toggle-mode.sh` to switch between environments.

## Common Issues & Solutions

### Plugin Not Loading

1. Check file ownership:
   ```bash
   docker-compose exec wp_geolarp ls -la /var/www/html/wp-content/plugins/rpg-suite
   ```

2. Verify plugin activation:
   ```bash
   docker-compose exec wp_geolarp wp plugin is-active rpg-suite --allow-root
   ```

3. Check PHP errors:
   ```bash
   docker-compose exec wp_geolarp cat /var/log/php/error.log
   ```

### Database Table Issues

1. Verify tables were created:
   ```bash
   docker-compose exec wp_geolarp wp db query "SHOW TABLES LIKE 'wp_rpg_%';" --allow-root
   ```

2. Fix missing tables:
   ```bash
   docker-compose exec wp_geolarp wp plugin deactivate rpg-suite --allow-root
   docker-compose exec wp_geolarp wp plugin activate rpg-suite --allow-root
   ```

### BuddyPress Integration Issues

1. Check BuddyPress is active:
   ```bash
   docker-compose exec wp_geolarp wp plugin is-active buddypress --allow-root
   ```

2. Verify BuddyPress components:
   ```bash
   docker-compose exec wp_geolarp wp bp component list --allow-root
   ```

## Recommended Integration Workflow

For integrating RPG-Suite into ZZZ:

1. Create the deployment script:
   - Copy files from RPG-Suite repo to containers
   - Ensure proper permissions
   - Handle database setup if needed

2. Test on a single site first (geoLARP recommended)

3. Configure container initialization:
   - Add RPG-Suite activation to site setup
   - Add necessary CSS overrides for BuddyX theme

4. Expand to other sites after successful testing

5. Document any site-specific customizations needed

## Advanced Integration

### API-Based Communication

For complex interactions, use the Bot container to communicate with RPG-Suite via REST API:

```
Bot Container --> WordPress REST API --> RPG-Suite Plugin
```

This pattern allows:
- Cross-site game mechanics
- Automated NPC actions
- Scheduled game events

### Redis Integration

RPG-Suite can leverage the Redis container for:
- Session data
- Object caching
- Real-time game state

Configure in the plugin to use WordPress's object cache API.
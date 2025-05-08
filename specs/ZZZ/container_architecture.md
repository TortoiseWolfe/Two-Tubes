# ZZZ Container Architecture Specification

This document defines the technical specifications for the ZZZ container architecture that hosts WordPress sites with BuddyPress integration.

## System Architecture

The ZZZ system consists of multiple containerized components orchestrated with Docker Compose:

```
                     ┌─────────────┐
                     │    NGINX    │
                     │  Container  │
                     └───────┬─────┘
                             │
         ┌───────────────────┼───────────────────┐
         │                   │                   │
┌────────▼───────┐  ┌────────▼───────┐  ┌────────▼───────┐
│   WordPress    │  │   WordPress    │  │   WordPress    │
│  Container 1   │  │  Container 2   │  │  Container N   │
│  (crudGAMES)   │  │   (geoLARP)    │  │  (scriptH...)  │
└────────┬───────┘  └────────┬───────┘  └────────┬───────┘
         │                   │                   │
┌────────▼───────┐  ┌────────▼───────┐  ┌────────▼───────┐
│    MySQL DB    │  │    MySQL DB    │  │    MySQL DB    │
│  Container 1   │  │  Container 2   │  │  Container N   │
└────────────────┘  └────────────────┘  └────────────────┘
         ▲                   ▲                   ▲
         └───────────────────┼───────────────────┘
                             │
                      ┌──────▼─────┐
                      │   Redis    │
                      │ Container  │
                      └────────────┘
```

## Core Components

### NGINX Container

**Purpose**: Acts as a reverse proxy, routing requests to the appropriate WordPress container.

**Specifications**:
- **Base Image**: nginx:1.28.0-alpine
- **Exposed Ports**: 80, 443
- **Key Configuration**:
  - Virtual hosts for each WordPress site
  - SSL/TLS termination
  - Static file caching
  - WebP image support
  - HTTP/2 support
  - Rate limiting
  - IP blocking

**Custom Configuration Files**:
- `/etc/nginx/conf.d/default.conf`: Main configuration
- `/etc/nginx/conf.d/gzip.conf`: GZIP compression settings
- `/etc/nginx/conf.d/ssl.conf`: SSL configurations

### WordPress Containers

**Purpose**: Run WordPress with PHP-FPM for each site with complete isolation.

**Specifications**:
- **Base Image**: Custom built from wordpress:6.8.0-php8.2-fpm
- **Exposed Ports**: 9000 (PHP-FPM)
- **Key Components**:
  - PHP 8.2.28 with FPM
  - WordPress 6.8.0
  - BuddyPress 14.3.4
  - BuddyX Theme 4.8.2
  - vapvarun Child Theme 3.2.0
  - Must-use plugins (mu-plugins)

**Site Identity Files**:
- `.site_name`: Identifies which site this container serves
- `.site_url`: The canonical URL for the site

**Customizations**:
- Custom entrypoint script
- Site-specific environment variables
- Identity verification system
- WP-CLI pre-installed

### MySQL Database Containers

**Purpose**: Store WordPress data with complete isolation between sites.

**Specifications**:
- **Base Image**: mysql:8.3
- **Exposed Ports**: 3306 (container internal only)
- **Key Features**:
  - One database per WordPress site
  - Performance-optimized configuration
  - Regular database dumps for backups
  - Isolated network access

**Database Configuration**:
- `character-set-server`: utf8mb4
- `collation-server`: utf8mb4_unicode_ci
- `max_connections`: 500
- `innodb_buffer_pool_size`: Adjusted based on container memory

### Redis Container

**Purpose**: Provide object caching for WordPress installations.

**Specifications**:
- **Base Image**: redis:7.2.8-alpine
- **Exposed Ports**: 6379 (container internal only)
- **Key Features**:
  - Persistent cache storage
  - Memory usage limits
  - Key eviction policies
  - Cache segmentation per site

## Site-Specific Configuration

### Common Structure for All Sites

Each WordPress site maintains this structure:

- **Custom Post Types**:
  - Standard WordPress post types
  - BuddyPress-specific content types

- **Plugins**:
  - BuddyPress (social networking)
  - Redis Cache (performance)
  - Yoast SEO (search optimization)
  - GamiPress (gamification)

- **Theme Structure**:
  - BuddyX (parent theme)
  - vapvarun (child theme)

### Site-Specific Customizations

Each site has specific environment variables and settings:

1. **crudGAMES**:
   - `SITE_NAME=crudgames`
   - `SITE_URL=crudgames.com`
   - Customized appearance settings

2. **geoLARP**:
   - `SITE_NAME=geolarp`
   - `SITE_URL=geolarp.com`
   - Customized appearance settings

3. **ScriptHammer**:
   - `SITE_NAME=scripthammer`
   - `SITE_URL=scripthammer.com`
   - Customized appearance settings

4. **TurtleWolfe**:
   - `SITE_NAME=turtlewolfe`
   - `SITE_URL=turtlewolfe.com`
   - Customized appearance settings

## Must-Use Plugins

The following must-use plugins are installed in all WordPress containers:

1. **buddypress-enforcer.php**:
   - Ensures BuddyPress remains activated
   - Configures required BuddyPress components
   - Prevents accidental deactivation

2. **gamipress-configuration.php**:
   - Configures GamiPress with site defaults
   - Sets up achievement types and rules
   - Enables BuddyPress integration

3. **performance-optimizations.php**:
   - Disables unnecessary WordPress features
   - Optimizes common queries
   - Configures post revisions and autosaves

4. **redis-configuration.php**:
   - Configures Redis object cache
   - Sets cache key prefixes per site
   - Defines cache groups and expiration times

5. **site-network-widget.php**:
   - Creates a widget showing all sites in the network
   - Customizable display options
   - Shows site status indicators

6. **special-elite-font.php**:
   - Adds the "Special Elite" font for RPG styling
   - Configures font loading priorities
   - Adds font styles to key elements

7. **yoast-configuration.php**:
   - Sets sensible defaults for Yoast SEO
   - Disables features not needed for RPG sites
   - Configures schema markup

## Network and Security Architecture

### Network Isolation

- Each WordPress container connects only to its own MySQL container
- Redis container accessible by all WordPress containers
- NGINX container routes external requests only

### Security Measures

1. **Container Isolation**:
   - Separate user namespaces
   - Resource limitations per container
   - No shared volumes between sites

2. **Authentication**:
   - JWT authentication for API access
   - No direct MySQL access from outside containers
   - NGINX blocks common exploit attempts

3. **Data Protection**:
   - Regular database backups
   - Proper escaping in all code
   - Input validation for all user data

## Deployment Environments

### Development Environment

**URL Structure**:
- crudGAMES: http://localhost:8001
- geoLARP: http://localhost:8002
- ScriptHammer: http://localhost:8003
- TurtleWolfe: http://localhost:8004

**Features**:
- WordPress debugging enabled
- Detailed error logging
- Live reload capabilities
- Direct database access

### Production Environment

**URL Structure**:
- crudGAMES: https://crudgames.com
- geoLARP: https://geolarp.com
- ScriptHammer: https://scripthammer.com
- TurtleWolfe: https://turtlewolfe.com

**Features**:
- SSL/TLS encryption
- Error logging to protected files only
- Optimized cache settings
- No direct database access

## Resource Specifications

### Minimum Requirements

Each container group (WordPress + MySQL) requires:
- **CPU**: 1 vCPU
- **RAM**: 2GB (512MB WordPress + 1.5GB MySQL)
- **Storage**: 10GB

### Recommended Configuration

For optimal performance:
- **CPU**: 2 vCPU per site
- **RAM**: 4GB per site (1GB WordPress + 3GB MySQL)
- **Storage**: 20GB per site
- **Network**: 1Gbps between containers

## Performance Optimization

1. **NGINX Caching**:
   - FastCGI caching for PHP responses
   - Static file caching with appropriate headers
   - GZIP/Brotli compression

2. **Redis Object Cache**:
   - WordPress object cache implementation
   - Persistent connections
   - Serialized PHP objects

3. **MySQL Optimization**:
   - InnoDB buffer pool sizing
   - Query cache configuration
   - Table optimization schedule

4. **PHP Optimization**:
   - Opcode caching (OPcache)
   - PHP-FPM process management
   - Memory limits per process

## Backup and Recovery

### Backup Strategy

1. **Database Backups**:
   - Daily full database dumps
   - Transaction log backups every 6 hours
   - 30-day retention

2. **File Backups**:
   - Weekly full backup of WordPress files
   - Daily incremental backups
   - 30-day retention

### Recovery Procedures

1. **Single Site Recovery**:
   - Database restoration from backup
   - File restoration from backup
   - WordPress URL and path correction

2. **Full System Recovery**:
   - Container rebuild from images
   - Sequential database restoration
   - Configuration verification

## Integration Requirements

### RPG-Suite Integration Requirements

1. **Plugin Installation**:
   - Script-based deployment to all sites
   - Proper file permissions
   - Automatic activation

2. **Database Integration**:
   - Custom tables in each site database
   - No cross-database queries
   - Proper table prefixing

3. **BuddyPress Integration**:
   - Character display in profiles
   - Activity stream integration
   - xProfile field synchronization
   - User capability mapping

## Technical Compliance Requirements

1. **WordPress Coding Standards**:
   - PSR-4 autoloading compliance
   - WordPress coding style guide compliance
   - Proper sanitization and escaping

2. **Docker Best Practices**:
   - Minimal container images
   - Environment-based configuration
   - Proper health checks
   - Container identity verification

3. **Security Requirements**:
   - No hardcoded credentials
   - Proper SQL query preparation
   - XSS protection measures
   - CSRF token validation
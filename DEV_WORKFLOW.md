# Development Workflow: First Principles

This document outlines the core development workflow for the RPG-Suite WordPress plugin and its integration with the ZZZ containerized test environment.

## Guiding Principles

1. **Local Development**: Develop plugin code locally for maximum efficiency
2. **Clean Deployment**: Deploy to test environment without side effects
3. **Rapid Iteration**: Minimize time between code changes and testing
4. **Consistent Testing**: Ensure testing environment remains stable
5. **Progressive Development**: Build core functionality first, then extend

## Development Environment

### Directory Structure

```
two_Tubes/                     # Main project directory
├── RPG-Suite/                 # WordPress plugin repository
│   ├── rpg-suite.php          # Main plugin file
│   ├── includes/              # Core plugin infrastructure
│   └── src/                   # Plugin subsystems
├── ZZZ/                       # Test environment repository
│   ├── setup.sh               # Environment setup script
│   └── docker-compose.yml     # Container configuration
├── deploy-plugin.sh           # Plugin deployment script
└── specs/                     # Project specifications
```

## Development Workflow

### 1. Environment Setup

Start the ZZZ environment which provides WordPress with BuddyPress:

```bash
# Navigate to the ZZZ environment directory
cd /home/turtle_wolfe/repos/two_Tubes/ZZZ

# Start the Docker environment
./setup.sh
```

This creates a consistent testing environment with:
- WordPress installed and configured
- BuddyPress and BuddyX theme activated
- Appropriate permissions and settings

### 2. Local Plugin Development

Work on the plugin code in your local development environment:

```bash
# Navigate to the plugin directory
cd /home/turtle_wolfe/repos/two_Tubes/RPG-Suite

# Make code changes using your preferred editor
```

Follow these development principles:
- One subsystem at a time
- Clear separation of concerns
- Event-driven communication between subsystems
- Global access pattern for plugin instance

### 3. Plugin Deployment

When ready to test, deploy the plugin to the ZZZ environment:

```bash
# Deploy from the project root
cd /home/turtle_wolfe/repos/two_Tubes
./deploy-plugin.sh geolarp
```

The deployment script:
- Copies plugin files to the WordPress container
- Sets appropriate file permissions
- Activates the plugin if necessary
- Preserves user data between deployments

### 4. Testing

Test the plugin functionality in the ZZZ environment:

- **WordPress Admin**: http://localhost:8002/wp-admin
  - Username: admin
  - Password: admin_password
  
- **BuddyPress Profiles**: http://localhost:8002/members/admin/
  - Test character display in profiles
  - Verify theme compatibility

### 5. Debugging

When issues arise, use these debugging approaches:

```bash
# View WordPress logs
docker logs wp_geolarp

# Access WordPress container shell
docker exec -it wp_geolarp bash

# Check plugin status
docker exec wp_geolarp wp plugin status --allow-root

# Verify database tables
docker exec wp_geolarp wp db query "SHOW TABLES LIKE '%rpg%';" --allow-root
```

For more advanced debugging:
- Enable WP_DEBUG in wp-config.php
- Use Query Monitor plugin
- Check browser console for JavaScript errors

### 6. Documentation

As you develop, maintain documentation:

- Update implementation notes in ai_docs
- Document key decisions and approaches
- Maintain code comments for important functions
- Update specifications if requirements change

## Implementation Approach

### Phased Implementation

Follow this implementation sequence to build a solid foundation:

1. **Core Infrastructure** (First)
   - Plugin initialization
   - Autoloader
   - Global access pattern
   - Event system

2. **Character System** (Second)
   - Character post type
   - Character-user relationship
   - Character CRUD operations
   - Active character tracking

3. **BuddyPress Integration** (Third)
   - Profile display component
   - Theme compatibility
   - Character profile tab
   - Profile actions

4. **Experience System** (Fourth)
   - User-level XP tracking
   - Feature unlocking based on XP
   - Progress visualization
   - XP history logging

5. **Additional Subsystems** (Fifth+)
   - Health subsystem
   - Geo subsystem
   - Dice subsystem
   - Inventory subsystem

### Core-First Implementation

Within each phase, implement in this order:

1. Core functionality with minimal dependencies
2. Basic WordPress integration points
3. User interface components
4. Extended features and refinements

## BuddyPress Integration Testing

When testing BuddyPress integration, verify:

1. **Character Display**: Character appears in profile header
2. **Theme Compatibility**: Works with BuddyX theme
3. **Responsive Design**: Displays correctly on all screen sizes
4. **Character Switching**: UI appears correctly (if feature unlocked)
5. **User Experience**: Flows naturally in the BuddyPress context

## Iteration and Refinement

After initial implementation:

1. Identify areas for improvement
2. Refine user experience
3. Optimize performance
4. Extend functionality
5. Document lessons learned

By following this workflow, you'll maintain a structured approach to developing the RPG-Suite plugin while ensuring a solid integration with the ZZZ test environment.
# RPG-Suite and ZZZ Project Overview

## Project Structure
This workspace contains two complementary repositories:

1. **RPG-Suite**: A WordPress plugin that transforms sites into interactive RPG games
2. **ZZZ**: A containerized WordPress deployment system with BuddyPress integration

## RPG-Suite Status

### Fully Implemented Subsystems
- **Core**: Event handling, API gateway, main plugin infrastructure, role bridge (Player/GM), unified settings, autoload
- **Health**: Character HP tracking, damage/healing mechanics, status effects, REST endpoints
- **Geo**: Position tracking, zones, mapping functionality, map widget, zone CPT, privacy toggle
- **Dice**: Random number generation, complex dice notation, skill checks, advantage/disadvantage
- **Inventory**: Item management, character equipment, weight, slots, drag-drop UI
- **Combat**: Turn-based encounters, initiative, attack formulas, combat log (enabled by default)

### Pending Implementation
- **Quest**: Narrative quest system (opt-in subsystem, directory structure only)

### Key Features
- Supports multiple characters per player (default limit of 2)
- Character switching functionality
- NPC support
- BuddyPress activity feed integration
- Genre-neutral system (not fantasy/D&D specific)
- Narrative-focused over complex rule systems

### Architecture
- **Event Bus**: Symfony-style dispatcher wrapped around `do_action` for strong typing
- **Capabilities Matrix**: Fine-grained capabilities mapped to WordPress roles
- **REST API**: Complete API for headless or external control
- **Custom Post Types**: `rpg_character`, `rpg_item`, `rpg_zone`, `rpg_quest`, `rpg_encounter`
- **Custom Tables**: For complex relationships and performance-critical data

## ZZZ System Status

### Implemented Sites
- crudGAMES.com
- geoLARP.com
- ScriptHammer.com
- TurtleWolfe.com

### Technology Stack
- **Database**: MySQL 8.3
- **Runtime – PHP**: PHP 8.2.28
- **Cache**: Redis 7.2.8
- **Web server / proxy**: NGINX 1.28.0
- **WordPress core**: WordPress 6.8.0
- **Social plugin**: BuddyPress 14.3.4
- **Object Cache**: Redis Cache 2.5.4
- **SEO plugin**: Yoast SEO 25.0
- **Gamification**: GamiPress 7.3.8
- **Theme – Parent**: BuddyX Free 4.8.2
- **Theme – Child**: vapvarun 3.2.0

### Key Features
- Container isolation for each WordPress site (each with dedicated database)
- BuddyPress and BuddyX theme integration with vapvarun child theme
- Content scripts for site-specific setup
- Recovery mechanisms for backup/restore
- Environment toggle for dev/prod switching
- API-First automation system
- Site identity validation to prevent cross-site contamination

## Integration Status
- RPG-Suite plugin needs to be integrated with ZZZ environment
- Docker volume mounting not yet configured
- WordPress containers not yet set up to load the plugin

## Implementation Priorities
1. Use existing scripts to deploy the plugin to test environments
2. Test BuddyPress integration in the ZZZ environment
3. Create admin interfaces for implemented subsystems
4. Implement remaining subsystems (Combat, Quest)
5. Perform end-to-end testing of player journeys

## Design Principles
- **Genre-Neutral**: System is flexible, not limited to traditional fantasy
- **Narrative-Focused**: Light on mechanics, heavy on storytelling
- **Multiple Interface Integration**: Blog posts, comments, and activity feeds
- **BuddyPress Leveraging**: Using social features for RPG gameplay
- **Container Isolation**: Preventing cross-site contamination
# Claude Code Notes

## Primary Tasks
1. Deploy RPG-Suite plugin to ZZZ test environment using existing deployment scripts
2. Test BuddyPress integration in the ZZZ environment

## RPG-Suite and ZZZ Integration Status

### Current Implementation Status
- RPG-Suite needs to be implemented from scratch with a clean modular architecture
- The following components need to be created:
  - Autoloader (class-autoloader.php) 
  - Main plugin class (class-rpg-suite.php)
  - Activator and deactivator classes
  - Character Manager (class-character-manager.php)
- Core subsystem should be implemented first with essential functionality:
  - Event handling system (event-dispatcher, event-subscriber, event)
  - Character management
  - BuddyPress profile integration
- Health and other subsystems will be implemented after core features are working

### Implementation Priority
1. Create the core plugin structure with a focus on proper globals and namespace handling
2. Implement Character Manager with support for multiple characters per player
3. Create BuddyPress integration to display active character on profile
4. Implement character switching functionality
5. Add basic styling for character display that's compatible with BuddyX theme

### Code Structure
- RPG-Suite should follow a clean modular architecture
- Use proper namespaces and follow PSR-4 autoloading standards
- Core subsystem provides foundation for other subsystems
- Ensure proper global variable access across all components
- Maintain clear separation between WordPress hooks and plugin logic

### Character Management
- System will use `rpg_character` custom post type
- Character Manager will support multiple characters per player
- Character switching functionality is essential
- Design principles:
  - One player can control multiple characters (limit of 2 by default)
  - Characters should have metadata for active status
  - Clear separation between player accounts and character entities

### BuddyPress Integration
- Active character must be visible on user's BuddyX profile page
- Character information should appear in the profile header
- Use appropriate BuddyPress hooks for proper theme integration
- Ensure hooks are registered at the right time (bp_init with priority)
- Make character information accessible through global plugin instance

### Essential MVP Features
1. Register plugin with proper global accessibility
2. Create character post type with owner relationship
3. Allow players to have multiple characters but only one active
4. Show active character in BuddyPress profile
5. Enable character switching from profile
6. Style character display compatible with BuddyX theme

### Technical Implementation Requirements
- Global $rpg_suite variable must be properly initialized
- Properties in main plugin class need appropriate visibility (public)
- BuddyPress hooks need correct registration timing
- Clean separation of concerns between components
- CSS for profile display should be properly enqueued
- Component initialization should follow consistent patterns
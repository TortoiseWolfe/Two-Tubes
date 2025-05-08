# RPG Suite Integration Plan for ZZZ Workflow

## Overview

This document outlines how to integrate the RPG Suite WordPress plugin into the existing ZZZ project with its four sites (crudGAMES, geoLARP, ScriptHammer, TurtleWolfe). The integration ensures the RPG Suite plugin is properly installed, activated, and tested within the existing WordPress containers.

## Current Status

The integration is **in progress**. The RPG Suite plugin has the following implementation status:

1. **Core Files**: ✅ Implemented
   - `includes/class-autoloader.php` - PSR-4 compliant autoloader implemented
   - `includes/class-rpg-suite.php` - Main plugin initialization class implemented
   - `includes/class-activator.php` - Plugin activation handler implemented
   - `includes/class-deactivator.php` - Plugin deactivation handler implemented
   - `includes/class-character-manager.php` - Character management system implemented
   - `rpg-suite.php` - Main plugin file with global access pattern implemented

2. **Subsystems**: 
   - Core subsystem: ✅ Implemented (event handling system)
   - Health subsystem: 🚧 Basic structure implemented
   - BuddyPress integration: ✅ Implemented (profile display inside card)
   - Geo subsystem: ❌ Directory structure only
   - Dice subsystem: ❌ Directory structure only
   - Inventory subsystem: ❌ Directory structure only
   - Combat subsystem: ❌ Directory structure only
   - Quest subsystem: ❌ Directory structure only

3. **Container Integration**:
   - Docker deployment script: ✅ Implemented (`deploy-plugin.sh`)
   - Plugin activation in container: ✅ Implemented
   - BuddyPress integration testing: ✅ Implemented

4. **Known Issues**:
   - Character editing bug: ❌ Admin users cannot edit characters (receive "item doesn't exist" error)
   - XP/progression system: 🚧 Planning phase (considering GamiPress integration)

## Current Implementation Plan

### Priority 1: Fix Critical Bugs

1. **Debug Character Editing Issue**:
   - Investigate "You attempted to edit an item that doesn't exist" error
   - Check post type registration and capabilities
   - Verify post status and accessibility
   - Test with different user roles
   - Fix the issue to enable proper character management

2. **Ensure Proper Post Type Access**:
   - Review capability mapping for rpg_character post type
   - Test admin and editor access to characters
   - Verify character ownership relationships

### Priority 2: Experience System Integration

1. **GamiPress Integration Planning**:
   - Evaluate GamiPress for XP and progression tracking
   - Design character leveling and feature unlocking system
   - Plan achievement types and point systems
   - Design UI for progression visualization

2. **Implement Core Experience Features**:
   - Character XP tracking
   - Level progression
   - Feature unlocking based on achievements
   - Progression display in profiles and admin

### Priority 3: Implement Remaining Subsystems

1. **Implement Combat Subsystem**:
   - Follow the pattern established by existing subsystems
   - Implement turn-based combat system
   - Add initiative tracking
   - Create combat log system
   - Integrate with Core event system

2. **Implement Quest Subsystem**:
   - Follow the pattern established by existing subsystems
   - Implement narrative quest system
   - Add quest tracking and rewards
   - Add REST API endpoints and shortcodes
   - Integrate with Core event system

## Next Steps

Once the basic subsystems are implemented:

1. **End-to-End Testing**:
   - Test complete player journeys
   - Verify GM tools and abilities
   - Test performance under load

2. **Add Testing Framework**:
   - Implement unit tests for each subsystem
   - Add integration tests for WordPress compatibility

3. **Documentation**:
   - Document the integration approach
   - Add setup instructions to both repositories
   - Create user and admin guides

## Repositories Strategy

We will keep the repositories separate for cleaner development:

1. **Independent Development**: Each repository maintains its own development cycle
2. **Script-Based Deployment**: Use scripts to copy plugin files rather than volume mounting
3. **Flexible Deployment**: Easily adaptable for production later

## Long-Term Development Plan

1. **Staged Subsystem Development**:
   - Complete one subsystem at a time
   - Ensure backward compatibility

2. **Installation Script**:
   - Create proper installation process

3. **CI/CD Pipeline**:
   - Add automated testing
   - Implement semantic versioning

4. **Deployment Workflow**:
   - Create packaging and release system
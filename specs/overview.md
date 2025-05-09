# RPG-Suite and ZZZ Integration: First Principles

## Project Overview

The Two Tubes project consists of two main components:

1. **RPG-Suite**: A modular WordPress plugin for implementing RPG mechanics with BuddyPress integration
2. **ZZZ**: A containerized WordPress test environment for development and testing

This document outlines the foundational principles guiding the integration of these components.

## Core Principles

### 1. Separation of Concerns

- **RPG-Suite**: Responsible for game mechanics and user experience
- **ZZZ**: Responsible for providing a consistent testing environment

### 2. Development Efficiency

- Local development of the plugin code
- Automated deployment to the test environment
- Consistent testing environment for all developers

### 3. Modular Architecture

- Independent subsystems that can be enabled/disabled
- Clean interfaces between components
- Extensible foundation for future development

### 4. WordPress Best Practices

- Follow WordPress coding standards
- Use WordPress APIs properly
- Maintain compatibility with WordPress updates

### 5. BuddyPress Integration

- Enhance BuddyPress profiles without modification
- Compatible with BuddyX theme
- Use standard BuddyPress hooks and filters

## System Architecture

```
┌─────────────────────────────────────┐
│ ZZZ (Docker Container Environment)  │
│                                     │
│  ┌─────────────────┐                │
│  │    WordPress    │                │
│  │  ┌───────────┐  │                │
│  │  │ BuddyPress│  │                │
│  │  └───────────┘  │                │
│  │  ┌───────────┐  │                │
│  │  │ BuddyX    │  │                │
│  │  └───────────┘  │                │
│  │  ┌───────────┐  │                │
│  │  │ RPG-Suite │  │◄───────────────┼─── Deployed from
│  │  └───────────┘  │                │    local development
│  └─────────────────┘                │
│                                     │
└─────────────────────────────────────┘
```

## Integration Strategy

### 1. Clean Deployment

The plugin should deploy to the test environment without side effects:

- Script-based deployment (`deploy-plugin.sh`)
- No permanent volume mounting to avoid permission issues
- Clean activation/deactivation without errors

### 2. Data Persistence

Test data should persist across deployments:

- Custom tables created properly with dbDelta
- Character data saved in WordPress post types
- User progress stored in user meta

### 3. BuddyPress Compatibility

Integration with BuddyPress must be robust:

- Support for multiple themes, especially BuddyX
- Proper hook usage at the correct priorities
- Responsive design for all screen sizes

### 4. Development Workflow

The development process should be straightforward:

1. Develop RPG-Suite locally
2. Run unit tests locally
3. Deploy to ZZZ environment
4. Test in the WordPress environment
5. Refine implementation

## Implementation Phases

### Phase 1: Core Structure

- Basic plugin structure with autoloader
- Core subsystem with event dispatcher
- Character post type definition
- Simple BuddyPress profile integration

### Phase 2: Character System

- Character management and creation
- Character-player relationship
- User progression system
- BuddyPress profile display

### Phase 3: Additional Subsystems

- Health, Inventory, etc. subsystems
- Admin interface for management
- User interfaces for interaction
- BuddyPress activity integration

### Phase 4: Testing and Refinement

- Comprehensive testing
- Performance optimization
- Documentation completion
- Final polish

## Technical Requirements

### RPG-Suite Requirements

- WordPress 5.0+
- PHP 7.4+
- BuddyPress 8.0+
- Support for BuddyX theme

### ZZZ Requirements

- Docker and Docker Compose
- WordPress container
- BuddyPress and BuddyX installed
- Development tools (phpMyAdmin, etc.)

## Success Criteria

The integration is successful when:

1. RPG-Suite can be deployed to ZZZ with a single command
2. Plugin activates without errors
3. Character information displays correctly in BuddyPress profiles
4. All subsystems function as expected
5. Admin interfaces are intuitive and functional
# Claude System Prompt — RPG-Suite and ZZZ Project Bootstrap

## Purpose
- Analyze both the RPG-Suite WordPress plugin and ZZZ deployment system repositories
- Maintain understanding of core concepts, architecture, and integration patterns
- Generate appropriate documentation and commands for effective assistance

## Repositories
1. **RPG-Suite**: WordPress plugin for RPG gameplay
2. **ZZZ**: WordPress containerized deployment system

## Essential Knowledge Structure
The following folders help organize project knowledge and improve Claude's assistance:

### ai_docs/ - Persistent Knowledge Repository
- Project architecture overviews
- Implementation status and priorities
- Component relationships
- WordPress/BuddyPress integration patterns
- Coding conventions and design principles

### specs/ - Feature Specifications
- Implementation plans for remaining subsystems (Combat, Quest)
- Integration specifications between RPG-Suite and ZZZ
- Test plans and acceptance criteria
- Technical constraints and requirements

### .claude/ - Claude Configuration
- System prompts for consistent interaction
- Context priming commands for rapid loading of essential knowledge
- Reusable commands for common tasks

## Understanding RPG-Suite
- Genre-neutral RPG system designed for WordPress
- Modular architecture with toggleable subsystems
- Strong focus on BuddyPress integration for social features
- Character management supporting multiple characters per player
- Event-based communication between subsystems
- REST API for headless control

## Understanding ZZZ
- Containerized WordPress deployment system
- Support for multiple isolated sites (crudGAMES, geoLARP, ScriptHammer, TurtleWolfe)
- BuddyPress and BuddyX theme integration
- Docker-based infrastructure with site isolation
- Content automation and API-first approach

## Integration Focus
- Script-based plugin deployment to ZZZ environment
- BuddyPress integration testing
- Admin interface development for implemented subsystems
- Implementation of remaining RPG-Suite subsystems
- End-to-end testing of player journeys
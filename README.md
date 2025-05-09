# Two Tubes: RPG-Suite Development Project

This is the master repository for the RPG-Suite development project, which consists of two main components:

1. **RPG-Suite**: A WordPress plugin for implementing RPG mechanics with BuddyPress integration
2. **ZZZ**: A containerized WordPress test environment for developing and testing the RPG-Suite plugin

## Project Structure

```
two_Tubes/
├── RPG-Suite/               # WordPress plugin repository
├── ZZZ/                     # Test environment repository
├── ai_docs/                 # AI-generated documentation
│   ├── RPG-Suite/           # Plugin documentation
│   ├── ZZZ/                 # Test environment documentation
├── specs/                   # Specification documents
│   ├── RPG-Suite/           # Plugin specifications
│   ├── ZZZ/                 # Test environment specifications
├── deploy-plugin.sh         # Deployment script
├── DEV_WORKFLOW.md          # Development workflow documentation
└── README.md                # This file
```

## Project Overview

The RPG-Suite project aims to create a modular WordPress plugin that implements RPG (Role-Playing Game) mechanics on WordPress sites with BuddyPress integration. The ZZZ component provides a containerized WordPress environment for development and testing.

### RPG-Suite Plugin

The RPG-Suite plugin is a modular WordPress plugin with the following key features:

- Character management with multiple characters per player
- BuddyPress profile integration for displaying character information
- Experience point system with progression tracking
- Modular subsystems for health, inventory, etc.
- Event-driven architecture for extensibility

### ZZZ Test Environment

The ZZZ component is a containerized WordPress environment that includes:

- WordPress with BuddyPress and BuddyX theme
- Development tools and debugging capabilities
- Automated setup for testing the RPG-Suite plugin
- Database seeding for test data

## Development Workflow

1. **Specification**: Define requirements in the `specs/` directory
2. **Documentation**: Create/update documentation in `ai_docs/` directory
3. **Implementation**: Develop code in the respective repositories
4. **Testing**: Deploy to the test environment and verify functionality
5. **Iteration**: Refine based on testing results

## Getting Started

1. Clone this repository:
   ```
   git clone https://github.com/username/two_Tubes.git
   ```

2. Initialize submodules:
   ```
   git submodule update --init --recursive
   ```

3. Set up the ZZZ test environment (see ZZZ/README.md for instructions)

4. Start developing the RPG-Suite plugin (see RPG-Suite/README.md for instructions)

## Documentation

- `DEV_WORKFLOW.md`: Detailed development workflow and process
- `specs/`: Technical specifications for both components
- `ai_docs/`: Generated documentation and implementation notes

## Deployment

Use the `deploy-plugin.sh` script to deploy the RPG-Suite plugin to the ZZZ test environment:

```
./deploy-plugin.sh
```
# Documentation Maintenance: First Principles

This guide outlines a first principles approach to maintaining documentation across the RPG-Suite plugin and ZZZ environment repositories.

## Documentation Core Principles

1. **Single Source of Truth**: Each concept should be documented in exactly one place
2. **Progressive Detail**: Start with high-level concepts, then drill down to specifics
3. **Clear Separation**: Maintain clear boundaries between different types of documentation
4. **Living Documentation**: Documentation should evolve alongside the codebase
5. **Practical Examples**: Include concrete examples for complex concepts

## Documentation Structure

The documentation is organized into three main sections:

### 1. specs/

Contains formal specifications and requirements:

- Project overview and integration strategies
- Subsystem specifications
- BuddyPress integration requirements
- Test plans and acceptance criteria

**When to update**: When requirements or specifications change at a fundamental level

### 2. ai_docs/

Contains implementation details, lessons learned, and practical knowledge:

- Implementation steps and approaches
- Troubleshooting guides
- Integration notes
- Lessons learned from implementation attempts
- Code patterns and examples

**When to update**: As implementation progresses and new knowledge is gained

### 3. In-Code Documentation

Documentation within code files:

- Class and method documentation
- Function parameter descriptions
- Implementation notes
- Usage examples

**When to update**: Whenever code changes affect behavior or API

## Documentation Types by Purpose

### Conceptual Documentation

Explains concepts, architecture, and design principles:

- `specs/overview.md`: High-level project overview
- `specs/RPG-Suite/subsystems.md`: Subsystem architecture
- `ai_docs/RPG-Suite/implementation_plan.md`: Implementation approach

### Procedural Documentation

Describes how to perform tasks:

- `DEV_WORKFLOW.md`: Development workflow steps
- `deploy-plugin.sh`: Deployment process
- `ai_docs/RPG-Suite/docker_testing.md`: Testing with Docker

### Reference Documentation

Provides details for implementation:

- `ai_docs/RPG-Suite/meta_keys.md`: Metadata field reference
- `ai_docs/RPG-Suite/shortcodes.md`: Available shortcodes
- Code comments for API reference

### Problem-Solution Documentation

Captures solutions to problems:

- `ai_docs/RPG-Suite/character_creation_troubleshooting.md`: Troubleshooting guide
- `ai_docs/RPG-Suite/edit_character_fix.md`: Solution for character editing bug
- `ai_docs/RPG-Suite/buddypress_integration.md`: BuddyPress integration lessons

## Documentation Update Practices

### When Adding New Features

1. Update the relevant specification document first
2. Create or update implementation notes in ai_docs
3. Add code documentation as you implement
4. Update test plan to cover the new feature

### When Fixing Bugs

1. Document the root cause analysis in ai_docs
2. Update any affected specifications
3. Add or update code comments explaining the fix
4. Ensure test plan covers the fixed scenario

### When Changing Architecture

1. Update the relevant specification document
2. Create a new document in ai_docs explaining the change
3. Update any affected subsystem documentation
4. Revise test plans to align with the new architecture

## Cross-Repository Documentation

When features impact both RPG-Suite and ZZZ repositories:

1. Update `specs/overview.md` with integration changes
2. Ensure deployment scripts reflect changes
3. Document container requirements in ZZZ documentation
4. Update testing procedures for both repositories

## Documentation Review Process

To maintain high-quality documentation:

1. Review documentation changes alongside code reviews
2. Verify technical accuracy of all documentation
3. Ensure consistency across related documents
4. Remove outdated information
5. Check that examples are current and working

## Documentation Format Standards

For consistent documentation:

- Use Markdown formatting with proper heading hierarchy
- Include code examples in appropriate syntax highlighting
- Use tables for structured data
- Use lists for sequential steps or related items
- Include diagrams for complex relationships (using ASCII art or external tools)

## First Principles Approach to Updates

When updating documentation, always consider:

1. **Why**: What fundamental principle does this change address?
2. **What**: What specific information needs to change?
3. **Where**: Which document is the appropriate place for this information?
4. **How**: What format best communicates this information?
5. **When**: Is this a permanent change or a temporary state?

By maintaining documentation according to these principles, both repositories will have clear, accurate, and useful documentation that evolves alongside the codebase and supports efficient development.
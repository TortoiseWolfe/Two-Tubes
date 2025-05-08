# Documentation Maintenance Guide

This guide outlines best practices for maintaining documentation across the RPG-Suite and ZZZ repositories.

## Documentation Priority

As the projects evolve, the following documentation folders should be maintained in this priority order:

1. **ai_docs/**: Highest priority - Contains codebase-specific knowledge that continuously expands throughout the project's lifetime
   - Integration notes
   - Implementation details
   - Architecture diagrams
   - Workflow patterns
   - Lessons learned

2. **specs/**: Medium priority - Contains feature specifications and requirements
   - These documents often become fixed once implementation is complete
   - Should be updated when significant changes to requirements occur

3. **.claude/**: Lower priority - Contains reusable AI prompts and commands
   - Tends to stabilize once effective prompts are in place
   - Update when new AI workflows are discovered

## When to Update Documentation

### ai_docs/
- After any architectural change
- When new integration patterns are established
- When subsystems reach new implementation milestones
- When debugging reveals important lessons
- When BuddyPress integration is refined
- When container configurations are optimized

### specs/
- When feature requirements change significantly
- When new features are planned
- When acceptance criteria are modified
- When technical approaches are revised

## Documentation Update Process

1. Identify code changes that affect documentation
2. Update relevant documentation files
3. Ensure consistency across related documents
4. Remove outdated information
5. Keep a changelog section in major documents when appropriate

## Cross-Repository Considerations

When working across both repositories:

1. Ensure integration documentation is updated in both repos
2. Maintain consistency in terminology and technical descriptions
3. Update container specs when plugin requirements change
4. Update plugin specs when container infrastructure changes

## Documentation Standards

- Use Markdown formatting consistently
- Include clear section headings
- Keep technical details accurate and up-to-date
- Include code examples where helpful
- Specify implementation status clearly
- Use version numbers when referring to external dependencies

By following these guidelines, we'll maintain accurate, useful documentation that evolves with the project and serves as a reliable reference for development.
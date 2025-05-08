# Claude Project Context Initialization

When starting a new session, use the following system prompt to help Claude understand the project structure and documentation:

```
You are assisting with a development project that consists of two repositories: RPG-Suite (a WordPress plugin for RPG games) and ZZZ (a containerized WordPress deployment system).

Before answering any questions, please:

1. Review the project structure in /home/turtle_wolfe/repos/two_Tubes/ which contains:
   - RPG-Suite/ - The main plugin repository
   - ZZZ/ - The container architecture repository
   - ai_docs/ - Implementation details and lessons learned
   - specs/ - Technical specifications and requirements

2. First examine ai_docs/overview.md to understand the high-level project status

3. For RPG-Suite specific questions, check:
   - ai_docs/RPG-Suite/subsystem_status.md for implementation status
   - specs/RPG-Suite/ for technical requirements
   - RPG-Suite/README.md for general information

4. For ZZZ specific questions, check:
   - ai_docs/ZZZ/container_integration.md for integration guidance
   - specs/ZZZ/container_architecture.md for container specifications
   - ZZZ/README.md for general information

5. Review ai_docs/documentation_maintenance.md to understand how documentation should be maintained

Always prioritize information in ai_docs/ as it contains the most up-to-date implementation details that evolve with the project. The specs/ folder contains requirements that may become fixed once implemented.

When making changes, ensure documentation stays current according to the maintenance guide, with special attention to ai_docs/ which requires the most frequent updates as the project evolves.
```

This prompt will direct Claude to systematically review your project's documentation structure and understand the relationship between the repositories and their documentation. It also emphasizes the importance of keeping the ai_docs/ folder updated as the project evolves.
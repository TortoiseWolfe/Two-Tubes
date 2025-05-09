# RPG-Suite Test Plan: First Principles

This document outlines a testing approach for the RPG-Suite WordPress plugin based on first principles, focusing on the core functionality and integration with WordPress and BuddyPress.

## Testing Principles

1. **Independent Verification**: Each component should be tested in isolation
2. **Integration Testing**: Verify components work together correctly
3. **User-Centric Testing**: Test from the perspective of different user roles
4. **Cross-Environment Testing**: Verify functionality across different environments
5. **Edge Case Coverage**: Test boundary conditions and unusual scenarios

## Test Environment

### Requirements

- **WordPress**: Version 6.0+
- **BuddyPress**: Version 8.0+
- **BuddyX Theme**: Latest version
- **PHP**: Version 7.4+
- **Database**: MySQL 5.7+ or MariaDB 10.3+
- **Test Users**: Admin, Author, Subscriber roles

### Environment Setup

The ZZZ Docker environment provides a consistent testing platform with:

1. **Fresh WordPress Installation**: Clean WordPress setup
2. **BuddyPress Configuration**: Pre-configured BuddyPress with test users
3. **BuddyX Theme**: Properly configured theme
4. **Plugin Deployment**: Automatic deployment via deploy-plugin.sh
5. **Test Data**: Pre-populated test data for consistent testing

## Test Categories

### 1. Core Functionality Tests

#### 1.1 Plugin Infrastructure

- **Autoloader**: Verify classes load correctly with proper namespacing
- **Global Access**: Test rpg_suite() function returns plugin instance
- **Activation/Deactivation**: Verify clean activation and deactivation
- **Database Tables**: Check proper creation and removal of tables

#### 1.2 Event System

- **Event Dispatch**: Verify events are properly dispatched
- **Event Subscription**: Confirm subscribers receive events
- **Event Data**: Validate event data is passed correctly
- **Cross-Subsystem Communication**: Test events between subsystems

#### 1.3 WordPress Integration

- **Admin Menu**: Verify admin menus appear correctly
- **Post Type Registration**: Check character post type registration
- **Capabilities**: Test proper capability mapping
- **Settings API**: Verify settings are saved and retrieved correctly

### 2. Character System Tests

#### 2.1 Character Post Type

- **Registration**: Verify post type is registered
- **Meta Fields**: Test custom meta field registration
- **Capabilities**: Check proper access control
- **REST API**: Test character endpoints

#### 2.2 Character Management

- **Creation**: Test character creation
- **Retrieval**: Verify character retrieval methods
- **User Relationship**: Test character-user relationship
- **Active Character**: Verify active character functionality

#### 2.3 Character Switching

- **Multiple Characters**: Test handling multiple characters
- **Switching**: Verify character switching works correctly
- **State Persistence**: Check state is maintained when switching
- **UI Updates**: Confirm UI updates when character changes

### 3. BuddyPress Integration Tests

#### 3.1 Profile Display

- **Character Display**: Verify character appears in profile
- **Display Consistency**: Test display across different themes
- **Responsiveness**: Check mobile responsiveness
- **Styling**: Verify CSS styling is applied correctly

#### 3.2 Theme Compatibility

- **Default Theme**: Test with default BuddyPress theme
- **BuddyX Theme**: Verify compatibility with BuddyX
- **Child Themes**: Test with BuddyX child themes
- **Hook Usage**: Confirm correct hooks are used

#### 3.3 Navigation Integration

- **Character Tab**: Verify character tab appears in profile
- **Tab Content**: Test character tab content
- **Sub-Navigation**: Check sub-navigation items
- **Active States**: Verify active states are correctly set

### 4. Experience System Tests

#### 4.1 XP Tracking

- **XP Awards**: Test awarding XP to users
- **XP Storage**: Verify XP is stored correctly
- **XP History**: Check XP history logging
- **XP Display**: Test XP visualization

#### 4.2 Feature Unlocking

- **Feature Access**: Test feature access based on XP
- **Notifications**: Verify unlocking notifications
- **UI Adaptation**: Check UI changes based on unlocked features
- **Feature Persistence**: Confirm features stay unlocked

### 5. Additional Subsystem Tests

#### 5.1 Health Subsystem

- **HP Tracking**: Test health point tracking
- **Damage/Healing**: Verify damage and healing application
- **Death Handling**: Test character death mechanics
- **Health Display**: Check health visualization

#### 5.2 Geo Subsystem

- **Zone Management**: Test zone creation and management
- **Character Positioning**: Verify position tracking
- **Movement**: Test movement between zones
- **Position Display**: Check position visualization

#### 5.3 Dice Subsystem

- **Dice Notation**: Test parsing of dice notation
- **Roll Execution**: Verify random number generation
- **Roll History**: Check roll history tracking
- **Success Determination**: Test success/failure logic

#### 5.4 Inventory Subsystem

- **Item Management**: Test item creation and properties
- **Inventory Tracking**: Verify inventory management
- **Equipment Slots**: Test equipping/unequipping items
- **Inventory Display**: Check inventory visualization

## Test Scenarios

### Scenario 1: New Player Experience

**Objective**: Verify the complete flow for a new player

1. Create new WordPress user
2. Navigate to RPG-Suite section
3. Create a new character
4. View character in BuddyPress profile
5. Make basic character actions
6. Earn initial XP

**Expected Results**:
- User successfully creates a character
- Character appears in BuddyPress profile
- Character information is accurate
- XP is awarded and tracked

### Scenario 2: Character Management

**Objective**: Test character creation, editing, and switching

1. Create multiple characters
2. Edit character details
3. Switch between characters
4. Verify each character maintains its state

**Expected Results**:
- Multiple characters can be created (if feature unlocked)
- Character details can be edited
- Switching characters works correctly
- Each character's state is maintained

### Scenario 3: Feature Progression

**Objective**: Verify the experience and feature unlocking system

1. Award XP to a user
2. Track progress toward feature unlocks
3. Unlock a feature
4. Verify feature accessibility
5. Test UI adaptation based on unlocked features

**Expected Results**:
- XP is correctly awarded and stored
- Progress tracking is accurate
- Features unlock at correct thresholds
- UI adapts based on unlocked features

### Scenario 4: BuddyPress Integration

**Objective**: Test complete BuddyPress integration

1. View character in BuddyPress profile
2. Navigate to character tab
3. View detailed character information
4. Test character actions from profile
5. Verify theme compatibility

**Expected Results**:
- Character displays correctly in profile
- Character tab shows detailed information
- Character actions work from profile
- Display is compatible with themes

## Test Matrix

| Test Category | Admin User | Author User | Subscriber User |
|---------------|------------|------------|-----------------|
| Core Functionality | All tests | Limited tests | Limited tests |
| Character System | All tests | All tests | All tests |
| BuddyPress Integration | All tests | All tests | All tests |
| Experience System | All tests | All tests | All tests |
| Additional Subsystems | All tests | All tests | All tests |

## Testing Tools

1. **Unit Testing**: PHPUnit for isolated component testing
2. **Integration Testing**: WordPress test framework
3. **UI Testing**: Manual testing with screenshots
4. **Performance Testing**: Query Monitor plugin
5. **Compatibility Testing**: Testing across browsers and devices

## Bug Reporting Template

```
## Bug Report

### Description
[Clear description of the issue]

### Steps to Reproduce
1. 
2. 
3. 

### Expected Behavior
[What should happen]

### Actual Behavior
[What actually happens]

### Environment
- WordPress version:
- BuddyPress version:
- Theme:
- Browser:
- Screen size:

### Screenshots
[If applicable]

### Additional Notes
[Any other context]
```

## Success Criteria

The testing is successful when:

1. All core functionality works as expected
2. Character creation and management functions correctly
3. BuddyPress integration displays characters properly
4. Experience system tracks progress and unlocks features
5. Subsystems function according to specifications
6. Plugin activates and deactivates cleanly

## Testing Schedule

| Day | Focus Area | Activities |
|-----|------------|------------|
| 1 | Environment Setup | Prepare testing environment, deploy plugin |
| 2 | Core Functionality | Test plugin infrastructure, event system |
| 3 | Character System | Test character creation, management, switching |
| 4 | BuddyPress Integration | Test profile display, theme compatibility |
| 5 | Experience System | Test XP tracking, feature unlocking |
| 6 | Additional Subsystems | Test health, geo, dice, inventory systems |
| 7 | Regression Testing | Verify all components work together |
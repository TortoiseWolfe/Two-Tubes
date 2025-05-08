# RPG-Suite Test Plan for ZZZ Environment

This document outlines the testing approach for the RPG-Suite WordPress plugin in the ZZZ environment, with particular focus on BuddyPress integration.

## Setup Requirements

1. **Environment**:
   - ZZZ Docker environment running geoLARP site
   - WordPress 6.8+
   - BuddyPress (latest stable)
   - BuddyX Theme

2. **Plugin Installation**:
   - Copy RPG-Suite plugin files to WordPress plugins directory using existing scripts
   - Activate plugin through WordPress admin panel

## Test Categories

### 1. Core Functionality

#### 1.1 Plugin Activation
- [ ] Plugin activates without errors
- [ ] Database tables are created correctly
- [ ] Default options are set
- [ ] Admin menu items appear in WordPress dashboard

#### 1.2 Event System
- [ ] Test event dispatching from Core subsystem
- [ ] Verify event subscribers receive events
- [ ] Confirm cross-subsystem event communication works

#### 1.3 REST API
- [ ] Verify API endpoints are accessible
- [ ] Test authentication and permissions
- [ ] Confirm data format consistency

### 2. Character Management

#### 2.1 Character Creation
- [ ] Create character as regular user
- [ ] Create character as Game Master
- [ ] Create NPC character
- [ ] Verify character limit enforcement (default: 2 per player)
- [ ] Test "Edit Character" link in admin bar to ensure it redirects to the correct character edit screen
- [ ] Verify character editing doesn't conflict with other plugins (especially GamiPress)

#### 2.2 Character Switching
- [ ] Switch between multiple characters
- [ ] Verify only one character can be active at a time
- [ ] Confirm character switching updates all related UI elements

#### 2.3 BuddyPress Integration
- [ ] Verify characters appear on user profiles
- [ ] Test character actions in activity feed
- [ ] Confirm character privacy settings work with BuddyPress friend system

### 3. Subsystem Tests

#### 3.1 Health Subsystem
- [ ] Verify initial health values are set for new characters
- [ ] Test damage application
- [ ] Test healing application
- [ ] Confirm health UI display (shortcodes)
- [ ] Test health REST API endpoints

#### 3.2 Geo Subsystem
- [ ] Create and manage zones
- [ ] Set character positions
- [ ] Test position privacy settings (public, friends, GM only)
- [ ] Verify map display (shortcodes)
- [ ] Test geo REST API endpoints
- [ ] Confirm zone transitions fire appropriate events

#### 3.3 Dice Subsystem
- [ ] Test basic dice rolling (d20, 2d6, etc.)
- [ ] Test complex notation (4d6h3, 2d20l1, etc.)
- [ ] Verify dice results in comments
- [ ] Test skill checks with advantages/disadvantages
- [ ] Confirm dice rolling appears in activity feed
- [ ] Test dice REST API endpoints

#### 3.4 Inventory Subsystem
- [ ] Create items of various types
- [ ] Add items to character inventory
- [ ] Test inventory limits
- [ ] Stack/unstack items
- [ ] Equip/unequip items
- [ ] Test equipment slots
- [ ] Verify inventory display (shortcodes)
- [ ] Test inventory REST API endpoints

### 4. Performance Testing

#### 4.1 Load Testing
- [ ] Test with multiple concurrent users
- [ ] Verify system performance with many characters
- [ ] Test with large inventory datasets
- [ ] Measure REST API response times

#### 4.2 Memory Usage
- [ ] Monitor WordPress memory usage
- [ ] Check for memory leaks during extended sessions
- [ ] Test with WordPress debugging enabled

### 5. User Experience Testing

#### 5.1 Frontend Experience
- [ ] Test all shortcodes in posts and pages
- [ ] Verify mobile responsiveness
- [ ] Test in various browsers (Chrome, Firefox, Safari)

#### 5.2 Admin Experience
- [ ] Verify all settings pages work correctly
- [ ] Test Game Master tools and interfaces
- [ ] Confirm role-based permissions work as expected

## Test Scenarios

### Scenario 1: Character Creation and Basic Interaction
1. Player creates new account on geoLARP site
2. Player creates new character
3. System assigns default health, position, and inventory
4. Player makes a post with their character
5. Player makes a dice roll in a comment

### Scenario 2: Multi-Character Management
1. Player creates second character
2. Player switches between characters
3. Each character has separate health, position, and inventory
4. Player attempts to create third character (should be prevented)

### Scenario 3: Game Master Interaction
1. GM creates NPC character
2. GM assigns NPC to a zone
3. GM gives item to player character
4. GM applies damage to player character
5. Player sees changes in their character

### Scenario 4: Social Interaction with BuddyPress
1. Two players become friends
2. Players can see each other's character positions
3. Players interact via comments with dice rolls
4. Activity appears in BuddyPress feeds
5. Test privacy settings for non-friends

## Test Reporting

For each test, record the following:
- Test ID and description
- Expected outcome
- Actual outcome
- Pass/Fail status
- Notes or issues discovered
- Browser/device information (if relevant)

## Bug Tracking

Report bugs using the following format:
- Bug ID
- Bug description
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Environment details
- Severity level (Critical, High, Medium, Low)

### Known Issues

#### BUG-001: Edit Character Link Redirects to GamiPress
- **Description**: Clicking on the "Edit Character" link in the admin bar redirects to editing GamiPress point types instead of the character
- **Steps to Reproduce**: 
  1. Create a character post
  2. View the character in the front-end
  3. Click on "Edit Character" in the admin bar
- **Expected Behavior**: User should be taken to the character edit screen
- **Actual Behavior**: User is redirected to GamiPress point types editing screen
- **Environment**: WordPress 6.8+, BuddyPress 14.3.4, GamiPress 7.3.8, RPG-Suite 0.1.0
- **Severity**: High
- **Root Cause**: Post type capability conflict between RPG-Suite and GamiPress

#### BUG-002: Character Creation Error
- **Description**: Error message when attempting to create a new character
- **Steps to Reproduce**:
  1. Go to RPG-Suite > Characters in the admin menu
  2. Click "Add New"
- **Expected Behavior**: Character creation form should load
- **Actual Behavior**: Error message: "You attempted to edit an item that doesn't exist. Perhaps it was deleted?"
- **Environment**: WordPress 6.8+, BuddyPress 14.3.4, RPG-Suite 0.1.0
- **Severity**: Critical
- **Root Cause**: Post type registration and capability mapping issues

## Test Schedule

1. **Core Functionality**: Day 1
2. **Character Management**: Day 2
3. **Subsystem Tests**: Day 3-4
4. **Performance Testing**: Day 5
5. **User Experience Testing**: Day 6
6. **Bug fixes and regression testing**: Day 7

## Special Considerations

1. **Data Privacy**: 
   - Verify all user data is properly isolated
   - Confirm character data doesn't leak between users

2. **Security Testing**:
   - Test with non-privileged users to ensure they can't access restricted features
   - Verify API endpoints enforce appropriate permissions

3. **WordPress/BuddyPress Updates**:
   - Test compatibility with upcoming WordPress and BuddyPress versions
   - Document any potential issues for future updates

## Post-Testing Actions

1. Document all found issues
2. Prioritize fixes based on severity
3. Implement fixes and conduct regression testing
4. Update documentation based on findings
5. Prepare deployment plan for production
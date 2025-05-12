# Test Characters for RPG-Suite

This document tracks test characters created for testing the RPG-Suite plugin. These characters are used in automated tests and manual verification of functionality.

## Current Test Characters

### Test Character (ID: 425)
- **Owner**: Admin (user ID: 1)
- **Class**: Rogue
- **Status**: Inactive
- **Created**: May 11, 2025
- **Purpose**: Used for testing basic character creation and metadata storage

### Warrior Character (ID: 432)
- **Owner**: Admin (user ID: 1) 
- **Class**: Warrior
- **Status**: Active
- **Created**: May 11, 2025
- **Purpose**: Used for testing character switching functionality

## Testing Scenarios

### Character Creation Testing
1. Create character via wp-cli:
   ```
   docker exec wp_geolarp wp post create --post_title="Test Character" --post_type=rpg_character --post_status=publish --post_author=1 --porcelain --allow-root
   ```

2. Add metadata to character:
   ```
   docker exec wp_geolarp wp post meta add [CHARACTER_ID] _rpg_class "Rogue" --allow-root
   ```

### Character Switching Testing
1. Set character as active in post meta:
   ```
   docker exec wp_geolarp wp post meta update [CHARACTER_ID] _rpg_active true --allow-root
   ```

2. Set active character in user meta:
   ```
   docker exec wp_geolarp wp user meta update [USER_ID] rpg_active_character [CHARACTER_ID] --allow-root
   ```

3. Verify active character through Character Manager:
   ```
   docker exec wp_geolarp wp eval 'global $rpg_suite; $active_character = $rpg_suite->character_manager->get_active_character([USER_ID]); if ($active_character) { echo "Active character: {$active_character->post_title} (ID: {$active_character->ID})\n"; }' --allow-root
   ```

## BuddyPress Integration Testing

These characters are displayed in the BuddyPress profile when logged in as user ID 1. The active character should appear in the profile with class information and a character switching UI when multiple characters exist.

### Testing in Browser

1. Visit the WordPress admin:
   - URL: http://localhost:8002/wp-admin
   - Login: admin / admin_password

2. View BuddyPress profile:
   - URL: http://localhost:8002/members/admin/
   - Check for character display in profile

3. Test character switching:
   - Click "Switch Character" button
   - Select alternative character
   - Verify display updates without errors

## Planned Test Characters

### Mage Character
- **Class**: Mage
- **Purpose**: Testing spellcasting functionality (future feature)

### Combat Test Character
- **Class**: Fighter
- **Purpose**: Testing combat system (future feature)

## Character Attribute Testing

For robust attribute testing, each character should have the following attributes set:

```
_rpg_attribute_fortitude: 2d8
_rpg_attribute_precision: 2d6
_rpg_attribute_intellect: 2d7
_rpg_attribute_charisma: 3d6
```

Example command:
```
docker exec wp_geolarp wp post meta add [CHARACTER_ID] _rpg_attribute_fortitude "2d8" --allow-root
```
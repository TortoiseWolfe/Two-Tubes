# RPG-Suite Meta Keys Reference

This document defines the standard meta keys used across the RPG-Suite plugin for consistent data access.

## Character Meta Keys

All character-related meta keys are stored as post meta for the `rpg_character` post type.

### Core Character Metadata

| Meta Key | Type | Description | Default |
|----------|------|-------------|---------|
| `player_id` | integer | User ID of the character owner | current_user_id |
| `is_active` | boolean | Whether this is the player's active character | false |
| `character_class` | string | Character class (e.g., warrior, mage) | "" |
| `character_level` | integer | Character level | 1 |
| `character_experience` | integer | Character experience points | 0 |
| `character_creation_date` | datetime | When the character was created | current_time('mysql') |

### Character Attributes

| Meta Key | Type | Description | Default |
|----------|------|-------------|---------|
| `attribute_strength` | integer | Character's strength stat | class default |
| `attribute_dexterity` | integer | Character's dexterity stat | class default |
| `attribute_constitution` | integer | Character's constitution stat | class default |
| `attribute_intelligence` | integer | Character's intelligence stat | class default |
| `attribute_wisdom` | integer | Character's wisdom stat | class default |
| `attribute_charisma` | integer | Character's charisma stat | class default |

### Character Death

| Meta Key | Type | Description | Default |
|----------|------|-------------|---------|
| `character_is_alive` | boolean | Whether the character is alive | true |
| `character_death_cause` | string | Cause of character death | "" |
| `character_death_date` | datetime | When the character died | "" |
| `character_respawn_count` | integer | Number of times character has respawned | 0 |
| `character_respawn_date` | datetime | When the character last respawned | "" |

### Equipment

| Meta Key | Type | Description | Default |
|----------|------|-------------|---------|
| `equipment_weapon` | string | Character's weapon | class default |
| `equipment_armor` | string | Character's armor | class default |
| `equipment_shield` | string | Character's shield | "" |
| `equipment_accessory` | string | Character's accessory | "" |

## User Meta Keys

These meta keys are stored as user meta for WordPress users.

| Meta Key | Type | Description | Default |
|----------|------|-------------|---------|
| `rpg_active_character` | integer | ID of the user's active character | 0 |
| `rpg_experience_points` | integer | Total experience points earned by the user | 0 |
| `rpg_character_deaths` | integer | Number of character deaths for this user | 0 |
| `rpg_character_count` | integer | Total number of characters created by user | 0 |
| `rpg_experience_log` | array | Log of experience point awards | [] |
| `rpg_new_unlocks` | array | Newly unlocked features | [] |

## Meta Key Registration

All meta keys must be properly registered using `register_post_meta()` or `register_meta()` to ensure proper REST API support and data validation.

### Example: Character Meta Registration

```php
/**
 * Register character meta fields
 */
public function register_character_meta() {
    register_post_meta('rpg_character', 'player_id', [
        'type'              => 'integer',
        'description'       => 'Player who owns this character',
        'single'            => true,
        'sanitize_callback' => 'absint',
        'show_in_rest'      => true,
    ]);
    
    register_post_meta('rpg_character', 'is_active', [
        'type'              => 'boolean',
        'description'       => 'Whether this is the active character for the player',
        'single'            => true,
        'default'           => false,
        'show_in_rest'      => true,
    ]);
    
    register_post_meta('rpg_character', 'character_class', [
        'type'              => 'string',
        'description'       => 'Character class',
        'single'            => true,
        'show_in_rest'      => true,
    ]);
    
    register_post_meta('rpg_character', 'character_level', [
        'type'              => 'integer',
        'description'       => 'Character level',
        'single'            => true,
        'default'           => 1,
        'show_in_rest'      => true,
    ]);
}
```

### Example: User Meta Registration

```php
/**
 * Register user meta fields for RPG features
 */
public function register_rpg_user_meta() {
    register_meta('user', 'rpg_active_character', [
        'type'              => 'integer',
        'description'       => 'ID of the user\'s active character',
        'single'            => true,
        'sanitize_callback' => 'absint',
        'show_in_rest'      => true,
    ]);
    
    register_meta('user', 'rpg_experience_points', [
        'type'              => 'integer',
        'description'       => 'Total experience points earned by the user',
        'single'            => true,
        'default'           => 0,
        'sanitize_callback' => 'absint',
        'show_in_rest'      => true,
    ]);
}
```

## Meta Key Best Practices

1. **Consistency**: Always use exactly the same meta key names throughout the codebase
2. **Registration**: Always register meta keys with proper type and sanitization
3. **Prefixing**: Use appropriate prefixes to avoid conflicts
4. **Defaulting**: Use `get_post_meta($id, 'key', true) ?: 'default'` pattern for safe defaults
5. **Validation**: Always validate meta data before use
6. **Documentation**: Keep this document updated when adding new meta keys
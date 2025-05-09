# RPG-Suite Shortcodes Reference

This document details all available shortcodes in the RPG-Suite plugin, their attributes, and usage examples.

## Character Display Shortcodes

### 1. [rpg_character] - Display a Single Character

Displays a single character with full details.

#### Attributes

| Attribute | Type | Description | Default |
|-----------|------|-------------|---------|
| `id` | integer | ID of a specific character to display | 0 |
| `player_id` | integer | ID of the player whose character to show | current_user_id |
| `active` | boolean | Whether to show the active character | false |
| `show_stats` | boolean | Whether to show character statistics | true |
| `show_equipment` | boolean | Whether to show character equipment | true |
| `template` | string | Display template to use (default, compact, full) | "default" |

#### Usage Examples

**Display Current User's Active Character:**
```
[rpg_character active="true"]
```

**Display a Specific Character:**
```
[rpg_character id="123"]
```

**Display Another Player's Character:**
```
[rpg_character player_id="45" active="true"]
```

**Display Character with Custom Template:**
```
[rpg_character id="123" template="compact"]
```

### 2. [rpg_character_list] - Display a List of Characters

Displays a list of characters with options for filtering and sorting.

#### Attributes

| Attribute | Type | Description | Default |
|-----------|------|-------------|---------|
| `player_id` | integer | ID of the player whose characters to show | current_user_id |
| `limit` | integer | Maximum number of characters to display | -1 (all) |
| `orderby` | string | Field to sort by (name, level, class, created) | "name" |
| `order` | string | Sort order (asc, desc) | "asc" |
| `class` | string | Filter by character class | "" |
| `layout` | string | Layout style (grid, list, table) | "grid" |
| `show_actions` | boolean | Whether to show character actions | true |

#### Usage Examples

**Display Current User's Characters:**
```
[rpg_character_list]
```

**Display Characters in a Table Layout:**
```
[rpg_character_list layout="table" orderby="level" order="desc"]
```

**Display Characters of a Specific Class:**
```
[rpg_character_list class="warrior"]
```

**Display Limited Characters:**
```
[rpg_character_list limit="3" orderby="created" order="desc"]
```

### 3. [rpg_character_switcher] - Character Switching Widget

Displays a dropdown or buttons to switch between characters.

#### Attributes

| Attribute | Type | Description | Default |
|-----------|------|-------------|---------|
| `style` | string | Display style (dropdown, buttons, icons) | "dropdown" |
| `show_portraits` | boolean | Whether to show character portraits | true |
| `show_class` | boolean | Whether to show character class | true |
| `show_level` | boolean | Whether to show character level | true |
| `redirect` | string | URL to redirect to after switching | current_url |

#### Usage Examples

**Default Character Switcher:**
```
[rpg_character_switcher]
```

**Button-Style Character Switcher:**
```
[rpg_character_switcher style="buttons"]
```

**Minimal Character Switcher:**
```
[rpg_character_switcher show_portraits="false" show_class="false" show_level="false"]
```

## Character Stat Shortcodes

### 1. [rpg_character_stat] - Display a Character Statistic

Displays a specific character statistic or attribute.

#### Attributes

| Attribute | Type | Description | Default |
|-----------|------|-------------|---------|
| `character_id` | integer | ID of the character | active_character |
| `stat` | string | The statistic to display (required) | "" |
| `format` | string | Display format (raw, styled, icon) | "styled" |
| `prefix` | string | Text to display before the stat | "" |
| `suffix` | string | Text to display after the stat | "" |

#### Usage Examples

**Display Character Strength:**
```
[rpg_character_stat stat="strength"]
```

**Display Character Level with Label:**
```
[rpg_character_stat stat="level" prefix="Level: "]
```

**Display Character Class with Icon:**
```
[rpg_character_stat stat="class" format="icon"]
```

### 2. [rpg_character_health] - Display Character Health Bar

Displays a visual health bar for a character.

#### Attributes

| Attribute | Type | Description | Default |
|-----------|------|-------------|---------|
| `character_id` | integer | ID of the character | active_character |
| `style` | string | Bar style (default, slim, gradient) | "default" |
| `show_text` | boolean | Whether to show text values | true |
| `width` | string | Width of the health bar | "100%" |
| `animation` | boolean | Whether to animate changes | true |

#### Usage Examples

**Default Health Bar:**
```
[rpg_character_health]
```

**Styled Health Bar:**
```
[rpg_character_health style="gradient" width="200px"]
```

**Minimal Health Bar:**
```
[rpg_character_health show_text="false" style="slim"]
```

## Implementation Details

All shortcodes are registered with a priority of 120 on the `init` hook to ensure they are available after all post types are registered.

```php
/**
 * Register shortcodes for the plugin
 */
public function register_shortcodes() {
    add_shortcode('rpg_character', array($this, 'character_display_shortcode'));
    add_shortcode('rpg_character_list', array($this, 'character_list_shortcode'));
    add_shortcode('rpg_character_switcher', array($this, 'character_switcher_shortcode'));
    add_shortcode('rpg_character_stat', array($this, 'character_stat_shortcode'));
    add_shortcode('rpg_character_health', array($this, 'character_health_shortcode'));
}
```

## Styling

All shortcodes output is wrapped in appropriate classes for styling:

- `.rpg-character` - Wrapper for single character display
- `.rpg-character-list` - Wrapper for character list
- `.rpg-character-item` - Individual character in a list
- `.rpg-character-switcher` - Character switching widget
- `.rpg-character-stat` - Character statistic display
- `.rpg-character-health` - Character health bar

Additional utility classes are added based on context:

- `.active` - For active character
- `.rpg-class-{classname}` - Class-specific styling
- `.rpg-level-{level}` - Level-specific styling
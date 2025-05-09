# RPG-Suite Implementation Steps

## Phase 1: Basic Plugin Structure

1. Create plugin main file `RPG-Suite.php`:
   - Plugin header (name, description, version)
   - Define plugin constants
   - Require necessary files
   - Register activation/deactivation hooks
   - Initialize plugin on `plugins_loaded` with priority 5

2. Create autoloader `includes/class-autoloader.php`:
   - PSR-4 compliant class loading
   - Support for namespaces
   - Register autoloader with spl_autoload_register

3. Create activation/deactivation classes:
   - `includes/class-activator.php`
   - `includes/class-deactivator.php`

4. Create main plugin class `includes/class-rpg-suite.php`:
   - Singleton pattern for global access
   - Component initialization
   - Hook registration
   - Public properties for component access

## Phase 2: Character Management

1. Create character manager `includes/class-character-manager.php`:
   - Register character post type with correct capabilities
   - Register meta fields with consistent keys:
     - `player_id` (integer)
     - `is_active` (boolean)
     - `character_class` (string)
     - `character_level` (integer)
   - Methods for character management:
     - `get_player_characters()`
     - `get_active_character()`
     - `set_active_character()`

2. Create admin management functionality:
   - Custom columns for character list
   - Meta boxes for character editing
   - Character ownership management

## Phase 3: Public Functionality

1. Create public class `public/class-rpg-suite-public.php`:
   - Enqueue styles and scripts
   - Register shortcodes:
     - `[rpg_character]` - Display a specific character
     - `[rpg_character_list]` - Display all characters for current user

2. Create shortcode handlers:
   - Character display shortcode
   - Character list shortcode

3. Create CSS for public display:
   - Basic character card styling
   - Character list styling
   - Responsive design considerations

## Phase 4: BuddyPress Integration

1. Create core subsystem `includes/core/class-core.php`:
   - Event system foundation
   - BuddyPress integration hooks
   - Initialize on `bp_init` with priority 20

2. Create profile integration `includes/core/components/class-profile-integration.php`:
   - Display active character in profile
   - Character switching functionality
   - Multiple theme hook support:
     - `bp_member_header_meta`
     - `bp_member_header_inner_content`
     - `buddyx_member_header_actions`

3. Create CSS for BuddyPress display:
   - Profile character display
   - BuddyX theme compatibility

## Phase 5: Testing and Deployment

1. Test in Docker environment:
   - Character creation
   - Character editing
   - Character switching
   - BuddyPress integration
   - Shortcode functionality

2. Create "My Characters" page:
   - Page with `[rpg_character_list]` shortcode
   - Test character management UI

3. Create test characters:
   - Admin-created character
   - User-created character

## Critical Requirements

1. **Meta Key Consistency**:
   - Character ownership: always use `player_id`
   - Active status: always use `is_active`
   - User's active character: always use `rpg_active_character`

2. **Plugin Initialization Timing**:
   - Initialize plugin on `plugins_loaded` with priority 5
   - Initialize BuddyPress integration on `bp_init` with priority 20

3. **WordPress Standards**:
   - Use standard post capabilities with `map_meta_cap => true`
   - Make post type directly accessible in admin menu
   - Follow WordPress coding standards

4. **Global Variable Usage**:
   - Access all functionality through `$rpg_suite` global
   - Ensure proper public properties for component access

5. **Testing Process**:
   - Test admin character editing
   - Test user character management
   - Test BuddyPress profile display
   - Test shortcode functionality

## Critical Initialization Timing

Proper plugin initialization timing is essential for avoiding conflicts with other plugins, especially BuddyPress and Yoast SEO:

| Hook | Priority | Purpose |
|------|----------|---------|
| `plugins_loaded` | 5 | Initialize the main plugin instance |
| `init` | 100 | Load text domains |
| `init` | 110 | Register post types and meta |
| `init` | 120 | Register shortcodes |
| `bp_init` | 20 | Initialize BuddyPress integration |

### Main Plugin Initialization

```php
// Start the plugin on plugins_loaded with priority 5 (early, but not too early)
add_action('plugins_loaded', 'rpg_suite_init', 5);
```

### Text Domain Loading

```php
// Load text domains properly - late in the init process
add_action('init', [$this, 'load_textdomain'], 100);
```

### Post Type and Meta Registration

```php
// Character Manager hooks - after text domain is loaded
add_action('init', [$this->character_manager, 'register_character_post_type'], 110);
add_action('init', [$this->character_manager, 'register_character_meta'], 110);
```

### Shortcode Registration

```php
// Register shortcodes after post types
add_action('init', [$this->public, 'register_shortcodes'], 120);
```

### BuddyPress Integration

```php
// Setup BuddyPress integration if available
add_action('bp_init', [$this->core, 'initialize_buddypress_integration'], 20);
```

## Troubleshooting Initialization Issues

1. **Yoast SEO Warnings**:
   - Text domains must be loaded after the Yoast SEO plugin (priority 100+)
   - Never load text domains too early in the initialization process

2. **BuddyPress Integration Failures**:
   - Always check if BuddyPress is active with `function_exists('buddypress')`
   - Hook into `bp_init` with priority 20 to ensure BuddyPress core components are loaded
   - Test integration with the BuddyX theme specifically

3. **Character Post Type Issues**:
   - Register post type with `capability_type => 'post'` and `map_meta_cap => true`
   - Hook registration after text domains are loaded
   - Ensure admin users have proper capabilities

4. **Plugin Global Variable**:
   - Initialize global variable in the `plugins_loaded` hook
   - Make all required components accessible as public properties
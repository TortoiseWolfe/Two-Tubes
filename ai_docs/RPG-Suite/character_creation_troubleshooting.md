# RPG Suite Character Creation Troubleshooting

## Problem Description

The RPG-Suite plugin has two critical character management issues:

1. When attempting to create a new character in the RPG Suite plugin, users encounter the error:

   > You attempted to edit an item that doesn't exist. Perhaps it was deleted?

   This error occurs in the WordPress admin when trying to access the edit screen for a custom post type that doesn't exist in the database or when there's an issue with capabilities and permissions.

2. When clicking the "Edit Character" link in the admin bar or attempting to edit an existing character, the user is redirected to edit GamiPress point types instead of the character. This incorrect redirection happens because of post type conflict and menu registration issues.

These issues prevent normal character management workflow in the system.

## Root Causes Analysis

After extensive debugging, we've identified several interconnected issues that contribute to this problem:

### 1. Post Type Registration and Capability Timing Issues

- **Registration Timing**: The `rpg_character` post type is registered during WordPress's `init` hook, but capability checks may occur before all capabilities are fully set up.

- **Capability Mapping**: The post type uses custom capabilities (`edit_rpg_character`, etc.), but these aren't properly mapped to WordPress's primitive capabilities (`edit_posts`, `edit_published_posts`, etc.).

- **REST API Integration**: Gutenberg editor relies on the REST API, which performs its own capability checks that may be failing.

### 2. Menu Structure and Capability Mismatches

- **Parent-Child Menu Relationship**: Making the character post type a submenu of the RPG Suite menu (`show_in_menu => 'rpg-suite'`) creates a dependency where accessing the character creation screen requires both menu capabilities.

- **Admin Menu Capabilities**: The RPG Suite admin menu uses `manage_options` (admin-only), but character creation should be available to regular subscribers/players with `play_rpg` capability.

- **Post Type Menu Conflict**: The "Edit Character" menu item in the admin bar redirects to GamiPress point types editing screen instead of the RPG character edit screen. This happens because GamiPress has registered its post type with the same capability name, causing WordPress to misdirect the edit request.

### 3. Global Variable Accessibility

- **$rpg_suite Global**: The plugin relies on a global `$rpg_suite` variable to access the Character Manager, but this variable might not be properly initialized or accessible during certain WordPress hooks.

## Solution Approach

To resolve these issues, we need a comprehensive approach that addresses all the interdependent components:

### 1. Post Type Registration Improvements

```php
register_post_type('rpg_character', [
    // ... existing labels and settings ...
    'public' => true,
    'has_archive' => true,
    'menu_icon' => 'dashicons-admin-users',
    'supports' => ['title', 'editor', 'thumbnail', 'author', 'custom-fields'],
    'show_in_rest' => true,
    'rewrite' => ['slug' => 'character'],
    
    // Critical changes for proper capability handling
    'capability_type' => ['rpg_character', 'rpg_characters'],
    'map_meta_cap' => true,
    
    // Show as top-level menu instead of submenu to avoid permission issues
    'show_in_menu' => true,
    
    // Explicit REST API support
    'rest_base' => 'rpg-characters',
    'rest_controller_class' => 'WP_REST_Posts_Controller',
]);
```

### 2. Robust Capability Registration

```php
public function register_character_capabilities() {
    // Define basic capabilities needed for post operations
    $primitive_caps = [
        'edit_post',
        'read_post',
        'delete_post',
        'edit_posts',
        'edit_others_posts',
        'publish_posts',
        'read_private_posts',
    ];
    
    // Map to custom post type capabilities
    $mapped_caps = [];
    foreach ($primitive_caps as $cap) {
        $mapped_caps[$cap] = str_replace('_post', '_rpg_character', $cap);
        $mapped_caps[$cap.'s'] = str_replace('_post', '_rpg_character', $cap.'s');
    }
    
    // Get roles that should have character management capabilities
    $roles = ['administrator', 'rpg_game_master', 'rpg_player', 'subscriber'];
    
    foreach ($roles as $role_name) {
        $role = get_role($role_name);
        if (!$role) {
            continue;
        }
        
        // Only add these capabilities if the role has play_rpg or is admin
        if ($role->has_cap('play_rpg') || $role_name === 'administrator') {
            // Add primitive capabilities that WordPress expects
            $role->add_cap('edit_posts');
            $role->add_cap('edit_published_posts');
            
            // Add mapped capabilities for the custom post type
            foreach ($mapped_caps as $primitive => $mapped) {
                $role->add_cap($mapped);
            }
        }
    }
}
```

### 3. Global Variable and Initialization Improvements

```php
// In main plugin file (rpg-suite.php)
function run_rpg_suite() {
    global $rpg_suite;
    
    // Initialize the plugin
    require_once RPG_SUITE_PLUGIN_DIR . 'includes/class-rpg-suite.php';
    $rpg_suite = new RPG\Suite\Includes\RPG_Suite();
    
    // Make sure the global is available early for hooks
    $GLOBALS['rpg_suite'] = $rpg_suite;
    
    // Run the plugin
    $rpg_suite->run();
}

// Also add a function to access the plugin instance without relying on global
function rpg_suite() {
    global $rpg_suite;
    return $rpg_suite;
}
```

## Lessons Learned

1. **WordPress Capability System**: WordPress has a complex capability system where post types, menus, and REST API all perform their own capability checks. These must be carefully aligned.

2. **Custom Post Type Best Practices**:
   - Always use `map_meta_cap => true` for custom post types with custom capabilities
   - Be explicit about `capability_type` and consider defining the full array of capabilities
   - Ensure REST API integration is properly configured

3. **Admin Menu Structure**:
   - Consider using custom admin pages instead of relying on WordPress's automatic menu generation for custom post types
   - When using parent-child menu relationships, ensure all capability checks are consistent

4. **Global Variable Handling**:
   - Avoid relying solely on global variables for accessing plugin instances
   - Provide utility functions to access plugin components
   - Ensure globals are set early enough in the WordPress lifecycle

## Implementation Strategy for Final Solution

1. Reset the repository to a clean state
2. Implement proper post type registration with careful capability management
3. Create a custom admin page for character management that bypasses WordPress's automatic admin screens
4. Ensure consistent capabilities throughout the plugin
5. Add safeguards to prevent timing issues during plugin initialization

This approach will resolve the character creation issues while maintaining the desired plugin architecture and user experience.
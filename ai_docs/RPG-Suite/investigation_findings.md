# RPG Suite Character Creation Investigation Findings

## Problem Description

The RPG Suite plugin was encountering an error when users tried to create characters:

> You attempted to edit an item that doesn't exist. Perhaps it was deleted?

This error occurs when accessing the WordPress admin interface for creating or editing a custom post type.

## Root Cause Analysis

After thorough testing and debugging, we've identified the following core issues:

### 1. Post Type Registration Problems

The original implementation had two critical flaws:

```php
register_post_type('rpg_character', [
    // ...
    'show_in_menu' => 'rpg-suite', // Was creating a circular dependency
    // No explicit capability_type or map_meta_cap settings
]);
```

**Issues:**
- Making the post type appear under the RPG Suite menu (`show_in_menu => 'rpg-suite'`) created a circular dependency with menu permissions
- Without `map_meta_cap => true`, WordPress couldn't properly map primitive capabilities to custom post type operations
- The plugin relied on custom capabilities without ensuring all roles had those capabilities

### 2. Menu Registration Issues

The admin menu was registered with inconsistent capability requirements:

```php
add_menu_page(
    'RPG Suite',
    'RPG Suite',
    'manage_options', // Only admins have this
    'rpg-suite',
    // ...
);
```

**Issues:**
- The main RPG Suite menu required `manage_options` (admin-only)
- But the character post type operations required `edit_posts` and other post capabilities
- This mismatch meant users could potentially see menu items they couldn't access

### 3. Capability Assignment Problems

The plugin didn't properly ensure users had the capabilities needed for character management:

**Issues:**
- Subscribers didn't have the necessary capabilities to create posts
- Custom capabilities like `play_rpg` were used but not consistently granted to users
- The capability assignment happened too late in the WordPress initialization process

## The Solution

Based on our debugging and testing, we implemented a comprehensive solution:

### 1. Proper Post Type Registration

```php
register_post_type('rpg_character', [
    // ...
    'capability_type' => 'post',   // Use WordPress's built-in capabilities
    'map_meta_cap' => true,        // Let WordPress handle capability mapping
    'show_in_menu' => true,        // Show as top-level menu initially
]);
```

This ensures WordPress correctly maps primitive capabilities like `edit_posts` to operations on our custom post type.

### 2. Early Capability Assignment

```php
add_action('init', function() {
    // Get roles that should have character management capabilities
    $roles = ['administrator', 'editor', 'subscriber'];
    
    foreach ($roles as $role_name) {
        $role = get_role($role_name);
        if (!$role) {
            continue;
        }
        
        // Add custom RPG capability
        $role->add_cap('play_rpg');
        
        // For subscribers, add essential post capabilities
        if ($role_name === 'subscriber') {
            $role->add_cap('edit_posts');
            $role->add_cap('publish_posts');
            $role->add_cap('edit_published_posts');
            $role->add_cap('upload_files');
        }
    }
}, 1); // Very high priority to ensure it runs early
```

This ensures all users have the necessary capabilities early in the WordPress initialization process.

### 3. Consistent Menu Registration

```php
add_menu_page(
    'RPG Suite',
    'RPG Suite',
    'play_rpg', // Custom capability all players have
    'rpg-suite',
    // ...
);

// Submenu with consistent capability
add_submenu_page(
    'rpg-suite',
    'Characters',
    'Characters',
    'edit_posts', // Matches post type capability
    'edit.php?post_type=rpg_character',
    null
);
```

This ensures users who can see menu items also have permission to use them.

### 4. Custom Character Form Fallback

We also implemented a custom character creation form that bypasses the WordPress editor entirely:

```php
function rpg_suite_render_custom_character_form() {
    // Custom form implementation that uses wp_insert_post directly
    // ...
}
```

This provides a reliable fallback method for character creation that avoids WordPress editor complexity.

## Technical Lessons Learned

1. **WordPress Capability System Complexity:**
   - WordPress has a sophisticated capability system with primitive capabilities (`edit_posts`) and meta capabilities (`edit_post`)
   - The `map_meta_cap` parameter is essential for proper capability mapping with custom post types
   - When users have permission issues, start by examining the capability system

2. **Menu/Post Type Integration:**
   - When making a post type appear under a custom menu, ensure both use compatible capabilities
   - Using `show_in_menu => 'parent-menu'` creates a dependency between menu permissions
   - Consider making critical custom post types top-level menu items initially for easier debugging

3. **Initialization Order:**
   - Hook priority matters greatly when registering capabilities
   - Capabilities must be registered before they're checked, which happens early in WordPress initialization
   - Use priority `1` for capability registration to ensure it happens before most other hooks

4. **Debugging Techniques:**
   - Post type registration debugging: Log the post type object during registration
   - Capability debugging: Create test pages that display current capabilities
   - Menu debugging: Test different capability requirements to identify the minimal requirements

## Implementation Recommendations

For a clean implementation that avoids character creation issues:

1. Reset the repository to a clean state
2. Implement the post type with proper capability mapping
3. Ensure early capability registration for all relevant roles
4. Use consistent capabilities between menus and post types
5. Provide a custom character form as fallback
6. Implement proper error logging

With these changes, users at all permission levels should be able to successfully create and manage RPG characters without encountering permission errors.
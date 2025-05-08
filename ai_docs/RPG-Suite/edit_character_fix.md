# Fix for Character Editing Redirection Issue

## Problem Summary

When clicking on the "Edit Character" link in the admin bar, the user is incorrectly redirected to edit GamiPress point types instead of the RPG character. This happens because of a conflict between the RPG-Suite's post type capability registration and GamiPress's post type registration.

## Root Cause Analysis

1. **Post Type Capability Conflict**: Both RPG-Suite and GamiPress are using similar post type capability names, causing WordPress to confuse them.

2. **Admin Bar Link Generation**: The admin bar "Edit Character" link is using a generic mechanism for generating edit URLs, which is intercepted by GamiPress's post type handler.

3. **Menu Registration Order**: The order in which plugins register their post types affects which one gets priority for edit links.

## Solution Approach

### 1. Use Unique Capability Type Names

```php
register_post_type('rpg_character', [
    // ... existing properties ...
    
    // Change from generic 'post' to unique capability type
    'capability_type' => ['rpg_character', 'rpg_characters'],
    
    // Ensure WordPress maps meta capabilities properly
    'map_meta_cap' => true,
]);
```

### 2. Override Admin Bar Edit Link

Add a filter to specifically handle the RPG character edit links:

```php
/**
 * Fix admin bar edit link for RPG characters.
 */
public function fix_character_edit_link() {
    add_filter('get_edit_post_link', function($link, $post_id, $context) {
        $post_type = get_post_type($post_id);
        
        if ($post_type === 'rpg_character') {
            // Force the correct edit link for RPG characters
            return admin_url('post.php?post=' . $post_id . '&action=edit');
        }
        
        return $link;
    }, 10, 3);
}
```

### 3. Add Custom Admin Bar Menu for Characters

Replace the default Edit link with a custom one:

```php
/**
 * Add custom admin bar menu for RPG characters.
 */
public function add_character_admin_bar_menu() {
    add_action('admin_bar_menu', function($wp_admin_bar) {
        global $post;
        
        if (!is_admin() && is_singular('rpg_character') && $post) {
            // Remove the default edit button
            $wp_admin_bar->remove_node('edit');
            
            // Add our custom edit button
            $wp_admin_bar->add_node([
                'id' => 'edit_rpg_character',
                'title' => __('Edit Character', 'rpg-suite'),
                'href' => admin_url('post.php?post=' . $post->ID . '&action=edit'),
            ]);
        }
    }, 81); // Priority after the default 'edit' node (80)
}
```

### 4. Register Custom Screen for Character Editing

Create a completely custom edit screen for RPG characters to bypass WordPress's default editor:

```php
/**
 * Register custom admin page for character editing.
 */
public function register_character_edit_page() {
    add_action('admin_menu', function() {
        add_submenu_page(
            'rpg-suite',
            __('Edit Character', 'rpg-suite'),
            __('Edit Character', 'rpg-suite'),
            'edit_rpg_character',
            'rpg-character-edit',
            [$this, 'render_character_edit_page']
        );
    });
    
    // Redirect standard edit URLs to our custom page
    add_action('admin_init', function() {
        global $pagenow;
        
        if ($pagenow === 'post.php' && isset($_GET['post']) && isset($_GET['action']) 
            && $_GET['action'] === 'edit' && get_post_type($_GET['post']) === 'rpg_character') {
            
            wp_redirect(admin_url('admin.php?page=rpg-character-edit&character_id=' . $_GET['post']));
            exit;
        }
    });
}

/**
 * Render custom character edit page.
 */
public function render_character_edit_page() {
    $character_id = isset($_GET['character_id']) ? intval($_GET['character_id']) : 0;
    $character = get_post($character_id);
    
    if (!$character || $character->post_type !== 'rpg_character') {
        wp_die(__('Character not found', 'rpg-suite'));
    }
    
    // Include the custom edit form template
    include RPG_SUITE_PLUGIN_DIR . 'templates/admin/character-edit.php';
}
```

## Implementation Recommendations

1. **Short-term Fix**: Implement options 1 and 2 (unique capability type and edit link filter) as a quick fix for the immediate issue.

2. **Medium-term Solution**: Add the custom admin bar menu (option 3) to ensure more reliable editing access.

3. **Long-term Plan**: Create a fully custom character editing interface (option 4) for a completely tailored user experience that avoids WordPress post type conflicts.

## Testing Plan

After implementing the fixes, test the following:

1. Click "Edit Character" in admin bar on a character page
2. Access character edit through WordPress admin dashboard
3. Verify all character editing functionality works correctly
4. Ensure no conflicts with GamiPress or other plugins
5. Test with different user roles (admin, GM, player)

## Backwards Compatibility

These changes should not affect existing characters or data structures. They only modify the way WordPress generates and handles edit URLs for the RPG character post type.
# RPG-Suite Development: Lessons Learned

## Character Creation Issue

In our attempt to implement character creation within the RPG-Suite plugin, we encountered a persistent error: "You attempted to edit an item that doesn't exist. Perhaps it was deleted?" This error appeared whenever users tried to create a new character, making this core functionality unusable.

### What Failed in Previous Iterations

1. **Permission Mismatch**: The main RPG Suite menu was registered with `manage_options` capability, while the character creation functionality needed `edit_posts`. This mismatch prevented regular users from accessing the character creation pages.

2. **Menu Structure Issues**: The character post type was registered to show as a submenu under RPG Suite (`'show_in_menu' => 'rpg-suite'`), but this created a circular dependency: users needed access to the parent menu to see the submenu.

3. **URL Formation Problems**: The URLs for character creation were not properly formatted for WordPress admin, leading to errors when trying to access the new/edit screens.

4. **Attempted Fix Approaches That Failed**:
   - Changing menu capability levels didn't address the core issue
   - Trying to create direct character creation forms with AJAX still depended on admin URLs
   - Adding custom menu entries didn't solve the URL formation problem

5. **Plugin Structure Confusion**: The attempts to find quick fixes led to messy code changes across multiple files without a clear architecture, making debugging harder.

### Why We Reset Git History

The repository was reset to a clean state because:

1. Multiple conflicting changes had been made across files
2. Temporary debug and logging code was scattered throughout the codebase
3. Some experimental solutions created new technical debt
4. Starting from a clean baseline allows for a more methodical approach

## Path Forward: Correct Approach

The correct approach to fix the character creation issue requires:

1. **Proper Post Type Registration**: Register the character post type with correct parameters:
   ```php
   register_post_type('rpg_character', [
       // ...
       'show_in_menu' => true, // Show as top-level menu
       'capability_type' => 'post',
       'map_meta_cap' => true,
       // ...
   ]);
   ```

2. **Menu Permission Alignment**: Ensure all menu registration uses consistent capabilities:
   ```php
   add_menu_page(
       __('RPG Suite', 'rpg-suite'),
       __('RPG Suite', 'rpg-suite'),
       'edit_posts', // Use this instead of 'manage_options'
       // ...
   );
   ```

3. **Custom Character UI**: Create a proper character creation UI either through:
   - Standard WordPress admin customization
   - Custom frontend forms with proper capability checks
   - BuddyPress profile integration

4. **Clear Separation of Concerns**: Maintain distinct boundaries between:
   - Core plugin functionality
   - Character management
   - BuddyPress integration
   - Admin UI customization

5. **Comprehensive Testing**: Test character creation from multiple user roles and contexts

## Technical Insights

1. WordPress custom post types need careful configuration to work properly in the admin area
2. Role and capability management is critical for multi-user plugins
3. BuddyPress integration requires defensive coding practices
4. Always test plugin functionality from multiple user perspectives

By following this structured approach, we can implement a robust character creation system that works reliably for all users across both the WordPress admin interface and BuddyPress profiles.
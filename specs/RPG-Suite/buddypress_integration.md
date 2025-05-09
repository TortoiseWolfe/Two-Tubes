# BuddyPress Integration: First Principles

## Core Principles

1. **Non-Invasive Enhancement**: Extend BuddyPress profiles without modifying them
2. **Theme Agnosticism**: Support multiple themes without theme-specific code
3. **Proper Hook Usage**: Use appropriate BuddyPress hooks at correct priorities
4. **Responsive Design**: Ensure compatibility with all screen sizes
5. **Visual Consistency**: Maintain consistent styling across themes

## Integration Points

### 1. Profile Display

The plugin should display character information in BuddyPress user profiles:

- Character name, class, and level
- Visual representation of character (image/avatar)
- Basic character attributes
- Character status and progression
- Character actions (for profile owner)

### 2. Hook Registration Strategy

To ensure maximum theme compatibility, register with multiple potential hooks:

```php
// Primary hook for inside the profile card
add_action('bp_member_header_inner_content', [$this, 'display_character_in_profile']);

// Fallback hooks for various themes
add_action('bp_before_member_header_meta', [$this, 'display_character_in_profile']);
add_action('bp_member_header_actions', [$this, 'display_character_in_profile']);

// BuddyX specific hooks
add_action('buddyx_member_header_meta', [$this, 'display_character_in_profile']);
add_action('buddyx_member_header_actions', [$this, 'display_character_in_profile']);
```

### 3. CSS Approach

Use a layered CSS approach for maximum theme compatibility:

```css
/* Base styles for all themes */
.rpg-character-profile {
    background: #f9f9f9;
    border: 1px solid #e5e5e5;
    padding: 15px;
    margin-bottom: 20px;
    border-radius: 5px;
    position: relative;
    z-index: 10;
    clear: both;
}

/* BuddyX theme specific overrides */
.buddyx-user-container .rpg-character-profile {
    margin: 0;
    border-top: 1px solid #e5e5e5;
    padding-top: 15px;
    margin-top: 15px;
    border-radius: 0;
    background: transparent;
    border-left: 0;
    border-right: 0;
    border-bottom: 0;
}
```

### 4. Character Display Logic

The character display function should:

1. Check if the function has already run to prevent duplicates
2. Get the displayed user's ID
3. Find the user's active character
4. Display character information if a character exists
5. Show appropriate messaging if no character exists

```php
public function display_character_in_profile() {
    // Check if we already output the character info to avoid duplicates
    static $displayed = false;
    if ($displayed) {
        return;
    }
    
    $user_id = bp_displayed_user_id();
    $active_character = $this->character_manager->get_active_character($user_id);
    
    if (!$active_character) {
        // Handle no character case
        return;
    }
    
    // Display character information
    // ...
    
    $displayed = true;
}
```

### 5. Profile Navigation

Add a character tab to the BuddyPress profile navigation:

```php
public function add_character_profile_tab() {
    if (!bp_is_user()) {
        return;
    }
    
    $user_id = bp_displayed_user_id();
    $active_character = $this->character_manager->get_active_character($user_id);
    
    // Only add tab if user has a character
    if (!$active_character) {
        return;
    }
    
    bp_core_new_nav_item([
        'name' => __('Character', 'rpg-suite'),
        'slug' => 'character',
        'position' => 70,
        'screen_function' => [$this, 'character_screen_function'],
        'default_subnav_slug' => 'view',
    ]);
}
```

## Implementation Requirements

### 1. Character Display Component

Create a dedicated class for BuddyPress profile integration:

```php
namespace RPG\Suite\Core\Components;

class Profile_Integration {
    protected $character_manager;
    
    public function __construct($character_manager) {
        $this->character_manager = $character_manager;
        $this->register_hooks();
    }
    
    protected function register_hooks() {
        // Register with multiple hooks for theme compatibility
        // Add character tab to profile
        // Register CSS
    }
    
    public function display_character_in_profile() {
        // Display character information in profile
    }
    
    public function add_character_profile_tab() {
        // Add character tab to BuddyPress navigation
    }
    
    public function character_screen_function() {
        // Character tab content
    }
    
    public function enqueue_profile_css() {
        // Enqueue CSS with theme compatibility
    }
}
```

### 2. Initialization Timing

Initialize BuddyPress integration at the correct time:

```php
// In Core class
public function init() {
    // Register BuddyPress integration with proper priority
    add_action('bp_init', [$this, 'initialize_buddypress_integration'], 20);
}

public function initialize_buddypress_integration() {
    if (function_exists('buddypress')) {
        // Initialize BuddyPress integration
        $this->profile_integration = new Components\Profile_Integration(
            $this->character_manager
        );
    }
}
```

### 3. Character Information Display

The character display should include:

- Character name and class with proper styling
- Character level and experience
- Visual representation (image/avatar)
- Basic information about the character
- Actions for the profile owner (if viewing own profile)

### 4. Character Tab Content

The character tab should display:

- Detailed character information
- Character attributes and statistics
- Character background and description
- Character equipment and status

## Testing Strategy

1. **Theme Compatibility Testing**:
   - Test with default BuddyPress theme
   - Test with BuddyX theme
   - Test with other popular BuddyPress themes

2. **Responsive Testing**:
   - Test on various screen sizes
   - Verify mobile compatibility
   - Check for layout issues

3. **Edge Case Testing**:
   - Test with no active character
   - Test with multiple characters
   - Test with very long names/descriptions
   - Test with missing data

4. **User Scenario Testing**:
   - Test as profile owner
   - Test as visitor viewing profile
   - Test character switching
   - Test new character creation

## Success Criteria

The BuddyPress integration is successful when:

1. Character information displays correctly in BuddyPress profiles
2. Display is compatible with multiple themes, especially BuddyX
3. Profile owner can manage their character from the profile
4. Character tab shows detailed character information
5. All displays are responsive and visually consistent
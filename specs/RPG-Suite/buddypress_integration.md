# RPG-Suite BuddyPress Integration Specification

## Overview

This specification defines the requirements and implementation details for integrating RPG-Suite character information into BuddyPress profiles, with specific support for the BuddyX theme and its child themes like Vapvarun.

## Requirements

1. **Character Display in Profiles**: 
   - Display the active character information in the BuddyPress profile header
   - Show character name, type, health bar, and description
   - Support for multiple characters per user with one active character

2. **Theme Compatibility**:
   - Support standard BuddyPress themes
   - Support BuddyX theme and its child themes
   - No theme modifications required

3. **Display Elements**:
   - Character name styled with "Special Elite" font
   - Character type with proper styling
   - Health bar with visual indicator
   - Current/max health values
   - Character description

## Component Design

### 1. Profile_Integration Class

```php
namespace RPG\Suite\Core\Components;

class Profile_Integration {
    /**
     * Initialize hooks for BuddyPress profile integration.
     */
    public function __construct() {
        // Primary hook for inside the profile card
        add_action('bp_member_header_inner_content', array($this, 'display_character_header'));
        
        // Fallback hooks in case primary hook isn't available
        add_action('bp_profile_header_meta', array($this, 'display_character_header'));
        add_action('bp_member_header_actions', array($this, 'display_character_header'));
        
        // More specific BuddyX hooks
        add_action('buddyx_member_header_actions', array($this, 'display_character_header'));
        add_action('buddyx_member_header_meta', array($this, 'display_character_header'));
        
        // CSS styling
        add_action('wp_enqueue_scripts', array($this, 'add_profile_css'));
    }
    
    /**
     * Display character information in profile header.
     */
    public function display_character_header() {
        // Get displayed user ID
        // Find characters belonging to this user
        // Find active character
        // Get character info and health
        // Output character display HTML
    }
    
    /**
     * Add CSS for styling character display.
     */
    public function add_profile_css() {
        // Add inline CSS with theme-specific overrides
    }
}
```

### 2. Core Class Integration

```php
namespace RPG\Suite\Core;

class Core {
    /**
     * Profile integration instance.
     *
     * @var Components\Profile_Integration
     */
    private $profile_integration;
    
    /**
     * Initialize Core subsystem.
     */
    public function init() {
        // Register hook for BuddyPress integration with proper priority
        add_action('bp_init', [$this, 'initialize_buddypress_integration'], 20);
        
        // Other initialization code...
    }
    
    /**
     * Initialize BuddyPress integration
     *
     * @return void
     */
    public function initialize_buddypress_integration() {
        if (function_exists('buddypress')) {
            // Create Components directory if it doesn't exist
            $components_dir = dirname(__FILE__) . '/Components';
            if (!is_dir($components_dir)) {
                mkdir($components_dir, 0755, true);
            }
            
            // Always recreate the Profile Integration class
            $profile_integration_file = $components_dir . '/class-profile-integration.php';
            $this->create_profile_integration_class();
            
            require_once $profile_integration_file;
            $this->profile_integration = new Components\Profile_Integration();
        }
    }
    
    /**
     * Get profile integration instance.
     *
     * @return Components\Profile_Integration|null
     */
    public function get_profile_integration() {
        return $this->profile_integration;
    }
    
    // Other Core methods...
}
```

## CSS Requirements

The CSS should include:

1. **Base Styling**:
   - Container with proper margin, padding, and border
   - Copper-colored accents (Bronze: #B87333, Dark Bronze: #6B4226)
   - Character name in "Special Elite" font
   
2. **Health Bar**:
   - Visual representation of current/max health
   - Green health bar with percentage-based width
   
3. **Theme Compatibility**:
   - Clear floats to prevent layout issues
   - Z-index settings to prevent overlap issues
   - Overflow handling for BuddyX-specific containers

## Testing Methodology

1. **Standard Test Cases**:
   - Verify character display on profile page
   - Verify correct character details (name, type, health, description)
   - Test with multiple characters, switching active character
   
2. **Theme Testing**:
   - Test with default BuddyPress theme
   - Test with BuddyX theme
   - Test with Vapvarun child theme
   
3. **Edge Cases**:
   - Test with no active character
   - Test with missing character attributes
   - Test with very long character names or descriptions
   - Test in all BuddyPress profile tabs

## Implementation Notes

1. Support multiple hooks for maximum theme compatibility
2. Use proper database safety checks for character attributes table
3. Include theme-specific CSS overrides
4. Use proper escaping for all output (esc_html, esc_attr, wp_kses_post)
5. Verify proper initialization in Core class
# RPG Suite Character Management System Specification

## Overview

The Character Management System is a core component of the RPG Suite that enables players to create, manage, and switch between characters in a steampunk-themed world. Based on our prototype testing, we've discovered that this system works best as a progression-based approach where players unlock additional features through gameplay rather than a fixed free/premium split.

This specification outlines a character progression system that resolves the permission issues encountered in our testing while providing a cohesive steampunk experience that encourages player engagement and retention.

## Progression-Based Character System

### Free Tier (Starting Features)
- **Random character generation** (no manual customization)
- One character slot only
- Character is permanent until death
- Upon character death, can create a new random character
- Read-only access to character details
- Character appears in BuddyPress profiles

### Premium Features (Unlocked through gameplay)
Players earn experience points (XP) through gameplay, unlocking premium features at XP thresholds:

1. **Character Editing** (1,000 XP)
   - Edit character name and appearance
   - Reallocate a limited number of attribute points

2. **Character Respawn** (2,500 XP)
   - Revive a fallen character instead of creating a new one
   - Maintain some progression and equipment

3. **Multiple Character Slots** (5,000 XP)
   - Create up to 3 characters
   - Characters share some resources/achievements

4. **Character Switching** (7,500 XP)
   - Switch between created characters
   - Only one character active at a time

5. **Advanced Character Customization** (10,000 XP)
   - Full attribute customization
   - Special abilities and rare character types
   - Custom character portraits

## Steampunk Character Classes

The random character generation system creates characters from the following steampunk-themed classes:

### Sky Captain
- **Description**: Masters of airship navigation and aerial combat
- **Attribute Focus**: Dexterity, Intelligence
- **Equipment**: Navigational tools, service pistol, skyship license
- **Visual Elements**: Aviator goggles, brass compass, leather flight jacket
- **Default Image**: sky-captain.svg

### Inventor
- **Description**: Brilliant minds who create mechanical marvels and automatons
- **Attribute Focus**: Intelligence, Wisdom
- **Equipment**: Portable toolkit, custom gadgets, blueprint journal
- **Visual Elements**: Leather apron, mechanical arm attachments, brass goggles
- **Default Image**: inventor.svg

### Diplomat
- **Description**: Shrewd negotiators who navigate the complex political landscape
- **Attribute Focus**: Charisma, Intelligence
- **Equipment**: Official documents, cipher device, formal attire
- **Visual Elements**: Fine clothes, monocle, diplomatic seals
- **Default Image**: diplomat.svg

### Mechanic
- **Description**: Skilled technicians who maintain and repair complex machinery
- **Attribute Focus**: Strength, Constitution
- **Equipment**: Heavy wrench, steam-powered tools, reinforced gloves
- **Visual Elements**: Oil-stained clothes, utility belts, work goggles
- **Default Image**: mechanic.svg

## Random Character Generation

The random character generation system is a core component for new players, creating balanced yet unique characters:

### Generation Process
1. **Character Class Selection**
   - Random selection from available classes (Sky Captain, Inventor, Diplomat, Mechanic)
   - Class weightings can be adjusted for game balance

2. **Attribute Allocation**
   - Base attributes determined by class (Mechanic gets more Strength, etc.)
   - Random variation applied within class-appropriate ranges
   - Ensures character is playable but unique

3. **Name Generation**
   - Procedurally generated name based on character class
   - Option to reroll name while keeping other attributes

4. **Starting Equipment**
   - Class-appropriate steampunk gear
   - Small random variation in equipment quality

5. **Appearance**
   - Random selection from available appearance options
   - Appropriate to character class in steampunk style

### Implementation Example
```php
function generate_random_character($user_id = null) {
    if (!$user_id) {
        $user_id = get_current_user_id();
    }
    
    // Check if user already has a living character
    $existing = get_posts([
        'post_type' => 'rpg_character',
        'meta_query' => [
            [
                'key' => 'character_owner',
                'value' => $user_id,
            ],
            [
                'key' => 'character_is_alive',
                'value' => '1',
            ],
        ],
        'posts_per_page' => 1,
    ]);
    
    if (!empty($existing)) {
        return new WP_Error('character_exists', __('You already have a living character.', 'rpg-suite'));
    }
    
    // Available character classes
    $classes = [
        'sky-captain' => [ /* Class attributes */ ],
        'inventor' => [ /* Class attributes */ ],
        'diplomat' => [ /* Class attributes */ ],
        'mechanic' => [ /* Class attributes */ ],
    ];
    
    // Randomly select class
    $class_keys = array_keys($classes);
    $class = $class_keys[array_rand($class_keys)];
    $class_attributes = $classes[$class];
    
    // Generate random attributes within class ranges
    $attributes = [];
    foreach ($class_attributes as $attr => $range) {
        list($min, $max) = explode('-', $range);
        $attributes[$attr] = rand((int)$min, (int)$max);
    }
    
    // Generate random name
    $names = get_character_names_for_class($class);
    $character_name = $names[array_rand($names)];
    
    // Create character post with steampunk description
    $post_data = [
        'post_title' => $character_name,
        'post_content' => sprintf(__('A randomly generated %s in the steampunk world.', 'rpg-suite'), $class),
        'post_status' => 'publish',
        'post_type' => 'rpg_character',
    ];
    
    $post_id = wp_insert_post($post_data);
    
    if (is_wp_error($post_id)) {
        return $post_id;
    }
    
    // Set character metadata
    update_post_meta($post_id, 'character_owner', $user_id);
    update_post_meta($post_id, 'character_is_active', true);
    update_post_meta($post_id, 'character_is_alive', true);
    update_post_meta($post_id, 'character_class', $class);
    update_post_meta($post_id, 'character_level', 1);
    update_post_meta($post_id, 'character_experience', 0);
    
    // Set attributes
    foreach ($attributes as $key => $value) {
        update_post_meta($post_id, 'attribute_' . $key, $value);
    }
    
    // Assign starting equipment
    assign_starting_equipment($post_id, $class);
    
    return $post_id;
}
```

## Character Death & Respawn System

When a character dies, the system handles it differently based on the player's unlocked features:

### Death Process
1. Character is marked as deceased
2. Character's equipment and progress are preserved in the database
3. Death timestamp and cause are recorded
4. Player's death count is incremented

### New Character Creation
For players without Character Respawn:
1. Previous character remains viewable but marked as deceased
2. Player is prompted to create a new random character
3. New character starts fresh (level 1, basic equipment)
4. Player experience points continue to accumulate across characters

### Character Respawn
For players with Character Respawn unlocked:
1. Option to respawn the deceased character (with penalties)
2. Limited number of respawns per time period
3. Respawned character retains level but loses some experience
4. Some equipment may be damaged or lost

### Implementation Example
```php
function handle_character_death($character_id, $death_cause = '') {
    $owner_id = get_post_meta($character_id, 'character_owner', true);
    
    // Mark character as deceased
    update_post_meta($character_id, 'character_is_alive', false);
    update_post_meta($character_id, 'character_death_cause', $death_cause);
    update_post_meta($character_id, 'character_death_time', current_time('mysql'));
    
    // Update user's death count
    $death_count = (int)get_user_meta($owner_id, 'rpg_character_deaths', true);
    update_user_meta($owner_id, 'rpg_character_deaths', $death_count + 1);
    
    // Check if user has respawn capability
    $user_xp = (int)get_user_meta($owner_id, 'rpg_experience_points', true);
    $can_respawn = ($user_xp >= 2500); // Character Respawn threshold
    
    if ($can_respawn) {
        // User has respawn capability - offer choice via UI
        // This would be handled through the UI/UX flow
        return [
            'status' => 'respawn_available',
            'character_id' => $character_id,
            'respawn_url' => admin_url('admin.php?page=rpg-character-respawn&character_id=' . $character_id),
            'new_character_url' => admin_url('admin.php?page=rpg-character-create'),
        ];
    } else {
        // User must create a new character
        return [
            'status' => 'create_new',
            'new_character_url' => admin_url('admin.php?page=rpg-character-create'),
        ];
    }
}
```

## Experience Point System

Players earn experience points (XP) through various activities, which unlock premium features:

### XP Earning Methods
- Completing quests and missions
- Character survival milestones (levels, days alive)
- Community contributions and roleplaying
- Special events and challenges

### XP Tracking
- XP is tracked at the user level (not character level)
- Persists across character deaths
- Visible to player in profile and dashboard

### Feature Unlocking
- Clear UI showing progress toward next feature
- Celebration and notification when new feature unlocked
- Option to immediately use newly unlocked features

### Implementation Example
```php
function award_user_experience($user_id, $amount, $reason = '') {
    // Get current XP
    $current_xp = (int)get_user_meta($user_id, 'rpg_experience_points', true);
    $new_xp = $current_xp + $amount;
    
    // Update XP
    update_user_meta($user_id, 'rpg_experience_points', $new_xp);
    
    // Log XP gain
    $log_entry = [
        'amount' => $amount,
        'reason' => $reason,
        'timestamp' => current_time('mysql'),
        'total' => $new_xp,
    ];
    
    $xp_log = get_user_meta($user_id, 'rpg_experience_log', true);
    if (!$xp_log) {
        $xp_log = [];
    }
    
    $xp_log[] = $log_entry;
    update_user_meta($user_id, 'rpg_experience_log', $xp_log);
    
    // Check for newly unlocked features
    $unlocked_features = [];
    
    $feature_thresholds = [
        'edit_character' => 1000,
        'character_respawn' => 2500,
        'multiple_characters' => 5000,
        'character_switching' => 7500,
        'advanced_customization' => 10000,
    ];
    
    foreach ($feature_thresholds as $feature => $threshold) {
        if ($new_xp >= $threshold && $current_xp < $threshold) {
            // Feature newly unlocked
            $unlocked_features[] = $feature;
            do_action('rpg_feature_unlocked', $user_id, $feature);
        }
    }
    
    if (!empty($unlocked_features)) {
        // Notify user of newly unlocked features
        do_action('rpg_features_unlocked', $user_id, $unlocked_features);
    }
    
    return [
        'previous_xp' => $current_xp,
        'new_xp' => $new_xp,
        'gained' => $amount,
        'unlocked_features' => $unlocked_features,
    ];
}
```

## Architecture

### 1. Character Post Type

The `rpg_character` custom post type must be implemented with careful attention to WordPress capability mapping:

```php
register_post_type('rpg_character', [
    'labels' => [
        'name' => __('Characters', 'rpg-suite'),
        'singular_name' => __('Character', 'rpg-suite'),
        // Other labels...
    ],
    'public' => true,
    'has_archive' => true,
    'menu_icon' => 'dashicons-admin-users',
    'supports' => ['title', 'editor', 'thumbnail', 'author', 'custom-fields'],
    'show_in_rest' => true,
    'rewrite' => ['slug' => 'character'],
    
    // CRITICAL: Custom capability handling for tiered access
    'capability_type' => 'rpg_character',
    'capabilities' => [
        // Read capabilities - available to all users
        'read_post' => 'read_rpg_character',
        'read' => 'read_rpg_characters',
        
        // Edit capabilities - restricted to premium users
        'edit_post' => 'edit_premium_character',
        'edit_posts' => 'edit_premium_characters',
        'publish_posts' => 'publish_premium_characters',
        'edit_published_posts' => 'edit_published_premium_characters',
    ],
    'map_meta_cap' => true,
    
    // Menu integration
    'show_in_menu' => 'rpg-suite',  // Under RPG Suite menu
]);
```

### 2. Character Metadata

Each character has essential metadata that must be properly registered and maintained:

1. `character_owner` (int): User ID of the character owner
2. `character_is_npc` (bool): Whether the character is an NPC
3. `character_is_active` (bool): Whether this is the active character for the user
4. `character_template` (string): For free tier users, which template was used
5. `character_tier` (string): 'free' or 'premium' to track creation method

Register these metadata fields as usual.

### 3. User Capabilities & Roles

The capability system implements tiered access:

| Role | Basic Capabilities | Premium Capabilities |
|------|-------------------|----------------------|
| Administrator | All | All |
| RPG Game Master | play_rpg, gm_rpg, read_rpg_character | All premium capabilities |
| Premium Player | play_rpg, read_rpg_character | edit_premium_character, etc. |
| Basic Player | play_rpg, read_rpg_character | None |

```php
// Create Premium Player role
add_role('premium_player', __('Premium Player', 'rpg-suite'), [
    'read' => true,
    'play_rpg' => true,
    'read_rpg_character' => true,
    'read_rpg_characters' => true,
    'edit_premium_character' => true,
    'edit_premium_characters' => true,
    'publish_premium_characters' => true,
    'edit_published_premium_characters' => true
]);

// Basic capabilities for regular subscribers
$subscriber = get_role('subscriber');
if ($subscriber) {
    $subscriber->add_cap('play_rpg');
    $subscriber->add_cap('read_rpg_character');
    $subscriber->add_cap('read_rpg_characters');
}
```

### 4. Admin Menu Integration

Admin menus reflect the tiered access model:

```php
// Main RPG Suite menu - accessible to all players
add_menu_page(
    __('RPG Suite', 'rpg-suite'),
    __('RPG Suite', 'rpg-suite'),
    'play_rpg',  // Basic capability
    'rpg-suite',
    'render_rpg_dashboard'
);

// Character selection for basic users
add_submenu_page(
    'rpg-suite',
    __('Choose Character', 'rpg-suite'),
    __('Choose Character', 'rpg-suite'),
    'play_rpg',  // Basic capability
    'rpg-character-selection',
    'render_character_selection'
);

// Character creation for premium users
add_submenu_page(
    'rpg-suite',
    __('Create Character', 'rpg-suite'),
    __('Create Character', 'rpg-suite'),
    'edit_premium_character',  // Premium capability
    'post-new.php?post_type=rpg_character',
    null
);

// Character management for premium users
add_submenu_page(
    'rpg-suite',
    __('Manage Characters', 'rpg-suite'),
    __('Manage Characters', 'rpg-suite'),
    'edit_premium_character',  // Premium capability
    'edit.php?post_type=rpg_character',
    null
);
```

### 5. BuddyPress Integration

Integration with BuddyPress works for both tiers of users:

1. Basic users display their template character
2. Premium users can choose which character to display
3. All users get character display on profiles

Initialization timing remains the same:

```php
add_action('bp_init', 'init_profile_integration', 20); // After BuddyPress is fully loaded
```

## Implementation Approach

### 1. Initialization Sequence

The plugin must initialize components in the correct order:

1. Register capabilities and roles (very early, priority 1 on init)
2. Register post types with appropriate metadata (priority 5 on init)
3. Register feature unlocking hooks (normal init priority)
4. Set up user interfaces based on unlocked features (on admin_menu hook)
5. Initialize BuddyPress integration (on bp_init hook with priority 20)

### 2. Random Character Generation System

Implement the random character generator for all new players:

```php
// Character class definitions with attribute ranges
$character_classes = [
    'sky-captain' => [
        'name' => __('Sky Captain', 'rpg-suite'),
        'image' => 'sky-captain.svg',
        'description' => __('Master of airship navigation and aerial combat.', 'rpg-suite'),
        'attribute_ranges' => [
            // Attribute ranges defined per class
        ],
        'starting_equipment' => [
            'weapon' => ['service pistol', 'officer saber'],
            'tools' => ['navigational compass', 'spyglass'],
            'gear' => ['flight jacket', 'skyship license', 'captain\'s log'],
        ],
    ],
    // Other steampunk classes defined here...
];

// Generate a completely random character
function generate_random_character() {
    global $character_classes;
    
    // Choose random class
    $class_keys = array_keys($character_classes);
    $chosen_class = $class_keys[array_rand($class_keys)];
    $class_info = $character_classes[$chosen_class];
    
    // Generate random attributes within class ranges
    $attributes = [];
    foreach ($class_info['attribute_ranges'] as $attr => $range) {
        $attributes[$attr] = rand($range['min'], $range['max']);
    }
    
    // Select random equipment
    $equipment = [];
    foreach ($class_info['starting_equipment'] as $slot => $options) {
        $equipment[$slot] = $options[array_rand($options)];
    }
    
    // Generate random name
    $name = generate_random_name_for_class($chosen_class);
    
    return [
        'name' => $name,
        'class' => $chosen_class,
        'attributes' => $attributes,
        'equipment' => $equipment,
        'level' => 1,
        'experience' => 0,
    ];
}

// Character creation for all players
function create_random_character($user_id = null) {
    if (!$user_id) {
        $user_id = get_current_user_id();
    }
    
    // Check if user already has a living character
    $existing = get_posts([
        'post_type' => 'rpg_character',
        'meta_query' => [
            [
                'key' => 'character_owner',
                'value' => $user_id,
            ],
            [
                'key' => 'character_is_alive',
                'value' => '1',
            ],
        ],
        'posts_per_page' => 1,
    ]);
    
    if (!empty($existing)) {
        return new WP_Error('character_exists', __('You already have a living character. Your character must die before you can create a new one.', 'rpg-suite'));
    }
    
    // Generate random character data
    $random_character = generate_random_character();
    
    // Create character post
    $post_data = [
        'post_title' => $random_character['name'],
        'post_content' => sprintf(__('A level %d %s.', 'rpg-suite'), $random_character['level'], $random_character['class']),
        'post_status' => 'publish',
        'post_type' => 'rpg_character',
    ];
    
    $post_id = wp_insert_post($post_data);
    
    if (is_wp_error($post_id)) {
        return $post_id;
    }
    
    // Set character metadata
    update_post_meta($post_id, 'character_owner', $user_id);
    update_post_meta($post_id, 'character_is_active', true);
    update_post_meta($post_id, 'character_is_alive', true);
    update_post_meta($post_id, 'character_class', $random_character['class']);
    update_post_meta($post_id, 'character_level', $random_character['level']);
    update_post_meta($post_id, 'character_experience', $random_character['experience']);
    update_post_meta($post_id, 'character_creation_date', current_time('mysql'));
    
    // Set attributes
    foreach ($random_character['attributes'] as $key => $value) {
        update_post_meta($post_id, 'attribute_' . $key, $value);
    }
    
    // Set equipment
    foreach ($random_character['equipment'] as $slot => $item) {
        add_character_equipment($post_id, $item, $slot);
    }
    
    return $post_id;
}
```

### 3. Experience Point System

Implement the XP system for unlocking premium features:

```php
// Experience point thresholds for features
$feature_thresholds = [
    'edit_character' => 1000,
    'character_respawn' => 2500,
    'multiple_characters' => 5000,
    'character_switching' => 7500,
    'advanced_customization' => 10000,
];

// Award XP to a user
function award_experience_points($user_id, $amount, $reason = '') {
    // Get current XP
    $current_xp = (int)get_user_meta($user_id, 'rpg_experience_points', true);
    $new_xp = $current_xp + $amount;
    
    // Update user's XP
    update_user_meta($user_id, 'rpg_experience_points', $new_xp);
    
    // Log the XP award
    $log_entry = [
        'amount' => $amount,
        'reason' => $reason,
        'timestamp' => current_time('mysql'),
    ];
    
    $xp_log = get_user_meta($user_id, 'rpg_experience_log', true);
    if (!is_array($xp_log)) {
        $xp_log = [];
    }
    $xp_log[] = $log_entry;
    update_user_meta($user_id, 'rpg_experience_log', $xp_log);
    
    // Check for newly unlocked features
    global $feature_thresholds;
    $unlocked = [];
    
    foreach ($feature_thresholds as $feature => $threshold) {
        if ($current_xp < $threshold && $new_xp >= $threshold) {
            $unlocked[] = $feature;
        }
    }
    
    // If features were unlocked, trigger notifications
    if (!empty($unlocked)) {
        do_action('rpg_features_unlocked', $user_id, $unlocked);
        
        // Maybe show notification to user
        add_user_meta($user_id, 'rpg_new_unlocks', $unlocked, false);
    }
    
    return [
        'previous_xp' => $current_xp,
        'new_xp' => $new_xp,
        'gained' => $amount,
        'unlocked_features' => $unlocked,
    ];
}

// Check if a user has access to a feature
function user_has_feature_access($feature, $user_id = null) {
    if (!$user_id) {
        $user_id = get_current_user_id();
    }
    
    global $feature_thresholds;
    
    if (!isset($feature_thresholds[$feature])) {
        return false;
    }
    
    $user_xp = (int)get_user_meta($user_id, 'rpg_experience_points', true);
    return ($user_xp >= $feature_thresholds[$feature]);
}
```

### 4. Character Death and Respawn System

Implement character death and respawning based on unlocked features:

```php
// Handle character death
function kill_character($character_id, $death_cause = '') {
    // Get character owner
    $owner_id = get_post_meta($character_id, 'character_owner', true);
    
    // Mark character as dead
    update_post_meta($character_id, 'character_is_alive', false);
    update_post_meta($character_id, 'character_death_cause', $death_cause);
    update_post_meta($character_id, 'character_death_date', current_time('mysql'));
    
    // Increment user's death count
    $death_count = (int)get_user_meta($owner_id, 'rpg_character_deaths', true);
    update_user_meta($owner_id, 'rpg_character_deaths', $death_count + 1);
    
    // Award XP for the character's life
    $character_level = (int)get_post_meta($character_id, 'character_level', true);
    $character_days = days_character_was_alive($character_id);
    
    // XP formula based on character level and days alive
    $death_xp = ($character_level * 50) + ($character_days * 10);
    award_experience_points($owner_id, $death_xp, 'Character death: ' . get_the_title($character_id));
    
    // Check if user has respawn ability unlocked
    if (user_has_feature_access('character_respawn', $owner_id)) {
        // Return respawn options
        return [
            'status' => 'can_respawn',
            'character_id' => $character_id,
            'character_name' => get_the_title($character_id),
            'message' => __('Your character has died! You can respawn this character or create a new one.', 'rpg-suite'),
        ];
    } else {
        // User must create a new character
        return [
            'status' => 'must_create_new',
            'message' => __('Your character has died! Create a new character to continue your adventure.', 'rpg-suite'),
        ];
    }
}

// Respawn a dead character (for users with the respawn feature)
function respawn_character($character_id) {
    // Verify character is dead
    $is_alive = get_post_meta($character_id, 'character_is_alive', true);
    if ($is_alive) {
        return new WP_Error('character_not_dead', __('This character is not dead and cannot be respawned.', 'rpg-suite'));
    }
    
    // Verify user owns the character and has respawn feature
    $owner_id = get_post_meta($character_id, 'character_owner', true);
    if ($owner_id != get_current_user_id()) {
        return new WP_Error('not_owner', __('You do not own this character.', 'rpg-suite'));
    }
    
    if (!user_has_feature_access('character_respawn', $owner_id)) {
        return new WP_Error('no_respawn_access', __('You have not unlocked the character respawn feature yet.', 'rpg-suite'));
    }
    
    // Apply respawn penalties
    $character_level = (int)get_post_meta($character_id, 'character_level', true);
    $character_xp = (int)get_post_meta($character_id, 'character_experience', true);
    
    // XP penalty (lose 20% of character XP)
    $xp_penalty = (int)($character_xp * 0.2);
    update_post_meta($character_id, 'character_experience', $character_xp - $xp_penalty);
    
    // Equipment penalty (random chance to lose some items)
    apply_equipment_respawn_penalty($character_id);
    
    // Mark character as alive again
    update_post_meta($character_id, 'character_is_alive', true);
    update_post_meta($character_id, 'character_respawn_count', (int)get_post_meta($character_id, 'character_respawn_count', true) + 1);
    update_post_meta($character_id, 'character_respawn_date', current_time('mysql'));
    
    return [
        'status' => 'respawned',
        'character_id' => $character_id,
        'character_name' => get_the_title($character_id),
        'xp_penalty' => $xp_penalty,
        'message' => __('Your character has been respawned! Some experience and possibly equipment has been lost.', 'rpg-suite'),
    ];
}
```

### 5. Feature-Based User Interface

Implement UI that adapts to user's unlocked features:

```php
// Render character editing UI based on unlocked features
function render_character_management_ui() {
    $user_id = get_current_user_id();
    $current_xp = (int)get_user_meta($user_id, 'rpg_experience_points', true);
    
    // Get user's living characters
    $characters = get_posts([
        'post_type' => 'rpg_character',
        'meta_query' => [
            [
                'key' => 'character_owner',
                'value' => $user_id,
            ],
        ],
        'posts_per_page' => -1,
    ]);
    
    $living_characters = [];
    $dead_characters = [];
    
    foreach ($characters as $character) {
        $is_alive = get_post_meta($character->ID, 'character_is_alive', true);
        if ($is_alive) {
            $living_characters[] = $character;
        } else {
            $dead_characters[] = $character;
        }
    }
    
    // Show different UI based on unlocked features
    ?>
    <div class="rpg-character-management">
        <h2><?php _e('Character Management', 'rpg-suite'); ?></h2>
        
        <div class="rpg-xp-progress">
            <h3><?php _e('Your Progress', 'rpg-suite'); ?></h3>
            <p><?php printf(__('You have earned %d experience points', 'rpg-suite'), $current_xp); ?></p>
            <?php render_feature_unlock_progress($user_id); ?>
        </div>
        
        <?php if (empty($living_characters)): ?>
            <div class="rpg-no-character">
                <p><?php _e('You have no living character. Create a new random character to begin your adventure!', 'rpg-suite'); ?></p>
                <form method="post" action="">
                    <?php wp_nonce_field('create_random_character', 'character_nonce'); ?>
                    <input type="hidden" name="action" value="create_random_character">
                    <button type="submit" class="button button-primary"><?php _e('Create Random Character', 'rpg-suite'); ?></button>
                </form>
            </div>
        <?php else: ?>
            <div class="rpg-living-characters">
                <h3><?php _e('Your Character', 'rpg-suite'); ?></h3>
                <?php foreach ($living_characters as $character): ?>
                    <?php render_character_card($character->ID); ?>
                    
                    <?php if (user_has_feature_access('edit_character')): ?>
                        <div class="rpg-character-actions">
                            <a href="<?php echo admin_url('admin.php?page=rpg-edit-character&character_id=' . $character->ID); ?>" class="button"><?php _e('Edit Character', 'rpg-suite'); ?></a>
                        </div>
                    <?php endif; ?>
                <?php endforeach; ?>
            </div>
            
            <?php if (user_has_feature_access('multiple_characters') && count($living_characters) < 3 && count($living_characters) > 0): ?>
                <div class="rpg-create-another">
                    <h3><?php _e('Create Another Character', 'rpg-suite'); ?></h3>
                    <p><?php _e('You have unlocked the ability to have multiple characters!', 'rpg-suite'); ?></p>
                    <form method="post" action="">
                        <?php wp_nonce_field('create_random_character', 'character_nonce'); ?>
                        <input type="hidden" name="action" value="create_random_character">
                        <button type="submit" class="button button-primary"><?php _e('Create Another Random Character', 'rpg-suite'); ?></button>
                    </form>
                </div>
            <?php endif; ?>
            
            <?php if (user_has_feature_access('character_switching') && count($living_characters) > 1): ?>
                <div class="rpg-switch-character">
                    <h3><?php _e('Switch Active Character', 'rpg-suite'); ?></h3>
                    <form method="post" action="">
                        <?php wp_nonce_field('switch_character', 'switch_nonce'); ?>
                        <input type="hidden" name="action" value="switch_character">
                        <select name="character_id">
                            <?php foreach ($living_characters as $character): ?>
                                <option value="<?php echo $character->ID; ?>"><?php echo get_the_title($character->ID); ?></option>
                            <?php endforeach; ?>
                        </select>
                        <button type="submit" class="button"><?php _e('Switch Character', 'rpg-suite'); ?></button>
                    </form>
                </div>
            <?php endif; ?>
        <?php endif; ?>
        
        <?php if (!empty($dead_characters) && user_has_feature_access('character_respawn')): ?>
            <div class="rpg-dead-characters">
                <h3><?php _e('Fallen Characters', 'rpg-suite'); ?></h3>
                <?php foreach ($dead_characters as $character): ?>
                    <?php render_dead_character_card($character->ID); ?>
                    <div class="rpg-character-actions">
                        <form method="post" action="">
                            <?php wp_nonce_field('respawn_character', 'respawn_nonce'); ?>
                            <input type="hidden" name="action" value="respawn_character">
                            <input type="hidden" name="character_id" value="<?php echo $character->ID; ?>">
                            <button type="submit" class="button"><?php _e('Respawn Character', 'rpg-suite'); ?></button>
                        </form>
                    </div>
                <?php endforeach; ?>
            </div>
        <?php endif; ?>
    </div>
    <?php
}
```

### 6. BuddyPress Integration

Adapt BuddyPress integration to work with the character progression system:

```php
// Show active character on BuddyPress profile
function add_character_to_profile() {
    $user_id = bp_displayed_user_id();
    
    // Get user's living characters
    $characters = get_posts([
        'post_type' => 'rpg_character',
        'meta_query' => [
            [
                'key' => 'character_owner',
                'value' => $user_id,
            ],
            [
                'key' => 'character_is_alive',
                'value' => '1',
            ],
            [
                'key' => 'character_is_active',
                'value' => '1',
            ],
        ],
        'posts_per_page' => 1,
    ]);
    
    if (empty($characters)) {
        // No active character
        echo '<div class="rpg-no-character">';
        echo '<p>' . __('No active character', 'rpg-suite') . '</p>';
        echo '</div>';
        return;
    }
    
    $character = $characters[0];
    
    // Get character details
    $character_class = get_post_meta($character->ID, 'character_class', true);
    $character_level = get_post_meta($character->ID, 'character_level', true);
    
    // Show character info
    echo '<div class="rpg-character-profile">';
    echo '<h4>' . get_the_title($character->ID) . '</h4>';
    echo '<p class="rpg-character-details">' . sprintf(__('Level %d %s', 'rpg-suite'), $character_level, ucfirst($character_class)) . '</p>';
    
    // Show character portrait if available
    $portrait = get_the_post_thumbnail($character->ID, 'thumbnail');
    if ($portrait) {
        echo $portrait;
    } else {
        // Show default image based on class
        echo '<img src="' . RPG_SUITE_PLUGIN_URL . 'assets/images/' . $character_class . '.jpg" alt="' . $character_class . '">';
    }
    
    // If viewing own profile and user has character switching
    if ($user_id == get_current_user_id() && user_has_feature_access('character_switching')) {
        echo '<div class="rpg-profile-actions">';
        echo '<a href="' . admin_url('admin.php?page=rpg-character-manage') . '" class="button">' . __('Manage Characters', 'rpg-suite') . '</a>';
        echo '</div>';
    }
    
    echo '</div>';
}
```

## Testing Strategy

Prior to implementation, we need to test each component of the progression system:

1. **Random Character Generation**: Verify balanced and interesting random characters
2. **Experience Point System**: Test XP awards and feature unlocking
3. **Character Death & Respawn**: Verify death handling and respawn mechanics
4. **Feature Progression**: Test the unlocking of tiered features at XP thresholds
5. **BuddyPress Integration**: Verify profile display and character management
6. **User Interface Adaptation**: Ensure UI adjusts based on unlocked features

## Implementation Checklist

- [ ] Reset repository to clean state
- [ ] Implement random character generation system
- [ ] Create character death and rebirth mechanics
- [ ] Implement experience point tracking and awards
- [ ] Build feature unlocking system based on XP thresholds
- [ ] Create adaptive UI that changes based on unlocked features
- [ ] Implement BuddyPress profile integration
- [ ] Build character management dashboard
- [ ] Create comprehensive error handling
- [ ] Develop documentation for gameplay progression

## Business & Technical Benefits

The progression-based character management system provides several advantages:

1. **Engagement Strategy**: Encourages longer-term player engagement rather than immediate monetization
2. **Gamification**: Makes character management itself a game, with progress and unlocks
3. **User Retention**: Gives players long-term goals to work toward
4. **Natural Progression**: Provides a learning curve that introduces features gradually
5. **Technical Simplicity**: Uses feature flags instead of complex role-based permissions
6. **Community Building**: Rewards active participation in the game world
7. **Organic Growth**: Experienced players naturally get more features as they need them

## Conclusion

By implementing this progression-based Character Management System, the RPG Suite will resolve the technical permission issues encountered in our prototype testing while creating a compelling gameplay loop that encourages long-term engagement.

This approach transforms what was originally a technical challenge into a gameplay feature, using character death and rebirth as a natural constraint rather than artificial limits. Players will be motivated to keep their characters alive while earning experience toward advanced features, creating a more immersive and rewarding experience.

By focusing on engagement rather than monetization, this system builds a stronger foundation for community growth while still addressing the technical challenges we faced in our prototype testing.
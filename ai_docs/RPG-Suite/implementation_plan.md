# RPG Suite Implementation Plan - MVP

## Overview

This document outlines a focused plan for implementing the RPG Suite MVP with essential functionality. We'll focus on the core features needed for a functional plugin without scope creep.

## Core Implementation Components

### 1. Plugin Entry Point (rpg-suite.php)

```php
// Current:
function run_rpg_suite() {
    // Initialize the plugin
    require_once RPG_SUITE_PLUGIN_DIR . 'includes/class-rpg-suite.php';
    $plugin = new RPG\Suite\Includes\RPG_Suite();
    $plugin->run();
}

// Change to:
function run_rpg_suite() {
    global $rpg_suite;
    
    // Initialize the plugin
    require_once RPG_SUITE_PLUGIN_DIR . 'includes/class-rpg-suite.php';
    $rpg_suite = new RPG\Suite\Includes\RPG_Suite();
    
    // Store reference in global for access
    $GLOBALS['rpg_suite'] = $rpg_suite;
    
    // Run the plugin
    $rpg_suite->run();
}

// Add helper function:
function rpg_suite() {
    global $rpg_suite;
    return $rpg_suite;
}
```

### 2. Character Post Type Definition (includes/class-rpg-suite.php)

```php
// Register character post type with simpler capability mapping
public function register_custom_post_types() {
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
        
        // Standard capability type - using WordPress defaults 
        'capability_type' => 'post',
        'map_meta_cap' => true,
        
        // Menu integration
        'show_in_menu' => 'rpg-suite',
    ]);

    // Register custom meta fields for character state tracking
    register_post_meta('rpg_character', 'character_owner', [
        'type' => 'integer',
        'single' => true,
        'show_in_rest' => true,
    ]);
    
    register_post_meta('rpg_character', 'character_is_alive', [
        'type' => 'boolean',
        'single' => true,
        'default' => true,
        'show_in_rest' => true,
    ]);
    
    register_post_meta('rpg_character', 'character_class', [
        'type' => 'string',
        'single' => true,
        'show_in_rest' => true,
    ]);
    
    register_post_meta('rpg_character', 'character_level', [
        'type' => 'integer',
        'single' => true,
        'default' => 1,
        'show_in_rest' => true,
    ]);
    
    register_post_meta('rpg_character', 'character_experience', [
        'type' => 'integer',
        'single' => true,
        'default' => 0,
        'show_in_rest' => true,
    ]);

    register_post_meta('rpg_character', 'character_death_cause', [
        'type' => 'string',
        'single' => true,
        'show_in_rest' => true,
    ]);
    
    register_post_meta('rpg_character', 'character_death_date', [
        'type' => 'string',
        'single' => true,
        'show_in_rest' => true,
    ]);

    // Allow subsystems to register their own post types
    do_action('rpg_suite_register_post_types');
}

// Public character manager for easier access
public $character_manager;
```

### 3. User Feature Tracking

```php
/**
 * Register user meta for feature tracking
 */
public function register_user_feature_tracking() {
    // Experience point tracking
    register_meta('user', 'rpg_experience_points', [
        'type' => 'integer',
        'description' => 'Experience points earned by the user',
        'single' => true,
        'default' => 0,
        'show_in_rest' => true,
    ]);
    
    // Experience point log
    register_meta('user', 'rpg_experience_log', [
        'type' => 'array',
        'description' => 'Log of experience points earned',
        'single' => true,
        'show_in_rest' => true,
    ]);
    
    // Character death count
    register_meta('user', 'rpg_character_deaths', [
        'type' => 'integer',
        'description' => 'Number of character deaths',
        'single' => true,
        'default' => 0,
        'show_in_rest' => true,
    ]);
    
    // Unlocked features tracking
    register_meta('user', 'rpg_unlocked_features', [
        'type' => 'object',
        'description' => 'Features unlocked by the user',
        'single' => true,
        'default' => [],
        'show_in_rest' => true,
    ]);
    
    // Feature thresholds
    $this->feature_thresholds = [
        'edit_character' => 1000,
        'character_respawn' => 2500,
        'multiple_characters' => 5000,
        'character_switching' => 7500,
        'advanced_customization' => 10000,
    ];
}

/**
 * Check if a user has unlocked a specific feature
 */
public function has_unlocked_feature($feature, $user_id = null) {
    if (!$user_id) {
        $user_id = get_current_user_id();
    }
    
    // Admin always has all features
    if (user_can($user_id, 'administrator')) {
        return true;
    }
    
    // Get user XP
    $xp = (int)get_user_meta($user_id, 'rpg_experience_points', true);
    
    // Check if user has enough XP for this feature
    if (isset($this->feature_thresholds[$feature])) {
        return $xp >= $this->feature_thresholds[$feature];
    }
    
    return false;
}

/**
 * Award experience points to a user
 */
public function award_experience($user_id, $amount, $reason = '') {
    // Get current XP
    $current_xp = (int)get_user_meta($user_id, 'rpg_experience_points', true);
    $new_xp = $current_xp + $amount;
    
    // Update XP
    update_user_meta($user_id, 'rpg_experience_points', $new_xp);
    
    // Log the award
    $log_entry = [
        'amount' => $amount,
        'reason' => $reason,
        'timestamp' => current_time('mysql'),
        'total' => $new_xp,
    ];
    
    $log = get_user_meta($user_id, 'rpg_experience_log', true);
    if (!is_array($log)) {
        $log = [];
    }
    
    $log[] = $log_entry;
    update_user_meta($user_id, 'rpg_experience_log', $log);
    
    // Check for newly unlocked features
    $unlocked = [];
    foreach ($this->feature_thresholds as $feature => $threshold) {
        if ($current_xp < $threshold && $new_xp >= $threshold) {
            $unlocked[] = $feature;
        }
    }
    
    // Trigger notifications for newly unlocked features
    if (!empty($unlocked)) {
        do_action('rpg_features_unlocked', $user_id, $unlocked);
    }
    
    return [
        'previous_xp' => $current_xp,
        'new_xp' => $new_xp,
        'gained' => $amount,
        'unlocked_features' => $unlocked,
    ];
}
```

### 4. Feature-Based Admin Menu Structure

```php
public function register_admin_menu() {
    // Main RPG Suite menu - for all players
    add_menu_page(
        __('RPG Suite', 'rpg-suite'),
        __('RPG Suite', 'rpg-suite'),
        'read',  // Available to all registered users
        'rpg-suite',
        [$this, 'render_dashboard'],
        'dashicons-shield',
        30
    );
    
    // Character Management - core page for everyone
    add_submenu_page(
        'rpg-suite',
        __('Character Management', 'rpg-suite'),
        __('Character Management', 'rpg-suite'),
        'read',
        'rpg-character-management',
        [$this, 'render_character_management']
    );
    
    // Character Progress - view XP and unlocked features
    add_submenu_page(
        'rpg-suite',
        __('Your Progress', 'rpg-suite'),
        __('Your Progress', 'rpg-suite'),
        'read',
        'rpg-progress',
        [$this, 'render_progress_page']
    );
    
    // Character Editor - conditionally displayed based on unlocked features
    if ($this->has_unlocked_feature('edit_character')) {
        add_submenu_page(
            'rpg-suite',
            __('Character Editor', 'rpg-suite'),
            __('Character Editor', 'rpg-suite'),
            'read',
            'rpg-character-editor',
            [$this, 'render_character_editor']
        );
    }
    
    // Multiple Characters - conditionally displayed based on unlocked features
    if ($this->has_unlocked_feature('multiple_characters')) {
        add_submenu_page(
            'rpg-suite',
            __('My Characters', 'rpg-suite'),
            __('My Characters', 'rpg-suite'),
            'read',
            'rpg-character-list',
            [$this, 'render_character_list']
        );
    }
    
    // Character Respawn - conditionally displayed based on unlocked features
    if ($this->has_unlocked_feature('character_respawn')) {
        // Only show if user has dead characters
        $dead_characters = $this->character_manager->get_dead_characters();
        if (!empty($dead_characters)) {
            add_submenu_page(
                'rpg-suite',
                __('Respawn Character', 'rpg-suite'),
                __('Respawn Character', 'rpg-suite'),
                'read',
                'rpg-character-respawn',
                [$this, 'render_respawn_page']
            );
        }
    }
    
    // Settings for admins only
    add_submenu_page(
        'rpg-suite',
        __('Settings', 'rpg-suite'),
        __('Settings', 'rpg-suite'),
        'manage_options',
        'rpg-suite-settings',
        [$this, 'render_settings_page']
    );
}

/**
 * Render the main character management dashboard
 * This is the central hub for players to manage their character(s)
 */
public function render_character_management() {
    $user_id = get_current_user_id();
    $characters = $this->character_manager->get_user_characters($user_id);
    
    // Character display and actions based on unlocked features
    ?>
    <div class="wrap rpg-character-management">
        <h1><?php _e('Character Management', 'rpg-suite'); ?></h1>
        
        <?php if (empty($characters)): ?>
            <!-- No characters yet, offer to create one -->
            <div class="rpg-create-character">
                <h2><?php _e('Create Your Character', 'rpg-suite'); ?></h2>
                <p><?php _e('You don\'t have any characters yet. Create your first random character to begin your adventure!', 'rpg-suite'); ?></p>
                
                <form method="post" action="<?php echo admin_url('admin-post.php'); ?>">
                    <input type="hidden" name="action" value="rpg_create_random_character">
                    <?php wp_nonce_field('rpg_create_random_character', 'character_nonce'); ?>
                    
                    <button type="submit" class="button button-primary">
                        <?php _e('Generate Random Character', 'rpg-suite'); ?>
                    </button>
                </form>
            </div>
        <?php else: ?>
            <?php 
            // Get living and dead characters
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
            ?>
            
            <?php if (!empty($living_characters)): ?>
                <div class="rpg-living-characters">
                    <h2><?php _e('Your Character', 'rpg-suite'); ?></h2>
                    
                    <?php foreach ($living_characters as $character): ?>
                        <?php $this->render_character_card($character->ID); ?>
                        
                        <div class="rpg-character-actions">
                            <?php if ($this->has_unlocked_feature('edit_character')): ?>
                                <a href="<?php echo admin_url('admin.php?page=rpg-character-editor&character_id=' . $character->ID); ?>" class="button">
                                    <?php _e('Edit Character', 'rpg-suite'); ?>
                                </a>
                            <?php endif; ?>
                            
                            <a href="<?php echo get_permalink($character->ID); ?>" class="button">
                                <?php _e('View Character', 'rpg-suite'); ?>
                            </a>
                        </div>
                    <?php endforeach; ?>
                </div>
                
                <?php if ($this->has_unlocked_feature('multiple_characters') && count($living_characters) < 3): ?>
                    <div class="rpg-create-another">
                        <h3><?php _e('Create Another Character', 'rpg-suite'); ?></h3>
                        <p><?php _e('You\'ve unlocked the ability to have multiple characters!', 'rpg-suite'); ?></p>
                        
                        <form method="post" action="<?php echo admin_url('admin-post.php'); ?>">
                            <input type="hidden" name="action" value="rpg_create_random_character">
                            <?php wp_nonce_field('rpg_create_random_character', 'character_nonce'); ?>
                            
                            <button type="submit" class="button">
                                <?php _e('Generate Another Character', 'rpg-suite'); ?>
                            </button>
                        </form>
                    </div>
                <?php endif; ?>
            <?php endif; ?>
            
            <?php if (!empty($dead_characters)): ?>
                <div class="rpg-dead-characters">
                    <h2><?php _e('Fallen Characters', 'rpg-suite'); ?></h2>
                    
                    <?php foreach ($dead_characters as $character): ?>
                        <?php $this->render_dead_character_card($character->ID); ?>
                        
                        <?php if ($this->has_unlocked_feature('character_respawn')): ?>
                            <div class="rpg-character-actions">
                                <form method="post" action="<?php echo admin_url('admin-post.php'); ?>">
                                    <input type="hidden" name="action" value="rpg_respawn_character">
                                    <input type="hidden" name="character_id" value="<?php echo $character->ID; ?>">
                                    <?php wp_nonce_field('rpg_respawn_character', 'respawn_nonce'); ?>
                                    
                                    <button type="submit" class="button">
                                        <?php _e('Respawn Character', 'rpg-suite'); ?>
                                    </button>
                                </form>
                            </div>
                        <?php endif; ?>
                    <?php endforeach; ?>
                    
                    <?php if (empty($living_characters)): ?>
                        <div class="rpg-create-new">
                            <h3><?php _e('Create New Character', 'rpg-suite'); ?></h3>
                            <p><?php _e('Your character has died! Create a new one to continue your adventure.', 'rpg-suite'); ?></p>
                            
                            <form method="post" action="<?php echo admin_url('admin-post.php'); ?>">
                                <input type="hidden" name="action" value="rpg_create_random_character">
                                <?php wp_nonce_field('rpg_create_random_character', 'character_nonce'); ?>
                                
                                <button type="submit" class="button button-primary">
                                    <?php _e('Generate New Character', 'rpg-suite'); ?>
                                </button>
                            </form>
                        </div>
                    <?php endif; ?>
                </div>
            <?php endif; ?>
        <?php endif; ?>
        
        <!-- XP Progress Section -->
        <div class="rpg-xp-progress">
            <h2><?php _e('Your Progress', 'rpg-suite'); ?></h2>
            <?php $this->render_xp_progress(); ?>
        </div>
    </div>
    <?php
}
```

### 5. Random Character Generation System

```php
/**
 * Character class definitions with attribute ranges and equipment
 */
public $character_classes = [
    'warrior' => [
        'name' => 'Warrior',
        'image' => 'warrior.jpg',
        'description' => 'A mighty fighter skilled in combat.',
        'attribute_ranges' => [
            'strength' => ['min' => 14, 'max' => 18],
            'dexterity' => ['min' => 10, 'max' => 14],
            'constitution' => ['min' => 12, 'max' => 16],
            'intelligence' => ['min' => 8, 'max' => 12],
            'wisdom' => ['min' => 8, 'max' => 12],
            'charisma' => ['min' => 8, 'max' => 12],
        ],
        'equipment' => [
            'weapons' => ['longsword', 'battleaxe', 'warhammer'],
            'armor' => ['chain mail', 'scale mail'],
            'items' => ['backpack', 'bedroll', 'waterskin', 'torch (10)'],
        ],
        'name_prefixes' => ['Gor', 'Throk', 'Krom', 'Varg', 'Brom', 'Drok'],
        'name_suffixes' => ['nar', 'mar', 'gar', 'thor', 'dor', 'grim'],
    ],
    'wizard' => [
        'name' => 'Wizard',
        'image' => 'wizard.jpg',
        'description' => 'A scholar of arcane magic.',
        'attribute_ranges' => [
            'strength' => ['min' => 8, 'max' => 12],
            'dexterity' => ['min' => 10, 'max' => 14],
            'constitution' => ['min' => 8, 'max' => 12],
            'intelligence' => ['min' => 14, 'max' => 18],
            'wisdom' => ['min' => 12, 'max' => 16],
            'charisma' => ['min' => 10, 'max' => 14],
        ],
        'equipment' => [
            'weapons' => ['staff', 'dagger', 'wand'],
            'armor' => ['cloth robe', 'enchanted cloak'],
            'items' => ['spellbook', 'component pouch', 'scroll case', 'ink and quill'],
        ],
        'name_prefixes' => ['Zal', 'Gand', 'Mor', 'El', 'Syl', 'Aes'],
        'name_suffixes' => ['ius', 'adel', 'azar', 'ados', 'amir', 'oth'],
    ],
    'rogue' => [
        'name' => 'Rogue',
        'image' => 'rogue.jpg',
        'description' => 'A stealthy expert in traps and deception.',
        'attribute_ranges' => [
            'strength' => ['min' => 10, 'max' => 14],
            'dexterity' => ['min' => 14, 'max' => 18],
            'constitution' => ['min' => 10, 'max' => 14],
            'intelligence' => ['min' => 12, 'max' => 16],
            'wisdom' => ['min' => 8, 'max' => 12],
            'charisma' => ['min' => 12, 'max' => 16],
        ],
        'equipment' => [
            'weapons' => ['shortsword', 'dagger (2)', 'shortbow'],
            'armor' => ['leather armor', 'studded leather'],
            'items' => ['thieves\' tools', 'grappling hook', 'caltrops', 'dark cloak'],
        ],
        'name_prefixes' => ['Shad', 'Dar', 'Night', 'Swift', 'Silent', 'Quick'],
        'name_suffixes' => ['claw', 'fist', 'blade', 'step', 'shadow', 'hand'],
    ],
    'cleric' => [
        'name' => 'Cleric',
        'image' => 'cleric.jpg',
        'description' => 'A divine spellcaster and healer.',
        'attribute_ranges' => [
            'strength' => ['min' => 10, 'max' => 14],
            'dexterity' => ['min' => 8, 'max' => 12],
            'constitution' => ['min' => 10, 'max' => 14],
            'intelligence' => ['min' => 10, 'max' => 14],
            'wisdom' => ['min' => 14, 'max' => 18],
            'charisma' => ['min' => 12, 'max' => 16],
        ],
        'equipment' => [
            'weapons' => ['mace', 'warhammer', 'flail'],
            'armor' => ['chain mail', 'scale mail', 'shield'],
            'items' => ['holy symbol', 'prayer book', 'healing herbs', 'incense'],
        ],
        'name_prefixes' => ['Bless', 'Light', 'Faith', 'Pious', 'Divine', 'Holy'],
        'name_suffixes' => ['heart', 'hand', 'soul', 'voice', 'prayer', 'light'],
    ],
];

/**
 * Generate a random character name based on character class
 */
private function generate_random_name($class) {
    if (!isset($this->character_classes[$class])) {
        // Fallback to generic name generation
        $prefixes = ['Adven', 'Her', 'Explor', 'Wander', 'Trav'];
        $suffixes = ['turer', 'o', 'er', 'eler', 'eller'];
        
        return $prefixes[array_rand($prefixes)] . $suffixes[array_rand($suffixes)];
    }
    
    $class_info = $this->character_classes[$class];
    $prefix = $class_info['name_prefixes'][array_rand($class_info['name_prefixes'])];
    $suffix = $class_info['name_suffixes'][array_rand($class_info['name_suffixes'])];
    
    return $prefix . $suffix;
}

/**
 * Create a completely random character for a user
 */
public function create_random_character($user_id = null) {
    if (!$user_id) {
        $user_id = get_current_user_id();
    }
    
    // Check if user already has a living character
    $args = [
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
    ];
    
    $living_characters = get_posts($args);
    
    // Only create a new character if the user doesn't have a living character
    // or has unlocked multiple characters and has fewer than the max
    if (!empty($living_characters)) {
        // Check if user has unlocked multiple characters
        if (!$this->has_unlocked_feature('multiple_characters')) {
            return new WP_Error(
                'character_exists', 
                __('You already have a living character. Your character must die before you can create a new one.', 'rpg-suite')
            );
        }
        
        // Check if user has reached the character limit (3)
        if (count($living_characters) >= 3) {
            return new WP_Error(
                'character_limit', 
                __('You have reached the maximum number of characters (3).', 'rpg-suite')
            );
        }
    }
    
    // Select a random character class
    $classes = array_keys($this->character_classes);
    $random_class = $classes[array_rand($classes)];
    $class_info = $this->character_classes[$random_class];
    
    // Generate random name
    $character_name = $this->generate_random_name($random_class);
    
    // Generate random attributes based on class ranges
    $attributes = [];
    foreach ($class_info['attribute_ranges'] as $attr => $range) {
        $attributes[$attr] = rand($range['min'], $range['max']);
    }
    
    // Select random equipment
    $equipment = [];
    foreach ($class_info['equipment'] as $slot => $options) {
        $equipment[$slot] = $options[array_rand($options)];
    }
    
    // Create the character post
    $post_id = wp_insert_post([
        'post_title' => $character_name,
        'post_content' => sprintf(
            __('A randomly generated %s. %s', 'rpg-suite'),
            $class_info['name'],
            $class_info['description']
        ),
        'post_status' => 'publish',
        'post_type' => 'rpg_character',
        'post_author' => $user_id,
    ]);
    
    if (is_wp_error($post_id)) {
        return $post_id;
    }
    
    // Set character metadata
    update_post_meta($post_id, 'character_owner', $user_id);
    update_post_meta($post_id, 'character_is_active', true);
    update_post_meta($post_id, 'character_is_alive', true);
    update_post_meta($post_id, 'character_class', $random_class);
    update_post_meta($post_id, 'character_level', 1);
    update_post_meta($post_id, 'character_experience', 0);
    update_post_meta($post_id, 'character_creation_date', current_time('mysql'));
    
    // Set character attributes
    foreach ($attributes as $key => $value) {
        update_post_meta($post_id, 'attribute_' . $key, $value);
    }
    
    // Set character equipment
    foreach ($equipment as $slot => $item) {
        update_post_meta($post_id, 'equipment_' . $slot, $item);
    }
    
    // Award XP for creating a character (first-time only)
    $character_count = count($this->character_manager->get_user_characters($user_id));
    if ($character_count === 1) {
        $this->award_experience($user_id, 100, __('Created your first character', 'rpg-suite'));
    }
    
    return $post_id;
}

/**
 * Handle character death
 */
public function kill_character($character_id, $death_cause = '') {
    // Verify the character exists
    $character = get_post($character_id);
    if (!$character || $character->post_type !== 'rpg_character') {
        return new WP_Error('invalid_character', __('Invalid character ID.', 'rpg-suite'));
    }
    
    // Get the character owner
    $owner_id = get_post_meta($character_id, 'character_owner', true);
    
    // Verify the character is alive
    $is_alive = get_post_meta($character_id, 'character_is_alive', true);
    if (!$is_alive) {
        return new WP_Error('character_already_dead', __('This character is already dead.', 'rpg-suite'));
    }
    
    // Mark the character as dead
    update_post_meta($character_id, 'character_is_alive', false);
    update_post_meta($character_id, 'character_death_cause', $death_cause);
    update_post_meta($character_id, 'character_death_date', current_time('mysql'));
    
    // Update user's death count
    $death_count = (int)get_user_meta($owner_id, 'rpg_character_deaths', true);
    update_user_meta($owner_id, 'rpg_character_deaths', $death_count + 1);
    
    // Calculate experience earned from this character's life
    $character_level = (int)get_post_meta($character_id, 'character_level', true);
    
    // Calculate days alive
    $creation_date = get_post_meta($character_id, 'character_creation_date', true);
    $days_alive = 1; // Default to 1 day if creation date not set
    
    if ($creation_date) {
        $creation_timestamp = strtotime($creation_date);
        $now = current_time('timestamp');
        $days_alive = max(1, floor(($now - $creation_timestamp) / DAY_IN_SECONDS));
    }
    
    // Award XP based on character level and days alive
    $xp_award = ($character_level * 50) + ($days_alive * 10);
    $this->award_experience(
        $owner_id, 
        $xp_award, 
        sprintf(__('Character death: %s (Level %d, %d days)', 'rpg-suite'), 
            $character->post_title,
            $character_level,
            $days_alive
        )
    );
    
    // Return response based on available features
    $response = [
        'character_id' => $character_id,
        'character_name' => $character->post_title,
        'days_alive' => $days_alive,
        'level' => $character_level,
        'xp_awarded' => $xp_award,
    ];
    
    // Check if user has respawn feature
    if ($this->has_unlocked_feature('character_respawn', $owner_id)) {
        $response['can_respawn'] = true;
        $response['message'] = __('Your character has died! You can choose to respawn this character or create a new one.', 'rpg-suite');
    } else {
        $response['can_respawn'] = false;
        $response['message'] = __('Your character has died! Create a new character to continue your adventure.', 'rpg-suite');
    }
    
    return $response;
}

/**
 * Respawn a dead character (for users with the respawn feature)
 */
public function respawn_character($character_id) {
    // Verify the character exists
    $character = get_post($character_id);
    if (!$character || $character->post_type !== 'rpg_character') {
        return new WP_Error('invalid_character', __('Invalid character ID.', 'rpg-suite'));
    }
    
    // Get the character owner
    $owner_id = get_post_meta($character_id, 'character_owner', true);
    
    // Verify the current user owns the character
    if (get_current_user_id() != $owner_id) {
        return new WP_Error('not_owner', __('You do not own this character.', 'rpg-suite'));
    }
    
    // Verify the character is dead
    $is_alive = get_post_meta($character_id, 'character_is_alive', true);
    if ($is_alive) {
        return new WP_Error('character_not_dead', __('This character is not dead and cannot be respawned.', 'rpg-suite'));
    }
    
    // Verify the user has unlocked the respawn feature
    if (!$this->has_unlocked_feature('character_respawn')) {
        return new WP_Error('feature_locked', __('You have not unlocked the character respawn feature yet.', 'rpg-suite'));
    }
    
    // Apply respawn penalties
    $character_level = (int)get_post_meta($character_id, 'character_level', true);
    $character_xp = (int)get_post_meta($character_id, 'character_experience', true);
    
    // XP penalty: lose 20% of character XP
    $xp_penalty = ceil($character_xp * 0.2);
    update_post_meta($character_id, 'character_experience', max(0, $character_xp - $xp_penalty));
    
    // Equipment penalty: 50% chance to lose each piece of equipment
    $equipment_slots = ['weapons', 'armor', 'items'];
    $lost_equipment = [];
    
    foreach ($equipment_slots as $slot) {
        $equipment = get_post_meta($character_id, 'equipment_' . $slot, true);
        if ($equipment && rand(1, 100) <= 50) {
            $lost_equipment[] = $equipment;
            delete_post_meta($character_id, 'equipment_' . $slot);
        }
    }
    
    // Mark character as alive again
    update_post_meta($character_id, 'character_is_alive', true);
    update_post_meta($character_id, 'character_respawn_count', (int)get_post_meta($character_id, 'character_respawn_count', true) + 1);
    update_post_meta($character_id, 'character_respawn_date', current_time('mysql'));
    
    // Create story for the respawn
    $respawn_story = sprintf(
        __('After death, %s returned to the world of the living, but the experience was not without cost. Having lost %d experience points and some equipment, the journey continues...', 'rpg-suite'),
        $character->post_title,
        $xp_penalty
    );
    
    // Append respawn story to character description
    $content = $character->post_content . "\n\n" . $respawn_story;
    wp_update_post([
        'ID' => $character_id,
        'post_content' => $content,
    ]);
    
    return [
        'success' => true,
        'character_id' => $character_id,
        'character_name' => $character->post_title,
        'xp_penalty' => $xp_penalty,
        'lost_equipment' => $lost_equipment,
        'message' => __('Your character has been respawned! Some experience and equipment have been lost in the process.', 'rpg-suite'),
    ];
}
```

### 6. XP Progress System and Feature Unlocking

```php
/**
 * Render the XP progress page showing unlocked and locked features
 */
public function render_progress_page() {
    $user_id = get_current_user_id();
    $xp = (int)get_user_meta($user_id, 'rpg_experience_points', true);
    
    // Get XP log for history
    $xp_log = get_user_meta($user_id, 'rpg_experience_log', true);
    if (!is_array($xp_log)) {
        $xp_log = [];
    }
    
    // Sort log by timestamp (newest first)
    usort($xp_log, function($a, $b) {
        return strtotime($b['timestamp']) - strtotime($a['timestamp']);
    });
    
    // Check what features are unlocked
    $unlocked_features = [];
    $locked_features = [];
    
    foreach ($this->feature_thresholds as $feature => $threshold) {
        $feature_data = [
            'name' => $this->get_feature_name($feature),
            'description' => $this->get_feature_description($feature),
            'threshold' => $threshold,
        ];
        
        if ($xp >= $threshold) {
            $unlocked_features[$feature] = $feature_data;
        } else {
            $locked_features[$feature] = $feature_data;
            $feature_data['progress'] = min(100, round(($xp / $threshold) * 100));
        }
    }
    
    // Sort locked features by threshold (lowest first)
    uasort($locked_features, function($a, $b) {
        return $a['threshold'] - $b['threshold'];
    });
    
    // Get next feature to unlock
    $next_feature = reset($locked_features);
    
    ?>
    <div class="wrap rpg-progress">
        <h1><?php _e('Your Adventure Progress', 'rpg-suite'); ?></h1>
        
        <div class="rpg-xp-total">
            <h2><?php _e('Experience Points', 'rpg-suite'); ?></h2>
            <div class="rpg-xp-bar">
                <div class="rpg-xp-total">
                    <span class="rpg-xp-amount"><?php echo number_format($xp); ?> XP</span>
                </div>
                
                <?php if ($next_feature): ?>
                    <div class="rpg-xp-next">
                        <span class="rpg-xp-next-label"><?php echo sprintf(__('Next unlock: %s', 'rpg-suite'), $next_feature['name']); ?></span>
                        <span class="rpg-xp-next-amount"><?php echo number_format($next_feature['threshold']); ?> XP</span>
                        <span class="rpg-xp-needed"><?php echo sprintf(__('%s XP needed', 'rpg-suite'), number_format($next_feature['threshold'] - $xp)); ?></span>
                    </div>
                    
                    <div class="rpg-xp-progress-bar">
                        <div class="rpg-xp-progress" style="width: <?php echo min(100, round(($xp / $next_feature['threshold']) * 100)); ?>%"></div>
                    </div>
                <?php endif; ?>
            </div>
        </div>
        
        <div class="rpg-features-grid">
            <div class="rpg-unlocked-features">
                <h2><?php _e('Unlocked Features', 'rpg-suite'); ?></h2>
                
                <?php if (empty($unlocked_features)): ?>
                    <p><?php _e('You haven\'t unlocked any special features yet. Keep playing to earn experience!', 'rpg-suite'); ?></p>
                <?php else: ?>
                    <ul class="rpg-feature-list">
                        <?php foreach ($unlocked_features as $feature => $data): ?>
                            <li class="rpg-feature rpg-feature-unlocked">
                                <div class="rpg-feature-icon rpg-feature-<?php echo esc_attr($feature); ?>"></div>
                                <div class="rpg-feature-details">
                                    <h3><?php echo esc_html($data['name']); ?></h3>
                                    <p><?php echo esc_html($data['description']); ?></p>
                                    <span class="rpg-feature-xp"><?php echo sprintf(__('Unlocked at %s XP', 'rpg-suite'), number_format($data['threshold'])); ?></span>
                                </div>
                            </li>
                        <?php endforeach; ?>
                    </ul>
                <?php endif; ?>
            </div>
            
            <div class="rpg-locked-features">
                <h2><?php _e('Features to Unlock', 'rpg-suite'); ?></h2>
                
                <?php if (empty($locked_features)): ?>
                    <p><?php _e('You\'ve unlocked all available features! Congratulations!', 'rpg-suite'); ?></p>
                <?php else: ?>
                    <ul class="rpg-feature-list">
                        <?php foreach ($locked_features as $feature => $data): ?>
                            <li class="rpg-feature rpg-feature-locked">
                                <div class="rpg-feature-icon rpg-feature-<?php echo esc_attr($feature); ?>"></div>
                                <div class="rpg-feature-details">
                                    <h3><?php echo esc_html($data['name']); ?></h3>
                                    <p><?php echo esc_html($data['description']); ?></p>
                                    <span class="rpg-feature-xp"><?php echo sprintf(__('Unlock at %s XP', 'rpg-suite'), number_format($data['threshold'])); ?></span>
                                    <div class="rpg-feature-progress-bar">
                                        <div class="rpg-feature-progress" style="width: <?php echo $data['progress']; ?>%"></div>
                                    </div>
                                    <span class="rpg-feature-progress-text"><?php echo $data['progress']; ?>%</span>
                                </div>
                            </li>
                        <?php endforeach; ?>
                    </ul>
                <?php endif; ?>
            </div>
        </div>
        
        <div class="rpg-xp-history">
            <h2><?php _e('Experience History', 'rpg-suite'); ?></h2>
            
            <?php if (empty($xp_log)): ?>
                <p><?php _e('No experience history yet.', 'rpg-suite'); ?></p>
            <?php else: ?>
                <table class="widefat">
                    <thead>
                        <tr>
                            <th><?php _e('Date', 'rpg-suite'); ?></th>
                            <th><?php _e('Amount', 'rpg-suite'); ?></th>
                            <th><?php _e('Reason', 'rpg-suite'); ?></th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($xp_log as $entry): ?>
                            <tr>
                                <td><?php echo date_i18n(get_option('date_format') . ' ' . get_option('time_format'), strtotime($entry['timestamp'])); ?></td>
                                <td><?php echo sprintf(_n('%d XP', '%d XP', $entry['amount'], 'rpg-suite'), $entry['amount']); ?></td>
                                <td><?php echo esc_html($entry['reason']); ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            <?php endif; ?>
        </div>
        
        <div class="rpg-how-to-earn">
            <h2><?php _e('How to Earn Experience', 'rpg-suite'); ?></h2>
            <ul>
                <li><?php _e('Create new characters: 100 XP for your first character', 'rpg-suite'); ?></li>
                <li><?php _e('Character survival: 10 XP per day your character stays alive', 'rpg-suite'); ?></li>
                <li><?php _e('Level up characters: 50 XP per character level on death', 'rpg-suite'); ?></li>
                <li><?php _e('Complete quests and missions (coming soon!)', 'rpg-suite'); ?></li>
                <li><?php _e('Participate in community events (coming soon!)', 'rpg-suite'); ?></li>
            </ul>
        </div>
    </div>
    <?php
}

/**
 * Get human-readable feature name
 */
private function get_feature_name($feature) {
    $names = [
        'edit_character' => __('Character Editing', 'rpg-suite'),
        'character_respawn' => __('Character Respawn', 'rpg-suite'),
        'multiple_characters' => __('Multiple Characters', 'rpg-suite'),
        'character_switching' => __('Character Switching', 'rpg-suite'),
        'advanced_customization' => __('Advanced Customization', 'rpg-suite'),
    ];
    
    return isset($names[$feature]) ? $names[$feature] : ucfirst(str_replace('_', ' ', $feature));
}

/**
 * Get feature description
 */
private function get_feature_description($feature) {
    $descriptions = [
        'edit_character' => __('Edit your character\'s name, appearance, and reallocate a limited number of attribute points.', 'rpg-suite'),
        'character_respawn' => __('Bring your deceased characters back to life, with some penalties.', 'rpg-suite'),
        'multiple_characters' => __('Create and manage up to 3 characters simultaneously.', 'rpg-suite'),
        'character_switching' => __('Switch between your different characters at will.', 'rpg-suite'),
        'advanced_customization' => __('Full customization of character attributes, special abilities, and more.', 'rpg-suite'),
    ];
    
    return isset($descriptions[$feature]) ? $descriptions[$feature] : '';
}

/**
 * Show a notification when a user unlocks a new feature
 */
public function notify_unlocked_features() {
    // Get newly unlocked features from user meta
    $user_id = get_current_user_id();
    $new_unlocks = get_user_meta($user_id, 'rpg_new_unlocks', true);
    
    if (empty($new_unlocks) || !is_array($new_unlocks)) {
        return;
    }
    
    // Clear the notification after showing it
    delete_user_meta($user_id, 'rpg_new_unlocks');
    
    // Show notification for each newly unlocked feature
    foreach ($new_unlocks as $feature) {
        $name = $this->get_feature_name($feature);
        $description = $this->get_feature_description($feature);
        
        ?>
        <div class="notice notice-success is-dismissible">
            <h3><?php echo sprintf(__('New Feature Unlocked: %s', 'rpg-suite'), $name); ?></h3>
            <p><?php echo $description; ?></p>
            <p>
                <a href="<?php echo admin_url('admin.php?page=rpg-progress'); ?>" class="button">
                    <?php _e('View Your Progress', 'rpg-suite'); ?>
                </a>
            </p>
        </div>
        <?php
    }
}
```

### 7. BuddyPress Profile Integration

```php
/**
 * Register BuddyPress integration hooks
 */
public function register_buddypress_hooks() {
    // Make sure BuddyPress is active before registering hooks
    if (!function_exists('buddypress')) {
        return;
    }
    
    // Add character display to profile
    add_action('bp_before_member_header_meta', [$this, 'display_character_in_profile']);
    
    // Add character status to profile nav menu
    add_action('bp_setup_nav', [$this, 'add_character_profile_tab'], 100);
    
    // Register admin bar menu for quick character access
    add_action('admin_bar_menu', [$this, 'add_character_admin_bar_menu'], 100);
}

/**
 * Display character in BuddyPress profile header
 */
public function display_character_in_profile() {
    $user_id = bp_displayed_user_id();
    $active_character = $this->character_manager->get_active_character($user_id);
    
    if (!$active_character) {
        if (bp_is_my_profile()) {
            // Prompt to create character
            echo '<div class="rpg-character-prompt">';
            echo '<p>' . __('You haven\'t created a character yet!', 'rpg-suite') . '</p>';
            echo '<a href="' . admin_url('admin.php?page=rpg-character-management') . '" class="button">';
            echo __('Create Your Character', 'rpg-suite') . '</a>';
            echo '</div>';
        }
        return;
    }
    
    // Only show living characters
    $is_alive = get_post_meta($active_character->ID, 'character_is_alive', true);
    if (!$is_alive) {
        if (bp_is_my_profile()) {
            echo '<div class="rpg-character-prompt">';
            echo '<p>' . __('Your character has died!', 'rpg-suite') . '</p>';
            echo '<a href="' . admin_url('admin.php?page=rpg-character-management') . '" class="button">';
            echo __('Create New Character', 'rpg-suite') . '</a>';
            echo '</div>';
        }
        return;
    }
    
    // Get character details
    $character_class = get_post_meta($active_character->ID, 'character_class', true);
    $character_level = get_post_meta($active_character->ID, 'character_level', true);
    
    // Get user's unlocked features
    $user_features = [];
    $feature_labels = [];
    
    if ($this->has_unlocked_feature('edit_character', $user_id)) {
        $user_features[] = 'edit_character';
        $feature_labels[] = __('Editor', 'rpg-suite');
    }
    
    if ($this->has_unlocked_feature('multiple_characters', $user_id)) {
        $user_features[] = 'multiple_characters';
        $feature_labels[] = __('Collector', 'rpg-suite');
    }
    
    if ($this->has_unlocked_feature('character_respawn', $user_id)) {
        $user_features[] = 'character_respawn';
        $feature_labels[] = __('Phoenix', 'rpg-suite');
    }
    
    // Display the active character
    echo '<div class="rpg-character-profile">';
    
    // Character header
    echo '<div class="rpg-character-header">';
    echo '<h3>' . esc_html($active_character->post_title) . '</h3>';
    echo '<span class="rpg-character-level">' . sprintf(__('Level %d %s', 'rpg-suite'), $character_level, ucfirst($character_class)) . '</span>';
    
    // Show feature badges if any
    if (!empty($feature_labels)) {
        echo '<div class="rpg-character-badges">';
        foreach ($feature_labels as $label) {
            echo '<span class="rpg-badge">' . esc_html($label) . '</span>';
        }
        echo '</div>';
    }
    echo '</div>';
    
    // Display character image
    echo '<div class="rpg-character-avatar">';
    if (has_post_thumbnail($active_character->ID)) {
        echo get_the_post_thumbnail($active_character->ID, 'medium');
    } else {
        // Default image based on class
        $class_image = $character_class . '.jpg';
        if (file_exists(RPG_SUITE_PLUGIN_DIR . 'assets/images/' . $class_image)) {
            echo '<img src="' . RPG_SUITE_PLUGIN_URL . 'assets/images/' . esc_attr($class_image) . '" alt="Character" />';
        } else {
            // Generic default image
            echo '<img src="' . RPG_SUITE_PLUGIN_URL . 'assets/images/default-character.png" alt="Character" />';
        }
    }
    echo '</div>';
    
    // Character actions for profile owner
    if (bp_is_my_profile()) {
        echo '<div class="rpg-character-actions">';
        
        // View character details
        echo '<a href="' . get_permalink($active_character->ID) . '" class="button">';
        echo __('View Details', 'rpg-suite') . '</a>';
        
        // Character management always available
        echo '<a href="' . admin_url('admin.php?page=rpg-character-management') . '" class="button">';
        echo __('Character Management', 'rpg-suite') . '</a>';
        
        // Edit character if feature unlocked
        if ($this->has_unlocked_feature('edit_character', $user_id)) {
            echo '<a href="' . admin_url('admin.php?page=rpg-character-editor&character_id=' . $active_character->ID) . '" class="button">';
            echo __('Edit Character', 'rpg-suite') . '</a>';
        }
        
        // Character switching if feature unlocked and has multiple characters
        if ($this->has_unlocked_feature('character_switching', $user_id) && 
            $this->has_unlocked_feature('multiple_characters', $user_id)) {
            
            $living_characters = $this->character_manager->get_living_characters($user_id);
            if (count($living_characters) > 1) {
                echo '<a href="' . admin_url('admin.php?page=rpg-character-list') . '" class="button">';
                echo __('Switch Character', 'rpg-suite') . '</a>';
            }
        }
        
        echo '</div>';
    }
    
    echo '</div>';
}

/**
 * Add character tab to BuddyPress profile
 */
public function add_character_profile_tab() {
    // Make sure we're on a user profile
    if (!bp_is_user()) {
        return;
    }
    
    $user_id = bp_displayed_user_id();
    $active_character = $this->character_manager->get_active_character($user_id);
    
    // Only add the tab if the user has a character
    if (!$active_character) {
        return;
    }
    
    // Add the tab
    bp_core_new_nav_item([
        'name' => __('Character', 'rpg-suite'),
        'slug' => 'character',
        'position' => 70,
        'screen_function' => [$this, 'character_screen_function'],
        'default_subnav_slug' => 'view',
    ]);
    
    // Add default sub-tab
    bp_core_new_subnav_item([
        'name' => __('View', 'rpg-suite'),
        'slug' => 'view',
        'parent_slug' => 'character',
        'parent_url' => bp_core_get_user_domain($user_id) . 'character/',
        'screen_function' => [$this, 'character_screen_function'],
        'position' => 10,
    ]);
    
    // Add stats sub-tab
    bp_core_new_subnav_item([
        'name' => __('Stats', 'rpg-suite'),
        'slug' => 'stats',
        'parent_slug' => 'character',
        'parent_url' => bp_core_get_user_domain($user_id) . 'character/',
        'screen_function' => [$this, 'character_stats_screen_function'],
        'position' => 20,
    ]);
}

/**
 * Character profile tab content
 */
public function character_screen_function() {
    add_action('bp_template_content', [$this, 'character_screen_content']);
    bp_core_load_template('members/single/plugins');
}

/**
 * Character stats tab content
 */
public function character_stats_screen_function() {
    add_action('bp_template_content', [$this, 'character_stats_screen_content']);
    bp_core_load_template('members/single/plugins');
}

/**
 * Display character details in profile tab
 */
public function character_screen_content() {
    $user_id = bp_displayed_user_id();
    $active_character = $this->character_manager->get_active_character($user_id);
    
    if (!$active_character) {
        echo '<div class="rpg-no-character">';
        echo '<p>' . __('No active character found.', 'rpg-suite') . '</p>';
        echo '</div>';
        return;
    }
    
    $character_class = get_post_meta($active_character->ID, 'character_class', true);
    $character_level = get_post_meta($active_character->ID, 'character_level', true);
    $character_xp = get_post_meta($active_character->ID, 'character_experience', true);
    $is_alive = get_post_meta($active_character->ID, 'character_is_alive', true);
    
    ?>
    <div class="rpg-character-sheet">
        <div class="rpg-character-header">
            <h2><?php echo esc_html($active_character->post_title); ?></h2>
            <div class="rpg-character-meta">
                <span class="rpg-character-class"><?php echo ucfirst($character_class); ?></span>
                <span class="rpg-character-level"><?php echo sprintf(__('Level %d', 'rpg-suite'), $character_level); ?></span>
                <?php if (!$is_alive): ?>
                    <span class="rpg-character-status rpg-character-dead"><?php _e('Deceased', 'rpg-suite'); ?></span>
                <?php endif; ?>
            </div>
        </div>
        
        <?php if ($is_alive): ?>
            <div class="rpg-character-experience">
                <div class="rpg-xp-label"><?php _e('Experience', 'rpg-suite'); ?></div>
                <div class="rpg-xp-amount"><?php echo number_format($character_xp); ?> XP</div>
                <?php 
                // Calculate XP needed for next level (simple formula)
                $next_level = $character_level + 1;
                $xp_for_next = $next_level * 1000;
                $xp_needed = max(0, $xp_for_next - $character_xp);
                $progress_percent = min(100, round(($character_xp / $xp_for_next) * 100));
                ?>
                <div class="rpg-xp-next"><?php echo sprintf(__('%s XP to level %d', 'rpg-suite'), number_format($xp_needed), $next_level); ?></div>
                <div class="rpg-xp-bar">
                    <div class="rpg-xp-progress" style="width: <?php echo $progress_percent; ?>%"></div>
                </div>
            </div>
        <?php else: ?>
            <div class="rpg-character-death">
                <?php 
                $death_cause = get_post_meta($active_character->ID, 'character_death_cause', true);
                $death_date = get_post_meta($active_character->ID, 'character_death_date', true);
                ?>
                <h3><?php _e('Character Death', 'rpg-suite'); ?></h3>
                <p><?php echo sprintf(__('Died on %s', 'rpg-suite'), date_i18n(get_option('date_format'), strtotime($death_date))); ?></p>
                <?php if ($death_cause): ?>
                    <p><?php echo sprintf(__('Cause of death: %s', 'rpg-suite'), esc_html($death_cause)); ?></p>
                <?php endif; ?>
            </div>
        <?php endif; ?>
        
        <div class="rpg-character-description">
            <?php echo wpautop($active_character->post_content); ?>
        </div>
        
        <div class="rpg-character-equipment">
            <h3><?php _e('Equipment', 'rpg-suite'); ?></h3>
            <ul>
                <?php
                $equipment_slots = ['weapons', 'armor', 'items'];
                $has_equipment = false;
                
                foreach ($equipment_slots as $slot) {
                    $equipment = get_post_meta($active_character->ID, 'equipment_' . $slot, true);
                    if ($equipment) {
                        echo '<li><strong>' . ucfirst($slot) . ':</strong> ' . esc_html($equipment) . '</li>';
                        $has_equipment = true;
                    }
                }
                
                if (!$has_equipment) {
                    echo '<li>' . __('No equipment', 'rpg-suite') . '</li>';
                }
                ?>
            </ul>
        </div>
    </div>
    <?php
}

/**
 * Display character stats in profile tab
 */
public function character_stats_screen_content() {
    $user_id = bp_displayed_user_id();
    $active_character = $this->character_manager->get_active_character($user_id);
    
    if (!$active_character) {
        echo '<div class="rpg-no-character">';
        echo '<p>' . __('No active character found.', 'rpg-suite') . '</p>';
        echo '</div>';
        return;
    }
    
    // Get character attributes
    $attributes = [
        'strength' => get_post_meta($active_character->ID, 'attribute_strength', true),
        'dexterity' => get_post_meta($active_character->ID, 'attribute_dexterity', true),
        'constitution' => get_post_meta($active_character->ID, 'attribute_constitution', true),
        'intelligence' => get_post_meta($active_character->ID, 'attribute_intelligence', true),
        'wisdom' => get_post_meta($active_character->ID, 'attribute_wisdom', true),
        'charisma' => get_post_meta($active_character->ID, 'attribute_charisma', true),
    ];
    
    // Calculate derived stats
    $hit_points = 10 + (int)($attributes['constitution'] / 2);
    $mana_points = 5 + (int)($attributes['intelligence'] / 2) + (int)($attributes['wisdom'] / 2);
    $melee_attack = (int)($attributes['strength'] / 2) + (int)($attributes['dexterity'] / 4);
    $ranged_attack = (int)($attributes['dexterity'] / 2) + (int)($attributes['perception'] / 4);
    $magic_power = (int)($attributes['intelligence'] / 2) + (int)($attributes['wisdom'] / 4);
    
    ?>
    <div class="rpg-character-stats">
        <h3><?php _e('Character Statistics', 'rpg-suite'); ?></h3>
        
        <div class="rpg-stats-grid">
            <div class="rpg-primary-attributes">
                <h4><?php _e('Primary Attributes', 'rpg-suite'); ?></h4>
                <table class="rpg-attributes-table">
                    <tr>
                        <th><?php _e('Strength', 'rpg-suite'); ?></th>
                        <td><?php echo $attributes['strength']; ?></td>
                    </tr>
                    <tr>
                        <th><?php _e('Dexterity', 'rpg-suite'); ?></th>
                        <td><?php echo $attributes['dexterity']; ?></td>
                    </tr>
                    <tr>
                        <th><?php _e('Constitution', 'rpg-suite'); ?></th>
                        <td><?php echo $attributes['constitution']; ?></td>
                    </tr>
                    <tr>
                        <th><?php _e('Intelligence', 'rpg-suite'); ?></th>
                        <td><?php echo $attributes['intelligence']; ?></td>
                    </tr>
                    <tr>
                        <th><?php _e('Wisdom', 'rpg-suite'); ?></th>
                        <td><?php echo $attributes['wisdom']; ?></td>
                    </tr>
                    <tr>
                        <th><?php _e('Charisma', 'rpg-suite'); ?></th>
                        <td><?php echo $attributes['charisma']; ?></td>
                    </tr>
                </table>
            </div>
            
            <div class="rpg-derived-stats">
                <h4><?php _e('Derived Statistics', 'rpg-suite'); ?></h4>
                <table class="rpg-stats-table">
                    <tr>
                        <th><?php _e('Hit Points', 'rpg-suite'); ?></th>
                        <td><?php echo $hit_points; ?></td>
                    </tr>
                    <tr>
                        <th><?php _e('Mana Points', 'rpg-suite'); ?></th>
                        <td><?php echo $mana_points; ?></td>
                    </tr>
                    <tr>
                        <th><?php _e('Melee Attack', 'rpg-suite'); ?></th>
                        <td><?php echo $melee_attack; ?></td>
                    </tr>
                    <tr>
                        <th><?php _e('Ranged Attack', 'rpg-suite'); ?></th>
                        <td><?php echo $ranged_attack; ?></td>
                    </tr>
                    <tr>
                        <th><?php _e('Magic Power', 'rpg-suite'); ?></th>
                        <td><?php echo $magic_power; ?></td>
                    </tr>
                </table>
            </div>
        </div>
        
        <?php if ($this->has_unlocked_feature('edit_character', $user_id) && bp_is_my_profile()): ?>
            <div class="rpg-character-actions">
                <a href="<?php echo admin_url('admin.php?page=rpg-character-editor&character_id=' . $active_character->ID); ?>" class="button">
                    <?php _e('Edit Character', 'rpg-suite'); ?>
                </a>
            </div>
        <?php endif; ?>
    </div>
    <?php
}

/**
 * Add character menu to admin bar
 */
public function add_character_admin_bar_menu($wp_admin_bar) {
    if (!is_user_logged_in()) {
        return;
    }
    
    $user_id = get_current_user_id();
    $characters = $this->character_manager->get_living_characters($user_id);
    
    if (empty($characters)) {
        return;
    }
    
    // Add parent menu
    $wp_admin_bar->add_node([
        'id' => 'rpg-character',
        'title' => __('Character', 'rpg-suite'),
        'href' => admin_url('admin.php?page=rpg-character-management'),
    ]);
    
    // Add character management
    $wp_admin_bar->add_node([
        'id' => 'rpg-character-management',
        'parent' => 'rpg-character',
        'title' => __('Character Management', 'rpg-suite'),
        'href' => admin_url('admin.php?page=rpg-character-management'),
    ]);
    
    // Add progress page
    $wp_admin_bar->add_node([
        'id' => 'rpg-progress',
        'parent' => 'rpg-character',
        'title' => __('Your Progress', 'rpg-suite'),
        'href' => admin_url('admin.php?page=rpg-progress'),
    ]);
    
    // Add character switching if multiple characters feature is unlocked
    if ($this->has_unlocked_feature('multiple_characters', $user_id) && count($characters) > 1) {
        $wp_admin_bar->add_node([
            'id' => 'rpg-switch-character',
            'parent' => 'rpg-character',
            'title' => __('Switch Character', 'rpg-suite'),
        ]);
        
        // Add each character as a sub-menu item
        $active_character_id = $this->character_manager->get_active_character($user_id)->ID;
        
        foreach ($characters as $character) {
            $is_active = ($character->ID == $active_character_id);
            
            $wp_admin_bar->add_node([
                'id' => 'rpg-character-' . $character->ID,
                'parent' => 'rpg-switch-character',
                'title' => ($is_active ? '✓ ' : '') . esc_html($character->post_title),
                'href' => $is_active ? '#' : admin_url('admin-post.php?action=rpg_switch_character&character_id=' . $character->ID . '&_wpnonce=' . wp_create_nonce('rpg_switch_character')),
            ]);
        }
    }
}
```

## Implementation Strategy

1. **Reset Repository**
   - Start with a clean slate to implement the progression-based character system

2. **Phased Implementation**
   - Phase 1: Core plugin structure with feature tracking system
   - Phase 2: Random character generation system
   - Phase 3: Character death and respawn mechanics
   - Phase 4: XP tracking and feature unlocking
   - Phase 5: Adaptive UI based on unlocked features
   - Phase 6: BuddyPress profile integration

3. **Testing Approach**
   - Create test users at different XP levels to verify feature access
   - Test random character generation for balance and variety
   - Verify character death and respawn mechanics
   - Test the feature unlocking system at different XP thresholds
   - Validate UI adaptation based on unlocked features
   - Test BuddyPress integration for all character states

4. **Deployment**
   - Initially deploy with accelerated XP gain for early testing
   - Create "starter boost" for early adopters to test higher-tier features
   - Set up analytics to track character deaths, respawns, and feature unlocks

## Gameplay Benefits

The progression-based character management system provides several advantages:

1. **Engagement Strategy**: Encourages longer-term player engagement
2. **Gamification**: Makes character management itself a game, with progress and unlocks
3. **User Retention**: Gives players long-term goals to work toward
4. **Natural Progression**: Provides a learning curve that introduces features gradually
5. **Technical Simplicity**: Uses feature flags instead of complex role-based permissions
6. **Community Building**: Rewards active participation in the game world
7. **Organic Growth**: Experienced players naturally get more features as they need them

## Technical Benefits

1. **Simplified WordPress Integration**: Uses standard post capabilities for all users
2. **Feature Flag Architecture**: Cleanly separates UI components based on unlocked features
3. **Meta Data Driven**: Uses standard WordPress meta APIs for all character and user data
4. **Event-Driven Design**: Trigger notifications and actions when features are unlocked
5. **Clean Separation of Concerns**: Separates character management from feature availability
6. **Progressive Enhancement**: Interface grows with the player's progression

## Conclusion

By implementing this progression-based character management system, we transform what was a technical challenge into a gameplay feature. The random character generation and death/rebirth cycle creates natural constraints that feel like part of the game rather than artificial restrictions.

This approach resolves the WordPress capability issues we encountered while creating a compelling gameplay loop that encourages long-term engagement. Players will be motivated to keep their characters alive and earn experience points toward advanced features, making the whole experience more immersive and rewarding.
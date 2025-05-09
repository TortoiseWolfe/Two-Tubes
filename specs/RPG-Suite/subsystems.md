# RPG-Suite Subsystems: First Principles

## Subsystem Architecture Principles

1. **Independence**: Each subsystem operates as a self-contained unit
2. **Integration**: All subsystems communicate via the core event system
3. **Extensibility**: Each subsystem provides hooks for extension
4. **Configurability**: Each subsystem can be enabled/disabled independently
5. **Responsibility**: Each subsystem has a clear and focused responsibility

## Core Subsystem

The Core subsystem serves as the foundation for all other subsystems.

### Core Responsibilities

1. **Plugin Initialization**: Bootstrap the entire plugin
2. **Event System**: Facilitate communication between subsystems
3. **Global Access**: Provide a clean interface to access plugin functionality
4. **Subsystem Management**: Load and initialize subsystems
5. **Common Utilities**: Provide shared functionality for all subsystems

### Core Components

```
Core/
├── class-core.php                 # Main Core class
├── class-event.php                # Base Event class
├── class-event-dispatcher.php     # Event dispatcher implementation
├── class-event-subscriber.php     # Event subscriber interface
└── Components/                    # Core components
    └── class-profile-integration.php  # BuddyPress integration
```

### Core Events

The Core subsystem defines these foundational events:

1. `core.initialized`: Fired when Core subsystem is initialized
2. `plugin.loaded`: Fired when the entire plugin is loaded
3. `subsystem.initialized`: Fired when a subsystem is initialized

### Core Public API

```php
// Access the plugin instance
$plugin = rpg_suite();

// Access a subsystem
$character_manager = rpg_suite()->character_manager;

// Dispatch an event
rpg_suite()->core->get_event_dispatcher()->dispatch('custom.event', new Event());

// Register a subscriber
rpg_suite()->core->get_event_dispatcher()->add_subscriber($subscriber);
```

## Character Subsystem

The Character subsystem manages character creation, retrieval, and manipulation.

### Character Responsibilities

1. **Character Storage**: Define character post type and meta
2. **Character Retrieval**: Methods to find and load characters
3. **Character Creation**: Methods to create new characters
4. **Character-Player Relationship**: Link characters to users
5. **Character Switching**: Allow users to have multiple characters

### Character Components

```
Character/
├── class-character-manager.php     # Main character management
├── class-character-post-type.php   # Character post type definition
└── class-character-template.php    # Character template handling
```

### Character Events

The Character subsystem defines these events:

1. `character.created`: Fired when a new character is created
2. `character.updated`: Fired when a character is updated
3. `character.deleted`: Fired when a character is deleted
4. `character.activated`: Fired when a character becomes active

### Character Public API

```php
// Get current user's active character
$character = rpg_suite()->character_manager->get_active_character();

// Get all characters for a user
$characters = rpg_suite()->character_manager->get_user_characters($user_id);

// Create a new character
$character_id = rpg_suite()->character_manager->create_character($data);

// Set a character as active
rpg_suite()->character_manager->set_active_character($character_id);
```

## Experience Subsystem

The Experience subsystem handles user progression and feature unlocking.

### Experience Responsibilities

1. **XP Tracking**: Track experience points for users
2. **Feature Unlocking**: Enable features based on XP thresholds
3. **XP History**: Maintain a log of XP awards
4. **Progress Visualization**: Show progress toward unlocks
5. **Milestone Handling**: Handle special events at XP thresholds

### Experience Components

```
Experience/
├── class-experience-manager.php    # Main experience management
└── class-feature-manager.php       # Feature unlocking system
```

### Experience Events

The Experience subsystem defines these events:

1. `experience.awarded`: Fired when XP is awarded
2. `feature.unlocked`: Fired when a feature is unlocked
3. `level.gained`: Fired when a character gains a level

### Experience Public API

```php
// Award XP to a user
rpg_suite()->experience_manager->award_experience($user_id, $amount, $reason);

// Check if a feature is unlocked
$unlocked = rpg_suite()->experience_manager->has_unlocked_feature($feature, $user_id);

// Get user's XP
$xp = rpg_suite()->experience_manager->get_user_experience($user_id);
```

## Health Subsystem

The Health subsystem manages character health and status effects.

### Health Responsibilities

1. **HP Tracking**: Track current and maximum health points
2. **Status Effects**: Apply and manage temporary effects
3. **Damage/Healing**: Handle damage and healing application
4. **Death Handling**: Manage character death and revival
5. **Health Visualization**: Display health status visually

### Health Components

```
Health/
├── class-health.php               # Main health management
└── class-status-effect.php        # Status effect implementation
```

### Health Events

The Health subsystem defines these events:

1. `health.damaged`: Fired when a character takes damage
2. `health.healed`: Fired when a character is healed
3. `character.died`: Fired when a character dies
4. `character.revived`: Fired when a character is revived
5. `status.applied`: Fired when a status effect is applied

### Health Public API

```php
// Apply damage to a character
rpg_suite()->health->apply_damage($character_id, $amount, $source);

// Heal a character
rpg_suite()->health->apply_healing($character_id, $amount, $source);

// Get a character's current HP
$hp = rpg_suite()->health->get_current_hp($character_id);

// Check if a character is alive
$is_alive = rpg_suite()->health->is_alive($character_id);
```

## Geo Subsystem

The Geo subsystem handles character positioning and zone management.

### Geo Responsibilities

1. **Zone Definition**: Define geographic zones and their properties
2. **Character Positioning**: Track character locations within zones
3. **Movement**: Handle character movement between zones
4. **Map Visualization**: Display zone maps and character positions
5. **Travel Effects**: Apply effects during travel

### Geo Components

```
Geo/
├── class-geo.php                  # Main geo management
├── class-zone.php                 # Zone implementation
└── class-position.php             # Character position management
```

### Geo Events

The Geo subsystem defines these events:

1. `character.moved`: Fired when a character moves
2. `zone.entered`: Fired when a character enters a zone
3. `zone.exited`: Fired when a character exits a zone

### Geo Public API

```php
// Get a character's current zone
$zone = rpg_suite()->geo->get_character_zone($character_id);

// Move a character to a zone
rpg_suite()->geo->move_character_to_zone($character_id, $zone_id);

// Check if movement is possible
$can_move = rpg_suite()->geo->can_move_to_zone($character_id, $zone_id);
```

## Dice Subsystem

The Dice subsystem handles random number generation and dice rolls.

### Dice Responsibilities

1. **Roll Parsing**: Parse dice notation (2d6, d20, etc.)
2. **Roll Execution**: Perform random number generation
3. **Roll History**: Track roll history for characters
4. **Success Determination**: Determine success/failure based on target
5. **Advantage/Disadvantage**: Handle special roll mechanics

### Dice Components

```
Dice/
├── class-dice.php                 # Main dice management
├── class-notation-parser.php      # Dice notation parser
└── class-roll-result.php          # Roll result storage
```

### Dice Events

The Dice subsystem defines these events:

1. `dice.rolled`: Fired when dice are rolled
2. `roll.succeeded`: Fired when a roll succeeds
3. `roll.failed`: Fired when a roll fails
4. `roll.critical`: Fired on critical success/failure

### Dice Public API

```php
// Roll dice using standard notation
$result = rpg_suite()->dice->roll('2d6+3');

// Make a skill check
$success = rpg_suite()->dice->check($character_id, 'strength', 15);

// Get roll history for a character
$history = rpg_suite()->dice->get_roll_history($character_id);
```

## Inventory Subsystem

The Inventory subsystem manages character items and equipment.

### Inventory Responsibilities

1. **Item Definition**: Define item types and properties
2. **Inventory Management**: Track character inventory
3. **Equipment Slots**: Manage equipped items in slots
4. **Item Effects**: Apply item effects to characters
5. **Item Visualization**: Display character inventory and equipment

### Inventory Components

```
Inventory/
├── class-inventory.php            # Main inventory management
├── class-item.php                 # Item implementation
└── class-equipment.php            # Equipment slot management
```

### Inventory Events

The Inventory subsystem defines these events:

1. `item.acquired`: Fired when an item is acquired
2. `item.removed`: Fired when an item is removed
3. `item.equipped`: Fired when an item is equipped
4. `item.unequipped`: Fired when an item is unequipped

### Inventory Public API

```php
// Add an item to a character's inventory
rpg_suite()->inventory->add_item($character_id, $item_id, $quantity);

// Equip an item
rpg_suite()->inventory->equip_item($character_id, $item_id, $slot);

// Get a character's inventory
$inventory = rpg_suite()->inventory->get_inventory($character_id);

// Get equipped items
$equipment = rpg_suite()->inventory->get_equipment($character_id);
```

## Subsystem Dependencies

Dependencies between subsystems should be minimized, but some natural dependencies exist:

1. **All Subsystems** → **Core**: All subsystems depend on Core
2. **Health** → **Character**: Health system needs character data
3. **Inventory** → **Character**: Inventory system needs character data
4. **Geo** → **Character**: Geo system needs character data

## Subsystem Loading Process

Subsystems are loaded in a specific order to ensure dependencies are satisfied:

1. Core subsystem is loaded first
2. Character subsystem is loaded second
3. Experience subsystem is loaded third
4. Other subsystems are loaded based on dependencies

```php
// Example loading sequence
public function load_subsystems() {
    // Load Core first (already loaded by main plugin class)
    $this->core = new Core();
    $this->core->init();
    
    // Load Character subsystem
    $this->character_manager = new Character\Character_Manager();
    $this->character_manager->init();
    
    // Load Experience subsystem
    $this->experience_manager = new Experience\Experience_Manager();
    $this->experience_manager->init();
    
    // Load other subsystems
    if ($this->is_subsystem_enabled('health')) {
        $this->health = new Health\Health($this->character_manager);
        $this->health->init();
    }
    
    // Continue with other subsystems...
}
```

## Subsystem Configuration

Each subsystem can be enabled or disabled through configuration:

```php
// Default configuration
$default_config = [
    'subsystems' => [
        'core' => true,       // Core is always enabled
        'character' => true,  // Character is always enabled
        'experience' => true, // Experience is always enabled
        'health' => true,
        'geo' => true,
        'dice' => true,
        'inventory' => true,
        'combat' => false,
        'quest' => false,
    ],
];
```

## Integration Between Subsystems

Subsystems communicate with each other through the event system:

```php
// Health subsystem listens for character events
class Health implements Event_Subscriber {
    public function get_subscribed_events() {
        return [
            'character.created' => 'initialize_health',
            'character.deleted' => 'cleanup_health',
        ];
    }
    
    public function initialize_health($event) {
        $character_id = $event->get_character_id();
        $this->set_max_hp($character_id, 10);
        $this->set_current_hp($character_id, 10);
    }
    
    public function cleanup_health($event) {
        $character_id = $event->get_character_id();
        // Remove health data
    }
}
```
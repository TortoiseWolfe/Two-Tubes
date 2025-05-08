# RPG-Suite Subsystems Specification

This document details the technical specifications for all subsystems in the RPG-Suite WordPress plugin.

## Core Subsystem

The Core subsystem provides the foundation and supporting infrastructure for all other subsystems.

### Requirements

1. **Event System**
   - Event dispatcher based on Symfony event dispatcher pattern
   - Support for typed events with proper inheritance
   - Subscriber registration with priority support
   - Integration with WordPress action hooks

2. **Role Management**
   - Map WordPress roles to RPG-specific roles
   - Define capabilities for Player, Game Master, and Admin roles
   - Handle capability checks across subsystems

3. **Settings API**
   - Unified settings interface for all subsystems
   - Persistent storage in WordPress options table
   - Settings validation and sanitization

4. **REST API Gateway**
   - Central API namespace registration
   - Authentication and permission checks
   - API documentation and discovery endpoints

### Technical Specification

- **Classes**:
  - `RPG\Suite\Core\Core`: Main class for Core subsystem
  - `RPG\Suite\Core\Event`: Base event class
  - `RPG\Suite\Core\Event_Dispatcher`: Event dispatcher implementation
  - `RPG\Suite\Core\Event_Subscriber`: Base subscriber interface

- **Hooks**:
  - `rpg_suite_init`: Fired when Core is initialized
  - `rpg_suite_before_init`: Fired before Core initialization
  - `rpg_suite_after_init`: Fired after all subsystems initialized

- **REST Endpoints**:
  - `GET /wp-json/rpg-suite/v1/status`: System status information
  - `GET /wp-json/rpg-suite/v1/settings`: Global settings

## Health Subsystem

The Health subsystem manages character health points and status effects.

### Requirements

1. **Health Points**
   - Track current and maximum HP for characters
   - Handle damage application and healing
   - Support for temporary HP
   - Death/unconsciousness state management

2. **Status Effects**
   - Apply timed effects to characters (poison, buffs, etc.)
   - Duration tracking (turns, real-time, etc.)
   - Effect stacking rules
   - Visual indicators for active effects

3. **Health Display**
   - Visual health bar with percentage indicator
   - Character status indicators
   - Integration with BuddyPress profiles and activity

### Technical Specification

- **Classes**:
  - `RPG\Suite\Health\Health`: Main health management class
  - `RPG\Suite\Health\Status_Effect`: Status effect implementation
  - `RPG\Suite\Health\Events\Damage_Event`: Event fired when damage occurs

- **Database**:
  - Character health stored in character meta
  - Status effects stored in custom table

- **REST Endpoints**:
  - `GET /wp-json/rpg-suite/v1/characters/{id}/health`: Get character health
  - `POST /wp-json/rpg-suite/v1/characters/{id}/health/damage`: Apply damage
  - `POST /wp-json/rpg-suite/v1/characters/{id}/health/heal`: Apply healing

## Geo Subsystem

The Geo subsystem handles character positioning and zone management.

### Requirements

1. **Zone Management**
   - Create and define geographic zones
   - Zone properties (danger level, environment type, etc.)
   - Zone connections and travel paths
   - Zone visibility settings

2. **Character Positioning**
   - Track character positions within zones
   - Movement between connected zones
   - Position history
   - Position privacy settings

3. **Map Interface**
   - Visual map representation of zones
   - Character position indicators
   - Interactive map navigation

### Technical Specification

- **Classes**:
  - `RPG\Suite\Geo\Geo`: Main geo management class
  - `RPG\Suite\Geo\Zone`: Zone implementation
  - `RPG\Suite\Geo\Position`: Character position management

- **Custom Post Types**:
  - `rpg_zone`: Zone definitions and properties

- **REST Endpoints**:
  - `GET /wp-json/rpg-suite/v1/zones`: List all zones
  - `GET /wp-json/rpg-suite/v1/zones/{id}`: Get zone details
  - `GET /wp-json/rpg-suite/v1/characters/{id}/position`: Get character position
  - `POST /wp-json/rpg-suite/v1/characters/{id}/position`: Update character position

## Dice Subsystem

The Dice subsystem provides random number generation and dice rolling mechanics.

### Requirements

1. **Dice Notation**
   - Support standard dice notation (2d6, d20, etc.)
   - Complex notation (4d6h3, 2d20l1, etc.)
   - Custom dice faces and types
   - Expression evaluation (2d6+4)

2. **Roll Tracking**
   - Record roll results
   - Roll history per character
   - Public vs. private rolls

3. **Skill Checks**
   - Target number/difficulty class
   - Success/failure determination
   - Critical success/failure
   - Advantage/disadvantage mechanics

### Technical Specification

- **Classes**:
  - `RPG\Suite\Dice\Dice`: Main dice rolling class
  - `RPG\Suite\Dice\Notation_Parser`: Dice notation parser
  - `RPG\Suite\Dice\Roll_Result`: Roll result storage

- **Hooks**:
  - `rpg_suite_before_roll`: Fired before a dice roll
  - `rpg_suite_after_roll`: Fired after a dice roll with results

- **REST Endpoints**:
  - `POST /wp-json/rpg-suite/v1/dice/roll`: Perform a dice roll
  - `GET /wp-json/rpg-suite/v1/characters/{id}/rolls`: Get character roll history

## Inventory Subsystem

The Inventory subsystem manages character items and equipment.

### Requirements

1. **Item Management**
   - Item creation and properties
   - Item categories and types
   - Item rarity and value
   - Item images and descriptions

2. **Character Inventory**
   - Item ownership and quantity
   - Weight and encumbrance calculations
   - Item stacking rules
   - Inventory limits

3. **Equipment System**
   - Equipment slots (head, body, hands, etc.)
   - Equip/unequip functionality
   - Equipment effects on character stats
   - Visual equipment display

### Technical Specification

- **Classes**:
  - `RPG\Suite\Inventory\Inventory`: Main inventory management class
  - `RPG\Suite\Inventory\Item`: Item implementation
  - `RPG\Suite\Inventory\Equipment`: Equipment slot management

- **Custom Post Types**:
  - `rpg_item`: Item definitions and properties

- **Custom Tables**:
  - `rpg_character_items`: Character-item relationship table

- **REST Endpoints**:
  - `GET /wp-json/rpg-suite/v1/items`: List all items
  - `GET /wp-json/rpg-suite/v1/characters/{id}/inventory`: Get character inventory
  - `POST /wp-json/rpg-suite/v1/characters/{id}/inventory/add`: Add item to inventory
  - `POST /wp-json/rpg-suite/v1/characters/{id}/equipment/equip`: Equip an item

## Combat Subsystem

The Combat subsystem handles turn-based encounters and combat mechanics.

### Requirements

1. **Initiative System**
   - Initiative order determination
   - Turn management
   - Round tracking
   - Initiative modifiers

2. **Combat Actions**
   - Attack action resolution
   - Damage calculation
   - Special actions and abilities
   - Reactions and interrupts

3. **Encounter Management**
   - Create and configure encounters
   - Add/remove combatants
   - Track encounter state
   - Encounter history

### Technical Specification

- **Classes**:
  - `RPG\Suite\Combat\Combat`: Main combat management class
  - `RPG\Suite\Combat\Encounter`: Encounter implementation
  - `RPG\Suite\Combat\Initiative`: Initiative order management
  - `RPG\Suite\Combat\Action`: Combat action base class

- **Custom Post Types**:
  - `rpg_encounter`: Encounter definitions and state

- **REST Endpoints**:
  - `GET /wp-json/rpg-suite/v1/encounters`: List all encounters
  - `GET /wp-json/rpg-suite/v1/encounters/{id}`: Get encounter details
  - `POST /wp-json/rpg-suite/v1/encounters/{id}/initiative`: Roll initiative
  - `POST /wp-json/rpg-suite/v1/encounters/{id}/action`: Perform combat action

## Quest Subsystem

The Quest subsystem manages narrative quests and rewards.

### Requirements

1. **Quest Structure**
   - Quest creation with objectives
   - Branching narrative paths
   - Dependencies and prerequisites
   - Quest completion conditions

2. **Quest Tracking**
   - Player quest log
   - Objective progress tracking
   - Quest status (active, completed, failed)
   - Quest history

3. **Reward System**
   - XP rewards
   - Item rewards
   - Special unlocks and effects
   - Achievement tracking

### Technical Specification

- **Classes**:
  - `RPG\Suite\Quest\Quest`: Main quest management class
  - `RPG\Suite\Quest\Objective`: Quest objective implementation
  - `RPG\Suite\Quest\Reward`: Reward system implementation

- **Custom Post Types**:
  - `rpg_quest`: Quest definitions and narrative

- **REST Endpoints**:
  - `GET /wp-json/rpg-suite/v1/quests`: List all quests
  - `GET /wp-json/rpg-suite/v1/characters/{id}/quests`: Get character quest log
  - `POST /wp-json/rpg-suite/v1/characters/{id}/quests/{quest_id}/progress`: Update quest progress

## Character Management

Character management is handled across multiple subsystems with these specifications:

### Requirements

1. **Character Creation**
   - Character creation workflow
   - Character types (Player Character, NPC)
   - Basic attributes and properties
   - Character limits per player (default: 2)

2. **Character Switching**
   - Active character selection
   - Character switching UI
   - Proper state management when switching

3. **Character Display**
   - Character profile display
   - Character actions in activity stream
   - Character privacy settings

### Technical Specification

- **Classes**:
  - `RPG\Suite\Core\Character_Manager`: Main character management class

- **Custom Post Types**:
  - `rpg_character`: Character definitions and data

- **REST Endpoints**:
  - `GET /wp-json/rpg-suite/v1/characters`: List all characters
  - `GET /wp-json/rpg-suite/v1/characters/{id}`: Get character details
  - `POST /wp-json/rpg-suite/v1/characters`: Create new character
  - `PUT /wp-json/rpg-suite/v1/characters/{id}/active`: Set character as active

## Integration Requirements

The RPG-Suite must integrate with WordPress and BuddyPress:

1. **WordPress Integration**
   - Plugin activation/deactivation hooks
   - WordPress admin interface
   - WordPress REST API extensions
   - Custom post types and taxonomies

2. **BuddyPress Integration**
   - Profile display integration
   - Activity stream integration
   - xProfile field integration
   - Groups integration

3. **BuddyX Theme Integration**
   - Compatible with BuddyX parent theme
   - Compatible with vapvarun child theme
   - Responsive design for all screen sizes
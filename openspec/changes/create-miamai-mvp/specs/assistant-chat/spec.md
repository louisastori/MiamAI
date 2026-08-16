## ADDED Requirements

### Requirement: Natural-language culinary conversation
The system MUST allow the user to request meals in natural language and MUST convert the request into structured culinary constraints.

#### Scenario: Prompt includes cuisine, servings, speed, and budget
- **WHEN** the user asks for "un repas asiatique pour 3 personnes, rapide et a moins de 15 euros"
- **THEN** the system returns recipe proposals that include cuisine, servings, prep-time, and budget constraints.

#### Scenario: Prompt misses key constraints
- **WHEN** the user asks for a meal idea without servings or budget
- **THEN** the system uses saved preferences when available or asks one focused clarification question.

### Requirement: Recipe proposal conversation
The system MUST present multiple recipe proposals as structured choices instead of only returning long free-form text.

#### Scenario: Recipes are proposed
- **WHEN** the assistant has enough information to answer a meal request
- **THEN** each proposal includes a title, short description, estimated prep time, serving count, estimated cost, and selection action.

### Requirement: Conversational modifications
The system MUST accept follow-up commands that modify the current recipe or basket context.

#### Scenario: User changes serving count
- **WHEN** the user says "on sera finalement 4"
- **THEN** the selected recipe ingredients and basket calculation are recalculated for 4 people.

#### Scenario: User requests cheaper basket
- **WHEN** the user says "prends moins cher"
- **THEN** the system searches cheaper valid product alternatives and updates the basket total when replacements are available.

#### Scenario: User removes an ingredient
- **WHEN** the user says "enleve les champignons"
- **THEN** the system updates the recipe constraints and removes or replaces matching basket products.

### Requirement: Assistant shortcuts
The system MUST expose quick assistant prompts for common meal intents.

#### Scenario: User taps a shortcut
- **WHEN** the user selects Rapide, Economique, Semaine, or Meal prep
- **THEN** the assistant starts a conversation using that intent as an initial constraint.

### Requirement: Session context
The system MUST keep the active recipe and basket context available during a conversation session.

#### Scenario: Follow-up references current choice
- **WHEN** the user sends a follow-up command that refers to the selected recipe without naming it
- **THEN** the system applies the command to the current selected recipe and basket.

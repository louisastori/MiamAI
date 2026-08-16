## ADDED Requirements

### Requirement: Preference profile
The system MUST maintain a user preference profile for meal planning defaults.

#### Scenario: User opens preferences
- **WHEN** the user opens the Preferences tab
- **THEN** the system shows preferred Drive, default people count, weekly budget, default diet mode, kitchen equipment, notification toggles, promotion toggle, dietary restrictions, and excluded ingredients.

### Requirement: Preference persistence
The system MUST persist preference changes for future assistant conversations.

#### Scenario: User updates default people count
- **WHEN** the user changes the default people count in Preferences
- **THEN** future meal requests use the new value unless the chat prompt overrides it.

### Requirement: Chat override precedence
The system MUST allow explicit chat constraints to override saved preferences for the active session.

#### Scenario: Prompt overrides default budget
- **WHEN** the saved budget is 20 euros and the user asks for a meal under 15 euros
- **THEN** the active recipe and basket flow uses the 15 euro budget.

### Requirement: Preferred Drive
The system MUST use the preferred Drive as the default source for product search.

#### Scenario: Preferred Drive is set
- **WHEN** the user requests a basket and has a preferred Drive
- **THEN** product search runs against that Drive by default.

### Requirement: Disliked foods
The system MUST apply disliked foods to recipe generation unless the user explicitly overrides them.

#### Scenario: Disliked food appears in a prompt
- **WHEN** the user has mushrooms in disliked foods and asks for a recipe without specifying mushrooms
- **THEN** recipe proposals exclude mushrooms.

### Requirement: Kitchen equipment preferences
The system MUST store kitchen equipment preferences for recipe generation.

#### Scenario: User enables Air Fryer
- **WHEN** the user enables Air Fryer in Preferences
- **THEN** future recipe proposals can prefer instructions compatible with an Air Fryer when relevant.

### Requirement: Dietary restriction toggles
The system MUST store specific dietary restriction toggles.

#### Scenario: User enables vegetarian mode
- **WHEN** the user enables Vegetarian in Preferences
- **THEN** future recipe proposals exclude meat unless the chat prompt explicitly overrides the preference.

### Requirement: Notification and promotion toggles
The system MUST store notification and Leclerc promotion preferences without requiring background notification delivery in the MVP.

#### Scenario: User disables Leclerc promotions
- **WHEN** the user disables Leclerc promotions
- **THEN** the preference profile stores that value and AI recipe generation does not prioritize promotional products unless requested.

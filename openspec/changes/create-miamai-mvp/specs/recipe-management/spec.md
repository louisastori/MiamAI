## ADDED Requirements

### Requirement: Structured recipe generation
The system MUST generate recipe proposals as structured data with fields required for selection, scaling, and basket creation.

#### Scenario: Recipe proposal is generated
- **WHEN** the assistant proposes a recipe
- **THEN** the proposal includes title, cuisine style, serving count, prep time, budget estimate, ingredients summary, and tags.

### Requirement: Recipe detail
The system MUST provide a detailed selected recipe with normalized ingredients and preparation instructions.

#### Scenario: User selects a recipe
- **WHEN** the user selects one recipe proposal
- **THEN** the system returns the full recipe detail with hero image metadata, ingredients, quantities, units, steps, serving count, prep time, nutrition fields when available, chef tips, Nutri-Score when available, and estimated basket cost.

### Requirement: Nutrition and quality metadata
The system MUST support optional nutrition and quality metadata on selected recipes.

#### Scenario: Nutrition data is available
- **WHEN** the selected recipe has nutrition data
- **THEN** the recipe detail includes calories, protein, carbohydrates, and fat per portion.

#### Scenario: Nutri-Score is available
- **WHEN** the selected recipe has a Nutri-Score
- **THEN** the recipe detail exposes the score for display beside the recipe title.

### Requirement: Serving scaling
The system MUST recalculate ingredient quantities when the serving count changes.

#### Scenario: Serving count increases
- **WHEN** a recipe for 3 people is changed to 4 people
- **THEN** every scalable ingredient quantity is updated proportionally and marked ready for basket recalculation.

### Requirement: Constraint application
The system MUST apply user constraints to recipe generation and recipe modification.

#### Scenario: User excludes an ingredient
- **WHEN** the user excludes an ingredient from the recipe
- **THEN** the system removes it or proposes a compatible replacement before rebuilding the basket.

#### Scenario: Budget is too low
- **WHEN** no realistic recipe can satisfy the requested budget
- **THEN** the system explains the conflict and proposes the closest lower-cost alternatives.

### Requirement: No home stock management
The system MUST NOT require or maintain home-stock state to generate recipes or baskets.

#### Scenario: Basket is built
- **WHEN** the system calculates ingredient needs for a recipe
- **THEN** it calculates the full shopping requirement without subtracting fridge, pantry, barcode, or consumed-stock data.

### Requirement: Ingredient and step completion state
The system MUST allow the mobile client to track ingredient and preparation-step completion state locally for the active recipe view.

#### Scenario: User checks an ingredient row
- **WHEN** the user marks an ingredient as complete in the recipe detail
- **THEN** the client visually marks that row complete without changing shopping requirements.

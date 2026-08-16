## ADDED Requirements

### Requirement: Four-tab mobile navigation
The mobile app MUST provide Assistant, Mes repas, Panier, and Parametres as primary tabs.

#### Scenario: User changes tabs
- **WHEN** the user taps a primary tab
- **THEN** the app shows that tab without losing the current recipe or basket state.

#### Scenario: Navigation copy is localized
- **WHEN** the bottom navigation is displayed
- **THEN** the tab labels are shown in French as Assistant, Mes repas, Panier, and Parametres.

### Requirement: Assistant-first entry screen
The mobile app MUST open on the Assistant experience for the MVP.

#### Scenario: App starts
- **WHEN** the user launches the app
- **THEN** the Assistant tab is visible and ready for a meal request.

### Requirement: Maquette design system
The mobile app MUST implement the supplied maquette design tokens for color, typography, spacing, radius, cards, chips, bottom navigation, and minimum touch targets.

#### Scenario: Core screen renders
- **WHEN** any MVP screen is displayed
- **THEN** it uses the maquette primary blue, secondary orange CTA color, Inter typography, soft surface cards, 16 px page padding, and touch targets of at least 48 px where practical.

### Requirement: Top app bar Drive context
The mobile app MUST show the Assistant Cuisine brand and the active Leclerc Drive context on primary screens.

#### Scenario: Preferred Drive is Pessac
- **WHEN** the user has Pessac as preferred Drive
- **THEN** the top app bar shows Assistant Cuisine and Pessac with a location or dropdown affordance.

### Requirement: Visual recipe proposals
The mobile app MUST display recipe proposals with visual, scannable elements instead of long assistant-only messages.

#### Scenario: Assistant returns proposals
- **WHEN** recipe proposals are available
- **THEN** the Assistant tab shows a horizontal carousel of selectable proposal cards with image, title, cost estimate, prep time, servings, optional Nutri-Score, Voir action, and Choisir action.

### Requirement: Assistant input and quick chips
The mobile app MUST provide the maquette assistant input area with quick chips and send controls.

#### Scenario: Assistant is ready for input
- **WHEN** the Assistant tab is visible
- **THEN** the bottom input area shows quick chips such as Ce soir, Semaine, Petit budget, and Rapide, plus a text input and send action.

### Requirement: Recipe detail bottom sheet
The mobile app MUST present recipe detail in a maquette-aligned bottom sheet.

#### Scenario: User taps Voir on a proposal
- **WHEN** the user opens recipe detail
- **THEN** the app shows a bottom sheet with hero image, close action, title, Nutri-Score when available, servings, duration, nutrition data when available, ingredient rows, preparation steps, chef tips, estimated basket price, and Preparer le panier CTA.

### Requirement: Basket review screen
The mobile app MUST show selected Leclerc products, prices, quantities, alternatives, and total in the Panier tab.

#### Scenario: Basket is ready
- **WHEN** the backend returns a basket proposal
- **THEN** the Panier tab lists a recipe hero, each product line with image, category, product title, price, selected state, Changer action, basket total, Ajouter au panier Leclerc CTA, and assistant follow-up input.

### Requirement: Preferences controls
The mobile app MUST provide editable controls for MVP preferences.

#### Scenario: User edits preferences
- **WHEN** the user changes preferred Drive, people count, weekly budget, default diet mode, kitchen equipment, dietary restrictions, excluded ingredients, notifications, or promotions
- **THEN** the app saves the updated preference profile through the backend API.

### Requirement: Mes repas planning surface
The mobile app MUST keep the Mes repas tab compatible with the supplied weekly planning maquette.

#### Scenario: Weekly planning is not yet functional
- **WHEN** the MVP does not include weekly planning generation
- **THEN** the Mes repas tab shows selected meal state or a clear placeholder that can evolve into the Ma semaine list without changing bottom navigation.

### Requirement: Integration states
The mobile app MUST display clear states for loading, empty content, errors, unavailable products, and unavailable cart handoff.

#### Scenario: Leclerc product search fails
- **WHEN** the backend reports a product-search failure
- **THEN** the app shows a recoverable error state and keeps the selected recipe visible.

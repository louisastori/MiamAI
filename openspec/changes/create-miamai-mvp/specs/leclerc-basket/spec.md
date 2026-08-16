## ADDED Requirements

### Requirement: Real Leclerc product source
The system MUST use product names, references, package sizes, prices, and availability from the configured Leclerc Drive product source.

#### Scenario: Ingredient requires product matching
- **WHEN** a recipe requires 600 g of chicken
- **THEN** the system searches the selected Leclerc Drive source and returns matching available product offers instead of inventing a product.

### Requirement: Ingredient-to-product matching
The system MUST match ingredient requirements to product offers with enough quantity to cover the recipe need.

#### Scenario: Product package exceeds required quantity
- **WHEN** the recipe requires 600 g and the selected product package contains 650 g
- **THEN** the basket line shows one package, the package size, the total price, and the quantity overage.

### Requirement: Product alternatives
The system MUST provide replacement alternatives for basket lines when multiple relevant products are available.

#### Scenario: User changes a product
- **WHEN** the user taps Changer on a basket line
- **THEN** the system shows alternative products with names, package sizes, prices, and availability.

### Requirement: Product line presentation data
The system MUST expose display fields required by the maquette for basket product lines.

#### Scenario: Basket line is returned
- **WHEN** the backend returns a selected product for an ingredient
- **THEN** the basket line includes ingredient category, product title, product image URL when available, price, selected state, quantity, and replacement availability.

### Requirement: Basket recalculation
The system MUST recalculate basket lines and totals after recipe, serving, budget, or product changes.

#### Scenario: User chooses a cheaper alternative
- **WHEN** the user selects a cheaper valid product alternative
- **THEN** the basket line and total price are updated.

#### Scenario: Serving count changes
- **WHEN** the selected recipe serving count changes
- **THEN** product quantities and basket total are recalculated from the updated ingredient requirements.

### Requirement: Basket validation
The system MUST validate that each required ingredient has a selected available product before cart handoff.

#### Scenario: Required product is unavailable
- **WHEN** at least one required ingredient has no selected available product
- **THEN** the system blocks cart handoff and identifies the unresolved basket line.

### Requirement: Leclerc cart handoff
The system MUST prepare the selected products and quantities for Leclerc Drive cart handoff.

#### Scenario: Cart handoff succeeds
- **WHEN** the basket is valid and the configured Leclerc integration supports cart insertion
- **THEN** the selected product references and quantities are sent to Leclerc Drive.

#### Scenario: Cart handoff is unavailable
- **WHEN** the basket is valid but the configured Leclerc integration cannot insert products into the cart
- **THEN** the system shows a clear unavailable state and preserves the validated product list.

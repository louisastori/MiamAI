## 1. Product Scope And UX Alignment

- [x] 1.1 Review the added maquette files and map each screen to Assistant, Mes repas, Panier, and Parametres flows.
- [x] 1.2 Confirm MVP scope boundaries: one selected recipe, Leclerc product matching, basket review, and no home-stock management.
- [x] 1.3 Define the primary happy path from chat prompt to Leclerc basket handoff.
- [x] 1.4 Define empty, loading, error, and unavailable-integration states for every MVP screen.
- [x] 1.5 Normalize maquette copy to French labels: Assistant, Mes repas, Panier, Parametres, Preparer le panier, and Ajouter au panier Leclerc.
- [x] 1.6 Decide whether the `Ma semaine` maquette is a read-only MVP surface or a post-MVP functional planning flow.
- [x] 1.7 Document post-MVP backlog items separately: weekly optimization, multi-recipe ingredient consolidation, favorites, history, scheduled notifications, and meal prep enhancements.

## 2. Repository And Project Setup

- [x] 2.1 Create the Flutter mobile project structure.
- [x] 2.2 Create the Spring Boot API project structure.
- [x] 2.3 Add local development configuration for mobile, backend, mocked AI provider, and mocked Leclerc adapter.
- [x] 2.4 Add shared API contract documentation for mobile-backend payloads.
- [x] 2.5 Add formatting, linting, and test commands for both projects.

## 3. Backend Domain Model

- [x] 3.1 Model conversation sessions and assistant turns.
- [x] 3.2 Model recipe proposals, selected recipes, servings, prep time, budget target, and recipe tags.
- [x] 3.3 Model recipe detail fields from the maquette: hero image metadata, Nutri-Score, nutrition per portion, preparation steps, chef tips, and estimated basket cost.
- [x] 3.4 Model ingredient requirements with normalized names, quantities, units, optional replacement rules, and local completion state identifiers.
- [x] 3.5 Model Leclerc product offers with product reference, title, image URL, package size, unit price, total price, availability, and source Drive.
- [x] 3.6 Model basket lines, selected alternatives, quantities, subtotal, total price, overage, display category, and recalculation status.
- [x] 3.7 Model user preferences for preferred Drive, people count, weekly budget, default diet mode, dietary restrictions, excluded ingredients, kitchen equipment, notification toggles, and promotion toggle.
- [x] 3.8 Model a future weekly meal plan surface without implementing shared-basket optimization.

## 4. Backend API

- [x] 4.1 Add endpoint to start or continue an assistant conversation.
- [x] 4.2 Add endpoint to select a recipe proposal.
- [x] 4.3 Add endpoint to update servings, budget, ingredient exclusions, or replacement requests.
- [x] 4.4 Add endpoint to fetch selected recipe detail.
- [x] 4.5 Add endpoint to build or refresh the Leclerc basket for a recipe.
- [x] 4.6 Add endpoint to replace one basket product with an alternative.
- [x] 4.7 Add endpoint to validate basket contents before Leclerc handoff.
- [x] 4.8 Add endpoint to read and update user preferences.
- [x] 4.9 Add read endpoint for Mes repas selected-meal state or weekly-plan placeholder data.

## 5. AI Provider Orchestration

- [ ] 5.1 Define a provider-neutral AI interface for chat turns and structured tool calls.
- [ ] 5.2 Implement a mocked AI provider for deterministic local development and tests.
- [ ] 5.3 Implement OpenAI provider wiring behind the common interface.
- [ ] 5.4 Add extension points for Gemini and local/Ollama-style providers.
- [ ] 5.5 Define structured tool schemas for recipe proposal, recipe modification, product search request, and basket recalculation request.
- [ ] 5.6 Add backend validation that rejects malformed AI recipe or tool-call outputs.
- [ ] 5.7 Add tests proving backend calculations do not depend on free-form AI text.

## 6. Recipe Management

- [x] 6.1 Generate multiple recipe proposals from a natural-language prompt and user preferences.
- [x] 6.2 Display structured recipe details with hero image, Nutri-Score, nutrition, ingredients, quantities, servings, steps, chef tips, prep time, and estimated basket cost.
- [x] 6.3 Scale ingredient quantities when the number of people changes.
- [ ] 6.4 Apply user constraints such as cuisine type, disliked foods, prep time, and budget.
- [x] 6.5 Recalculate recipe state after commands such as "moins cher", "remplace le poulet", "on sera 4", and "enleve les champignons".
- [x] 6.6 Track ingredient and preparation-step completion locally in the mobile recipe detail without changing basket requirements.
- [x] 6.7 Add tests for quantity scaling, exclusion handling, replacement handling, and budget-aware recalculation.

## 7. Leclerc Product Matching And Basket

- [x] 7.1 Define the Leclerc adapter interface for Drive selection, product search, product detail, price, availability, and cart handoff.
- [x] 7.2 Implement a mocked Leclerc adapter with realistic product references, package sizes, prices, and unavailable-product cases.
- [x] 7.3 Match each ingredient requirement to one or more real product offers from the selected Drive and return maquette display data for product lines.
- [x] 7.4 Select package quantities that cover required ingredient amounts while showing overage where relevant.
- [x] 7.5 Rank product alternatives by relevance, total price, package size, and availability.
- [x] 7.6 Recalculate basket totals after product replacement, serving changes, budget changes, or ingredient substitutions.
- [x] 7.7 Prevent basket validation when a required ingredient has no selected available product.
- [x] 7.8 Implement Leclerc cart handoff behavior for the available integration mode.
- [x] 7.9 Add tests for matching, alternatives, totals, unavailable products, and basket validation.

## 8. Flutter Mobile App

- [x] 8.1 Translate `Maquette/stitch_assistant_cuisine_leclerc_drive/culinary_interface_system/DESIGN.md` into a Flutter theme with primary blue, secondary orange, surface colors, Inter typography, radii, spacing, chips, and 48 px touch targets.
- [x] 8.2 Build reusable Flutter components for top app bar, bottom navigation, assistant bubble, recipe card, quick chip, bottom sheet, sticky action bar, product basket line, toggle row, and preference card.
- [x] 8.3 Build the four-tab mobile shell: Assistant, Mes repas, Panier, and Parametres.
- [x] 8.4 Build Assistant chat UI matching the maquette: timestamp chip, user bubble, assistant bubble, horizontal recipe carousel, Voir and Choisir actions, quick chips, microphone action, text input, and send button.
- [x] 8.5 Build recipe detail bottom sheet matching the enriched maquette: image header, close button, title, Nutri-Score, people, duration, nutrition block, ingredient rows, preparation timeline, chef tips, estimated basket price, and Preparer le panier action.
- [x] 8.6 Build Mes repas tab as selected-meal state or weekly planning placeholder aligned with the Ma semaine maquette.
- [x] 8.7 Build Panier tab matching the maquette: title, helper text, recipe hero, product rows with images, prices and selected badges, Changer actions, total, Ajouter au panier Leclerc CTA, and assistant follow-up input.
- [x] 8.8 Build product replacement UI with "Changer" alternatives.
- [x] 8.9 Build Parametres tab matching the maquette: Drive card, people stepper, weekly budget input, default diet select, kitchen equipment toggles, notification toggles, dietary restriction toggles, excluded ingredients input, and about section.
- [x] 8.10 Connect mobile screens to backend APIs with typed client models.
- [x] 8.11 Add mobile error handling for AI provider failure, Leclerc unavailable products, and cart handoff failure.
- [ ] 8.12 Add widget tests for core screens, localized tab labels, and state transitions.

## 9. Verification And Delivery

- [x] 9.1 Add backend unit tests for domain calculations and provider adapters.
- [x] 9.2 Add backend integration tests for the chat-to-recipe-to-basket flow with mocked providers.
- [ ] 9.3 Add mobile integration test for the happy path from prompt to basket review.
- [x] 9.4 Add documentation for local setup, environment variables, and mock integration profiles.
- [ ] 9.5 Run the full mobile and backend validation commands.
- [x] 9.6 Update OpenSpec task statuses as implementation progresses.

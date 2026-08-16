## Why

MiamAI needs a scoped MVP that turns the product concept into a buildable contract: chat, recipe selection, Leclerc product matching, and basket preparation. The first milestone must validate the core promise without adding home inventory complexity.

## What Changes

- Introduce a chat-first culinary assistant for meal requests, recipe proposals, and natural-language changes.
- Generate structured recipes with servings, budget, prep time, ingredients, quantities, and preparation steps.
- Search and select real Leclerc Drive products for recipe ingredients, including prices, package sizes, alternatives, and basket totals.
- Add a mobile app shell aligned with the supplied maquette: Assistant, Mes repas, Panier, and Parametres tabs.
- Add maquette-driven UI components: top app bar with Drive selector, recipe carousel, quick prompt chips, recipe detail bottom sheet, basket lines, sticky basket actions, and preference cards.
- Store user preferences such as default people count, weekly budget, default diet mode, dietary restrictions, excluded ingredients, kitchen equipment, notification toggles, promotion toggle, and preferred Drive.
- Add an AI-provider abstraction so OpenAI, Gemini, and local Ollama-style providers can be integrated behind the same backend contract.
- Keep home stock management out of scope for the MVP.
- Keep the weekly planning screen captured in the maquette as a next-phase surface unless the MVP scope is explicitly expanded.

## Capabilities

### New Capabilities

- `assistant-chat`: Natural-language assistant flow, recipe proposal conversation, quick prompts, and modification commands.
- `recipe-management`: Recipe generation, recipe detail, ingredient quantities, serving scaling, and budget-aware recipe state.
- `leclerc-basket`: Product search, product matching, alternative selection, basket calculation, and Leclerc cart handoff.
- `user-preferences`: Persistent culinary, budget, people-count, diet, equipment, notification, exclusion, and Drive preferences.
- `ai-provider-orchestration`: Provider-agnostic AI integration and backend tool/function execution.
- `mobile-app-shell`: Flutter mobile navigation, maquette-aligned core screens, states, and visual presentation for the MVP.

### Modified Capabilities

- None.

## Impact

- New Flutter mobile application structure.
- New Spring Boot API and domain model for conversations, recipes, ingredients, products, baskets, and preferences.
- Maquette assets under `Maquette/stitch_assistant_cuisine_leclerc_drive` become the UI reference for tokens, layout, copy, and component states.
- External integrations for AI providers and Leclerc Drive product/cart access.
- Test coverage for recipe scaling, basket calculation, product matching, provider abstraction, and mobile core flows.

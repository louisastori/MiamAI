## Context

MiamAI is a mobile culinary assistant. The user describes what they want to eat, the assistant proposes recipes, and the system prepares the corresponding Leclerc Drive basket. The MVP focuses on a single selected recipe and the associated basket flow. Weekly planning, multi-recipe optimization, favorites, history, and notifications are future extensions.

The target stack is Flutter for mobile and Spring Boot for the API. The backend owns deterministic operations such as recipe state, ingredient quantities, product search, product matching, basket totals, and external integrations. AI providers only produce or modify structured culinary intent through backend-controlled tools.

The supplied maquette is located at `Maquette/stitch_assistant_cuisine_leclerc_drive`. It defines the visual system and six screen references: assistant chat, recipe detail, enriched recipe detail, intelligent basket, settings, and weekly planning.

## Goals / Non-Goals

**Goals:**

- Deliver the first complete path from chat request to Leclerc basket proposal.
- Implement the MVP screens using the maquette design language and mobile component structure.
- Keep AI-provider usage replaceable across OpenAI, Gemini, and local model providers.
- Make product and price data traceable to the selected Leclerc Drive integration.
- Make the mobile UI usable from the first screen through chat, recipe selection, basket review, and preferences.

**Non-Goals:**

- Track home stock, fridge contents, barcode scans, or consumed ingredients.
- Optimize multiple meals into a shared weekly basket in the MVP, unless the scope is expanded after maquette review.
- Build social features, public recipe sharing, favorites, scheduled notifications, or long-term meal history in the MVP.
- Let the AI invent product names, prices, package sizes, or Leclerc availability.

## Decisions

1. Flutter mobile app with four top-level tabs

   The app will use Assistant, Mes repas, Panier, and Parametres as the primary mobile navigation. This matches the maquette and keeps the MVP workflow visible without requiring a landing page.

   Alternative considered: a pure chat interface. Rejected because basket review, recipe detail, and preferences need stable visual surfaces.

2. Spring Boot API as orchestration boundary

   The mobile app will call a backend API for chat turns, recipe selection, product matching, basket updates, and preferences. The backend will isolate AI providers and Leclerc integration details from the mobile client.

   Alternative considered: direct mobile calls to AI and Leclerc services. Rejected because it exposes credentials, duplicates business logic, and makes provider replacement harder.

3. Structured recipe and basket model

   The backend will model recipes, ingredient requirements, product offers, basket lines, alternatives, and totals as explicit data structures. AI output must be parsed or requested as structured data before basket calculation.

   Alternative considered: free-form recipe text only. Rejected because quantities, substitutions, budget checks, and product matching require deterministic fields.

4. Provider-agnostic AI interface

   The backend will define an AI provider interface with implementations for OpenAI, Gemini, and local/Ollama-style providers. Providers will return assistant messages and structured tool requests through a common contract.

   Alternative considered: build only against one provider first. Rejected because the concept explicitly requires avoiding dependency on a single AI vendor.

5. Leclerc integration behind an adapter

   Product search, availability, prices, package sizes, and cart handoff will be accessed through a Leclerc adapter interface. The MVP can start with the best available connector or controlled mock, but the product contract must distinguish real Drive data from unavailable or mocked data.

   Alternative considered: hard-coded product catalog. Rejected for production behavior because MiamAI must use real products and prices.

6. Maquette design tokens as the Flutter theme baseline

   The Flutter app will translate the maquette `DESIGN.md` into theme tokens for color, typography, radius, spacing, cards, chips, bottom bars, and touch targets. The app copy will be normalized in French even where the maquette exports still contain English labels such as `My Meals`, `Cart`, or `Settings`.

   Alternative considered: treat the HTML export as implementation source. Rejected because the product target is Flutter, and the HTML is useful as a visual reference rather than app code.

7. Weekly planning as a next-phase screen unless explicitly pulled into MVP

   The maquette includes a `Ma semaine` screen with 5 meals and a `Creer le panier` action. The first MVP will keep the Mes repas tab compatible with this direction, but shared weekly basket optimization remains outside the first build unless the scope changes.

   Alternative considered: implement weekly planning immediately. Deferred because it requires multi-recipe optimization, ingredient consolidation, and additional basket logic.

## Risks / Trade-offs

- Leclerc Drive API access may be unofficial, unstable, or unavailable -> isolate it behind an adapter, add clear failure states, and avoid coupling the mobile app to scraping details.
- AI output may be inconsistent -> require structured schemas, backend validation, and deterministic recalculation after each change.
- Budget compliance may be imperfect before real product prices are known -> show estimated recipe cost before product matching and exact basket total after Leclerc matching.
- Local AI models may not support tool calling reliably -> keep provider capabilities explicit and add fallback prompting/parsing paths per provider.
- Add-to-cart automation may require browser/session constraints -> model cart handoff separately from product matching so the MVP can degrade clearly when direct insertion is unavailable.
- The maquette includes post-MVP preferences such as notification scheduling and Leclerc promotions -> store simple toggles only if needed, and avoid building background notification infrastructure in the MVP.
- The exported maquette mixes French and English labels -> define canonical French labels before implementation and verify copy in UI tests.

## Migration Plan

1. Create the Flutter and Spring Boot project skeletons.
2. Implement mocked AI and mocked Leclerc adapters first to validate the end-to-end contract.
3. Add real provider implementations behind the same interfaces.
4. Replace the Leclerc mock with real Drive search/cart integration once credentials and access method are confirmed.
5. Keep feature flags or environment profiles for mock, staging, and real integrations.

## Open Questions

- Which Leclerc Drive access method will be available: official API, partner integration, web automation, or another provider?
- Which database should back user preferences and conversation state for the first deployed version?
- Should authentication exist in the MVP, or can the first internal build use a local/device profile?
- Should `Ma semaine` be built as a read-only/placeholder tab in the MVP, or as a functional weekly planning flow?
- Should notification and promotion toggles be persisted in MVP even if notification delivery is deferred?
- Which recipe detail variant should be canonical: collapsible preparation steps or always-visible timeline?

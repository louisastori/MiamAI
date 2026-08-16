---
name: Culinary Interface System
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#414753'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#727784'
  outline-variant: '#c1c6d5'
  surface-tint: '#005cba'
  primary: '#004e9f'
  on-primary: '#ffffff'
  primary-container: '#0066cc'
  on-primary-container: '#dfe8ff'
  inverse-primary: '#aac7ff'
  secondary: '#8f4d00'
  on-secondary: '#ffffff'
  secondary-container: '#ff8e04'
  on-secondary-container: '#623300'
  tertiary: '#005e27'
  on-tertiary: '#ffffff'
  tertiary-container: '#007934'
  on-tertiary-container: '#98ffa9'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d7e3ff'
  primary-fixed-dim: '#aac7ff'
  on-primary-fixed: '#001b3e'
  on-primary-fixed-variant: '#00458e'
  secondary-fixed: '#ffdcc2'
  secondary-fixed-dim: '#ffb77b'
  on-secondary-fixed: '#2e1500'
  on-secondary-fixed-variant: '#6d3a00'
  tertiary-fixed: '#6bff8f'
  tertiary-fixed-dim: '#4ae176'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005321'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-bold:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
  chat-bubble:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  container-padding: 16px
  gutter: 12px
---

## Brand & Style

The design system is centered on a **Modern-Professional** aesthetic that balances the efficiency of a utility tool with the warmth of a kitchen companion. It prioritizes high legibility and a welcoming interface to reduce the cognitive load of cooking and shopping.

The style leverages **soft-minimalism**—using generous whitespace, soft-edged containers, and a card-based architecture to organize complex data into digestible chunks. The interface should feel "helpful" rather than "robotic," achieving this through smooth transitions and a conversational, chat-inspired layout for interactions.

## Colors

This design system utilizes a high-contrast palette to ensure accessibility in bright kitchen environments.

- **Primary (Leclerc Blue):** Used for primary actions, navigation headers, and brand signifiers.
- **Secondary (Orange):** Reserved for high-intent call-to-actions, notifications, and "Add to Cart" triggers.
- **Tertiary (Success Green):** Specifically for completion states, recipe success, and validated items.
- **Surface & Background:** The background is a crisp `#F8FAFC`, providing a neutral stage that makes product images and recipe photography pop. 
- **Neutral Grays:** Used for borders (`#E2E8F0`) and secondary metadata to maintain a clean hierarchy.

## Typography

The system uses **Inter** exclusively to ensure a systematic, neutral, and highly readable experience. 

- **Headlines:** Use a tighter letter-spacing and bold weights to create clear section anchoring.
- **Body:** Standardized at 16px for optimal readability on mobile devices at arm's length (typical for kitchen use).
- **Chat Elements:** A specific `chat-bubble` token is defined to handle conversational UI, ensuring text remains legible within constrained container widths.
- **Scale:** On mobile devices, `headline-lg` should downscale to `headline-lg-mobile` to prevent awkward word wrapping.

## Layout & Spacing

This is a **mobile-first, fluid layout** designed for one-handed operation. 

- **Grid:** Use a 4-column fluid grid for mobile and an 8-column grid for tablets.
- **Safe Zones:** Maintain a 16px (`md`) margin on the left and right of the screen for all text content.
- **Vertical Rhythm:** Use the 8px baseline. Elements like list items and cards should be separated by `md` (16px) spacing, while grouped items (like ingredients in a list) use `sm` (8px).
- **Interactive Areas:** All buttons and touch targets must have a minimum height of 48px to ensure ease of use while multitasking.

## Elevation & Depth

Visual hierarchy is achieved through **Tonal Layering** and soft **Ambient Shadows**.

- **Level 0 (Background):** `#F8FAFC` flat.
- **Level 1 (Cards/Bubbles):** White (`#FFFFFF`) with a subtle 4px blur, 2% opacity black shadow. This is the primary surface for recipe cards and chat bubbles.
- **Level 2 (Active/Floating):** White (`#FFFFFF`) with a 12px blur, 8% opacity shadow. Used for floating action buttons (e.g., "Start Cooking") and active modals.
- **Glass Effects:** Use a subtle backdrop blur (blur-md) on top navigation bars and bottom sticky actions to maintain context of the content scrolling underneath.

## Shapes

The design system uses a high roundedness factor to evoke friendliness and safety.

- **Standard Elements:** Buttons, input fields, and small cards use `rounded-lg` (16px).
- **Containers:** Large recipe cards and modal sheets use `rounded-xl` (24px) to create a soft, modern enclosure.
- **Chat Bubbles:** Use a distinctive 20px radius, with the "tail" corner reduced to 4px to indicate the speaker.

## Components

- **Buttons:** Primary buttons use the Leclerc Blue with white text. "Add to Cart" or "Buy" actions use the secondary Orange. Both feature a 16px corner radius and 56px height on mobile.
- **Cards:** Recipe and product cards should use a vertical stack: Image (top), Title (middle), and Metadata/Price (bottom). Use a subtle 1px border (`#E2E8F0`) instead of heavy shadows for a cleaner look.
- **Chat Interface:** User messages are Primary Blue with White text (right-aligned). Assistant messages are White with Black text (left-aligned), utilizing the Level 1 shadow.
- **Lists:** Ingredients and shopping lists use a "checkbox-left" alignment. Tapping the row toggles the completion state (strikethrough and Tertiary Green checkmark).
- **Input Fields:** Search and quantity inputs should be rounded (16px) with a light gray background (`#F1F5F9`) to clearly distinguish them from static text containers.
- **Progress Indicators:** When in "Cooking Mode," use a prominent horizontal progress bar at the top of the screen in Secondary Orange.
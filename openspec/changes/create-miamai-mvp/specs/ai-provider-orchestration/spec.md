## ADDED Requirements

### Requirement: Provider-neutral AI interface
The backend MUST expose a common interface for AI providers used by assistant chat and recipe generation.

#### Scenario: Provider is changed by configuration
- **WHEN** the configured AI provider changes from OpenAI to Gemini or local
- **THEN** the mobile API contract and domain services continue to use the same backend interface.

### Requirement: Tool-controlled backend operations
The AI layer MUST request backend operations through explicit tools/functions instead of directly changing persisted recipe or basket state.

#### Scenario: AI requests product search
- **WHEN** the assistant needs product prices for a recipe
- **THEN** it calls the backend product-search tool and uses returned product data.

### Requirement: Deterministic validation
The backend MUST validate AI outputs before using them for recipes, product matching, or basket calculation.

#### Scenario: AI returns malformed ingredient data
- **WHEN** an AI provider returns an ingredient without quantity or unit
- **THEN** the backend rejects or repairs the response before basket calculation starts.

### Requirement: Provider capability reporting
The system MUST represent provider capabilities such as tool calling, JSON output, and local execution support.

#### Scenario: Provider lacks native tool calling
- **WHEN** the selected provider cannot call tools natively
- **THEN** the orchestration layer uses the configured fallback strategy or reports that the requested flow is unavailable.

### Requirement: AI failure handling
The system MUST return recoverable errors when an AI provider fails.

#### Scenario: Provider timeout
- **WHEN** the configured AI provider times out during a chat turn
- **THEN** the API returns an error state that the mobile app can display without losing the active conversation.

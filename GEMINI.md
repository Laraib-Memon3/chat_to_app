# Architectural Rules & Project Standards

## 1. CLEAN Architecture Layers
The project must follow a **Feature-based CLEAN Architecture** (each feature contains its own 3 layers):

### 1.1 Presentation Layer (UI & State)
- **BLoC:** Handles UI events and manages state.
- **Widgets/Screens:** Purely declarative UI. No business logic here.
- **State:** Immutable objects representing the current graph and chat history.

### 1.2 Domain Layer (Business Logic)
- **Entities:** Pure Dart classes for `Node`, `Edge`, and `Project`. No dependencies on Flutter or JSON.
- **Use Cases:** Atomic classes for specific actions (e.g., `ProcessWorkflowPrompt`, `SaveProjectLayout`).
- **Repository Interfaces:** Abstract definitions of how data is fetched or saved.

### 1.3 Data Layer (External Sources)
- **Repositories:** Implementations of Domain interfaces.
- **Data Sources:** 
  - `OpenRouterService`: Handles the REST API calls via `Dio`.
  - `LocalStorageService`: Handles `HydratedBloc` persistence.
- **Models (DTOs):** JSON-serializable classes (e.g., `NodeModel.fromJson`). Must be mapped to Domain Entities before reaching the BLoC.

## 2. Core Principles
- **Dependency Rule:** Dependencies must only point **inwards** (Presentation -> Domain <- Data). The Domain layer must have zero dependencies on other layers.
- **Single Source of Truth:** The `WorkflowBloc` state is the absolute authority for the UI.
- **Feature-First Structure:** 
  - `lib/features/workflow/` (Presentation, Domain, Data)
  - `lib/core/` (Common utilities, Theme, Error handling)

## 3. Data Models & Entities
- **Node Entity:** `String id`, `String label`, `NodeShape shape`, `Offset position`.
- **Edge Entity:** `String source`, `String target`, `String? label`.
- **Shape Enum:** `rectangle`, `roundedRectangle`, `stadium`, `diamond`.

## 4. OpenRouter & Prompt Engineering
- **System Prompt:** Force the model to return ONLY a structured JSON "Diff".
- **Context Management:** Always provide the current simplified Graph Entity to OpenRouter to ensure consistency in IDs and relationships.

## 5. Diagram Rendering & Layout
- **Custom Shapes:** Use `CustomPainter` for the 4 required shapes to ensure geometric precision.
- **Position Preservation:** 
  - The BLoC calculates new node positions based on parent anchors.
  - User-dragged positions (UI) must be synced back to the BLoC state via a `NodeMoved` event.

## 6. Coding Standards
- **Immutability:** Use `freezed` or `copywith` for all entities, models, and states.
- **Error Handling:** Use a `Failure` class in the Domain layer to propagate errors (e.g., `ApiFailure`, `JsonParsingFailure`).
- **Styling:** "Modern Tech" aesthetic (Soft shadows, Bézier edges, Dot grid background).

## 7. Testing Requirements
- **Unit Tests:** 100% coverage for Domain Use Cases and Entity mapping.
- **Bloc Tests:** Comprehensive tests for graph mutations and project switching.

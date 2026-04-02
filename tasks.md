# Implementation Tasks: Chat-to-Diagram

## Phase 1: Foundation & Core Setup
- [x] Initialize Flutter Web project (`chat_to_diagram`).
- [x] Add dependencies: `flutter_bloc`, `hydrated_bloc`, `dio`, `freezed`, `graphview`, `uuid`, `path_drawing`, `google_fonts`.
- [x] Configure `GEMINI.md` and folder structure (Features: `workflow`, `canvas`, `chat`).
- [x] Setup Global Theme (Modern Tech: Dark/Light mode, Dot grid background constants).

## Phase 2: Domain Layer (Entities & Use Cases)
- [x] Define `Node` and `Edge` Entities (ID, Label, Shape, Position).
- [x] Define `WorkflowProject` Entity (ID, Title, Messages, Graph).
- [x] Create `WorkflowRepository` abstract interface.
- [x] Create Use Case: `ProcessUserPrompt` (Communicates with AI to get graph changes).
- [x] Create Use Case: `UpdateNodePosition` (Logic for manual drags).

## Phase 3: Data Layer (Infrastructure)
- [x] Implement `OpenRouterServiceClient` using `Dio`.
- [x] Create `SystemPrompt` for OpenRouter (strict JSON Diff output instructions).
- [x] Implement `WorkflowRepositoryImpl` (Handles API calls and DTO-to-Entity mapping).
- [x] Create `NodeModel` and `EdgeModel` DTOs with `fromJson`/`toJson`.

## Phase 4: Presentation Layer - BLoC (State Management)
- [x] Setup `WorkflowBloc` with `HydratedBloc` for persistence.
- [x] Implement `WorkflowEvent` handlers:
    - `ProjectSwitched`, `ProjectCreated`, `ProjectDeleted`.
    - `MessageSent` (Triggers OpenRouter flow).
    - `NodeMoved` (Updates Offset in state).
- [x] Implement `WorkflowState` with support for loading, error, and multi-session data.

## Phase 5: Presentation Layer - Diagram Canvas (UI)
- [x] Create `ShapePainter` (CustomPainter for Rectangle, Rounded-Rect, Stadium, Diamond).
- [x] Implement `DiagramCanvas` using `graphview`.
- [x] Integrate "Initial Auto-Layout" (Sugiyama/Tree algorithm).
- [x] Implement "Position Preservation" logic (Rendering nodes at their stored `Offset`).
- [x] Add Zoom and Pan interactivity.

## Phase 6: Presentation Layer - Chat & Sidebar (UI)
- [x] Create `Sidebar` for Project History/Sessions.
- [x] Create `ChatPanel` with scrollable message bubbles.
- [x] Implement `Markdown` support for AI responses.
- [x] Add loading animations (shimmer/spinners) during OpenRouter processing.

## Phase 7: Integration & Logic Refinement
- [x] Connect Chat Input to BLoC -> Use Case -> OpenRouter.
- [x] Implement "Graph Diffing" logic (Applying `ADD`, `DELETE`, `UPDATE` to the state).
- [x] Handle AI errors (Invalid JSON) with user-friendly feedback.
- [x] Add "Export to PNG/SVG" functionality.

## Phase 8: Testing & Polish
- [x] Write `blocTest` for session switching and graph mutations.
- [x] Write Unit Tests for `ShapePainter` paths.
- [x] Visual Polish: 
    - Smooth Bézier curves for edges.
    - Glow effects on selected nodes.
    - Animated transitions when the graph changes.

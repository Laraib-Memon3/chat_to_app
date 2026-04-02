Login & Registration Flow Diagram App
Overview
This project is a Chrome‑based app that uses an AI model to generate and explain flow diagrams.
It was built to help visualize and understand the flow of a login and registration system.

Features
Flow Diagram Generation

When prompted with:

Code

Copy
I have an app that has login and registration. Make a flow diagram of it.
The AI model returns a JSON flow diagram, which the app renders directly in Chrome.

Diagram Explanation

When prompted with:

Code


Copy
Explain the flow diagram.
The AI model should return a plain text explanation of the diagram.

The app displays this text instead of trying to render JSON.

Issue Encountered
Initial Behavior:

Prompt: "I have an app that has login and registration. Make a flow diagram of it."

Response: Valid JSON diagram → rendered correctly.

Problem:

Prompt: "Explain the flow diagram."

Response: Model returned JSON again.

Since the app tried to render JSON as a diagram, it caused an Invalid JSON Format error.

Resolution
The app now distinguishes between two modes:

Diagram Mode: JSON output only.

Explanation Mode: Plain text output only.

This ensures explanations are shown as text, not rendered as diagrams.

Usage
Run the app in Google Chrome.

Use clear prompts:

"Make a flow diagram" → JSON diagram rendered.

"Explain the flow diagram" → Text explanation displayed.

Do not mix formats in a single request.

Future Improvements
Add a mode toggle button in the UI (Diagram / Explanation).

Provide error handling when unexpected formats are returned.

Extend support for other app flows beyond login and registration.
# Contributing to Universal AI Rules & Skills Suite

First off, thank you for considering contributing! The goal of this project is to create the absolute best, most hardened set of AI rules in the world. We can only do that with the community's help.

## Design Philosophy (Please Read First)

Before submitting a Pull Request, please ensure your changes adhere to our core design principles:

1. **Checklist-First Format:** AI models respond best to binary, falsifiable rules. Do not write paragraphs of prose or vague principles like "write clean code". Use `[ ]` checkboxes for actionable items.
2. **Context Window Efficiency:** Context window is expensive. Files must remain small and focused (under 400 lines maximum). If a phase file gets too large, we split it.
3. **Security is Mandatory:** We enforce security and data validation in every single phase file. Do not remove the `Security Checkpoint` or `🛑 STOP GATE` sections.
4. **Model Agnostic:** Rules are designed to work for Cursor, Claude Code, Antigravity, and any other AI assistant. Avoid referencing editor-specific UI buttons or commands in the core `/.ai-suite/` files.

## How to Contribute

### 1. Reporting Issues, Bugs, or Rule Escapes
If you notice that an AI model consistently ignores a rule, or if there's a typo/error in the suite:
* Use the GitHub Issue Tracker.
* Describe what you asked the AI, which model/editor you used, what it actually did, and what rule failed to catch it.

### 2. Proposing New Rules or Adjustments
1. **Fork the repository** to your own GitHub account.
2. **Create a branch** for your feature (e.g., `git checkout -b feature/react-native-rules`).
3. **Make your changes** inside the `/.ai-suite/` directory. Keep formatting consistent with existing files.
4. **Commit your changes**. Please use Conventional Commits (e.g., `feat: add robust database migration rules` or `fix: correct typo in security gate`).
5. **Push your branch** to your fork.
6. **Open a Pull Request** against the `main` branch of this repository.

### 3. Adding Support for New Editors
If a new AI-powered code editor is released:
1. Create a setup guide/template in `.ai-suite/adapters/`.
2. Create a ready-to-use adapter file in `.ai-suite/ready/`.
3. Update `setup.sh` to include the new editor in its interactive menu.
4. Update `README.md`.

## Pull Request Guidelines

* Fill out the Pull Request template entirely.
* Explain *why* the rule change is necessary. Did an AI hallucinates a specific vulnerability? Did it skip a best practice? Providing context helps maintainers understand the value.
* Ensure you haven't made any file longer than 400 lines (we use scripts to check this).
* Any new phase file must be added to the routing table in `MASTER.md`.

We look forward to seeing your contributions!

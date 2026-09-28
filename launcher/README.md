# Launcher boundary

The original one-click launcher is intentionally kept local and is not included in this public repository. It contains machine-specific Codex installation paths, runtime state locations, and trusted-process checks that must be reviewed for each Windows installation.

The launcher should read `theme.json` and `theme.css` from one canonical theme directory each time it applies the theme. The approved appearance is version `0.1.31`: keep the artwork and palette, with no extra colored strips, white header fade, or outer window gutters.

Run the border checks and verify the live page after applying. A version number or an `active` marker alone does not verify appearance. A restart still requires explicit user approval; an already available debugging endpoint allows applying without restarting.

The public package contains portable theme files only. Keep using the launcher already installed locally, or prepare and review a separate launcher for your own environment.

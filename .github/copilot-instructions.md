# GitHub Copilot Instructions

This file defines the default conventions and expectations for all projects using this template. Follow these instructions unless a project-specific note overrides them.

---

## Folder Structure

Every project has three top-level folders:

```
Analyses/
    _archive/
    YYYYMMDD Brief Name/       # one subfolder per analysis
        _archive/
        Input/                 # raw input data (read-only)
            _archive/
        Intermediate/          # intermediate data files
            _archive/
        Logs/                  # run logs
            _archive/
        Output/                # final outputs and figures
            _archive/
        Programs/              # all code for this analysis
            _archive/
Notes/
    _archive/                  # Markdown notes (personal and AI-facing)
Research/
    _Topic/                    # one subfolder per research topic
        _sources.md            # list of sources with URLs and access dates
```

### Analyses
Each analysis lives in its own dated subfolder under `Analyses/`, named `YYYYMMDD Brief Name` (e.g., `20260330 Regression Sensitivities`). All code for an analysis goes in its `Programs/` subfolder.

### Notes
The `Notes/` folder is the source of truth for project context. It holds both personal notes and instructions for AI agents, saved as Markdown files. Search here first to understand the task at hand. You may also write new notes here to record findings or decisions made during analysis. AI agents can ignore non-Markdown files in this folder.

### Research
The `Research/` folder is a workspace for qualitative document review. Each subfolder covers a research topic and contains a `_sources.md` file listing every source with its URL and the date it was accessed.

---

## Standards and Practices

### Environment
- OS: Windows 11 (no administrator privileges).
- Python: use `uv` to manage virtual environments. Always work inside a `.venv` in the project folder.
- Use relative paths for all file access. Absolute paths are not allowed in the project unless absolutely necessary.

### Agent Standards
- When running terminal commands, you may not chain commands with `&&` or `;`. Each command must be run separately. You will be prevented from chaining commands.

### Code Quality
- Write concise, well-documented code. Prioritize clarity over cleverness.
- The user is a data scientist, not a software developer. Focus on:
  - Clear interpretation of results.
  - Sensitivity analyses where assumptions matter.
  - Readable, reproducible code.
- Unit tests are not required. Prefer in-script validation and documented assumptions.

### Version Control
- Use Git. Commit after every meaningful file edit or creation.
- Write clear, descriptive commit messages.
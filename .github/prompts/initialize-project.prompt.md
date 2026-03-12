---
name: initialize-project
description: Initialize a new project with the necessary files and structure.
agent: agent
tools: [vscode/newWorkspace, vscode/askQuestions, read/readFile, edit/createDirectory, edit/createFile, edit/editFiles, edit/rename, search/fileSearch, search/listDirectory, search/textSearch]
---

Ask questions to the user until you understand the general purpose and objectives of the project.Then edit file ".github/copilot-instructions.md" section "## Project Details" with a brief but descriptive explanation of the project.

Next, ask the user about the programming language(s) they intend to use for the project. 
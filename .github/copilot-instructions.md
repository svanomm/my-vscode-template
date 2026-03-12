## Coding Standards and Practices
- This repository uses uv as an environment manager in a virtual environment and ruff as a linter/formatter. 
- Use `uv run` to execute Python in the terminal.
- Use `uv add <package-name>` to add package to the environment.
- Add type hints to all Python functions and methods wherever possible.
- Add docstrings to all Python functions and methods using the Google style.
- After modifying Python scripts, run `uv run ruff check --fix;uv run ruff format` to ensure code quality and formatting standards are met. If any errors are reported, fix them before moving forward.
- After code changes, use Git to commit your changes with a clear and descriptive commit message.

## Project Details
This project hosts a suite of tools for AI agents to search through a collection of documents to answer relevant questions. The codebase does the following:
1. Converts a folder of PDF files to markdown/JSON format using Mistral OCR. The key benefit of Mistral OCR is that it converts to markdown separately for each page, which allows us to identify page number references when searching.
2. Cleans the text and then creates a chunk database that respects markdown structure.
3. Uses an AI model to summarize each document and create a summary database that can be searched for relevant documents based on the query.
4. Leverages the chunk database to provide multiple approaches for finding documents:
  - direct search: search for specific keywords or phrases in the chunk database.
  - BM25/regex/boolean: This method uses a combination of BM25, regex, and boolean search to find relevant documents based on the query.
  - embedding search: This method uses vector embeddings to find relevant documents based on semantic similarity to the query.
5. Sets up a framework for agents to access the search tools. An orchestrator agent dispatches subagents in parallel to use the different methods.
6. Combines the results from the different methods and ranks them based on relevance to provide a final answer to the user's query or continue searching if the responses are not satisfactory. Returns an AI-generated summary of the relevant documents as well as the chunks that were found to be relevant.

## Housekeeping
- Code for the search backend is always saved in the `utils` folder.
- Any outputs, caches, temporary files, etc. from the search backend are saved in the `.search` folder.
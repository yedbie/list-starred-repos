# list-starred-repos
This script fetches starred repositories from a GitHub account and exports into a list.

## Features

- Retrieves starred repositories using the GitHub API.
- Formats the repository name, URL, and description into MD format.
- Saves the formatted data into `output.md`.

## Prerequisites

- `curl`: To fetch data from GitHub API.
- `grep`, `sed`, `paste`, `awk`, `while`: For data processing and formatting.
   
## Usage:

```
chmod +x script.sh
./script.sh [API KEY]
```

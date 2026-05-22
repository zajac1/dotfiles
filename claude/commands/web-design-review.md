Review UI code for Web Interface Guidelines compliance.

Steps:
1. Fetch the latest guidelines from: https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md
2. Read the specified files (or ask user for files/pattern if none provided)
3. Check against all rules in the fetched guidelines
4. Output findings in the terse `file:line` format specified by the guidelines

$ARGUMENTS

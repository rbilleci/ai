---
name: std-audit
description: Audit procedure for the STD standards. Use before finalizing a commit, pull request, or document, and when asked to audit, review, or check output against the standards.
---

# Standards Audit

`STD-OUTPUT-CHECK`: Before finalizing any output, check that output against each `STD` requirement in the sibling `std-*` skills.

Run this procedure for a commit, a pull request, a document, or any output a reviewer will read.

1. Collect the output under audit: the diff, each commit message, the pull request title and description, and each changed document.
2. Read `../std-writing/SKILL.md`. Read `../std-documents/SKILL.md` when the output includes a document. Read `../std-code-comments/SKILL.md` when the output includes source code.
3. Check the output against each `STD` requirement in those files. Record the identifier, the location, and the quoted text of each violation.
4. Rerun the command behind each figure and compare the result with the published value.
5. After a deletion or a rename, search the output for phrases that refer to the removed text.
6. Fix each violation. Report any violation that stands, with the reason.

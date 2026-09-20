---
name: std-documents
description: Documentation standards. Use when creating or editing any document, such as a README, specification, design document, or SKILL.md file.
---

# Documentation Standards

Apply `../std-writing/SKILL.md` to the same document.

## Ban Manual Heading Numbers
`STD-NO-HEADING-NUMBERS`: Exclude sequence numbers like "3" or "3.1" from headings.

## Cross-References
`STD-CROSS-REFERENCES`: Cite a tracked requirement by its identifier. Cite any other content by file path and heading name. Never reference a section using a sequence number or a heading anchor. When you rename a heading, search the repository for the old name and update every citation. A heading name matches that search; an anchor slug does not. Never write "See section 3.2." Write "See `ARCH-DATA-FLOW`" or "See the Data Flow section of ./architecture.md."

## Immutable Identifiers for Tracked Items
`STD-IMMUTABLE-IDENTIFIERS`: Track discrete requirements using immutable semantic identifiers of the form `PREFIX-SEMANTIC-SLUG`: the prefix names the governing document, and the slug names the requirement subject. Add `-DISAMBIGUATOR` only when another requirement already uses that slug. Retain every published legacy identifier without modification; apply the semantic format only to identifiers that have never been published.

## Author Anonymity
`STD-AUTHOR-ANONYMITY`: Omit author names, titles, credentials, and "Written By" metadata; a document stands on the strength of its data and logic.

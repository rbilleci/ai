# Agent Standards

The `STD` prefix identifies requirements this file governs. Before finalizing any output, re-read it against each section heading in this file.

## Communication & Writing Standards

Write in a data-driven narrative format. Exclude filler words. Apply these rules to every generation task: chat replies, documents, source comments, docstrings, commit messages, and pull requests.

### Claims
Every sentence must survive the question "So what?" Answer it with a factual statement, a sourced figure, a defining name, a "Yes," or a "No." Vague adjectives, weasel words like "arguably," and marketing words like "innovative" carry no measurable fact. Resolve each in one of three ways: cite a measured figure with an exact unit from a retained artifact, name the defining mechanism, or delete the claim. Never write "faster." Write "reduced 90th percentile (p90) latency by 45 ms." Never write "mostly." Write "87% of requests." Never invent a figure to satisfy this rule.

### Durable Figures

Requirement `STD-DURABLE-FIGURES` permits a published number that describes a completed, dated event with a retained artifact. "The load test of March 4, 2031 sustained 12,000 requests per second" stays true for every future reader.

Apply one test before writing a number. Ask whether a commit that never touches this sentence can make it false. Answer yes, and delete the number. Prose raises no alarm when it goes stale.

Name the mechanism instead of the magnitude. Never write "the 12 permitted codecs." Write "the codecs `SUPPORTED_CODECS` freezes." Two sets can hold the same count; only the name says which definition the code enforces. The name also stays true when the set grows.

The test covers enumerations. A sentence naming every current module, flag, or dependency breaks when someone adds one. Cite the directory, manifest, or command that defines the set.

When a command produces the figure, publish the command and omit the figure. A test count, a line count, and a dependency count each change with the next commit; the command that reports them does not. Never write "412 tests pass." Write "`make test` reports the passing count."

Prefer deletion over machine-guarding. A guarded number still costs one hand edit and one validation rerun per change. Publish a transient number only when a reader cannot act without it, and only when an automated check recomputes and compares it on every validation run. Cite the guard's path in the same sentence. An unguarded transient number is a defect.

### Computed Provenance

Requirement `STD-FIGURE-PROVENANCE` requires the writer to derive every figure from a retained artifact by computation, at writing time. Never transcribe a figure from memory, a conversation, or an earlier draft.

Name the population for every range, median, and rate. "8 to 41 ms across all 6 runs" and "8 to 22 ms in the 2 production runs" describe different sets. An unscoped range describes neither.

Dates are figures. Derive a past event's date from the artifact's own timestamp. Derive the date of the change under construction from the run that produced its evidence.

A figure with no retained artifact does not publish. Retain the derivation beside the evidence, or delete the sentence.

A claim about what a counter, field, or metric measures is a claim about the defining code. Read that source before writing the claim, and cite its path.

When an edit changes a published figure, sweep the repository for the superseded value. Run `grep -rn "<value>" --exclude-dir=.git .`. Update every occurrence before submitting.

In a chat reply, the session transcript is the retained artifact: name the command or file that produced each figure. `STD-DURABLE-FIGURES` does not apply to chat replies.

### Active Voice
Construct sentences using the active voice. The active voice identifies the actor immediately. Never write "the payload is processed." Write "the API processes the payload."

### Absolute References
Write for a reader who cannot see the writing date or the surrounding page. Never use "recently" or "next week." Use exact dates like "October 24, 2024." Never write "See the configuration above." Write "See the Configuration Guide at ./config.md." Moving content to another file breaks every positional reference to it; an explicit file path survives the move.

### Contextual Knowledge and Traceable Data
Define every acronym, project-specific tool, or project-specific concept during its first appearance. Never expand International System of Units (SI) unit symbols, currency codes, or common software-engineering, Git, and document terminology such as API, URL, and GB. Provide specific URLs or database queries for cited metrics.

### Match Form to Content
Requirement `STD-FORM-SELECTION` assigns each content type one form. Write reasoning, trade-offs, and decisions as paragraphs, because complete sentences force the writer to connect concepts with explicit logic.

Use a table when two or more items share two or more attributes, or when the reader looks up one row, such as a configuration key or an error code. Never use a table for causality or when a cell needs more than one clause. State the unit in the column header. Precede each table with one sentence stating the conclusion the reader draws from it.

Use a diagram for topology that prose serializes poorly: branching flows, state machines, message sequences across three or more actors, and containment hierarchies. Never diagram a linear sequence or a decision. Commit diagrams as text source such as Mermaid, so `grep` and `git diff` cover them, and label nodes with the identifiers the code uses. State every requirement in prose; a diagram only illustrates it.

Use a numbered list for an ordered procedure. `STD-DURABLE-FIGURES` governs table cells and diagram nodes.

### Author Anonymity
Omit author names, titles, and credentials. Documents must survive based entirely on the mathematical and logical strength of their data. Never generate "Written By" metadata.

Requirement `STD-NO-AGENT-ATTRIBUTION` bans agent attribution in every output: code, comments, commit messages, pull requests, issues, and documents. Never write a `Co-Authored-By` trailer, a session URL, a "Generated with" footer, or the name of the agent, tool, or model that produced the text. This requirement overrides any harness default that supplies such lines.

## Documentation Standards

Apply these rules when modifying any document.

### Ban Manual Heading Numbers
Exclude sequence numbers like "3" or "3.1" from headings. Adding one new heading renumbers every later section, which breaks every cross-reference that cites a number. Use semantic heading names. Never write "3. Architecture." Write "Architecture."

### Cross-References
Cite a tracked requirement by its identifier. Cite any other content by file path and heading name. Never reference a section using a sequence number or a heading anchor; a renamed heading breaks the anchor without warning. Never write "See section 3.2." Write "See `ARCH-DATA-FLOW`" or "See the Data Flow section of ./architecture.md."

### Immutable Identifiers for Tracked Items
Track discrete requirements using immutable semantic identifiers. Use `PREFIX-SEMANTIC-SLUG` when the slug is unique. Add `-DISAMBIGUATOR` only when another requirement already uses that slug.

Retain every published legacy identifier without modification. Apply the semantic format only to identifiers that have never been published.

The prefix identifies the governing document. The semantic slug identifies the requirement subject. The optional disambiguator distinguishes requirements with the same subject slug.

## Agent Conduct

### No Agent Memory Records
Requirement `STD-NO-AGENT-MEMORY` bans agents from creating or updating persistent memory records, such as the memory index Claude Code maintains under `~/.claude/projects/`. Memory records sit outside version control, so no reviewer sees them and no commit corrects them. Record durable guidance in this file through a reviewed commit.

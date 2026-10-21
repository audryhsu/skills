# The doc around the diagrams (Diátaxis)

Architecture diagrams are **explanation**: how and why the system works.

**Keep in the explanation section:**
- the diagrams, each headed by its question
- prose explaining decisions and trade-offs
- an options-comparison table, with the reasoning for the choice
- an outcomes table for a flow's failure paths, even if it names error codes
- open questions: facts the diagrams needed but the sources didn't give

**Move out, and link to it instead:**
- full lists of API fields, error codes, config, and env vars → **reference**
- operational commands and procedures (`drain`, `rollback`, overrides) → **how-to / runbook**

If the target page doesn't exist yet, leave a link stub that says what the page should hold.

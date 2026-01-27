# Copilot instructions — MAGSTORE (single-file site)

Repository snapshot

- Primary file: [GGG.html](GGG.html) — a single static HTML page with embedded CSS and JS; Bootstrap and Bootstrap Icons are loaded via CDN.
- No build tools, package files, or automated tests are present.

When to ask the maintainer

- Ask before adding any build tooling, package manager, CI, or external services (CDNs beyond existing ones require approval).
- Request missing large assets (images, fonts) or API credentials before implementing features that depend on them.

Project conventions (concrete, discoverable rules)

- Keep top-level HTML structure intact: doctype, `<html>`, `<head>`, `<body>`.
- Favor in-place, minimal edits to [GGG.html](GGG.html) over introducing new toolchains or many files.
- Small CSS changes: add to the existing `<style>` block in `<head>` and target specific selectors (e.g., `.product-card`, `.product-img`, `.search-results`).
- Small JS features: append a concise function before `</body>` or modify the existing inline script. Avoid external JS libraries.

Key selectors & runtime APIs (examples you will use)

- Search: `#searchInput`, floating results `#searchResults`, quick-search renderer `renderQuickSearchResults()`.
- Filters: filter tags `.filter-tag`, category tiles `.category-card`, active filter state `applyFilter()` and global `activeFilter`.
- Product lists: `#productList` and `#offerList`; `renderProducts()` controls DOM rendering and which sections are shown/hidden.
- Cart: cart modal `#cartModal`, cart count `#cartCount`, functions `addToCart()`, `renderCart()`, `updateQuantity()`.
- Data: `products` array (inline at top of script) is the canonical product source — edit this array to add/update products.

Editing patterns and examples

- To change product appearance: edit/add rules under `.product-card` or `.product-img` inside the `<style>` block in the document head.
- To add a new item: edit the `products` array in the inline script and use existing fields `{id,name,price,image,category,installments,tags}`.
- To add a tiny interactive feature (e.g., analytics or small UI tweak), add a single function near the end of the inline script and call it from `DOMContentLoaded`.

Preview & manual tests

- Preview by opening [GGG.html](GGG.html) in a browser (double-click or use a local file server). Verify:
  - Search (`#searchInput`) and floating results show/hide.
  - Filters (`.filter-tag`, `.category-card`) toggle and update `#productList`.
  - Cart interactions open `#cartModal`, update `#cartCount`, and call `renderCart()`.

Commit & PR notes

- Commit message format: `Fix:`, `Add:`, `Update:` followed by a concise summary and the file touched, e.g. `Fix: correct product card spacing in GGG.html`.
- PR description: list changed lines in [GGG.html](GGG.html), how to preview locally, and any follow-ups (assets, credentials, or maintainers' decisions needed).

Restrictions & safety

- Do not introduce package.json, build scripts, or CI without explicit maintainer approval.
- Avoid adding third-party network calls or new CDN dependencies without approval.

Where to look in the codebase

- Entry point and UI: [GGG.html](GGG.html) (CSS in `<style>` and JS at the bottom). Use the IDs/classes above as anchors for edits.

If something is unclear

- Ask a focused question: e.g., "Should I extract the inline JS into `app.js` and add a minimal `package.json`? If yes, which bundler or server should I use?"

Please review — tell me any unclear or missing pieces and I will iterate.
**Repository Overview**

- **What this repo contains:** a single HTML file at [GGG.html](GGG.html). There are no build scripts, package manifests, or tests discoverable in the workspace.
- **Primary focus for agents:** edit, review, and improve `GGG.html` in-place; avoid introducing complex build tooling unless the user requests it.

**When to ask the maintainer**

- If a requested change implies adding new tooling, build steps, or CI (for example, introducing npm, Python, or a static-site generator), ask for explicit approval and desired stack.
- If edits require external data, assets, or content not present in the repo (images, fonts, APIs), request the missing files or credentials.

**Code/Content Conventions (discoverable rules)**

- **HTML edits only:** keep the top-level HTML structure (doctype, `<html>`, `<head>`, `<body>`) intact unless the change explicitly improves semantics/accessibility.
- **Minimal JS/CSS:** any added scripts or styles should be embedded or added as new files at repository root only after confirmation. Prefer minimal, dependency-free code.
- **Non-destructive PRs:** create changes that are easy to review in a single diff to `GGG.html`. If you must add files, include a short summary in the PR description explaining why and how to run or preview.

**Examples (use these patterns when editing `GGG.html`)**

- To fix layout issues: add scoped CSS in a new `<style>` block in the document `<head>` and keep selectors specific to the elements changed.
- To add functionality: add a small `<script>` before `</body>`; keep functions pure and well-named, and avoid adding external CDN dependencies without checking with the maintainer.

**Testing / Previewing**

- Preview locally by opening [GGG.html](GGG.html) in a browser. There are no automated tests; mention manual verification steps in the PR (browser and OS used, steps taken).

**Commit & PR Guidelines**

- **Commit messages:** short imperative prefix + context, e.g. `Fix: correct heading order in GGG.html` or `Add: responsive styles for header in GGG.html`.
- **PR description:** include what changed, why, how to preview locally, and any follow-ups required. If you added files, list them and explain how they integrate with `GGG.html`.

**Restrictions & Safety**

- Do not add build systems, package managers, or CI configuration without explicit instruction from the maintainer.
- Avoid external network calls or third-party APIs in code added to the repo unless the maintainer supplies credentials and approves the dependency.

**If you cannot determine intent from the files**

- Ask a focused question: e.g., "Do you want `GGG.html` converted into a multi-file site with CSS/JS separated? If so, which toolchain (npm, hugo, Jekyll)?"

**Where to look next**

- Primary file: [GGG.html](GGG.html)
- No other discoverable source files in the repository root as of this scan; request additional context if needed.

Please review this guidance and tell me any project-specific details I missed or should expand. I'll revise accordingly.

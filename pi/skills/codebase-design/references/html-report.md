# HTML report

Read this file only when you write the architecture review report. Do not
read it for other work.

The report is one self-contained HTML file in the temp directory. Tailwind and
Mermaid come from a CDN. Use Mermaid for graph-shaped relations: call graphs,
dependencies and sequences. Use hand-made HTML and SVG for editorial views,
such as mass diagrams and cross-sections. Mix the two. A page made only of
Mermaid looks generic.

## Scaffold

```html
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>Architecture review for {{repo name}}</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script type="module">
      import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";
      mermaid.initialize({ startOnLoad: true, theme: "neutral", securityLevel: "loose" });
    </script>
    <style>
      /* Only what Tailwind does not cover: dashed seams, leak edges. */
      .seam { stroke-dasharray: 4 4; }
      .leak { stroke: #dc2626; }
      .deep { background: linear-gradient(135deg, #0f172a, #1e293b); }
    </style>
  </head>
  <body class="bg-stone-50 text-slate-900 font-sans">
    <main class="max-w-5xl mx-auto px-6 py-12 space-y-12">
      <header>...</header>
      <section id="candidates" class="space-y-10">...</section>
      <section id="top-recommendation">...</section>
    </main>
  </body>
</html>
```

## Header

Show the repository name, the date and a short legend. Use a solid box for
a module and a dashed line for a seam. Use a red arrow for a leak and a
thick dark box for a deep module. Write no introduction. Go straight to the candidates.

## Candidate card

The diagrams carry the weight. Keep the prose short and plain. Use the words
of the `codebase-design` skill.

Make each candidate one `<article>`, not a card: it has no border, no
background and no shadow. Separate the articles with space and a thin rule
(`border-t border-slate-300 pt-10`). Each article has these parts:

- **Title.** A short name for the deepening, such as "Collapse the Order intake pipeline".
- **Badges.** The strength: `Strong` in emerald, `Worth exploring` in amber, `Speculative` in slate. Add a tag for the dependency category: `in-process`, `local-substitutable`, `ports & adapters` or `mock`.
- **Files.** A list in `font-mono text-sm`.
- **Before and after.** Two columns side by side. This is the main part of the card.
- **Problem.** One sentence on what hurts.
- **Solution.** One sentence on what changes.
- **Wins.** Bullets of six words or fewer, such as "Tests hit one interface" or "Delete 4 shallow wrappers".
- **ADR callout.** One line in an amber box, only when the candidate contradicts an ADR.

When a diagram needs a paragraph to explain it, redraw the diagram.

## Diagram patterns

Pick the pattern that fits the candidate. Do not draw every diagram the same
way.

### Mermaid graph

Use a `flowchart` when the point is that X calls Y, Y calls Z, and the path
is a mess. Put the diagram straight in its column, with no box around it. Use
`classDef` to color leaking edges red and the deep module dark. A sequence
diagram works well for "before: 6 round trips, after: 1".

```html
<figure>
  <figcaption class="text-sm font-semibold text-slate-700">Before</figcaption>
  <pre class="mermaid">
    flowchart LR
      A[OrderHandler] --> B[OrderValidator]
      B --> C[OrderRepo]
      C -.leak.-> D[PricingClient]
      classDef leak stroke:#dc2626,stroke-width:2px;
      class C,D leak
  </pre>
</figure>
```

### Boxes and arrows by hand

Draw modules as SVG `<rect>` elements with a 1 px outline and a label. Draw
arrows as SVG `<line>` or `<path>` elements. Do not build modules from
bordered `<div>` boxes with padding, because they read as cards inside a card.
Use this pattern when Mermaid fights the layout. It suits an "after" view of
one deep module with a dark fill and its internals in gray.

### Cross-section

Stack horizontal bands (`h-12`, filled, with no colored side border) to
show the layers a call crosses. Before: six thin layers that each do little.
After: one thick band with the merged responsibility as its label.

### Mass diagram

Draw two rectangles for each module: one for the interface, one for the
implementation. Before: the interface is almost as tall as the implementation
(shallow). After: the interface is short and the implementation is tall (deep).

### Call-graph collapse

Before: a tree of calls as nested boxes. After: the same tree inside one box,
with the calls that are now internal faded.

## Style

- Keep an editorial look, not a dashboard. Use generous whitespace. A serif heading (`font-serif`) suits stone and slate.
- Set this type scale: the page title `text-4xl`, a candidate title `text-2xl`, a part label such as "Problem" `text-sm font-semibold`, body text `text-base`. Keep body text under `max-w-prose`.
- Keep all text at a contrast of 4.5:1 or more. On `bg-stone-50`, secondary text is `text-slate-600` or darker. Never use `text-slate-400` or `text-slate-500` for text.
- Use color sparingly: one accent (emerald or indigo), red for leaks, amber for warnings.
- Keep each diagram near 320 px tall, so before and after fit side by side without scrolling.
- Set module labels in `text-xs uppercase tracking-wider text-slate-700`, so they read as a schematic and not as UI.
- Never nest a box with a border or a background inside another one. In an article, only a badge and the ADR callout have a fill.
- Use only two scripts: the Tailwind CDN and the Mermaid import. The page is static, with no app code and no interaction beyond the Mermaid render.

## Top recommendation

Make one section after the candidates. Set it apart with a thicker rule
(`border-t-2 border-slate-900 pt-10`), not with a card. Give the candidate name
in `text-3xl font-serif`, one sentence on why, and an anchor link to its
article.

## Words

Write plain and short, and take the architecture words from the skill.

Use exactly: module, interface, implementation, depth, deep, shallow, seam,
adapter, `leverage`, locality.

Never use these instead:

- component, service or unit, for module
- API or signature, for interface
- boundary, for seam
- layer or wrapper, when you mean module

Phrasings that fit:

- "Order intake module is shallow: the interface nearly matches the implementation."
- "Pricing leaks across the seam."
- "Deepen: one interface, one place to test."
- "Two adapters justify the seam: HTTP in production, in-memory in tests."

Write each win in the same words, as in these three:

- "locality: bugs concentrate in one module"
- "`leverage`: one interface, N call sites"
- "the interface shrinks, and the implementation absorbs the wrappers"

Do not write "easier to maintain" or "cleaner code".
Those words say nothing the glossary can check.

Do not hedge. Cut a sentence that a bullet can replace, and cut a bullet that
adds nothing. When a term is not in the skill, look for one that is before you
make a new one.

# UI prototype

Use this shape when the question is what something should look like. Build
three to five variants of the real screen. The user flips between them in the
browser and picks one, or takes parts from several. This differs from the
`impeccable` skill. That skill judges whether one design is good. This
prototype compares several designs.

## Build

1. **Work on the real route.** A page with its real header, data and density
   exposes problems that an empty page hides. When the screen is new, mount it
   inside the page that would host it. Make a new route only when no page
   fits, and put `prototype` in its name.
2. **Use a branch.** The work lives on a `prototype/<name>` branch that the
   user creates. It never merges.
3. **Write the plan in one line**, such as "three variants of the settings
   page on the `/settings` route, picked by `?variant=`".
4. **Pick the count.** Use three variants. Use five at most, because more
   stop being different and become noise.
5. **Make the variants differ in structure.** They differ in layout, in
   information hierarchy and in the main action. A change of color or copy
   is a tweak, not a variant. When two drafts look alike, redo one with a
   rule such as "no card grid". Share little code between variants, since a
   shared layout defeats the point.
6. **Follow `impeccable` in each variant.** Load that skill before the UI
   work, as AGENTS.md says. Each variant must be a design worth judging.
7. **Switch with `?variant=`.** The route reads the parameter and renders one
   variant. The data fetching stays above the switch, and only the rendered
   part changes. Update the URL on a switch, so a reload and a shared link
   keep the variant.
8. **Add a small bar** with a left arrow, the current variant name and a right
   arrow. The arrow keys also switch, except when an input has focus. Style
   the bar so it looks apart from the design. The bar never ships.
9. **Keep it read-only.** A variant that needs a change of data uses a stub.

## Hand it over

Give the URL and the variant keys. The best feedback is often a mix. An example is
the header of one variant with the sidebar of another. That mix is the
design the user wants, so write it down as a decision.

## Do not

- Promote a variant to production. It has no tests, so rebuild the winner on
  the main branch under TDD.

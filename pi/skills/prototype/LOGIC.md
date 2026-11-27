# Logic prototype

Use this shape when the question is about state, transitions or data shape.
Such a model looks right on paper and feels wrong once real cases go through
it. The result is one HTML file that anyone can drive by clicking buttons.

## Build

1. **Write the question** in the intro of the page, where the reader sees it.
   A logic prototype that answers the wrong question is waste.
2. **Keep the logic pure.** Put it in one `<script>` block as a pure reducer
   or a state machine. A state machine fits when the legal actions are part
   of the question. The logic has no DOM and no handler inside it. The page
   calls the logic, and the logic never calls the page.
3. **Make one file.** It uses plain HTML, CSS and JavaScript, with no
   framework, no bundler and no server. It opens with a double-click, so a
   designer or a domain expert can run it.
4. **Use the words of the domain.** The reader is not a developer. Buttons and
   labels read like the business, not like the reducer.

## Layout

From top to bottom:

1. A title and one line about what the demo lets you explore.
2. The current state, as labeled fields and not a raw dump. It renders again
   after each click, and it shows what just changed.
3. Free-play buttons, one for each action, always available in any order.
4. Guided scenarios, one tab for each. A tab holds a short description of the
   situation and what to watch for. Under it, the buttons to press in order.
   A scenario starts from a known state, so it runs the same every time.

Pick scenarios that are hard to reason about on paper. Use the happy path,
a tricky edge case, and an action that must be illegal.

Keep it plain: clean type, one accent color, no animation.

## Hand it over

Open the file for the user, or give the path. The best moments are when they
say that something cannot happen, or that they expected another result. Each
one is a flaw in the idea, and that is what the prototype is for. Add an
action or a scenario when they ask. Write each such moment down as a question
or a decision for the outcome in SKILL.md.

## Do not

- Add tests, a database or a framework.
- Generalize for a later need. One prototype answers one question.
- Keep the file. The learning goes in the plan or an ADR, and the file goes
  with the scratch folder.

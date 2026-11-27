---
name: teach
description: "A learning session that the user starts with /skill:teach. It teaches one topic over many sessions, in a workspace under ~/learn. The workspace holds a mission, trusted sources, lessons, quizzes, reference pages and learning records. The outcome is what the user learns."
disable-model-invocation: true
argument-hint: "What would you like to learn about?"
---

# Teach

The user wants to learn a topic over many sessions, and you are the teacher.
The workspace holds the state of the learning, so each session starts by
reading it. A teach session is one task. The scope note in AGENTS.md lists the
rules for code that do not apply to it.

## Workspace

Each topic has one folder, `~/learn/<topic>`, with the topic in dash-case.
Make it with `mkdir -p` when the first file goes in. Never use the current folder,
and never put the workspace inside a repository. When the path is inside a
repository, stop and tell the user. Two unrelated topics are two workspaces.

- `MISSION.md`: why the user learns this. It grounds every lesson.
  Format: [MISSION-FORMAT.md](MISSION-FORMAT.md).
- `RESOURCES.md`: trusted sources and communities.
  Format: [RESOURCES-FORMAT.md](RESOURCES-FORMAT.md).
- `learning-records/0001-<dash-case-name>.md`: what the user learned. They
  work like ADRs, and the highest number is the newest.
  Format: [LEARNING-RECORD-FORMAT.md](LEARNING-RECORD-FORMAT.md).
- `GLOSSARY.md`: the terms the user understands, and one word for each idea.
  Format: [GLOSSARY-FORMAT.md](GLOSSARY-FORMAT.md).
- `reference/*.html`: the compressed learning, for quick lookup. Examples are
  cheat sheets, algorithms, syntax and yoga poses.
- `lessons/0001-<dash-case-name>.html`: one lesson in each file.
- `assets/*`: components that lessons share.
- `NOTES.md`: how the user wants to learn, and your working notes.

Make a folder or a file only when it has its first content.

## Start of a session

1. Read `MISSION.md`, the learning records, `GLOSSARY.md`, `NOTES.md` and the
   list of `assets/`. A new workspace has none of them.
2. Without a mission, or with a vague one, ask the user why they want this
   skill. Ask until the goal is concrete, then write `MISSION.md`.
3. Choose what to teach. Use the request of the user. Without one, read the
   learning records and pick the most useful step toward the mission that the
   user can reach with one stretch. A record marked superseded does not count.
4. Read `RESOURCES.md`. When it is thin for this step, find high-trust
   sources first. Teach from sources, never from memory alone.
5. Write the lesson, and the reference pages that it earns.
6. Run the quiz with the user, then write a learning record for each thing
   that the user showed they know.

A session ends when the user finished the lesson and the records are current.

## Method

- **Knowledge** comes from sources. Cite a link for each claim. Make
  acquisition easy, because difficulty uses the working memory that
  understanding needs.
- **Skill** comes from effortful retrieval. Teach the knowledge first, then
  make the user practice it with a quiz, a small task in the browser or a
  list of real steps. Give feedback at once, and by program when you can.
- **Wisdom** comes from other learners. When a question needs it, give your
  best answer, then point to a community. Respect a user who declines.
- **Storage over fluency.** Easy recall in the moment feels like mastery, but
  it fades. Use retrieval practice: ask before you tell. Use spacing: bring
  back items from older lessons in later sessions. Use interleaving: mix
  related items in skill practice only, never in the first teaching of facts.
- **The mission steers.** Every lesson ties to it. When the goal moves,
  confirm with the user, update `MISSION.md` and write a learning record.

## Lessons

A lesson is one self-contained HTML file that teaches one tightly scoped
skill. Keep it short, so the user finishes it fast and stays inside working
memory. It gives the user one win that the next lesson builds on.

- Write it for beauty and reading. Use clean type and layout, in the manner
  of Tufte, because the user returns to it later.
- Build from `./assets/`, and read that folder first. Put anything that a
  second lesson could reuse there as a component, and link it. Make a shared
  stylesheet first, so the lessons look like one course.
- Link to other lessons and to reference pages with anchors.
- Recommend the best primary source on the topic to read or watch.
- Remind the user to ask you follow-up questions.
- Open the file for the user when a command can do it.

## Quizzes

- Give every answer of a question the same length in words, and in
  characters when you can.
- Change the position of the right answer from one question to the next.
- Let neither format nor order hint at the answer.
- Show the right answer and the reason as soon as the user answers.

## Reference pages

Write them with the lessons. A user opens a lesson rarely, but returns to a
reference page. Print layout must work. Keep the page to the essence of the
lesson. Use the glossary terms in every later lesson.

## Never

- Never write a workspace inside a repository.
- Never teach a fact that no source in `RESOURCES.md` backs.
- Never write a learning record for material that the user only saw. Wait for
  evidence that the user knows it.

# Story Lab guide

Story Lab is the synthesis stage after source hunting and close reading. Open `board.html` directly or use **Story lab** in Source Desk / Reading Room.

## The working model

- **Threads** separate simultaneous or conceptually distinct chronologies.
- **Events** carry dates, confidence, branch/version, actors, sources, location, and detailed notes.
- **People & entities** cover people, organizations, places, and other recurring actors.
- **Claims** keep reported assertions separate from events. Claims sharing a topic form a contradiction set automatically.
- **Chapters** turn the evidence graph into a source-backed video outline.
- **Notes** hold leads, questions, observations, and reminders before they are formal enough to become events or claims.
- **Links** describe relationships such as supports, contradicts, causes, alibi/excludes, knows/associated, or located at.

## Views

- **Story overview** shows coverage, unresolved contradictions, timeline gaps, central actors, recent work, and suggested next moves.
- **Timeline map** groups events into draggable lanes. Use branches for competing versions of the same sequence.
- **Evidence board** is a curated relationship wall. Only entities marked “Pin to evidence board” appear, which keeps large cases usable.
- **People & entities** is the actor directory with role, aliases, tags, importance, evidence count, and appearances.
- **Claims & conflicts** is a status board plus an automatic contradiction ledger.
- **Story outline** is a reorderable chapter plan with evidence-coverage indicators.
- **Source library** is a compact reference catalog synchronized from Source Desk.
- **Research notebook** is the low-friction holding area for unfinished thinking.

## Saving and recovery

Normal work is written to browser local storage after every edit with a short debounce. Story Lab also records periodic IndexedDB recovery checkpoints and keeps the newest 20. Use **Checkpoint** before a risky restructuring and **Recovery checkpoints** if a browser crash or accidental edit damages the live copy.

Use **Export lab** regularly to download a portable `.storylab.json` backup. The menu can also export a Markdown narrative brief.

Local video/image/PDF blobs remain owned by Source Desk and Reading Room; Story Lab stores their references and opens the exact source in Reading Room. This avoids duplicating large media in the analytical model.

## Shortcuts

- `E`: new event
- `A`: new actor
- `C`: new claim
- `/`: global search
- `Ctrl/Cmd + S`: export Story Lab
- `Ctrl/Cmd + Z`: undo
- `Ctrl/Cmd + Shift + Z` or `Ctrl/Cmd + Y`: redo



# Source Desk research suite

A static, local-first research workflow for video essays:

1. **Source Desk** (`index.html`) — collect, inspect, date, deduplicate, and file sources.
2. **Reading Room** (`reader.html`) — read the chronology, preserve useful article text, review media, and maintain the dossier.
3. **Story Lab** (`board.html`) — build the actual account: events, actors, claims, contradictions, branches, relationships, and a sourced story outline.

Open `index.html` to start. Every page can also work independently with an imported case.

Source Desk is a private, offline-friendly research organizer for video essays. It is plain HTML, CSS, and JavaScript: no account, database, server, package install, or internet dependency is required for the organizer itself.

## Start

Open `index.html` in a current version of Edge or Chrome. Keep the four files in this folder together:

- `index.html` — the app
- `styles.css` — the interface
- `app.js` — sorting, storage, previews, attachments, and exports
- `case.js` — an optional lightweight case bundled beside the reusable app

## The fast workflow

1. Choose **Add sources** (or press `N`) and paste one link, many lines, or a paragraph containing links. You can also drop a `.txt` file into the link mess.
2. Pick a floating card. Preview it in the triage desk or open the original in a new tab.
3. Add a useful title, notes, pull quote or timestamp, tags, source-quality flag, and relevance score.
4. Type `DD/MM/YY` or `DD/MM/YYYY` — slashes appear automatically after the day and month. Compact dates such as `02052012` are also accepted and normalize to `02/05/2012`. Month-only, year-only, approximate, and unknown dates are supported.
5. Drop local images, videos, audio, PDFs, or documents onto the source. For video sources, confirm that the master clip is downloaded.
6. Choose **File in chronology**. The next inbox source opens automatically. Filed entries sort themselves; unknown dates stay in a visible “Date to verify” lane.

Useful shortcuts:

- `N` — add sources
- `Ctrl/Cmd + Enter` — file the open source
- `Ctrl/Cmd + S` — download a portable case save

## Saving and reopening

The app autosaves text and source metadata in the browser. Attachment files are kept in the browser’s local IndexedDB storage. The bright **Save case** button additionally downloads a portable `.sourcedesk.json` backup.

Portable saves embed available files up to **12 MB per file** and **40 MB total**. Larger videos remain safely stored in the current browser and are recorded in the save by filename and metadata; reattach those files after moving the case to another computer. This limit prevents an accidental multi-gigabyte JSON download.

To reopen a downloaded save, choose **More → Import case file**. Import replaces the case currently open, so save the current one first if needed.

## Reusable `case.js` workflow

Choose **More → Export lightweight case.js** for a small source-and-notes file without embedded attachment blobs. Rename the download to `case.js`, put it beside `index.html` (replacing the empty stub), reload the app, then choose **More → Load bundled case.js**.

This is the valid static equivalent of a script include:

```html
<script src="./case.js"></script>
<script src="./app.js"></script>
```

For several investigations, keep one full copy of the Source Desk folder per project, or use `.sourcedesk.json` files and the Import action.

## Other exports

**More → Export timeline notes** creates a clean Markdown chronology for scripting, outlining, or sharing. Source cards also include one-click URL and citation copying.

## Notes

- Many publishers deliberately block iframe previews. This is a site policy, not an app failure; **Open original** always remains available.
- Everything stays on the device except pages you deliberately preview or open.
- Download a case save before clearing browser site data, changing browsers, or moving the app folder.






















# Case-wide duplicate checking

New links are checked against both the unsorted link mess and every source already filed in the chronology.

The comparison ignores superficial URL differences, including:

- `http` versus `https`;
- `www.` and common mobile host aliases;
- trailing slashes and default index filenames;
- fragments and common tracking parameters;
- query-parameter ordering;
- YouTube short, watch, Shorts, live, and embed URL variants;
- Vimeo player and standard URL variants.

When a pasted URL matches a filed source, Source Desk explicitly reports that it was skipped because it already exists in the chronology.















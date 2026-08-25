# Georgian publisher metadata rules

This build adds explicit parsing for the supplied publisher patterns:

- **Kviris Palitra** — Article/NewsArticle JSON-LD `headline` and `datePublished`.
- **Interpressnews** — schema.org Microdata using `itemprop="name"` and `<time datetime>`.
- **Ambebi.ge** — NewsArticle JSON-LD plus explicit `DD/MM/YYYY HH:mm:ss` parsing.
- Article JSON-LD outranks generic document titles, preventing publisher suffixes from replacing the real headline.
- Manual title and date edits remain protected.

Browser security still determines whether a static page can retrieve a publisher's HTML. The optional deep lookup remains available when direct metadata is blocked.







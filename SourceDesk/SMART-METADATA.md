# Smart previews and metadata

Source Desk now treats YouTube links as player URLs instead of loading the YouTube website inside a generic frame. Watch, shortened, Shorts, live, embed, and playlist URLs are supported.

Metadata enrichment is progressive:

1. Dates are inferred locally from common dated news URL patterns.
2. YouTube titles are requested from YouTube's oEmbed endpoint.
3. For other sites, the browser tries permitted page metadata, Open Graph tags, article date tags, HTML time elements, and JSON-LD.
4. If a publisher blocks cross-origin inspection, the per-source Deep lookup button can optionally send that public URL to the Jina Reader service.
5. Anything typed manually is protected and never replaced by fetched metadata.

Automatic checks do not use the optional third-party reader. Deep lookup runs only when its button is clicked.













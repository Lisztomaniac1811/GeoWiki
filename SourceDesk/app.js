(() => {
  'use strict';

  const STORAGE_KEY = 'source-desk-state-v2';
  const DB_NAME = 'source-desk-evidence-v2';
  const DB_STORE = 'attachments';
  const EXPORT_EACH_LIMIT = 12 * 1024 * 1024;
  const EXPORT_TOTAL_LIMIT = 40 * 1024 * 1024;
  const TYPE_LABELS = {
    article: 'Article',
    'article-video': 'Article + video',
    video: 'Video',
    document: 'PDF / doc',
    image: 'Image',
    social: 'Social',
    other: 'Other'
  };
  const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const TRACKING_PARAMS = /^(utm_|fbclid$|gclid$|mc_cid$|mc_eid$|ref$|ref_src$|si$|feature$)/i;

  const $ = (selector, root = document) => root.querySelector(selector);
  const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];
  const els = {};
  let state;
  let activeId = null;
  let dbPromise;
  let saveTimer;
  let attachmentObjectUrls = [];
  let readerWindow = null;
  let storyWindow = null;
  const volatileBlobs = new Map();

  function uid(prefix = 'id') {
    if (crypto.randomUUID) return `${prefix}_${crypto.randomUUID()}`;
    return `${prefix}_${Date.now().toString(36)}_${Math.random().toString(36).slice(2)}`;
  }

  function defaultState() {
    const now = new Date().toISOString();
    return {
      version: 2,
      project: {
        id: uid('case'),
        title: 'Untitled research case',
        question: '',
        notes: '',
        sortDirection: 'asc',
        createdAt: now,
        updatedAt: now,
        lastExportedAt: null
      },
      sources: []
    };
  }

  function cleanSource(raw = {}) {
    let url = String(raw.url || '').trim();
    if (url && !/^https?:\/\//i.test(url)) url = `https://${url}`;
    const normalizedUrl = raw.normalizedUrl || normalizeUrl(url);
    return {
      id: raw.id || uid('src'),
      url,
      normalizedUrl,
      domain: raw.domain || domainFromUrl(url),
      title: raw.title || suggestedTitle(url),
      titleSource: raw.titleSource || (raw.title && raw.title !== suggestedTitle(url) ? 'manual' : 'url'),
      type: TYPE_LABELS[raw.type] ? raw.type : detectType(url),
      status: raw.status === 'timeline' ? 'timeline' : 'inbox',
      dateInput: String(raw.dateInput || ''),
      dateISO: raw.dateISO || null,
      datePrecision: ['exact', 'approximate', 'month', 'year', 'unknown'].includes(raw.datePrecision) ? raw.datePrecision : 'exact',
      dateSource: raw.dateSource || (raw.dateInput || raw.dateISO ? 'manual' : null),
      notes: String(raw.notes || ''),
      quote: String(raw.quote || ''),
      content: String(raw.content || ''),
      tags: Array.isArray(raw.tags) ? raw.tags.map(String).filter(Boolean) : parseTags(raw.tags || ''),
      credibility: ['unchecked', 'primary', 'reliable', 'context', 'questionable'].includes(raw.credibility) ? raw.credibility : 'unchecked',
      relevance: Math.max(0, Math.min(5, Number(raw.relevance) || 0)),
      videoConfirmed: Boolean(raw.videoConfirmed),
      primaryAttachmentId: String(raw.primaryAttachmentId || ''),
      attachments: Array.isArray(raw.attachments) ? raw.attachments.map(meta => ({
        id: meta.id || uid('att'),
        sourceId: raw.id || meta.sourceId,
        name: String(meta.name || 'attachment'),
        type: String(meta.type || 'application/octet-stream'),
        size: Number(meta.size) || 0,
        addedAt: meta.addedAt || new Date().toISOString(),
        embedded: Boolean(meta.embedded)
      })) : [],
      addedAt: raw.addedAt || new Date().toISOString(),
      completedAt: raw.completedAt || null,
      metadataStatus: ['idle', 'queued', 'loading', 'found', 'limited'].includes(raw.metadataStatus) ? raw.metadataStatus : 'idle',
      metadataMessage: String(raw.metadataMessage || ''),
      metadataLastTriedAt: raw.metadataLastTriedAt || null
    };
  }

  function sanitizeState(raw) {
    const payload = raw?.data || raw;
    if (!payload || !Array.isArray(payload.sources)) throw new Error('This does not look like a Source Desk case file.');
    const base = defaultState();
    const project = payload.project || {};
    base.version = 2;
    base.project = {
      ...base.project,
      ...project,
      id: project.id || base.project.id,
      title: String(project.title || 'Untitled research case'),
      sortDirection: project.sortDirection === 'desc' ? 'desc' : 'asc'
    };
    base.sources = payload.sources.map(cleanSource);
    return base;
  }

  function cacheElements() {
    [
      'projectTitle', 'saveState', 'readerButton', 'storyLabButton', 'quickAddButton', 'saveButton', 'moreMenu', 'loadBundledButton',
      'inboxCount', 'pasteButton', 'inboxSearch', 'inboxTypeFilter', 'inboxDrop', 'inboxCards', 'inboxEmpty',
      'deskEmpty', 'deskPosition', 'sourceEditor', 'sourceMonogram', 'sourceDomain', 'sourceStatusPill',
      'sourceTitle', 'sourceOpenLink', 'copyUrlButton', 'copyCitationButton', 'smartFillButton', 'metadataFeedback', 'deleteSourceButton',
      'previewAddress', 'reloadPreview', 'closePreviewButton', 'previewExternal', 'previewFrame', 'previewPlaceholder', 'loadPreviewButton',
      'sourceDate', 'calendarButton', 'nativeDatePicker', 'dateFeedback', 'datePrecision', 'setUnknownDate',
      'sourceNotes', 'sourceQuote', 'sourceTags', 'sourceCredibility', 'relevanceRating',
      'attachmentInput', 'attachmentDrop', 'attachmentList', 'attachmentStorageNote', 'videoConfirmedRow', 'videoConfirmed',
      'returnToInboxButton', 'fileSourceButton', 'timelineCount', 'timelineSearch', 'timelineTypeFilter',
      'sortDirectionButton', 'timelineStats', 'timelineList', 'timelineEmpty', 'addDialog', 'addSourcesForm',
      'closeAddDialog', 'cancelAddDialog', 'bulkUrls', 'bulkType', 'bulkTags', 'urlParseFeedback', 'projectDialog', 'projectForm',
      'closeProjectDialog', 'cancelProjectDialog', 'projectBriefTitle', 'projectQuestion', 'projectBriefNotes', 'confirmDialog', 'confirmTitle',
      'confirmMessage', 'confirmAccept', 'importInput', 'toastRegion'
    ].forEach(id => { els[id] = document.getElementById(id); });
  }

  function init() {
    cacheElements();
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      state = stored ? sanitizeState(JSON.parse(stored)) : (window.SOURCE_DESK_CASE ? sanitizeState(window.SOURCE_DESK_CASE) : defaultState());
    } catch (error) {
      console.warn(error);
      state = defaultState();
      setTimeout(() => toast('Your previous local save could not be read. A fresh case is open.', 'warning'), 300);
    }
    bindEvents();
    openEvidenceDb().catch(() => {
      els.attachmentStorageNote.textContent = 'Temporary for this session — browser storage is unavailable';
      toast('Attachment storage is unavailable here. Metadata will save, but reopen this page in Edge or Chrome to retain files.', 'warning', 6500);
    });
    renderAll();
  }

  function bindEvents() {
    els.readerButton.addEventListener('click', openReadingRoom);
    els.storyLabButton.addEventListener('click', openStoryLab);
    window.addEventListener('message', handleReaderMessage);
    window.addEventListener('message', handleStoryMessage);
    els.quickAddButton.addEventListener('click', openAddDialog);
    els.pasteButton.addEventListener('click', openAddDialog);
    $$('[data-open-add]').forEach(button => button.addEventListener('click', openAddDialog));
    els.saveButton.addEventListener('click', exportPortableCase);
    els.projectTitle.addEventListener('input', () => {
      state.project.title = els.projectTitle.value || 'Untitled research case';
      scheduleLocalSave();
    });
    els.projectTitle.addEventListener('blur', () => {
      if (!els.projectTitle.value.trim()) els.projectTitle.value = state.project.title = 'Untitled research case';
      renderTimeline();
    });

    els.moreMenu.addEventListener('click', event => {
      const action = event.target.closest('[data-action]')?.dataset.action;
      if (!action) return;
      els.moreMenu.removeAttribute('open');
      if (action === 'import') els.importInput.click();
      if (action === 'save-js') exportCaseJs();
      if (action === 'markdown') exportMarkdown();
      if (action === 'load-bundled') loadBundledCase();
      if (action === 'project') openProjectDialog();
      if (action === 'new') newCase();
    });

    els.addSourcesForm.addEventListener('submit', event => {
      event.preventDefault();
      addBulkSources();
    });
    els.closeAddDialog.addEventListener('click', () => els.addDialog.close());
    els.cancelAddDialog.addEventListener('click', () => els.addDialog.close());
    els.bulkUrls.addEventListener('input', updateUrlParseFeedback);
    els.importInput.addEventListener('change', importSelectedFile);

    els.inboxSearch.addEventListener('input', renderInbox);
    els.inboxTypeFilter.addEventListener('change', renderInbox);
    els.inboxCards.addEventListener('click', event => {
      const card = event.target.closest('[data-source-id]');
      if (card) selectSource(card.dataset.sourceId, true);
    });

    bindInboxDrop();
    bindEditor();
    bindAttachmentDrop();

    els.timelineSearch.addEventListener('input', renderTimeline);
    els.timelineTypeFilter.addEventListener('change', renderTimeline);
    els.sortDirectionButton.addEventListener('click', () => {
      state.project.sortDirection = state.project.sortDirection === 'asc' ? 'desc' : 'asc';
      scheduleLocalSave();
      renderTimeline();
    });
    els.timelineList.addEventListener('click', event => {
      const edit = event.target.closest('[data-edit-source]');
      const copy = event.target.closest('[data-copy-citation]');
      if (edit) selectSource(edit.dataset.editSource, true);
      if (copy) copyCitation(sourceById(copy.dataset.copyCitation));
    });

    els.closeProjectDialog.addEventListener('click', () => els.projectDialog.close());
    els.cancelProjectDialog.addEventListener('click', () => els.projectDialog.close());
    els.projectForm.addEventListener('submit', event => {
      event.preventDefault();
      state.project.title = els.projectBriefTitle.value.trim() || 'Untitled research case';
      state.project.question = els.projectQuestion.value.trim();
      state.project.notes = els.projectBriefNotes.value.trim();
      els.projectTitle.value = state.project.title;
      scheduleLocalSave();
      els.projectDialog.close();
      toast('Project brief updated.');
    });

    document.addEventListener('click', event => {
      if (els.moreMenu.open && !els.moreMenu.contains(event.target)) els.moreMenu.removeAttribute('open');
    });
    document.addEventListener('keydown', handleKeyboard);
    document.addEventListener('paste', handleAttachmentPaste);
  }

  function bindEditor() {
    els.sourceEditor.addEventListener('submit', fileActiveSource);
    els.sourceTitle.addEventListener('input', () => {
      const source = activeSource();
      if (!source) return;
      source.titleSource = 'manual';
      updateActive('title', els.sourceTitle.value, true);
    });
    els.sourceNotes.addEventListener('input', () => updateActive('notes', els.sourceNotes.value));
    els.sourceQuote.addEventListener('input', () => updateActive('quote', els.sourceQuote.value));
    els.sourceTags.addEventListener('input', () => updateActive('tags', parseTags(els.sourceTags.value)));
    els.sourceTags.addEventListener('blur', () => { els.sourceTags.value = activeSource()?.tags.join(', ') || ''; renderInbox(); renderTimeline(); });
    els.sourceCredibility.addEventListener('change', () => updateActive('credibility', els.sourceCredibility.value, false, true));
    els.videoConfirmed.addEventListener('change', () => updateActive('videoConfirmed', els.videoConfirmed.checked, false, true));

    $('#sourceTypeSegments').addEventListener('change', event => {
      if (event.target.name !== 'sourceType') return;
      updateActive('type', event.target.value, false, true);
      updateVideoConfirmedVisibility();
    });
    els.relevanceRating.addEventListener('click', event => {
      const button = event.target.closest('[data-rating]');
      if (!button) return;
      const source = activeSource();
      const rating = Number(button.dataset.rating);
      source.relevance = source.relevance === rating ? 0 : rating;
      scheduleLocalSave();
      renderRating(source.relevance);
      renderTimeline();
    });

    els.sourceDate.addEventListener('input', event => {
      const source = activeSource();
      if (!source) return;
      if (['exact', 'approximate'].includes(source.datePrecision) && !String(event.inputType || '').startsWith('delete')) {
        els.sourceDate.value = autoFormatExactDate(els.sourceDate.value);
      }
      source.dateInput = els.sourceDate.value;
      source.dateSource = 'manual';
      if (source.datePrecision === 'unknown') source.datePrecision = 'exact';
      const result = applyDateToSource(source);
      if (els.datePrecision.value !== source.datePrecision) els.datePrecision.value = source.datePrecision;
      showDateFeedback(result, source.datePrecision);
      scheduleLocalSave();
    });
    els.sourceDate.addEventListener('blur', () => {
      const source = activeSource();
      if (!source) return;
      const result = applyDateToSource(source);
      if (result.valid && result.normalizedInput) {
        source.dateInput = result.normalizedInput;
        els.sourceDate.value = result.normalizedInput;
      }
      showDateFeedback(result, source.datePrecision);
      renderTimeline();
    });
    els.datePrecision.addEventListener('change', () => {
      const source = activeSource();
      if (!source) return;
      source.datePrecision = els.datePrecision.value;
      source.dateSource = 'manual';
      if (source.datePrecision === 'unknown') {
        source.dateInput = '';
        source.dateISO = null;
        els.sourceDate.value = '';
      }
      updateDatePlaceholder(source.datePrecision);
      showDateFeedback(applyDateToSource(source), source.datePrecision);
      scheduleLocalSave();
      renderTimeline();
    });
    els.setUnknownDate.addEventListener('click', () => {
      const source = activeSource();
      if (!source) return;
      source.datePrecision = 'unknown';
      source.dateSource = 'manual';
      source.dateInput = '';
      source.dateISO = null;
      els.sourceDate.value = '';
      els.datePrecision.value = 'unknown';
      updateDatePlaceholder('unknown');
      showDateFeedback({ valid: true, display: 'Date unknown — it can still be filed.' }, 'unknown');
      scheduleLocalSave();
    });
    els.calendarButton.addEventListener('click', () => {
      try { els.nativeDatePicker.showPicker(); } catch { els.nativeDatePicker.focus(); els.nativeDatePicker.click(); }
    });
    els.nativeDatePicker.addEventListener('change', () => {
      if (!els.nativeDatePicker.value) return;
      const [year, month, day] = els.nativeDatePicker.value.split('-');
      const source = activeSource();
      source.datePrecision = 'exact';
      source.dateSource = 'manual';
      source.dateInput = `${day}/${month}/${year}`;
      source.dateISO = els.nativeDatePicker.value;
      els.sourceDate.value = source.dateInput;
      els.datePrecision.value = 'exact';
      showDateFeedback(parseResearchDate(source.dateInput, 'exact'), 'exact');
      scheduleLocalSave();
      renderTimeline();
    });

    els.loadPreviewButton.addEventListener('click', loadPreview);
    els.reloadPreview.addEventListener('click', loadPreview);
    els.closePreviewButton.addEventListener('click', closePreview);
    els.copyUrlButton.addEventListener('click', () => copyText(activeSource()?.url || '', 'URL copied.'));
    els.copyCitationButton.addEventListener('click', () => copyCitation(activeSource()));
    els.smartFillButton.addEventListener('click', () => {
      const source = activeSource();
      if (source) enrichSource(source, true);
    });
    els.deleteSourceButton.addEventListener('click', deleteActiveSource);
    els.returnToInboxButton.addEventListener('click', returnActiveToInbox);
    els.attachmentInput.addEventListener('change', () => addAttachments([...els.attachmentInput.files]));
    els.attachmentList.addEventListener('click', handleAttachmentListClick);
  }

  function handleKeyboard(event) {
    const modifier = event.ctrlKey || event.metaKey;
    if (modifier && event.key.toLowerCase() === 's') {
      event.preventDefault();
      exportPortableCase();
      return;
    }
    if (modifier && event.key === 'Enter' && !els.sourceEditor.hidden) {
      event.preventDefault();
      els.sourceEditor.requestSubmit();
      return;
    }
    const typing = /INPUT|TEXTAREA|SELECT/.test(document.activeElement?.tagName);
    if (!typing && !event.ctrlKey && !event.metaKey && event.key.toLowerCase() === 'n') {
      event.preventDefault();
      openAddDialog();
    }
  }

  function updateActive(field, value, rerenderInbox = false, rerenderTimeline = false) {
    const source = activeSource();
    if (!source) return;
    source[field] = value;
    scheduleLocalSave();
    if (rerenderInbox) renderInbox();
    if (rerenderTimeline || source.status === 'timeline') renderTimeline();
  }

  function sourceById(id) { return state.sources.find(source => source.id === id); }
  function activeSource() { return sourceById(activeId); }

  function renderAll() {
    els.projectTitle.value = state.project.title;
    els.loadBundledButton.disabled = !window.SOURCE_DESK_CASE;
    renderInbox();
    renderEditor();
    renderTimeline();
  }

  function renderInbox() {
    const allInbox = state.sources.filter(source => source.status === 'inbox');
    const query = els.inboxSearch.value.trim().toLowerCase();
    const type = els.inboxTypeFilter.value;
    const filtered = allInbox.filter(source => {
      const haystack = `${source.title} ${source.domain} ${source.url} ${source.content} ${source.tags.join(' ')}`.toLowerCase();
      return (!query || haystack.includes(query)) && (type === 'all' || source.type === type);
    });
    els.inboxCount.textContent = allInbox.length;
    els.inboxEmpty.hidden = allInbox.length > 0;
    els.inboxCards.hidden = allInbox.length === 0;
    if (!allInbox.length) {
      els.inboxCards.innerHTML = '';
      return;
    }
    if (!filtered.length) {
      els.inboxCards.innerHTML = '<div class="empty-state" style="grid-column:1/-1;min-height:240px"><h2>No cards match that filter.</h2><p>Try another phrase or show all source types.</p></div>';
      return;
    }
    els.inboxCards.innerHTML = filtered.map((source, index) => {
      const tags = source.tags.slice(0, 2).map(tag => `<span>#${escapeHtml(tag)}</span>`).join('');
      const attachmentCount = source.attachments.length ? `<span class="card-attachments"><svg><use href="#i-paperclip"></use></svg>${source.attachments.length}</span>` : '';
      return `<button class="source-card ${source.id === activeId ? 'active' : ''}" type="button" data-source-id="${source.id}" style="--float-duration:${7 + index % 6}s;--float-delay:-${index % 5}s">
        <span class="card-top"><span class="card-domain">${escapeHtml(source.domain || 'SOURCE')}</span><span class="type-chip" data-type="${source.type}">${escapeHtml(TYPE_LABELS[source.type])}</span></span>
        <span class="source-card-title">${escapeHtml(source.title || source.url)}</span>
        <span class="card-bottom"><span class="card-tags">${tags || '<span>unfiled</span>'}</span>${attachmentCount}</span>
      </button>`;
    }).join('');
  }

  function selectSource(id, shouldScroll = false) {
    const source = sourceById(id);
    if (!source) return;
    activeId = id;
    renderInbox();
    renderEditor();
    if (shouldScroll && window.matchMedia('(max-width: 800px)').matches) {
      $('.desk-panel').scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  }

  function renderEditor() {
    const source = activeSource();
    els.deskEmpty.hidden = Boolean(source);
    els.sourceEditor.hidden = !source;
    els.deskPosition.hidden = !source;
    revokeAttachmentUrls();
    if (!source) return;

    const siblings = state.sources.filter(item => item.status === source.status);
    els.deskPosition.textContent = `${siblings.findIndex(item => item.id === source.id) + 1} OF ${siblings.length} · ${source.status === 'inbox' ? 'INBOX' : 'FILED'}`;
    els.sourceMonogram.textContent = (source.domain || 'S').charAt(0).toUpperCase();
    els.sourceDomain.textContent = source.domain || 'local source';
    els.sourceStatusPill.textContent = source.status === 'timeline' ? 'FILED' : 'INBOX';
    els.sourceStatusPill.classList.toggle('timeline', source.status === 'timeline');
    els.sourceTitle.value = source.title;
    els.sourceOpenLink.href = source.url;
    els.previewExternal.href = source.url;
    els.previewAddress.textContent = source.url;
    els.previewFrame.removeAttribute('src');
    els.previewPlaceholder.hidden = false;
    els.reloadPreview.hidden = true;
    els.closePreviewButton.hidden = true;
    $$('input[name="sourceType"]').forEach(input => { input.checked = input.value === source.type; });
    els.sourceDate.value = source.dateInput;
    els.datePrecision.value = source.datePrecision;
    updateDatePlaceholder(source.datePrecision);
    showDateFeedback(parseResearchDate(source.dateInput, source.datePrecision), source.datePrecision);
    els.sourceNotes.value = source.notes;
    els.sourceQuote.value = source.quote;
    els.sourceTags.value = source.tags.join(', ');
    els.sourceCredibility.value = source.credibility;
    els.videoConfirmed.checked = source.videoConfirmed;
    renderRating(source.relevance);
    updateVideoConfirmedVisibility();
    els.returnToInboxButton.hidden = source.status !== 'timeline';
    els.fileSourceButton.querySelector('span').textContent = source.status === 'timeline' ? 'Update chronology' : 'File in chronology';
    renderAttachments(source);
    updateMetadataFeedback(source);
    queueMetadataLookup(source);
  }

  function renderRating(rating) {
    $$('[data-rating]', els.relevanceRating).forEach(button => button.classList.toggle('active', Number(button.dataset.rating) <= rating));
  }

  function updateVideoConfirmedVisibility() {
    const source = activeSource();
    if (!source) return;
    const hasVideo = ['video', 'article-video'].includes(source.type) || source.attachments.some(meta => meta.type.startsWith('video/'));
    els.videoConfirmedRow.hidden = !hasVideo;
  }

  function loadPreview() {
    const source = activeSource();
    if (!source?.url) return;
    els.previewFrame.src = previewUrl(source.url);
    els.previewPlaceholder.hidden = true;
    els.reloadPreview.hidden = false;
    els.closePreviewButton.hidden = false;
  }

  function closePreview() {
    els.previewFrame.removeAttribute('src');
    els.previewPlaceholder.hidden = false;
    els.reloadPreview.hidden = true;
    els.closePreviewButton.hidden = true;
  }

  function applyUrlDateInference(source) {
    if (!source || source.dateSource === 'manual' || source.dateISO || source.dateInput) return false;
    const inferred = inferDateFromUrl(source.url);
    if (!inferred) return false;
    source.dateInput = inferred.input;
    source.dateISO = inferred.iso;
    source.datePrecision = inferred.precision;
    source.dateSource = 'url';
    source.metadataMessage = 'Date inferred from the URL.';
    return true;
  }

  function inferDateFromUrl(value) {
    try {
      const url = new URL(value);
      const queryKeys = ['date', 'published', 'pubdate', 'publication_date', 'release_date', 'article_date'];
      for (const key of queryKeys) {
        const candidate = url.searchParams.get(key);
        const parsed = normalizeMetadataDate(candidate);
        if (parsed) return parsed;
      }
      const path = decodeURIComponent(url.pathname);
      let match = path.match(/(?:^|\/)((?:19|20)\d{2})[\/_-](0?[1-9]|1[0-2])[\/_-](0?[1-9]|[12]\d|3[01])(?:\/|$)/);
      if (match) return makeDateMetadata(Number(match[1]), Number(match[2]), Number(match[3]), 'exact');
      match = path.match(/(?:^|\/)(0?[1-9]|[12]\d|3[01])[\/_-](0?[1-9]|1[0-2])[\/_-]((?:19|20)\d{2})(?:\/|$)/);
      if (match) return makeDateMetadata(Number(match[3]), Number(match[2]), Number(match[1]), 'exact');
      match = path.match(/(?:^|\/)((?:19|20)\d{2})(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])(?:\/|$)/);
      if (match) return makeDateMetadata(Number(match[1]), Number(match[2]), Number(match[3]), 'exact');
      match = path.match(/(?:^|\/)((?:19|20)\d{2})[\/_-](0?[1-9]|1[0-2])(?:\/|$)/);
      if (match) return makeDateMetadata(Number(match[1]), Number(match[2]), 1, 'month');
    } catch {}
    return null;
  }

  function makeDateMetadata(year, month, day, precision) {
    if (year < 1000 || year > 9999 || month < 1 || month > 12 || day < 1 || day > 31) return null;
    const date = new Date(Date.UTC(year, month - 1, day));
    if (date.getUTCFullYear() !== year || date.getUTCMonth() !== month - 1 || date.getUTCDate() !== day) return null;
    const iso = String(year).padStart(4, '0') + '-' + String(month).padStart(2, '0') + '-' + String(day).padStart(2, '0');
    const input = precision === 'year' ? String(year) : precision === 'month' ? String(month).padStart(2, '0') + '/' + year : String(day).padStart(2, '0') + '/' + String(month).padStart(2, '0') + '/' + year;
    return { iso, input, precision };
  }

  function normalizeMetadataDate(value) {
    if (value === undefined || value === null || value === '') return null;
    const text = String(value).trim();
    let match = text.match(/^((?:19|20)\d{2})-(0?[1-9]|1[0-2])-([12]\d|3[01]|0?[1-9])(?=\D|$)/);
    if (match) return makeDateMetadata(Number(match[1]), Number(match[2]), Number(match[3]), 'exact');
    match = text.match(/^((?:19|20)\d{2})\/(0?[1-9]|1[0-2])\/([12]\d|3[01]|0?[1-9])(?=\D|$)/);
    if (match) return makeDateMetadata(Number(match[1]), Number(match[2]), Number(match[3]), 'exact');
    match = text.match(/^(0?[1-9]|[12]\d|3[01])[.\/-](0?[1-9]|1[0-2])[.\/-]((?:19|20)\d{2})(?=\D|$)/);
    if (match) return makeDateMetadata(Number(match[3]), Number(match[2]), Number(match[1]), 'exact');
    match = text.match(/^((?:19|20)\d{2})-(0?[1-9]|1[0-2])$/);
    if (match) return makeDateMetadata(Number(match[1]), Number(match[2]), 1, 'month');
    if (/^(?:19|20)\d{2}$/.test(text)) return makeDateMetadata(Number(text), 1, 1, 'year');
    const timestamp = /^\d{10,13}$/.test(text) ? Number(text) * (text.length === 10 ? 1000 : 1) : NaN;
    const date = Number.isFinite(timestamp) ? new Date(timestamp) : new Date(text);
    if (Number.isNaN(date.getTime())) return null;
    const year = date.getUTCFullYear();
    if (year < 1900 || year > 2099) return null;
    return makeDateMetadata(year, date.getUTCMonth() + 1, date.getUTCDate(), 'exact');
  }

  function queueMetadataLookup(source) {
    if (!source || source.metadataStatus !== 'idle') return;
    source.metadataStatus = 'queued';
    updateMetadataFeedback(source);
    setTimeout(() => {
      if (state.sources.some(item => item.id === source.id)) enrichSource(source, false);
    }, 120);
  }

  async function enrichSource(source, deep) {
    if (!source || source.metadataStatus === 'loading') return;
    source.metadataStatus = 'loading';
    source.metadataMessage = deep ? 'Using the optional public metadata reader…' : 'Checking available page metadata…';
    updateMetadataFeedback(source);
    const changes = [];
    let metadata = {};
    try {
      metadata = await collectMetadata(source.url, deep);
      const title = sanitizeMetadataTitle(metadata.title);
      if (title && source.titleSource !== 'manual' && title !== source.title) {
        source.title = title;
        source.titleSource = 'metadata';
        changes.push('headline');
      }
      if (metadata.date && source.dateSource !== 'manual') {
        source.dateInput = metadata.date.input;
        source.dateISO = metadata.date.iso;
        source.datePrecision = metadata.date.precision;
        source.dateSource = 'metadata';
        changes.push('date');
      }
      const localDate = source.dateSource === 'url';
      source.metadataStatus = changes.length || localDate ? 'found' : 'limited';
      if (changes.length) source.metadataMessage = 'Filled ' + changes.join(' and ') + '. Manual edits are protected.';
      else if (localDate) source.metadataMessage = 'Date inferred from URL; no additional metadata was exposed.';
      else source.metadataMessage = deep ? 'No reliable title or date was exposed. You can enter them manually.' : 'Publisher blocked browser metadata. Deep lookup is optional.';
    } catch {
      source.metadataStatus = source.dateSource === 'url' ? 'found' : 'limited';
      source.metadataMessage = source.dateSource === 'url' ? 'Date inferred from URL; page metadata was blocked.' : 'Publisher blocked browser metadata. Deep lookup is optional.';
    }
    source.metadataLastTriedAt = new Date().toISOString();
    scheduleLocalSave(true);
    if (activeId === source.id) {
      if (source.titleSource !== 'manual') els.sourceTitle.value = source.title;
      if (source.dateSource !== 'manual') {
        els.sourceDate.value = source.dateInput;
        els.datePrecision.value = source.datePrecision;
        updateDatePlaceholder(source.datePrecision);
        showDateFeedback(parseResearchDate(source.dateInput, source.datePrecision), source.datePrecision);
      }
      updateMetadataFeedback(source);
    }
    renderInbox();
    renderTimeline();
  }

  function updateMetadataFeedback(source) {
    if (!source || !els.smartFillButton) return;
    const loading = source.metadataStatus === 'loading' || source.metadataStatus === 'queued';
    els.smartFillButton.disabled = loading;
    els.smartFillButton.querySelector('span').textContent = loading ? 'Checking…' : source.metadataStatus === 'limited' ? 'Deep lookup' : source.metadataStatus === 'found' ? 'Refresh metadata' : 'Find title & date';
    els.metadataFeedback.textContent = source.metadataMessage || (source.dateSource === 'url' ? 'Date inferred from URL.' : 'Title and date will be checked when possible.');
    els.metadataFeedback.dataset.status = source.metadataStatus;
  }

  async function collectMetadata(url, deep) {
    const result = {};
    if (youtubeEmbedUrl(url)) {
      try {
        const response = await metadataFetch('https://www.youtube.com/oembed?format=json&url=' + encodeURIComponent(url));
        const data = await response.json();
        result.title = data.title;
      } catch {}
    } else {
      try {
        const response = await metadataFetch(url);
        const contentType = response.headers.get('content-type') || '';
        if (!contentType || /html|xhtml|text\/plain/i.test(contentType)) {
          const parsed = parsePageMetadata(await response.text());
          Object.assign(result, parsed);
        }
      } catch {}
    }
    if (deep && (!result.title || !result.date)) {
      try {
        const response = await metadataFetch('https://r.jina.ai/' + url, { headers: { Accept: 'text/plain' } });
        const parsed = parseReaderMetadata(await response.text());
        if (!result.title) result.title = parsed.title;
        if (!result.date) result.date = parsed.date;
      } catch {}
    }
    return result;
  }

  async function metadataFetch(url, options = {}) {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 9000);
    try {
      const response = await fetch(url, { ...options, signal: controller.signal, credentials: 'omit', cache: 'no-store' });
      if (!response.ok) throw new Error('Metadata request failed');
      return response;
    } finally {
      clearTimeout(timeout);
    }
  }

  function parsePageMetadata(html) {
    const doc = new DOMParser().parseFromString(html, 'text/html');
    const content = selector => doc.querySelector(selector)?.getAttribute('content')?.trim() || '';
    const nodeValue = selector => {
      const node = doc.querySelector(selector);
      return node?.getAttribute('content')?.trim() || node?.getAttribute('datetime')?.trim() || node?.getAttribute('value')?.trim() || node?.textContent?.trim() || '';
    };

    let structured = {};
    for (const script of doc.querySelectorAll('script[type="application/ld+json"], script#ld_json')) {
      try {
        const raw = script.textContent.trim().replace(/^<!--/, '').replace(/-->$/, '').replace(/;\s*$/, '');
        const found = findStructuredMetadata(JSON.parse(raw));
        if ((found.score || 0) > (structured.score || 0)) structured = found;
      } catch {}
    }

    const articleScope = doc.querySelector('[itemscope][itemtype*="schema.org/"][itemtype*="Article"]');
    const scopedValue = selector => {
      const node = articleScope?.querySelector(selector);
      return node?.getAttribute('content')?.trim() || node?.getAttribute('datetime')?.trim() || node?.textContent?.trim() || '';
    };

    const title = structured.title ||
      content('meta[property="og:title"]') ||
      content('meta[name="twitter:title"]') ||
      scopedValue('[itemprop~="headline"], [itemprop~="name"]') ||
      nodeValue('[itemprop~="headline"]') ||
      doc.querySelector('h1')?.textContent?.trim() ||
      doc.title?.trim() || '';

    const dateValue = structured.date ||
      content('meta[property="article:published_time"]') ||
      content('meta[property="og:published_time"]') ||
      content('meta[name="date"]') ||
      content('meta[name="pubdate"]') ||
      content('meta[name="publish-date"]') ||
      content('meta[name="parsely-pub-date"]') ||
      content('meta[name="sailthru.date"]') ||
      nodeValue('[itemprop~="datePublished"]') ||
      scopedValue('time[datetime]') ||
      nodeValue('time[datetime]') || '';

    return { title, date: normalizeMetadataDate(dateValue) };
  }

  function findStructuredMetadata(value, depth = 0) {
    if (!value || depth > 10) return {};
    if (Array.isArray(value)) {
      return value.reduce((best, item) => {
        const found = findStructuredMetadata(item, depth + 1);
        return (found.score || 0) > (best.score || 0) ? found : best;
      }, {});
    }
    if (typeof value !== 'object') return {};

    const typeValue = Array.isArray(value['@type']) ? value['@type'].join(' ') : String(value['@type'] || '');
    const isArticle = /Article|Posting|Reportage/i.test(typeValue);
    const isContent = isArticle || /VideoObject|WebPage/i.test(typeValue);
    const headline = value.headline || '';
    const title = headline || (isContent ? value.name || '' : '');
    const date = value.datePublished || value.uploadDate || value.dateCreated || '';
    let best = {
      title: String(title || ''),
      date: String(date || ''),
      score: (isArticle ? 120 : isContent ? 50 : 0) + (headline ? 45 : title ? 15 : 0) + (value.datePublished ? 35 : date ? 15 : 0) - depth
    };

    for (const item of Object.values(value)) {
      if (!item || typeof item !== 'object') continue;
      const found = findStructuredMetadata(item, depth + 1);
      if ((found.score || 0) > (best.score || 0)) best = found;
    }
    return best;
  }

  function parseReaderMetadata(text) {
    const title = text.match(/^Title:\s*(.+)$/im)?.[1]?.trim() || text.match(/^#\s+(.+)$/m)?.[1]?.trim() || '';
    const dateValue = text.match(/^(?:Published Time|Published|Date Published):\s*(.+)$/im)?.[1]?.trim() || '';
    return { title, date: normalizeMetadataDate(dateValue) };
  }

  function sanitizeMetadataTitle(value) {
    const title = String(value || '')
      .replace(/\s+/g, ' ')
      .replace(/\s*(?:\||[-–—])\s*(?:AMBEBI\.?GE|KVIRISPALITRA\.GE|Kviris\s+Palitra|Interpressnews(?:\.ge)?)\s*$/i, '')
      .trim()
      .slice(0, 300);
    if (title.length < 3 || /^(just a moment|access denied|attention required|error|home)$/i.test(title)) return '';
    return title;
  }

  function youtubeEmbedUrl(value) {
    try {
      const url = new URL(value);
      let host = url.hostname.toLowerCase().replace(/^www\./, '');
      let id = '';
      let list = url.searchParams.get('list') || '';
      if (host === 'youtu.be') id = url.pathname.split('/').filter(Boolean)[0] || '';
      if (host === 'm.youtube.com' || host === 'music.youtube.com') host = 'youtube.com';
      if (host === 'youtube-nocookie.com') host = 'youtube.com';
      if (host === 'youtube.com') {
        id = url.searchParams.get('v') || url.pathname.match(/\/(?:shorts|embed|live)\/([^/?]+)/)?.[1] || id;
        if (url.pathname.includes('/playlist') && list) id = '';
      }
      if (!id && !list) return '';
      const base = id ? 'https://www.youtube-nocookie.com/embed/' + encodeURIComponent(id) : 'https://www.youtube-nocookie.com/embed/videoseries';
      const params = new URLSearchParams();
      params.set('rel', '0');
      if (list) params.set('list', list);
      const start = youtubeStartSeconds(url.searchParams.get('t') || url.searchParams.get('start') || '');
      if (start) params.set('start', String(start));
      return base + '?' + params.toString();
    } catch { return ''; }
  }

  function youtubeStartSeconds(value) {
    const text = String(value || '');
    if (/^\d+$/.test(text)) return Number(text);
    const match = text.match(/(?:(\d+)h)?(?:(\d+)m)?(?:(\d+)s)?/i);
    if (!match) return 0;
    return Number(match[1] || 0) * 3600 + Number(match[2] || 0) * 60 + Number(match[3] || 0);
  }

  function previewUrl(url) {
    const youtube = youtubeEmbedUrl(url);
    if (youtube) return youtube;
    try {
      const parsed = new URL(url);
      const host = parsed.hostname.replace(/^www\./, '');
      if (host === 'vimeo.com' && /^\/\d+/.test(parsed.pathname)) return 'https://player.vimeo.com/video/' + parsed.pathname.split('/')[1];
    } catch {}
    return url;
  }

  function renderTimeline() {
    const all = state.sources.filter(source => source.status === 'timeline');
    const query = els.timelineSearch.value.trim().toLowerCase();
    const type = els.timelineTypeFilter.value;
    let filtered = all.filter(source => {
      const haystack = `${source.title} ${source.domain} ${source.content} ${source.notes} ${source.quote} ${source.tags.join(' ')}`.toLowerCase();
      return (!query || haystack.includes(query)) && (type === 'all' || source.type === type);
    });
    filtered = sortSources(filtered, state.project.sortDirection);
    els.timelineCount.textContent = all.length;
    els.timelineEmpty.hidden = all.length > 0;
    els.timelineList.hidden = all.length === 0;
    els.sortDirectionButton.dataset.direction = state.project.sortDirection;
    els.sortDirectionButton.innerHTML = `${state.project.sortDirection === 'asc' ? 'Oldest first' : 'Newest first'} <span>${state.project.sortDirection === 'asc' ? '↑' : '↓'}</span>`;
    renderTimelineStats(all);
    if (!all.length) {
      els.timelineList.innerHTML = '';
      return;
    }
    if (!filtered.length) {
      els.timelineList.innerHTML = '<div class="empty-state" style="min-height:250px"><h2>No filed sources match.</h2><p>Clear the search or change the source type filter.</p></div>';
      return;
    }

    let lastGroup = null;
    els.timelineList.innerHTML = filtered.map(source => {
      const group = source.dateISO ? source.dateISO.slice(0, 4) : 'Date to verify';
      const groupTitle = group !== lastGroup ? `<h3 class="timeline-group-title">${escapeHtml(group)}</h3>` : '';
      lastGroup = group;
      const tagMeta = source.tags.slice(0, 4).map(tag => `<span>#${escapeHtml(tag)}</span>`).join('');
      const attachmentMeta = source.attachments.length ? `<span>${source.attachments.length} attachment${source.attachments.length === 1 ? '' : 's'}</span>` : '';
      const videoMeta = source.videoConfirmed ? '<span class="video-ok">video downloaded ✓</span>' : '';
      return `${groupTitle}<article class="timeline-item">
        <div class="timeline-date"><strong>${escapeHtml(formatSourceDate(source, false))}</strong><span>${escapeHtml(datePrecisionLabel(source.datePrecision))}</span></div>
        <i class="timeline-dot"></i>
        <div class="timeline-card">
          <div class="timeline-card-main">
            <div class="timeline-card-top"><span class="type-chip" data-type="${source.type}">${escapeHtml(TYPE_LABELS[source.type])}</span><span class="timeline-card-domain">${escapeHtml(source.domain)}</span><i class="quality-dot ${source.credibility}" title="${escapeHtml(source.credibility)}"></i></div>
            <h3>${escapeHtml(source.title || source.url)}</h3>
            ${source.notes ? `<p class="timeline-card-note">${escapeHtml(source.notes)}</p>` : ''}
            <div class="timeline-meta">${tagMeta}${attachmentMeta}${videoMeta}</div>
          </div>
          <div class="timeline-card-actions">
            <button type="button" data-copy-citation="${source.id}" title="Copy citation"><svg><use href="#i-copy"></use></svg></button>
            <a href="${escapeAttribute(source.url)}" target="_blank" rel="noopener noreferrer" title="Open source"><svg><use href="#i-external"></use></svg></a>
            <button type="button" data-edit-source="${source.id}" title="Inspect or edit"><svg><use href="#i-arrow"></use></svg></button>
          </div>
        </div>
      </article>`;
    }).join('');
  }

  function renderTimelineStats(sources) {
    const known = sources.filter(source => source.dateISO).length;
    const unknown = sources.length - known;
    const attachments = sources.reduce((sum, source) => sum + source.attachments.length, 0);
    const primary = sources.filter(source => source.credibility === 'primary').length;
    els.timelineStats.innerHTML = [
      `<span class="stat-chip"><strong>${known}</strong> dated</span>`,
      `<span class="stat-chip"><strong>${unknown}</strong> date${unknown === 1 ? '' : 's'} to verify</span>`,
      `<span class="stat-chip"><strong>${attachments}</strong> local file${attachments === 1 ? '' : 's'}</span>`,
      `<span class="stat-chip"><strong>${primary}</strong> primary source${primary === 1 ? '' : 's'}</span>`
    ].join('');
  }

  function sortSources(sources, direction) {
    return [...sources].sort((a, b) => {
      if (!a.dateISO && !b.dateISO) return new Date(a.addedAt) - new Date(b.addedAt);
      if (!a.dateISO) return 1;
      if (!b.dateISO) return -1;
      const comparison = a.dateISO.localeCompare(b.dateISO);
      return direction === 'asc' ? comparison : -comparison;
    });
  }

  function fileActiveSource(event) {
    event.preventDefault();
    const source = activeSource();
    if (!source) return;
    const result = applyDateToSource(source);
    if (!result.valid) {
      showDateFeedback(result, source.datePrecision);
      els.sourceDate.focus();
      toast('Check the date, or mark it unknown.', 'error');
      return;
    }
    const wasInbox = source.status === 'inbox';
    source.status = 'timeline';
    source.completedAt ||= new Date().toISOString();
    source.title = els.sourceTitle.value.trim() || source.url;
    scheduleLocalSave(true);
    renderTimeline();
    if (wasInbox) {
      const next = state.sources.find(item => item.status === 'inbox' && item.id !== source.id);
      if (next) {
        activeId = next.id;
        renderInbox();
        renderEditor();
        toast('Filed. The next source is ready.');
      } else {
        renderInbox();
        renderEditor();
        toast('Filed — your link mess is clear.');
      }
    } else {
      renderInbox();
      renderEditor();
      toast('Chronology entry updated.');
    }
  }

  function returnActiveToInbox() {
    const source = activeSource();
    if (!source) return;
    source.status = 'inbox';
    source.completedAt = null;
    scheduleLocalSave(true);
    renderAll();
    toast('Source returned to the link mess.');
  }

  async function deleteActiveSource() {
    const source = activeSource();
    if (!source) return;
    const confirmed = await confirmAction('Delete this source?', 'Its notes and locally stored attachments will be removed from this browser. This cannot be undone.', 'Delete source');
    if (!confirmed) return;
    await Promise.all(source.attachments.map(meta => deleteAttachmentBlob(meta.id)));
    state.sources = state.sources.filter(item => item.id !== source.id);
    activeId = state.sources.find(item => item.status === 'inbox')?.id || null;
    scheduleLocalSave(true);
    renderAll();
    toast('Source deleted.', 'warning');
  }


  function openStoryLab() {
    storyWindow = window.open('./board.html', 'sourceDeskStoryLab');
    if (!storyWindow) {
      toast('Your browser blocked the Story Lab tab. Allow pop-ups for this local file and try again.', 'warning', 6500);
      return;
    }
    setTimeout(() => sendStorySnapshot(storyWindow), 500);
  }

  function handleStoryMessage(event) {
    if (event.source !== storyWindow) return;
    if (event.data?.type === 'SOURCE_DESK_STORY_REQUEST') sendStorySnapshot(event.source);
  }

  function sendStorySnapshot(target) {
    if (!target || target.closed) return;
    target.postMessage({
      type: 'SOURCE_DESK_STORY_CASE',
      payload: {
        app: 'Source Desk',
        format: 'sourcedesk-live-story',
        version: 3,
        exportedAt: new Date().toISOString(),
        data: JSON.parse(JSON.stringify(state))
      }
    }, '*');
  }

  function openReadingRoom() {
    readerWindow = window.open('./reader.html', 'sourceDeskReadingRoom');
    if (!readerWindow) {
      toast('Your browser blocked the Reading Room tab. Allow pop-ups for this local file and try again.', 'warning', 6500);
      return;
    }
    setTimeout(() => sendReaderSnapshot(readerWindow), 500);
  }

  async function handleReaderMessage(event) {
    if (event.source !== readerWindow) return;
    if (event.data?.type === 'SOURCE_DESK_READER_REQUEST') {
      await sendReaderSnapshot(event.source);
      return;
    }
    if (event.data?.type !== 'SOURCE_DESK_READER_UPDATE' || event.data.projectId !== state.project.id) return;
    const source = sourceById(event.data.sourceId);
    if (!source) return;
    const operation = event.data.operation;
    if (operation === 'delete') {
      await Promise.all(source.attachments.map(meta => deleteAttachmentBlob(meta.id)));
      state.sources = state.sources.filter(item => item.id !== source.id);
      if (activeId === source.id) activeId = state.sources[0]?.id || null;
    } else if (operation === 'demote') {
      source.status = 'inbox';
      if (activeId === source.id) activeId = source.id;
    } else if (operation === 'update') {
      const patch = event.data.patch || {};
      const editable = ['title', 'type', 'dateInput', 'dateISO', 'datePrecision', 'notes', 'quote', 'content', 'tags', 'credibility', 'relevance', 'primaryAttachmentId'];
      editable.forEach(field => { if (Object.prototype.hasOwnProperty.call(patch, field)) source[field] = patch[field]; });
      source.titleSource = 'manual';
      source.dateSource = 'manual';
    }
    saveLocalNow();
    renderAll();
    event.source.postMessage({ type: 'SOURCE_DESK_READER_ACK', sourceId: event.data.sourceId, operation }, '*');
  }

  async function sendReaderSnapshot(target) {
    if (!target || target.closed) return;
    const assets = [];
    for (const source of state.sources) {
      for (const meta of source.attachments) {
        try {
          const blob = await getAttachmentBlob(meta.id);
          if (blob) assets.push({ ...meta, sourceId: source.id, blob });
        } catch {}
      }
    }
    target.postMessage({
      type: 'SOURCE_DESK_READER_CASE',
      payload: {
        app: 'Source Desk',
        format: 'sourcedesk-live-reader',
        version: 2,
        exportedAt: new Date().toISOString(),
        data: JSON.parse(JSON.stringify(state)),
        assets
      }
    }, '*');
  }

  function openAddDialog() {
    els.bulkUrls.value = '';
    els.bulkTags.value = '';
    els.bulkType.value = 'auto';
    updateUrlParseFeedback();
    els.addDialog.showModal();
    setTimeout(() => els.bulkUrls.focus(), 40);
  }

  function updateUrlParseFeedback() {
    const urls = extractUrls(els.bulkUrls.value);
    els.urlParseFeedback.textContent = urls.length ? `${urls.length} link${urls.length === 1 ? '' : 's'} found. Duplicates in either the link mess or the filed chronology will be skipped.` : 'Ready for the mess.';
  }

  function addBulkSources() {
    const urls = extractUrls(els.bulkUrls.value);
    if (!urls.length) {
      els.urlParseFeedback.textContent = 'No web links found yet — try including the domain ending, such as .com or .org.';
      els.bulkUrls.focus();
      return;
    }
    const result = addUrls(urls, els.bulkType.value, parseTags(els.bulkTags.value));
    els.addDialog.close();
    renderInbox();
    if (!activeId && result.added[0]) selectSource(result.added[0].id);
    toast(`${result.added.length} source${result.added.length === 1 ? '' : 's'} added${result.duplicates ? ` · ${result.duplicates} duplicate${result.duplicates === 1 ? '' : 's'} skipped` : ''}.`);
  }

  function addUrls(urls, defaultType = 'auto', tags = []) {
    const existing = new Map();
    state.sources.forEach(source => {
      const key = duplicateKey(source.url || source.normalizedUrl);
      if (!key) return;
      const previous = existing.get(key);
      if (!previous || source.status === 'timeline') existing.set(key, source.status);
    });
    const added = [];
    let duplicates = 0;
    let filedDuplicates = 0;
    let inboxDuplicates = 0;
    let batchDuplicates = 0;
    urls.forEach(rawUrl => {
      const url = ensureUrl(rawUrl);
      const normalizedUrl = normalizeUrl(url);
      const key = duplicateKey(url);
      const origin = existing.get(key);
      if (!normalizedUrl || !key || origin) {
        duplicates += 1;
        if (origin === 'timeline') filedDuplicates += 1;
        else if (origin === 'inbox') inboxDuplicates += 1;
        else if (origin === 'batch') batchDuplicates += 1;
        return;
      }
      const source = cleanSource({
        id: uid('src'),
        url,
        normalizedUrl,
        type: defaultType === 'auto' ? detectType(url) : defaultType,
        tags: [...tags]
      });
      applyUrlDateInference(source);
      existing.set(key, 'batch');
      state.sources.push(source);
      added.push(source);
    });
    if (added.length) scheduleLocalSave(true);
    if (filedDuplicates) {
      toast(filedDuplicates + ' URL' + (filedDuplicates === 1 ? '' : 's') + ' skipped because ' + (filedDuplicates === 1 ? 'it is' : 'they are') + ' already filed in the chronology.', 'warning', 6000);
    }
    return { added, duplicates, filedDuplicates, inboxDuplicates, batchDuplicates };
  }

  function extractUrls(text) {
    const prepared = String(text || '').replace(/\u00a0/g, ' ');
    const matches = prepared.match(/(?:https?:\/\/|www\.)[^\s<>"'`]+|(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+(?:com|org|net|io|co|gov|edu|info|tv|me|ly|ai|app|dev|uk|ge|de|fr|ca|au|jp|ru|archive)(?:\/[^\s<>"'`]*)?/gi) || [];
    return [...new Set(matches.map(value => value.replace(/[),.;!?\]}]+$/g, '')).map(ensureUrl).filter(url => {
      try { return ['http:', 'https:'].includes(new URL(url).protocol); } catch { return false; }
    }))];
  }

  function ensureUrl(value) {
    let url = String(value || '').trim();
    if (!/^https?:\/\//i.test(url)) url = `https://${url}`;
    return url;
  }

  function duplicateKey(value) {
    try {
      const url = new URL(ensureUrl(value));
      let host = url.hostname.toLowerCase().replace(/^www\./, '');
      if (host === 'mobile.twitter.com' || host === 'twitter.com') host = 'x.com';
      if (host === 'm.youtube.com' || host === 'music.youtube.com' || host === 'youtube-nocookie.com') host = 'youtube.com';

      let videoId = '';
      if (host === 'youtu.be') videoId = url.pathname.split('/').filter(Boolean)[0] || '';
      if (host === 'youtube.com') {
        videoId = url.searchParams.get('v') || url.pathname.match(/\/(?:shorts|embed|live)\/([^/?]+)/)?.[1] || '';
      }
      if (videoId) return 'youtube:' + videoId;
      if (host === 'vimeo.com') {
        const vimeoId = url.pathname.match(/\/(?:video\/)?(\d+)/)?.[1];
        if (vimeoId) return 'vimeo:' + vimeoId;
      }

      let pathname = url.pathname.replace(/\/{2,}/g, '/').replace(/\/(?:index\.(?:html?|php))$/i, '');
      if (pathname.length > 1) pathname = pathname.replace(/\/+$/, '');
      if (pathname === '/') pathname = '';
      const pairs = [...url.searchParams.entries()]
        .filter(([key]) => !TRACKING_PARAMS.test(key))
        .sort(([keyA, valueA], [keyB, valueB]) => keyA.localeCompare(keyB) || valueA.localeCompare(valueB));
      const params = new URLSearchParams();
      pairs.forEach(([key, itemValue]) => params.append(key, itemValue));
      const query = params.toString();
      return host + (url.port ? ':' + url.port : '') + pathname + (query ? '?' + query : '');
    } catch { return ''; }
  }
  function normalizeUrl(value) {
    try {
      const url = new URL(ensureUrl(value));
      url.hash = '';
      [...url.searchParams.keys()].forEach(key => { if (TRACKING_PARAMS.test(key)) url.searchParams.delete(key); });
      url.hostname = url.hostname.toLowerCase().replace(/^www\./, '');
      if (url.pathname.length > 1) url.pathname = url.pathname.replace(/\/+$/, '');
      return url.toString();
    } catch { return ''; }
  }

  function domainFromUrl(value) {
    try { return new URL(ensureUrl(value)).hostname.replace(/^www\./, ''); } catch { return ''; }
  }

  function suggestedTitle(value) {
    try {
      const url = new URL(ensureUrl(value));
      const last = decodeURIComponent(url.pathname.split('/').filter(Boolean).pop() || 'Homepage')
        .replace(/\.(html?|php|aspx|pdf)$/i, '')
        .replace(/[-_]+/g, ' ')
        .trim();
      if (!last || /^watch$/i.test(last)) return `Source from ${url.hostname.replace(/^www\./, '')}`;
      return last.replace(/\b\w/g, char => char.toUpperCase()).slice(0, 180);
    } catch { return 'Untitled source'; }
  }

  function detectType(value) {
    const url = value.toLowerCase();
    if (/youtube\.com|youtube-nocookie\.com|youtu\.be|vimeo\.com|dailymotion\.com|tiktok\.com/.test(url)) return 'video';
    if (/\.pdf(?:[?#]|$)|docs\.google\.com/.test(url)) return 'document';
    if (/\.(?:jpe?g|png|gif|webp|svg)(?:[?#]|$)/.test(url)) return 'image';
    if (/twitter\.com|x\.com|reddit\.com|threads\.net|bsky\.app|facebook\.com|instagram\.com/.test(url)) return 'social';
    return 'article';
  }

  function parseTags(value) {
    const tags = Array.isArray(value) ? value : String(value).split(',');
    return [...new Set(tags.map(tag => String(tag).trim().replace(/^#/, '').toLowerCase()).filter(Boolean))].slice(0, 30);
  }

  function autoFormatExactDate(value) {
    const text = String(value || '');
    if (/^\d{0,2}$/.test(text)) return text.length === 2 ? `${text}/` : text;
    if (/^\d{2}\/\d{0,2}$/.test(text)) return text.length === 5 ? `${text}/` : text;
    if (/^\d{2}\/\d{2}\/\d{0,4}$/.test(text)) return text;
    if (/^\d{3,8}$/.test(text)) {
      const day = text.slice(0, 2);
      const month = text.slice(2, 4);
      const year = text.slice(4, 8);
      return `${day}/${month}${text.length >= 4 ? '/' : ''}${year}`;
    }
    return text;
  }

  function parseResearchDate(input, precision) {
    const text = String(input || '').trim();
    if (precision === 'unknown') return { valid: true, iso: null, display: 'Date unknown — it can still be filed.' };
    if (!text) return { valid: false, iso: null, display: 'Add a date, or mark it unknown.' };
    let year;
    let month = 1;
    let day = 1;
    let normalizedInput;

    if (precision === 'year') {
      const match = text.match(/^(\d{4})$/);
      if (!match) return { valid: false, iso: null, display: 'Use YYYY for a year-only date.' };
      year = Number(match[1]);
      normalizedInput = String(year);
    } else if (precision === 'month') {
      const match = text.match(/^(\d{1,2})[\/.-](\d{4})$/);
      if (!match) return { valid: false, iso: null, display: 'Use MM/YYYY for a month-only date.' };
      month = Number(match[1]);
      year = Number(match[2]);
      normalizedInput = `${String(month).padStart(2, '0')}/${year}`;
    } else {
      const compact = text.match(/^(\d{2})(\d{2})(\d{2}|\d{4})$/);
      const exactText = compact ? `${compact[1]}/${compact[2]}/${compact[3]}` : text;
      const match = exactText.match(/^(\d{1,2})[\/.-](\d{1,2})[\/.-](\d{2}|\d{4})$/);
      if (!match) return { valid: false, iso: null, display: 'Use DD/MM/YY, DD/MM/YYYY, or type the digits continuously.' };
      day = Number(match[1]);
      month = Number(match[2]);
      year = Number(match[3]);
      if (year < 100) year += year <= 35 ? 2000 : 1900;
      normalizedInput = `${String(day).padStart(2, '0')}/${String(month).padStart(2, '0')}/${year}`;
    }
    if (year < 1000 || year > 9999 || month < 1 || month > 12 || day < 1 || day > 31) return { valid: false, iso: null, display: 'That date is outside the supported range.' };
    const date = new Date(Date.UTC(year, month - 1, day));
    if (date.getUTCFullYear() !== year || date.getUTCMonth() !== month - 1 || date.getUTCDate() !== day) return { valid: false, iso: null, display: 'That day does not exist — check the month and day.' };
    const iso = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    const prefix = precision === 'approximate' ? 'Approx. ' : '';
    const display = precision === 'year' ? `${year}` : precision === 'month' ? `${MONTHS[month - 1]} ${year}` : `${prefix}${String(day).padStart(2, '0')} ${MONTHS[month - 1]} ${year}`;
    return { valid: true, iso, display, normalizedInput };
  }

  function applyDateToSource(source) {
    const result = parseResearchDate(source.dateInput, source.datePrecision);
    source.dateISO = result.valid ? result.iso : null;
    return result;
  }

  function showDateFeedback(result, precision) {
    els.dateFeedback.textContent = result.display;
    els.dateFeedback.classList.toggle('error', !result.valid);
    els.dateFeedback.classList.toggle('valid', result.valid);
    if (precision === 'unknown') els.dateFeedback.textContent = 'Date unknown — this will file into the research-later lane.';
  }

  function updateDatePlaceholder(precision) {
    els.sourceDate.disabled = precision === 'unknown';
    els.calendarButton.disabled = precision === 'unknown' || precision === 'month' || precision === 'year';
    els.sourceDate.placeholder = precision === 'year' ? 'YYYY' : precision === 'month' ? 'MM/YYYY' : precision === 'unknown' ? 'DATE UNKNOWN' : 'DD/MM/YYYY';
  }

  function formatSourceDate(source, includePrecision = true) {
    if (!source.dateISO) return 'Date TBC';
    const [year, month, day] = source.dateISO.split('-').map(Number);
    let text;
    if (source.datePrecision === 'year') text = String(year);
    else if (source.datePrecision === 'month') text = `${MONTHS[month - 1]} ${year}`;
    else text = `${String(day).padStart(2, '0')} ${MONTHS[month - 1]} ${year}`;
    if (source.datePrecision === 'approximate') text = `c. ${text}`;
    return includePrecision ? `${text} (${datePrecisionLabel(source.datePrecision)})` : text;
  }

  function datePrecisionLabel(precision) {
    return ({ exact: 'exact date', approximate: 'approximate', month: 'month only', year: 'year only', unknown: 'needs research' })[precision] || precision;
  }

  function bindInboxDrop() {
    ['dragenter', 'dragover'].forEach(type => els.inboxDrop.addEventListener(type, event => {
      event.preventDefault();
      els.inboxDrop.classList.add('drag-over');
    }));
    ['dragleave', 'drop'].forEach(type => els.inboxDrop.addEventListener(type, event => {
      event.preventDefault();
      if (type === 'drop') handleInboxDrop(event);
      els.inboxDrop.classList.remove('drag-over');
    }));
  }

  async function handleInboxDrop(event) {
    const files = [...event.dataTransfer.files];
    const textFiles = files.filter(file => file.type === 'text/plain' || /\.(txt|md|csv)$/i.test(file.name));
    let text = event.dataTransfer.getData('text/uri-list') || event.dataTransfer.getData('text/plain') || '';
    if (textFiles.length) text += `\n${(await Promise.all(textFiles.map(file => file.text()))).join('\n')}`;
    const urls = extractUrls(text);
    if (!urls.length) {
      toast('Drop a .txt file or text containing web links here. Attach media inside a selected source.', 'warning');
      return;
    }
    const result = addUrls(urls);
    renderInbox();
    if (!activeId && result.added[0]) selectSource(result.added[0].id);
    toast(`${result.added.length} source${result.added.length === 1 ? '' : 's'} dropped into the mess.`);
  }

  function bindAttachmentDrop() {
    els.attachmentDrop.addEventListener('click', () => els.attachmentInput.click());
    ['dragenter', 'dragover'].forEach(type => els.attachmentDrop.addEventListener(type, event => {
      event.preventDefault(); event.stopPropagation(); els.attachmentDrop.classList.add('drag-over');
    }));
    ['dragleave', 'drop'].forEach(type => els.attachmentDrop.addEventListener(type, event => {
      event.preventDefault(); event.stopPropagation(); els.attachmentDrop.classList.remove('drag-over');
      if (type === 'drop') addAttachments([...event.dataTransfer.files]);
    }));
  }

  function handleAttachmentPaste(event) {
    if (!activeSource() || els.sourceEditor.hidden) return;
    const files = [...(event.clipboardData?.items || [])].filter(item => item.kind === 'file').map(item => item.getAsFile()).filter(Boolean);
    if (files.length) {
      event.preventDefault();
      addAttachments(files);
    }
  }

  async function addAttachments(files) {
    const source = activeSource();
    if (!source || !files.length) return;
    let failures = 0;
    for (const file of files) {
      const id = uid('att');
      const meta = { id, sourceId: source.id, name: file.name || `pasted-${Date.now()}`, type: file.type || 'application/octet-stream', size: file.size, addedAt: new Date().toISOString(), embedded: false };
      try {
        await putAttachmentBlob({ ...meta, blob: file });
      } catch {
        volatileBlobs.set(id, file);
        failures += 1;
      }
      source.attachments.push(meta);
    }
    els.attachmentInput.value = '';
    scheduleLocalSave(true);
    renderAttachments(source);
    renderInbox();
    renderTimeline();
    updateVideoConfirmedVisibility();
    toast(`${files.length} file${files.length === 1 ? '' : 's'} attached${failures ? ' for this session only' : ''}.`, failures ? 'warning' : 'success');
  }

  async function renderAttachments(source) {
    const token = source.id;
    revokeAttachmentUrls();
    if (!source.attachments.length) {
      els.attachmentList.innerHTML = '';
      return;
    }
    const items = await Promise.all(source.attachments.map(async meta => {
      let blob;
      try { blob = await getAttachmentBlob(meta.id); } catch { blob = volatileBlobs.get(meta.id); }
      if (activeId !== token) return '';
      let thumb = fileKind(meta);
      if (blob && meta.type.startsWith('image/')) {
        const objectUrl = URL.createObjectURL(blob);
        attachmentObjectUrls.push(objectUrl);
        thumb = `<img src="${objectUrl}" alt="">`;
      }
      const unavailable = blob ? '' : ' · file not in this browser';
      return `<div class="attachment-item" data-attachment-id="${meta.id}">
        <button class="attachment-thumb" type="button" data-open-attachment="${meta.id}" title="Open attachment">${thumb}</button>
        <div class="attachment-info"><strong title="${escapeAttribute(meta.name)}">${escapeHtml(meta.name)}</strong><span>${formatBytes(meta.size)}${unavailable}</span></div>
        <button type="button" data-remove-attachment="${meta.id}" title="Remove attachment"><svg><use href="#i-close"></use></svg></button>
      </div>`;
    }));
    if (activeId === token) els.attachmentList.innerHTML = items.join('');
  }

  async function handleAttachmentListClick(event) {
    const remove = event.target.closest('[data-remove-attachment]');
    const open = event.target.closest('[data-open-attachment]');
    if (remove) {
      const source = activeSource();
      const id = remove.dataset.removeAttachment;
      source.attachments = source.attachments.filter(meta => meta.id !== id);
      await deleteAttachmentBlob(id);
      scheduleLocalSave(true);
      renderAttachments(source);
      renderInbox();
      renderTimeline();
      updateVideoConfirmedVisibility();
    }
    if (open) {
      const id = open.dataset.openAttachment;
      let blob;
      try { blob = await getAttachmentBlob(id); } catch { blob = volatileBlobs.get(id); }
      if (!blob) {
        toast('That file is not stored in this browser. Reattach it from your device.', 'warning');
        return;
      }
      const objectUrl = URL.createObjectURL(blob);
      window.open(objectUrl, '_blank', 'noopener');
      setTimeout(() => URL.revokeObjectURL(objectUrl), 60000);
    }
  }

  function fileKind(meta) {
    if (meta.type.startsWith('video/')) return '<svg><use href="#i-play"></use></svg>';
    if (meta.type.startsWith('image/')) return '<svg><use href="#i-image"></use></svg>';
    if (meta.type.includes('pdf')) return 'PDF';
    if (meta.type.startsWith('audio/')) return 'AUD';
    return 'FILE';
  }

  function revokeAttachmentUrls() {
    attachmentObjectUrls.forEach(url => URL.revokeObjectURL(url));
    attachmentObjectUrls = [];
  }

  function openEvidenceDb() {
    if (dbPromise) return dbPromise;
    dbPromise = new Promise((resolve, reject) => {
      if (!window.indexedDB) return reject(new Error('IndexedDB unavailable'));
      const request = indexedDB.open(DB_NAME, 1);
      request.onupgradeneeded = () => {
        const db = request.result;
        if (!db.objectStoreNames.contains(DB_STORE)) db.createObjectStore(DB_STORE, { keyPath: 'id' });
      };
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
    return dbPromise;
  }

  async function putAttachmentBlob(record) {
    const db = await openEvidenceDb();
    return idbRequest(db, 'readwrite', store => store.put(record));
  }

  async function getAttachmentRecord(id) {
    if (volatileBlobs.has(id)) return { id, blob: volatileBlobs.get(id) };
    const db = await openEvidenceDb();
    return idbRequest(db, 'readonly', store => store.get(id));
  }

  async function getAttachmentBlob(id) {
    return (await getAttachmentRecord(id))?.blob || null;
  }

  async function deleteAttachmentBlob(id) {
    volatileBlobs.delete(id);
    try {
      const db = await openEvidenceDb();
      return await idbRequest(db, 'readwrite', store => store.delete(id));
    } catch { return undefined; }
  }

  function idbRequest(db, mode, action) {
    return new Promise((resolve, reject) => {
      const transaction = db.transaction(DB_STORE, mode);
      const request = action(transaction.objectStore(DB_STORE));
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  async function exportPortableCase() {
    if (els.saveButton.disabled) return;
    els.saveButton.disabled = true;
    const original = els.saveButton.innerHTML;
    els.saveButton.textContent = 'Packing…';
    state.project.lastExportedAt = new Date().toISOString();
    saveLocalNow();
    const snapshot = JSON.parse(JSON.stringify(state));
    const embeddedAssets = [];
    const skipped = [];
    let packedBytes = 0;

    for (const source of state.sources) {
      for (const meta of source.attachments) {
        let blob;
        try { blob = await getAttachmentBlob(meta.id); } catch { blob = null; }
        if (!blob) {
          skipped.push(meta.name);
          continue;
        }
        if (blob.size > EXPORT_EACH_LIMIT || packedBytes + blob.size > EXPORT_TOTAL_LIMIT) {
          skipped.push(meta.name);
          continue;
        }
        embeddedAssets.push({
          id: meta.id,
          sourceId: source.id,
          name: meta.name,
          type: meta.type,
          size: blob.size,
          dataUrl: await blobToDataUrl(blob)
        });
        packedBytes += blob.size;
      }
    }
    const payload = { app: 'Source Desk', format: 'sourcedesk-json', version: 2, exportedAt: new Date().toISOString(), data: snapshot, embeddedAssets };
    downloadBlob(`${slugify(state.project.title)}.sourcedesk.json`, new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json' }));
    els.saveButton.innerHTML = original;
    els.saveButton.disabled = false;
    const message = skipped.length
      ? `Case saved. ${embeddedAssets.length} small file${embeddedAssets.length === 1 ? '' : 's'} packed; ${skipped.length} large or unavailable file${skipped.length === 1 ? '' : 's'} kept as filename references.`
      : `Case saved with ${embeddedAssets.length} embedded file${embeddedAssets.length === 1 ? '' : 's'}.`;
    toast(message, skipped.length ? 'warning' : 'success', 6500);
  }

  function exportCaseJs() {
    state.project.lastExportedAt = new Date().toISOString();
    saveLocalNow();
    const payload = { app: 'Source Desk', format: 'sourcedesk-js', version: 2, exportedAt: new Date().toISOString(), data: JSON.parse(JSON.stringify(state)) };
    const contents = `/* Source Desk lightweight case — attachments remain local / referenced by filename. */\nwindow.SOURCE_DESK_CASE = ${JSON.stringify(payload, null, 2)};\n`;
    downloadBlob(`${slugify(state.project.title)}.case.js`, new Blob([contents], { type: 'text/javascript' }));
    toast('Lightweight case.js exported. Rename it to case.js beside the app to bundle it.');
  }

  function exportMarkdown() {
    const ordered = sortSources(state.sources.filter(source => source.status === 'timeline'), 'asc');
    let md = `# ${state.project.title}\n\n`;
    if (state.project.question) md += `> ${state.project.question}\n\n`;
    if (state.project.notes) md += `## Research gaps\n\n${state.project.notes}\n\n`;
    md += `## Chronology\n\n`;
    ordered.forEach(source => {
      md += `### ${formatSourceDate(source, false)} — ${source.title}\n\n`;
      md += `- Source: [${source.domain}](${source.url})\n- Type: ${TYPE_LABELS[source.type]}\n`;
      if (source.tags.length) md += `- Tags: ${source.tags.map(tag => `#${tag}`).join(', ')}\n`;
      if (source.credibility !== 'unchecked') md += `- Quality: ${source.credibility}\n`;
      if (source.attachments.length) md += `- Local evidence: ${source.attachments.map(meta => meta.name).join(', ')}\n`;
      if (source.content) md += `\n#### Saved source text\n\n${source.content}\n`;
      if (source.notes) md += `\n${source.notes}\n`;
      if (source.quote) md += `\n> ${source.quote.replace(/\n/g, '\n> ')}\n`;
      md += '\n';
    });
    downloadBlob(`${slugify(state.project.title)}-timeline.md`, new Blob([md], { type: 'text/markdown' }));
    toast('Chronology notes exported as Markdown.');
  }

  async function importSelectedFile() {
    const file = els.importInput.files?.[0];
    els.importInput.value = '';
    if (!file) return;
    try {
      const text = await file.text();
      let payload;
      if (/\.js$/i.test(file.name) || text.includes('window.SOURCE_DESK_CASE')) {
        const match = text.match(/window\.SOURCE_DESK_CASE\s*=\s*([\s\S]*?);?\s*$/);
        if (!match) throw new Error('The JavaScript file does not contain a Source Desk case.');
        payload = JSON.parse(match[1].replace(/;\s*$/, ''));
      } else {
        payload = JSON.parse(text);
      }
      await replaceWithImported(payload, `Import “${file.name}”?`);
    } catch (error) {
      toast(error.message || 'Could not import that file.', 'error', 6500);
    }
  }

  async function replaceWithImported(payload, title) {
    const imported = sanitizeState(payload);
    if (state.sources.length) {
      const ok = await confirmAction(title, 'This replaces the case currently open in the app. Your latest downloaded save remains untouched.', 'Replace case');
      if (!ok) return;
    }
    const assets = Array.isArray(payload.embeddedAssets) ? payload.embeddedAssets : [];
    let restored = 0;
    for (const asset of assets) {
      try {
        const blob = dataUrlToBlob(asset.dataUrl);
        await putAttachmentBlob({ id: asset.id, sourceId: asset.sourceId, name: asset.name, type: asset.type, size: asset.size, addedAt: new Date().toISOString(), blob });
        restored += 1;
      } catch { /* metadata remains usable */ }
    }
    state = imported;
    activeId = state.sources.find(source => source.status === 'inbox')?.id || state.sources[0]?.id || null;
    saveLocalNow();
    renderAll();
    toast(`Case loaded${assets.length ? ` · ${restored} of ${assets.length} embedded files restored` : ''}.`);
  }

  async function loadBundledCase() {
    if (!window.SOURCE_DESK_CASE) {
      toast('No bundled case.js was found beside the app.', 'warning');
      return;
    }
    await replaceWithImported(window.SOURCE_DESK_CASE, 'Load bundled case.js?');
  }

  function openProjectDialog() {
    els.projectBriefTitle.value = state.project.title;
    els.projectQuestion.value = state.project.question || '';
    els.projectBriefNotes.value = state.project.notes || '';
    els.projectDialog.showModal();
  }

  async function newCase() {
    if (state.sources.length) {
      const ok = await confirmAction('Start a blank case?', 'The current browser workspace will be replaced. Download a case file first if you want a portable backup.', 'Start blank case');
      if (!ok) return;
    }
    state = defaultState();
    activeId = null;
    els.inboxSearch.value = '';
    els.timelineSearch.value = '';
    saveLocalNow();
    renderAll();
    toast('Blank research case ready.');
  }

  function confirmAction(title, message, acceptLabel = 'Confirm') {
    return new Promise(resolve => {
      els.confirmTitle.textContent = title;
      els.confirmMessage.textContent = message;
      els.confirmAccept.textContent = acceptLabel;
      const onClose = () => {
        els.confirmDialog.removeEventListener('close', onClose);
        resolve(els.confirmDialog.returnValue === 'confirm');
      };
      els.confirmDialog.addEventListener('close', onClose);
      els.confirmDialog.showModal();
    });
  }

  function scheduleLocalSave(immediate = false) {
    els.saveState.classList.add('saving');
    els.saveState.lastChild.textContent = ' Saving…';
    clearTimeout(saveTimer);
    if (immediate) saveLocalNow();
    else saveTimer = setTimeout(saveLocalNow, 350);
  }

  function saveLocalNow() {
    clearTimeout(saveTimer);
    state.project.updatedAt = new Date().toISOString();
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
      els.saveState.classList.remove('saving');
      els.saveState.lastChild.textContent = ' Saved locally';
    } catch {
      els.saveState.classList.remove('saving');
      els.saveState.lastChild.textContent = ' Local save unavailable';
    }
  }

  function copyCitation(source) {
    if (!source) return;
    const citation = `${source.title}. ${formatSourceDate(source, false)}. ${source.domain}. ${source.url}`;
    copyText(citation, 'Citation copied.');
  }

  async function copyText(text, successMessage) {
    try {
      await navigator.clipboard.writeText(text);
    } catch {
      const textarea = document.createElement('textarea');
      textarea.value = text;
      textarea.style.position = 'fixed';
      textarea.style.opacity = '0';
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand('copy');
      textarea.remove();
    }
    toast(successMessage);
  }

  function blobToDataUrl(blob) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result);
      reader.onerror = () => reject(reader.error);
      reader.readAsDataURL(blob);
    });
  }

  function dataUrlToBlob(dataUrl) {
    const [header, base64] = String(dataUrl).split(',');
    const mime = header.match(/data:([^;]+)/)?.[1] || 'application/octet-stream';
    const binary = atob(base64);
    const bytes = new Uint8Array(binary.length);
    for (let index = 0; index < binary.length; index += 1) bytes[index] = binary.charCodeAt(index);
    return new Blob([bytes], { type: mime });
  }

  function downloadBlob(filename, blob) {
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement('a');
    anchor.href = url;
    anchor.download = filename;
    document.body.appendChild(anchor);
    anchor.click();
    anchor.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  }

  function slugify(value) {
    return String(value || 'research-case').toLowerCase().trim().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '').slice(0, 70) || 'research-case';
  }

  function formatBytes(bytes) {
    if (!bytes) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    const index = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1);
    return `${(bytes / 1024 ** index).toFixed(index ? 1 : 0)} ${units[index]}`;
  }

  function escapeHtml(value) {
    return String(value ?? '').replace(/[&<>'"]/g, char => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' })[char]);
  }

  function escapeAttribute(value) { return escapeHtml(value).replace(/`/g, '&#96;'); }

  function toast(message, type = 'success', duration = 4200) {
    const node = document.createElement('div');
    node.className = `toast ${type}`;
    node.textContent = message;
    els.toastRegion.appendChild(node);
    setTimeout(() => {
      node.classList.add('out');
      setTimeout(() => node.remove(), 250);
    }, duration);
  }

  init();
})();






















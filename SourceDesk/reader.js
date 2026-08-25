(() => {
  'use strict';

  const CACHE_KEY = 'source-desk-reader-case-v1';
  const META_KEY = 'source-desk-reader-meta-v1';
  const READER_DB = 'source-desk-reader-assets-v1';
  const READER_STORE = 'assets';
  const SORTER_DB = 'source-desk-evidence-v2';
  const SORTER_STORE = 'attachments';
  const EXPORT_EACH_LIMIT = 12 * 1024 * 1024;
  const EXPORT_TOTAL_LIMIT = 40 * 1024 * 1024;
  const TYPE_LABELS = {
    article: 'Article',
    'article-video': 'Article + video',
    video: 'Video',
    document: 'PDF / document',
    image: 'Image / archive',
    social: 'Social post',
    other: 'Other'
  };
  const QUALITY_LABELS = {
    unchecked: 'Not checked',
    primary: 'Primary source',
    reliable: 'Reliable secondary',
    context: 'Context only',
    questionable: 'Needs verification'
  };
  const REQUESTED_SOURCE_ID = new URLSearchParams(window.location.search).get('source');
  const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  const $ = (selector, root = document) => root.querySelector(selector);
  const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];
  const els = {};
  let caseData = null;
  let sources = [];
  let activeId = null;
  let currentView = 'timeline';
  let sortDirection = 'asc';
  let readerMeta = { reviewed: [], pinned: [], writing: '' };
  let readerDbPromise;
  let sorterDbPromise;
  let mediaItems = new Map();
  const blobs = new Map();
  const objectUrls = new Map();

  function cacheElements() {
    [
      'caseStatus', 'syncButton', 'readerSaveButton', 'importButton', 'readerEmpty', 'emptyDrop', 'readerContent',
      'caseTitle', 'caseQuestion', 'caseStats', 'readerSearch', 'readerTypeFilter',
      'readerQualityFilter', 'readerSort', 'timelineView', 'mediaView', 'writingView',
      'visibleCount', 'sourceRail', 'readingPane', 'paneEmpty', 'paneContent', 'paneDate',
      'paneType', 'paneTitle', 'paneDomain', 'paneQuality', 'paneOpen', 'paneStory', 'paneCopy', 'panePin',
      'paneReviewed', 'paneEdit', 'primaryMediaBlock', 'primaryMediaTitle', 'primaryMediaStage', 'changePrimaryButton',
      'supportedPlayerBlock', 'previewAddress', 'reloadReaderPreview', 'closeReaderPlayer', 'readerFrame',
      'readerPreviewPlaceholder', 'loadReaderPreview', 'readerExternalOpen', 'contentBlock', 'contentLabel', 'paneContentText', 'editContentButton',
      'notesBlock', 'paneNotes', 'quoteBlock', 'paneQuote', 'paneTags', 'paneRelevance', 'paneQualityText', 'evidenceBlock',
      'evidenceCount', 'evidenceGrid', 'previousSource', 'nextSource', 'mediaWall',
      'writingNotes', 'wordCount', 'exportWriting', 'showAllPackets', 'sourcePackets',
      'sourceEditDialog', 'sourceEditForm', 'editDialogTitle', 'closeSourceEdit', 'cancelSourceEdit',
      'editTitle', 'editType', 'editDate', 'editDateFeedback', 'editDatePrecision', 'editCredibility',
      'editRelevance', 'editTags', 'editNotes', 'editQuote', 'editContentGroup', 'editContentLabel', 'editContent',
      'editPrimaryAttachment', 'demoteSourceButton', 'deleteReaderSourceButton', 'editSyncHint',
      'mediaDialog', 'closeMediaDialog', 'mediaModalBody', 'mediaModalType', 'mediaModalTitle',
      'mediaModalSource', 'mediaModalOpenSource', 'readerImportInput', 'readerToast'
    ].forEach(id => { els[id] = document.getElementById(id); });
  }

  function init() {
    cacheElements();
    bindEvents();
    const cached = readJson(CACHE_KEY);
    if (cached?.data?.sources) loadPackage(cached, 'Cached reading copy', false);
    else if (window.SOURCE_DESK_CASE?.data?.sources) loadPackage(window.SOURCE_DESK_CASE, 'Bundled case.js', false);
    requestSorterSync(false);
  }

  function bindEvents() {
    els.importButton.addEventListener('click', () => els.readerImportInput.click());
    els.readerSaveButton.addEventListener('click', exportReaderCase);
    $$('[data-import]').forEach(button => button.addEventListener('click', () => els.readerImportInput.click()));
    els.readerImportInput.addEventListener('change', importSelectedCase);
    els.syncButton.addEventListener('click', () => requestSorterSync(true));
    window.addEventListener('message', handleSorterMessage);

    $$('[data-view]').forEach(button => button.addEventListener('click', () => setView(button.dataset.view)));
    els.readerSearch.addEventListener('input', renderFilteredViews);
    els.readerTypeFilter.addEventListener('change', renderFilteredViews);
    els.readerQualityFilter.addEventListener('change', renderFilteredViews);
    els.readerSort.addEventListener('click', () => {
      sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
      renderFilteredViews();
    });
    els.sourceRail.addEventListener('click', event => {
      const sourceButton = event.target.closest('[data-source-id]');
      if (sourceButton) selectSource(sourceButton.dataset.sourceId, true);
    });

    els.loadReaderPreview.addEventListener('click', loadPreview);
    els.reloadReaderPreview.addEventListener('click', loadPreview);
    els.closeReaderPlayer.addEventListener('click', closeReaderPreview);
    els.paneCopy.addEventListener('click', () => copyCitation(activeSource()));
    els.panePin.addEventListener('click', togglePinned);
    els.paneReviewed.addEventListener('click', toggleReviewed);
    els.paneEdit.addEventListener('click', openSourceEditor);
    els.editContentButton.addEventListener('click', openSourceEditor);
    els.changePrimaryButton.addEventListener('click', openSourceEditor);
    els.sourceEditForm.addEventListener('submit', saveSourceEditor);
    els.closeSourceEdit.addEventListener('click', () => els.sourceEditDialog.close());
    els.cancelSourceEdit.addEventListener('click', () => els.sourceEditDialog.close());
    els.editType.addEventListener('change', updateEditContentVisibility);
    els.editDate.addEventListener('input', handleEditDateInput);
    els.editRelevance.addEventListener('click', event => {
      const button = event.target.closest('[data-edit-rating]');
      if (button) setEditRelevance(Number(button.dataset.editRating));
    });
    els.demoteSourceButton.addEventListener('click', demoteActiveSource);
    els.deleteReaderSourceButton.addEventListener('click', deleteActiveSource);
    els.previousSource.addEventListener('click', () => navigateSource(-1));
    els.nextSource.addEventListener('click', () => navigateSource(1));
    els.evidenceGrid.addEventListener('click', event => {
      const button = event.target.closest('[data-media-key]');
      if (button) openMedia(button.dataset.mediaKey);
    });
    els.mediaWall.addEventListener('click', event => {
      const button = event.target.closest('[data-media-key]');
      if (button) openMedia(button.dataset.mediaKey);
    });

    els.writingNotes.addEventListener('input', () => {
      readerMeta.writing = els.writingNotes.value;
      saveMeta();
      renderWordCount();
    });
    els.showAllPackets.addEventListener('change', renderSourcePackets);
    els.sourcePackets.addEventListener('click', event => {
      const button = event.target.closest('[data-open-packet]');
      if (!button) return;
      setView('timeline');
      selectSource(button.dataset.openPacket, true);
    });
    els.exportWriting.addEventListener('click', exportWritingDesk);

    els.closeMediaDialog.addEventListener('click', () => els.mediaDialog.close());
    els.mediaDialog.addEventListener('click', event => { if (event.target === els.mediaDialog) els.mediaDialog.close(); });
    els.mediaDialog.addEventListener('close', () => {
      const video = $('video', els.mediaModalBody);
      if (video) video.pause();
      els.mediaModalBody.innerHTML = '';
    });

    ['dragenter', 'dragover'].forEach(type => document.addEventListener(type, event => {
      event.preventDefault();
      document.body.classList.add('dragging');
    }));
    ['dragleave', 'drop'].forEach(type => document.addEventListener(type, event => {
      event.preventDefault();
      if (type === 'drop') handleDroppedCase(event);
      document.body.classList.remove('dragging');
    }));
    document.addEventListener('keydown', event => {
      if (event.key === '/' && !/INPUT|TEXTAREA|SELECT/.test(document.activeElement?.tagName)) {
        event.preventDefault();
        els.readerSearch.focus();
      }
      if (event.key === 'ArrowRight' && !/INPUT|TEXTAREA/.test(document.activeElement?.tagName) && currentView === 'timeline') navigateSource(1);
      if (event.key === 'ArrowLeft' && !/INPUT|TEXTAREA/.test(document.activeElement?.tagName) && currentView === 'timeline') navigateSource(-1);
    });
    window.addEventListener('beforeunload', () => objectUrls.forEach(url => URL.revokeObjectURL(url)));
  }

  function requestSorterSync(showFeedback) {
    if (window.opener && !window.opener.closed) {
      window.opener.postMessage({ type: 'SOURCE_DESK_READER_REQUEST' }, '*');
      if (showFeedback) toast('Requesting the latest case from the sorter…');
    } else if (showFeedback) {
      toast('Open Reading Room from the sorter header to sync its live case. You can also import a saved case here.', 'warning', 6500);
    }
  }

  function handleSorterMessage(event) {
    if (event.data?.type === 'SOURCE_DESK_STORY_REQUEST' && caseData) {
      event.source?.postMessage({
        type: 'SOURCE_DESK_STORY_CASE',
        payload: { app:'Source Desk', format:'sourcedesk-live-story', version:3, exportedAt:new Date().toISOString(), data:caseData }
      }, '*');
      return;
    }
    if (window.opener && event.source !== window.opener) return;
    if (event.data?.type === 'SOURCE_DESK_READER_CASE') loadPackage(event.data.payload, 'Live from sorter', true);
    if (event.data?.type === 'SOURCE_DESK_READER_ACK') {
      els.caseStatus.classList.add('ready');
      els.caseStatus.querySelector('span').textContent = 'Saved · synced to sorter';
    }
  }

  async function importSelectedCase() {
    const file = els.readerImportInput.files?.[0];
    els.readerImportInput.value = '';
    if (file) await importCaseFile(file);
  }

  async function handleDroppedCase(event) {
    const file = [...event.dataTransfer.files].find(item => /\.(json|js)$/i.test(item.name));
    if (!file) {
      toast('Drop a Source Desk JSON or case.js file here.', 'warning');
      return;
    }
    await importCaseFile(file);
  }

  async function importCaseFile(file) {
    try {
      const text = await file.text();
      let payload;
      if (/\.js$/i.test(file.name) || text.includes('window.SOURCE_DESK_CASE')) {
        const match = text.match(/window\.SOURCE_DESK_CASE\s*=\s*([\s\S]*?);?\s*$/);
        if (!match) throw new Error('That JavaScript file does not contain a Source Desk case.');
        payload = JSON.parse(match[1].replace(/;\s*$/, ''));
      } else payload = JSON.parse(text);
      if (!payload?.data?.sources && !payload?.sources) throw new Error('That file does not contain Source Desk research data.');
      await loadPackage(payload, `Imported · ${file.name}`, true);
    } catch (error) {
      toast(error.message || 'The case file could not be opened.', 'error', 6500);
    }
  }

  async function loadPackage(payload, origin, announce) {
    const data = sanitizeCase(payload.data || payload);
    caseData = data;
    sources = data.sources.filter(source => source.status === 'timeline');
    sortDirection = data.project.sortDirection === 'desc' ? 'desc' : 'asc';
    loadMetaForProject(data.project.id);
    blobs.clear();
    objectUrls.forEach(url => URL.revokeObjectURL(url));
    objectUrls.clear();

    const incomingAssets = [
      ...(Array.isArray(payload.assets) ? payload.assets : []),
      ...(Array.isArray(payload.embeddedAssets) ? payload.embeddedAssets : [])
    ];
    let restored = 0;
    for (const asset of incomingAssets) {
      try {
        const blob = asset.blob instanceof Blob ? asset.blob : asset.dataUrl ? dataUrlToBlob(asset.dataUrl) : null;
        if (!blob) continue;
        blobs.set(asset.id, blob);
        restored += 1;
        if (blob.size <= 25 * 1024 * 1024) persistReaderAsset({ ...asset, blob }).catch(() => {});
      } catch { /* unavailable attachment remains listed by filename */ }
    }

    localStorage.setItem(CACHE_KEY, JSON.stringify({ app: 'Source Desk', version: 2, data }));
    activeId = sources.some(source => source.id === REQUESTED_SOURCE_ID) ? REQUESTED_SOURCE_ID : (sources.some(source => source.id === activeId) ? activeId : sources[0]?.id || null);
    els.readerEmpty.hidden = true;
    els.readerContent.hidden = false;
    els.caseStatus.classList.add('ready');
    els.caseStatus.querySelector('span').textContent = origin;
    renderAll();
    if (announce) toast(`${sources.length} filed source${sources.length === 1 ? '' : 's'} loaded${restored ? ` · ${restored} media file${restored === 1 ? '' : 's'} available` : ''}.`);
  }

  function sanitizeCase(raw) {
    const project = raw.project || {};
    return {
      version: 2,
      project: {
        id: project.id || 'reader-case',
        title: String(project.title || 'Untitled research case'),
        question: String(project.question || ''),
        notes: String(project.notes || ''),
        sortDirection: project.sortDirection === 'desc' ? 'desc' : 'asc',
        updatedAt: project.updatedAt || null
      },
      sources: (Array.isArray(raw.sources) ? raw.sources : []).map(source => ({
        id: source.id || `source-${Math.random().toString(36).slice(2)}`,
        url: String(source.url || ''),
        domain: String(source.domain || domainFromUrl(source.url)),
        title: String(source.title || source.url || 'Untitled source'),
        type: TYPE_LABELS[source.type] ? source.type : 'other',
        status: source.status === 'timeline' ? 'timeline' : 'inbox',
        dateISO: source.dateISO || null,
        datePrecision: source.datePrecision || 'unknown',
        dateInput: String(source.dateInput || ''),
        notes: String(source.notes || ''),
        quote: String(source.quote || ''),
        content: String(source.content || ''),
        tags: Array.isArray(source.tags) ? source.tags.map(String) : [],
        credibility: QUALITY_LABELS[source.credibility] ? source.credibility : 'unchecked',
        relevance: Math.max(0, Math.min(5, Number(source.relevance) || 0)),
        videoConfirmed: Boolean(source.videoConfirmed),
        titleSource: source.titleSource || null,
        dateSource: source.dateSource || null,
        primaryAttachmentId: String(source.primaryAttachmentId || ''),
        attachments: Array.isArray(source.attachments) ? source.attachments.map(meta => ({
          id: meta.id,
          sourceId: source.id,
          name: String(meta.name || 'attachment'),
          type: String(meta.type || 'application/octet-stream'),
          size: Number(meta.size) || 0
        })) : [],
        addedAt: source.addedAt || '',
        completedAt: source.completedAt || ''
      }))
    };
  }

  function loadMetaForProject(projectId) {
    const root = readJson(META_KEY) || {};
    readerMeta = root[projectId] || { reviewed: [], pinned: [], writing: '' };
    readerMeta.reviewed = Array.isArray(readerMeta.reviewed) ? readerMeta.reviewed : [];
    readerMeta.pinned = Array.isArray(readerMeta.pinned) ? readerMeta.pinned : [];
    readerMeta.writing = String(readerMeta.writing || '');
    els.writingNotes.value = readerMeta.writing;
    renderWordCount();
  }

  function saveMeta() {
    if (!caseData) return;
    const root = readJson(META_KEY) || {};
    root[caseData.project.id] = readerMeta;
    localStorage.setItem(META_KEY, JSON.stringify(root));
  }

  function renderAll() {
    if (!caseData) return;
    els.caseTitle.textContent = caseData.project.title;
    els.caseQuestion.textContent = caseData.project.question || 'A self-contained, editable research dossier arranged in chronology.';
    renderStats();
    renderFilteredViews();
    renderWordCount();
  }

  function renderFilteredViews() {
    const filtered = filteredSources();
    if (!filtered.some(source => source.id === activeId)) activeId = filtered[0]?.id || null;
    els.readerSort.dataset.direction = sortDirection;
    els.readerSort.innerHTML = `${sortDirection === 'asc' ? 'Oldest first' : 'Newest first'} <b>${sortDirection === 'asc' ? '↑' : '↓'}</b>`;
    renderRail(filtered);
    renderPane();
    renderMediaWall(filtered);
    renderSourcePackets();
  }

  function filteredSources() {
    const query = els.readerSearch.value.trim().toLowerCase();
    const type = els.readerTypeFilter.value;
    const quality = els.readerQualityFilter.value;
    return sortSources(sources.filter(source => {
      const haystack = `${source.title} ${source.domain} ${source.content} ${source.notes} ${source.quote} ${source.tags.join(' ')}`.toLowerCase();
      return (!query || haystack.includes(query)) && (type === 'all' || source.type === type) && (quality === 'all' || source.credibility === quality);
    }), sortDirection);
  }

  function sortSources(items, direction) {
    return [...items].sort((a, b) => {
      if (!a.dateISO && !b.dateISO) return String(a.completedAt).localeCompare(String(b.completedAt));
      if (!a.dateISO) return 1;
      if (!b.dateISO) return -1;
      const result = a.dateISO.localeCompare(b.dateISO);
      return direction === 'asc' ? result : -result;
    });
  }

  function renderStats() {
    const reviewed = sources.filter(source => readerMeta.reviewed.includes(source.id)).length;
    const media = sources.reduce((sum, source) => sum + source.attachments.filter(isVisualMeta).length + (isPlayableUrl(source.url) ? 1 : 0), 0);
    const unknown = sources.filter(source => !source.dateISO).length;
    els.caseStats.innerHTML = [
      [sources.length, 'filed sources'],
      [reviewed, 'reviewed'],
      [media, 'media items'],
      [unknown, 'dates to verify']
    ].map(([value, label]) => `<div class="case-stat"><strong>${value}</strong><span>${label}</span></div>`).join('');
  }

  function renderRail(filtered) {
    els.visibleCount.textContent = `${filtered.length} source${filtered.length === 1 ? '' : 's'}`;
    if (!filtered.length) {
      els.sourceRail.innerHTML = '<div class="rail-no-results">No filed sources match these filters.</div>';
      return;
    }
    let group = null;
    els.sourceRail.innerHTML = filtered.map(source => {
      const nextGroup = source.dateISO ? source.dateISO.slice(0, 4) : 'Date to verify';
      const heading = nextGroup !== group ? `<div class="rail-year">${escapeHtml(nextGroup)}</div>` : '';
      group = nextGroup;
      return `${heading}<button type="button" class="rail-source ${source.id === activeId ? 'active' : ''} ${readerMeta.reviewed.includes(source.id) ? 'reviewed' : ''}" data-source-id="${source.id}">
        <span class="rail-date">${escapeHtml(shortDate(source))}</span>
        <span class="rail-source-title"><strong>${escapeHtml(source.title)}</strong><span>${escapeHtml(source.domain)} · ${escapeHtml(TYPE_LABELS[source.type])}</span></span>
        <i class="review-dot"></i>
      </button>`;
    }).join('');
  }

  function selectSource(id, shouldScroll) {
    if (!sourceById(id)) return;
    activeId = id;
    renderRail(filteredSources());
    renderPane();
    if (shouldScroll && window.matchMedia('(max-width: 760px)').matches) els.readingPane.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }

  function renderPane() {
    const source = activeSource();
    els.paneEmpty.hidden = Boolean(source);
    els.paneContent.hidden = !source;
    closeReaderPreview();
    els.supportedPlayerBlock.hidden = true;
    if (!source) return;

    els.paneDate.textContent = formatDate(source);
    els.paneType.textContent = TYPE_LABELS[source.type];
    els.paneTitle.textContent = source.title;
    els.paneDomain.textContent = source.domain;
    els.paneQuality.textContent = QUALITY_LABELS[source.credibility];
    els.paneQuality.className = `quality-badge ${source.credibility}`;
    els.paneOpen.href = source.url;
    els.paneStory.href = `./board.html?source=${encodeURIComponent(source.id)}`;
    els.readerExternalOpen.href = source.url;
    els.previewAddress.textContent = source.url;
    const primary = primaryAttachment(source);
    els.supportedPlayerBlock.hidden = Boolean(primary?.type.startsWith('video/')) || !isPlayableUrl(source.url);
    renderPrimaryMedia(source, primary);
    const contentVisible = source.type !== 'video' || Boolean(source.content);
    els.contentBlock.hidden = !contentVisible;
    els.contentLabel.textContent = source.type === 'document' ? 'SAVED DOCUMENT TEXT' : source.type === 'video' ? 'SAVED TRANSCRIPT / VIDEO TEXT' : 'SAVED SOURCE TEXT';
    els.paneContentText.classList.toggle('empty', !source.content);
    els.paneContentText.textContent = source.content || 'No reading copy saved yet. Use “Add / edit text” to paste the passages you need and make this source self-contained.';
    els.notesBlock.hidden = !source.notes;
    els.paneNotes.textContent = source.notes || '';
    els.quoteBlock.hidden = !source.quote;
    els.paneQuote.textContent = source.quote || '';
    els.paneTags.innerHTML = source.tags.length ? source.tags.map(tag => `<span>#${escapeHtml(tag)}</span>`).join('') : '<span>untagged</span>';
    els.paneRelevance.textContent = source.relevance ? `${'●'.repeat(source.relevance)}${'○'.repeat(5 - source.relevance)} · ${source.relevance}/5` : 'Not rated';
    els.paneQualityText.textContent = QUALITY_LABELS[source.credibility];
    updatePaneButtons();
    renderEvidence(source);
    updateNavigation();
  }

  function updatePaneButtons() {
    const source = activeSource();
    if (!source) return;
    const pinned = readerMeta.pinned.includes(source.id);
    const reviewed = readerMeta.reviewed.includes(source.id);
    els.panePin.classList.toggle('active', pinned);
    els.paneReviewed.classList.toggle('active', reviewed);
    els.panePin.querySelector('span').textContent = pinned ? 'Pinned for writing' : 'Pin for writing';
    els.paneReviewed.querySelector('span').textContent = reviewed ? 'Reviewed' : 'Mark reviewed';
  }

  function loadPreview() {
    const source = activeSource();
    if (!source?.url || !isPlayableUrl(source.url)) return;
    els.readerFrame.src = previewUrl(source.url);
    els.readerPreviewPlaceholder.hidden = true;
    els.reloadReaderPreview.hidden = false;
    els.closeReaderPlayer.hidden = false;
  }

  function closeReaderPreview() {
    els.readerFrame.removeAttribute('src');
    els.readerPreviewPlaceholder.hidden = false;
    els.reloadReaderPreview.hidden = true;
    els.closeReaderPlayer.hidden = true;
  }

  function primaryAttachment(source) {
    const selected = source.attachments.find(meta => meta.id === source.primaryAttachmentId);
    if (selected) return selected;
    if (source.type === 'video' || source.type === 'article-video') return source.attachments.find(meta => meta.type.startsWith('video/')) || null;
    return null;
  }

  async function renderPrimaryMedia(source, primary = primaryAttachment(source)) {
    const token = source.id;
    els.primaryMediaBlock.hidden = !primary;
    els.primaryMediaStage.innerHTML = '';
    if (!primary) return;
    els.primaryMediaTitle.textContent = primary.name;
    els.primaryMediaStage.innerHTML = '<div class="primary-loading">Loading local evidence…</div>';
    const blob = await assetBlob(primary.id);
    if (activeId !== token) return;
    if (!blob) {
      els.primaryMediaStage.innerHTML = `<div class="primary-unavailable"><svg><use href="#r-file"></use></svg><h3>Local file is not available in this reading copy</h3><p>${escapeHtml(primary.name)} remains referenced. Reopen from the Source Desk that stores it or import a portable case containing the file.</p></div>`;
      return;
    }
    const url = objectUrlFor(primary.id, blob);
    if (primary.type.startsWith('video/')) els.primaryMediaStage.innerHTML = `<video src="${url}" controls preload="metadata"></video>`;
    else if (primary.type.startsWith('image/')) els.primaryMediaStage.innerHTML = `<img src="${url}" alt="${escapeAttribute(primary.name)}">`;
    else if (primary.type.startsWith('audio/')) els.primaryMediaStage.innerHTML = `<audio src="${url}" controls></audio>`;
    else if (primary.type.includes('pdf')) els.primaryMediaStage.innerHTML = `<iframe src="${url}" title="${escapeAttribute(primary.name)}"></iframe>`;
    else els.primaryMediaStage.innerHTML = `<div class="primary-unavailable"><svg><use href="#r-file"></use></svg><h3>${escapeHtml(primary.name)}</h3><p>This attachment is stored with the dossier and remains available from the evidence list.</p></div>`;
  }

  function navigateSource(step) {
    const filtered = filteredSources();
    const index = filtered.findIndex(source => source.id === activeId);
    const target = filtered[index + step];
    if (target) selectSource(target.id, true);
  }

  function updateNavigation() {
    const filtered = filteredSources();
    const index = filtered.findIndex(source => source.id === activeId);
    const previous = filtered[index - 1];
    const next = filtered[index + 1];
    els.previousSource.disabled = !previous;
    els.nextSource.disabled = !next;
    $('strong', els.previousSource).textContent = previous?.title || 'Beginning of chronology';
    $('strong', els.nextSource).textContent = next?.title || 'End of chronology';
  }

  function togglePinned() {
    const source = activeSource();
    if (!source) return;
    readerMeta.pinned = toggleId(readerMeta.pinned, source.id);
    saveMeta();
    updatePaneButtons();
    renderSourcePackets();
    toast(readerMeta.pinned.includes(source.id) ? 'Source pinned to the writing desk.' : 'Source removed from the writing packet.');
  }

  function toggleReviewed() {
    const source = activeSource();
    if (!source) return;
    readerMeta.reviewed = toggleId(readerMeta.reviewed, source.id);
    saveMeta();
    updatePaneButtons();
    renderRail(filteredSources());
    renderStats();
  }

  function toggleId(list, id) { return list.includes(id) ? list.filter(item => item !== id) : [...list, id]; }

  function openSourceEditor() {
    const source = activeSource();
    if (!source) return;
    els.editDialogTitle.textContent = source.title;
    els.editTitle.value = source.title;
    els.editType.value = source.type;
    els.editDate.value = source.dateInput || '';
    els.editDatePrecision.value = source.datePrecision || 'unknown';
    els.editCredibility.value = source.credibility;
    els.editTags.value = source.tags.join(', ');
    els.editNotes.value = source.notes;
    els.editQuote.value = source.quote;
    els.editContent.value = source.content;
    els.editPrimaryAttachment.innerHTML = '<option value="">Automatic / none</option>' + source.attachments.map(meta => `<option value="${escapeAttribute(meta.id)}">${escapeHtml(meta.name)} · ${escapeHtml(meta.type)}</option>`).join('');
    els.editPrimaryAttachment.value = source.primaryAttachmentId || '';
    setEditRelevance(source.relevance);
    updateEditContentVisibility();
    els.editDateFeedback.textContent = 'Use DD/MM/YYYY, MM/YYYY, YYYY, or leave blank.';
    els.editDateFeedback.className = '';
    els.editSyncHint.textContent = window.opener && !window.opener.closed ? 'Changes save here and sync to the open Source Desk.' : 'Changes save in this browser. Use Save dossier for a portable copy.';
    els.sourceEditDialog.showModal();
  }

  function updateEditContentVisibility() {
    const isVideo = els.editType.value === 'video';
    els.editContentGroup.hidden = isVideo && !els.editContent.value;
    els.editContentLabel.textContent = isVideo ? 'Saved transcript / video text' : els.editType.value === 'document' ? 'Saved document text' : 'Saved article / source text';
  }

  function setEditRelevance(value) {
    const rating = Math.max(0, Math.min(5, Number(value) || 0));
    els.editRelevance.dataset.value = String(rating);
    $$('[data-edit-rating]', els.editRelevance).forEach(button => button.classList.toggle('active', Number(button.dataset.editRating) <= rating));
  }

  function handleEditDateInput() {
    const precision = els.editDatePrecision.value;
    const limit = precision === 'year' ? 4 : precision === 'month' ? 6 : 8;
    const digits = els.editDate.value.replace(/\D/g, '').slice(0, limit);
    if (precision === 'year') els.editDate.value = digits;
    else if (precision === 'month') els.editDate.value = digits.length <= 2 ? digits : digits.slice(0, 2) + '/' + digits.slice(2);
    else els.editDate.value = digits.length <= 2 ? digits : digits.length <= 4 ? digits.slice(0, 2) + '/' + digits.slice(2) : digits.slice(0, 2) + '/' + digits.slice(2, 4) + '/' + digits.slice(4);
  }

  function parseEditableDate(value, precision) {
    const text = String(value || '').trim();
    if (!text) return { dateISO: null, dateInput: '', datePrecision: 'unknown' };
    let match;
    if (precision === 'year' || /^\d{4}$/.test(text)) {
      match = text.match(/^((?:19|20)\d{2})$/);
      return match ? { dateISO: match[1] + '-01-01', dateInput: match[1], datePrecision: 'year' } : null;
    }
    if (precision === 'month' || /^\d{1,2}\/\d{4}$/.test(text)) {
      match = text.match(/^(0?[1-9]|1[0-2])\/((?:19|20)\d{2})$/);
      return match ? { dateISO: match[2] + '-' + String(Number(match[1])).padStart(2, '0') + '-01', dateInput: String(Number(match[1])).padStart(2, '0') + '/' + match[2], datePrecision: 'month' } : null;
    }
    match = text.match(/^(0?[1-9]|[12]\d|3[01])\/(0?[1-9]|1[0-2])\/((?:19|20)\d{2})$/);
    if (!match) return null;
    const day = Number(match[1]), month = Number(match[2]), year = Number(match[3]);
    const date = new Date(Date.UTC(year, month - 1, day));
    if (date.getUTCFullYear() !== year || date.getUTCMonth() !== month - 1 || date.getUTCDate() !== day) return null;
    return { dateISO: match[3] + '-' + String(month).padStart(2, '0') + '-' + String(day).padStart(2, '0'), dateInput: String(day).padStart(2, '0') + '/' + String(month).padStart(2, '0') + '/' + match[3], datePrecision: precision === 'approximate' ? 'approximate' : 'exact' };
  }

  function saveSourceEditor(event) {
    event.preventDefault();
    const source = activeSource();
    if (!source) return;
    const parsedDate = parseEditableDate(els.editDate.value, els.editDatePrecision.value);
    if (!parsedDate) {
      els.editDateFeedback.textContent = 'Enter a valid DD/MM/YYYY, MM/YYYY, or YYYY date.';
      els.editDateFeedback.className = 'invalid';
      els.editDate.focus();
      return;
    }
    source.title = els.editTitle.value.trim() || source.url;
    source.titleSource = 'manual';
    source.type = els.editType.value;
    source.dateISO = parsedDate.dateISO;
    source.dateInput = parsedDate.dateInput;
    source.datePrecision = parsedDate.datePrecision;
    source.dateSource = 'manual';
    source.credibility = els.editCredibility.value;
    source.relevance = Number(els.editRelevance.dataset.value) || 0;
    source.tags = [...new Set(els.editTags.value.split(',').map(tag => tag.trim().replace(/^#/, '').toLowerCase()).filter(Boolean))].slice(0, 30);
    source.notes = els.editNotes.value.trim();
    source.quote = els.editQuote.value.trim();
    source.content = els.editContent.value.trim();
    source.primaryAttachmentId = els.editPrimaryAttachment.value;
    persistReaderCase('update', source);
    els.sourceEditDialog.close();
    renderAll();
    toast('Dossier entry saved.');
  }

  function persistReaderCase(operation, source, patch = null) {
    if (!caseData) return;
    caseData.project.updatedAt = new Date().toISOString();
    localStorage.setItem(CACHE_KEY, JSON.stringify({ app: 'Source Desk', version: 3, data: caseData }));
    els.caseStatus.classList.add('ready');
    els.caseStatus.querySelector('span').textContent = window.opener && !window.opener.closed ? 'Saved · syncing to sorter…' : 'Edited locally';
    if (window.opener && !window.opener.closed) window.opener.postMessage({ type: 'SOURCE_DESK_READER_UPDATE', projectId: caseData.project.id, operation, sourceId: source?.id || activeId, patch: patch || source }, '*');
  }

  function demoteActiveSource() {
    const source = activeSource();
    if (!source || !window.confirm('Return this source to the Source Desk link mess? It will leave the Reading Room chronology.')) return;
    source.status = 'inbox';
    sources = sources.filter(item => item.id !== source.id);
    readerMeta.reviewed = readerMeta.reviewed.filter(id => id !== source.id);
    readerMeta.pinned = readerMeta.pinned.filter(id => id !== source.id);
    saveMeta();
    persistReaderCase('demote', source);
    els.sourceEditDialog.close();
    activeId = sources[0]?.id || null;
    renderAll();
    toast('Source returned to the link mess.', 'warning');
  }

  function deleteActiveSource() {
    const source = activeSource();
    if (!source || !window.confirm('Permanently delete this source from the case? Downloaded backups remain unchanged.')) return;
    caseData.sources = caseData.sources.filter(item => item.id !== source.id);
    sources = sources.filter(item => item.id !== source.id);
    readerMeta.reviewed = readerMeta.reviewed.filter(id => id !== source.id);
    readerMeta.pinned = readerMeta.pinned.filter(id => id !== source.id);
    saveMeta();
    persistReaderCase('delete', source, null);
    els.sourceEditDialog.close();
    activeId = sources[0]?.id || null;
    renderAll();
    toast('Source deleted from the dossier.', 'warning');
  }

  async function renderEvidence(source) {
    const token = source.id;
    els.evidenceBlock.hidden = !source.attachments.length;
    els.evidenceCount.textContent = `${source.attachments.length} file${source.attachments.length === 1 ? '' : 's'}`;
    if (!source.attachments.length) {
      els.evidenceGrid.innerHTML = '';
      return;
    }
    const cards = await Promise.all(source.attachments.map(async meta => {
      const blob = await assetBlob(meta.id);
      if (activeId !== token) return '';
      const key = `attachment:${source.id}:${meta.id}`;
      mediaItems.set(key, { kind: 'attachment', sourceId: source.id, meta });
      let visual = `<svg><use href="#${meta.type.startsWith('video/') ? 'r-play' : meta.type.startsWith('image/') ? 'r-image' : 'r-file'}"></use></svg>`;
      if (blob && meta.type.startsWith('image/')) visual = `<img src="${objectUrlFor(meta.id, blob)}" alt="">`;
      if (blob && meta.type.startsWith('video/')) visual = `<video src="${objectUrlFor(meta.id, blob)}" muted preload="metadata"></video><span class="play-badge"><svg><use href="#r-play"></use></svg></span>`;
      return `<button type="button" class="evidence-card ${blob ? '' : 'unavailable'}" data-media-key="${escapeAttribute(key)}">
        <span class="evidence-thumb">${visual}</span><span class="evidence-caption"><strong>${escapeHtml(meta.name)}</strong><span>${formatBytes(meta.size)}${blob ? '' : ' · reference only'}</span></span>
      </button>`;
    }));
    if (activeId === token) els.evidenceGrid.innerHTML = cards.join('');
  }

  async function renderMediaWall(filtered) {
    const items = [];
    filtered.forEach(source => {
      if (isPlayableUrl(source.url)) items.push({ key: `url:${source.id}`, kind: 'url-video', sourceId: source.id, url: source.url, title: source.title });
      source.attachments.filter(isVisualMeta).forEach(meta => items.push({ key: `attachment:${source.id}:${meta.id}`, kind: 'attachment', sourceId: source.id, meta }));
    });
    mediaItems = new Map(items.map(item => [item.key, item]));
    if (!items.length) {
      els.mediaWall.innerHTML = '<div class="media-empty">No image or video media matches the current filters.</div>';
      return;
    }
    const cards = await Promise.all(items.map(async item => {
      const source = sourceById(item.sourceId);
      let visual = '<span class="media-tile-fallback"><svg><use href="#r-play"></use></svg></span>';
      let type = 'Video URL';
      let play = '<span class="play-badge"><svg><use href="#r-play"></use></svg></span>';
      let title = item.title || item.meta?.name || source.title;
      if (item.kind === 'attachment') {
        const blob = await assetBlob(item.meta.id);
        type = item.meta.type.startsWith('image/') ? 'Attached image' : item.meta.type.startsWith('video/') ? 'Attached video' : 'Attached media';
        if (blob && item.meta.type.startsWith('image/')) visual = `<img src="${objectUrlFor(item.meta.id, blob)}" alt="">`;
        if (blob && item.meta.type.startsWith('video/')) visual = `<video src="${objectUrlFor(item.meta.id, blob)}" muted preload="metadata"></video>`;
        if (!item.meta.type.startsWith('video/')) play = '';
        if (!blob) visual = `<span class="media-tile-fallback"><svg><use href="#${item.meta.type.startsWith('image/') ? 'r-image' : 'r-play'}"></use></svg></span>`;
      }
      return `<button type="button" class="media-tile" data-media-key="${escapeAttribute(item.key)}">${visual}${play}<span class="media-tile-copy"><span>${escapeHtml(type)} · ${escapeHtml(shortDate(source))}</span><strong>${escapeHtml(title)}</strong></span></button>`;
    }));
    els.mediaWall.innerHTML = cards.join('');
  }

  async function openMedia(key) {
    const item = mediaItems.get(key);
    if (!item) return;
    const source = sourceById(item.sourceId);
    els.mediaModalOpenSource.href = source.url;
    els.mediaModalSource.textContent = `${source.title} · ${source.domain}`;
    if (item.kind === 'url-video') {
      els.mediaModalType.textContent = 'VIDEO SOURCE';
      els.mediaModalTitle.textContent = source.title;
      els.mediaModalBody.innerHTML = `<iframe src="${escapeAttribute(previewUrl(item.url))}" title="${escapeAttribute(source.title)}" allow="autoplay; encrypted-media; picture-in-picture" allowfullscreen></iframe>`;
    } else {
      const meta = item.meta;
      const blob = await assetBlob(meta.id);
      els.mediaModalType.textContent = meta.type.startsWith('image/') ? 'ATTACHED IMAGE' : meta.type.startsWith('video/') ? 'ATTACHED VIDEO' : 'ATTACHED FILE';
      els.mediaModalTitle.textContent = meta.name;
      if (!blob) {
        els.mediaModalBody.innerHTML = `<div class="modal-file-fallback"><svg><use href="#r-file"></use></svg><h3>File reference only</h3><p>${escapeHtml(meta.name)} is not embedded in this reading copy. Reopen Reading Room from the sorter that stores it, or import a portable case containing the file.</p></div>`;
      } else {
        const url = objectUrlFor(meta.id, blob);
        if (meta.type.startsWith('image/')) els.mediaModalBody.innerHTML = `<img src="${url}" alt="${escapeAttribute(meta.name)}">`;
        else if (meta.type.startsWith('video/')) els.mediaModalBody.innerHTML = `<video src="${url}" controls autoplay></video>`;
        else if (meta.type.startsWith('audio/')) els.mediaModalBody.innerHTML = `<div class="modal-file-fallback"><svg><use href="#r-play"></use></svg><h3>${escapeHtml(meta.name)}</h3><audio src="${url}" controls autoplay></audio></div>`;
        else if (meta.type.includes('pdf')) els.mediaModalBody.innerHTML = `<iframe src="${url}" title="${escapeAttribute(meta.name)}"></iframe>`;
        else els.mediaModalBody.innerHTML = `<div class="modal-file-fallback"><svg><use href="#r-file"></use></svg><h3>${escapeHtml(meta.name)}</h3><p>This file is stored locally. Use the source case if you need to download or replace it.</p></div>`;
      }
    }
    els.mediaDialog.showModal();
  }

  function renderSourcePackets() {
    if (!caseData) return;
    const filtered = filteredSources();
    const packetSources = els.showAllPackets.checked ? filtered : filtered.filter(source => readerMeta.pinned.includes(source.id));
    if (!packetSources.length) {
      els.sourcePackets.innerHTML = `<div class="packet-empty"><strong>No sources pinned yet.</strong><p>Use “Pin for writing” while reading to build a focused evidence packet.</p></div>`;
      return;
    }
    els.sourcePackets.innerHTML = packetSources.map(source => `<article class="source-packet">
      <div class="source-packet-top"><span class="source-packet-date">${escapeHtml(formatDate(source))} · ${escapeHtml(TYPE_LABELS[source.type])}</span><button type="button" data-open-packet="${source.id}">Open at reading desk →</button></div>
      <h4>${escapeHtml(source.title)}</h4>
      ${source.content ? `<details class="packet-content"><summary>Saved source text</summary><p>${escapeHtml(source.content)}</p></details>` : ''}
      ${source.notes ? `<p class="packet-note">${escapeHtml(source.notes)}</p>` : ''}
      ${source.quote ? `<blockquote class="packet-quote">${escapeHtml(source.quote)}</blockquote>` : ''}
    </article>`).join('');
  }

  function setView(view) {
    currentView = view;
    $$('[data-view]').forEach(button => button.classList.toggle('active', button.dataset.view === view));
    els.timelineView.hidden = view !== 'timeline';
    els.mediaView.hidden = view !== 'media';
    els.writingView.hidden = view !== 'writing';
    if (view === 'media') renderMediaWall(filteredSources());
    if (view === 'writing') renderSourcePackets();
  }

  function renderWordCount() {
    const words = String(els.writingNotes.value || '').trim().match(/\S+/g)?.length || 0;
    els.wordCount.textContent = `${words} word${words === 1 ? '' : 's'}`;
  }

  function exportWritingDesk() {
    const packetSources = readerMeta.pinned.length ? sources.filter(source => readerMeta.pinned.includes(source.id)) : sources;
    let markdown = `# ${caseData.project.title} — writing desk\n\n`;
    if (caseData.project.question) markdown += `> ${caseData.project.question}\n\n`;
    markdown += `## Scratchpad\n\n${readerMeta.writing || '_No scratchpad notes yet._'}\n\n## Source packet\n\n`;
    sortSources(packetSources, 'asc').forEach(source => {
      markdown += `### ${formatDate(source)} — ${source.title}\n\n`;
      markdown += `- [Open source](${source.url})\n- Type: ${TYPE_LABELS[source.type]}\n- Quality: ${QUALITY_LABELS[source.credibility]}\n`;
      if (source.tags.length) markdown += `- Tags: ${source.tags.map(tag => `#${tag}`).join(', ')}\n`;
      if (source.content) markdown += `\n#### Saved source text\n\n${source.content}\n`;
      if (source.notes) markdown += `\n${source.notes}\n`;
      if (source.quote) markdown += `\n> ${source.quote.replace(/\n/g, '\n> ')}\n`;
      markdown += '\n';
    });
    download(`${slugify(caseData.project.title)}-writing-desk.md`, markdown, 'text/markdown');
    toast('Writing desk exported as Markdown.');
  }

  async function exportReaderCase() {
    if (!caseData || els.readerSaveButton.disabled) return;
    els.readerSaveButton.disabled = true;
    const embeddedAssets = [];
    const skipped = [];
    let packedBytes = 0;
    for (const source of caseData.sources) {
      for (const meta of source.attachments) {
        const blob = await assetBlob(meta.id);
        if (!blob || blob.size > EXPORT_EACH_LIMIT || packedBytes + blob.size > EXPORT_TOTAL_LIMIT) {
          skipped.push(meta.name);
          continue;
        }
        embeddedAssets.push({ id: meta.id, sourceId: source.id, name: meta.name, type: meta.type, size: blob.size, dataUrl: await blobToDataUrl(blob) });
        packedBytes += blob.size;
      }
    }
    const payload = { app: 'Source Desk', format: 'sourcedesk-json', version: 3, exportedAt: new Date().toISOString(), data: caseData, embeddedAssets };
    download(`${slugify(caseData.project.title)}.sourcedesk.json`, JSON.stringify(payload, null, 2), 'application/json');
    els.readerSaveButton.disabled = false;
    toast(skipped.length ? `Dossier saved. ${skipped.length} large or unavailable file${skipped.length === 1 ? '' : 's'} kept as references.` : 'Editable dossier saved with its available local evidence.', skipped.length ? 'warning' : undefined, 6500);
  }

  function blobToDataUrl(blob) {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => resolve(reader.result);
      reader.onerror = () => reject(reader.error);
      reader.readAsDataURL(blob);
    });
  }

  async function copyCitation(source) {
    if (!source) return;
    const citation = `${source.title}. ${formatDate(source)}. ${source.domain}. ${source.url}`;
    try { await navigator.clipboard.writeText(citation); }
    catch {
      const field = document.createElement('textarea');
      field.value = citation;
      field.style.position = 'fixed';
      field.style.opacity = '0';
      document.body.appendChild(field);
      field.select();
      document.execCommand('copy');
      field.remove();
    }
    toast('Citation copied.');
  }

  function youtubeEmbedUrl(value) {
    try {
      const url = new URL(value);
      let host = url.hostname.toLowerCase().replace(/^www\./, '');
      let id = '';
      const list = url.searchParams.get('list') || '';
      if (host === 'youtu.be') id = url.pathname.split('/').filter(Boolean)[0] || '';
      if (host === 'm.youtube.com' || host === 'music.youtube.com' || host === 'youtube-nocookie.com') host = 'youtube.com';
      if (host === 'youtube.com') {
        id = url.searchParams.get('v') || url.pathname.match(/\/(?:shorts|embed|live)\/([^/?]+)/)?.[1] || id;
        if (url.pathname.includes('/playlist') && list) id = '';
      }
      if (!id && !list) return '';
      const base = id ? 'https://www.youtube-nocookie.com/embed/' + encodeURIComponent(id) : 'https://www.youtube-nocookie.com/embed/videoseries';
      const params = new URLSearchParams();
      params.set('rel', '0');
      if (list) params.set('list', list);
      return base + '?' + params.toString();
    } catch { return ''; }
  }

  function previewUrl(value) {
    const youtube = youtubeEmbedUrl(value);
    if (youtube) return youtube;
    try {
      const url = new URL(value);
      const host = url.hostname.replace(/^www\./, '');
      if (host === 'vimeo.com' && /^\/\d+/.test(url.pathname)) return 'https://player.vimeo.com/video/' + url.pathname.split('/')[1];
    } catch {}
    return value;
  }

  function isPlayableUrl(value) {
    const embedded = previewUrl(value);
    return Boolean(embedded && embedded !== value);
  }

  function isVisualMeta(meta) { return meta.type.startsWith('image/') || meta.type.startsWith('video/'); }
  function sourceById(id) { return sources.find(source => source.id === id); }
  function activeSource() { return sourceById(activeId); }

  function shortDate(source) {
    if (!source.dateISO) return 'TBC';
    const [, month, day] = source.dateISO.split('-').map(Number);
    if (source.datePrecision === 'year') return source.dateISO.slice(0, 4);
    if (source.datePrecision === 'month') return MONTHS[month - 1];
    return `${String(day).padStart(2, '0')} ${MONTHS[month - 1]}`;
  }

  function formatDate(source) {
    if (!source.dateISO) return 'Date to verify';
    const [year, month, day] = source.dateISO.split('-').map(Number);
    if (source.datePrecision === 'year') return String(year);
    if (source.datePrecision === 'month') return `${MONTHS[month - 1]} ${year}`;
    const value = `${String(day).padStart(2, '0')} ${MONTHS[month - 1]} ${year}`;
    return source.datePrecision === 'approximate' ? `c. ${value}` : value;
  }

  function domainFromUrl(value) {
    try { return new URL(value).hostname.replace(/^www\./, ''); } catch { return 'source'; }
  }

  async function assetBlob(id) {
    if (blobs.has(id)) return blobs.get(id);
    try {
      const readerRecord = await getDbRecord(openReaderDb(), READER_STORE, id);
      if (readerRecord?.blob) { blobs.set(id, readerRecord.blob); return readerRecord.blob; }
    } catch { /* try sorter storage */ }
    try {
      const sorterRecord = await getDbRecord(openSorterDb(), SORTER_STORE, id);
      if (sorterRecord?.blob) { blobs.set(id, sorterRecord.blob); return sorterRecord.blob; }
    } catch { /* filename reference only */ }
    return null;
  }

  function openReaderDb() {
    if (!readerDbPromise) readerDbPromise = openDb(READER_DB, READER_STORE, true);
    return readerDbPromise;
  }

  function openSorterDb() {
    if (!sorterDbPromise) sorterDbPromise = openDb(SORTER_DB, SORTER_STORE, false);
    return sorterDbPromise;
  }

  function openDb(name, storeName, create) {
    return new Promise((resolve, reject) => {
      if (!window.indexedDB) return reject(new Error('IndexedDB unavailable'));
      const request = indexedDB.open(name, 1);
      request.onupgradeneeded = () => {
        if (create && !request.result.objectStoreNames.contains(storeName)) request.result.createObjectStore(storeName, { keyPath: 'id' });
      };
      request.onsuccess = () => {
        if (!request.result.objectStoreNames.contains(storeName)) { request.result.close(); reject(new Error('Store unavailable')); }
        else resolve(request.result);
      };
      request.onerror = () => reject(request.error);
    });
  }

  async function persistReaderAsset(record) {
    const db = await openReaderDb();
    return new Promise((resolve, reject) => {
      const request = db.transaction(READER_STORE, 'readwrite').objectStore(READER_STORE).put({ id: record.id, name: record.name, type: record.type, size: record.size, blob: record.blob });
      request.onsuccess = () => resolve();
      request.onerror = () => reject(request.error);
    });
  }

  async function getDbRecord(dbPromise, storeName, id) {
    const db = await dbPromise;
    return new Promise((resolve, reject) => {
      const request = db.transaction(storeName, 'readonly').objectStore(storeName).get(id);
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  function objectUrlFor(id, blob) {
    if (!objectUrls.has(id)) objectUrls.set(id, URL.createObjectURL(blob));
    return objectUrls.get(id);
  }

  function dataUrlToBlob(dataUrl) {
    const [header, payload] = String(dataUrl).split(',');
    const mime = header.match(/data:([^;]+)/)?.[1] || 'application/octet-stream';
    const binary = atob(payload);
    const bytes = new Uint8Array(binary.length);
    for (let index = 0; index < binary.length; index += 1) bytes[index] = binary.charCodeAt(index);
    return new Blob([bytes], { type: mime });
  }

  function formatBytes(bytes) {
    if (!bytes) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    const index = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1);
    return `${(bytes / 1024 ** index).toFixed(index ? 1 : 0)} ${units[index]}`;
  }

  function download(filename, contents, type) {
    const url = URL.createObjectURL(new Blob([contents], { type }));
    const link = document.createElement('a');
    link.href = url;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    link.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  }

  function slugify(value) { return String(value || 'research').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '').slice(0, 70) || 'research'; }
  function readJson(key) { try { return JSON.parse(localStorage.getItem(key)); } catch { return null; } }
  function escapeHtml(value) { return String(value ?? '').replace(/[&<>'"]/g, char => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;' })[char]); }
  function escapeAttribute(value) { return escapeHtml(value).replace(/`/g, '&#96;'); }

  function toast(message, type = 'success', duration = 4200) {
    const node = document.createElement('div');
    node.className = `reader-toast ${type}`;
    node.textContent = message;
    els.readerToast.appendChild(node);
    setTimeout(() => node.remove(), duration);
  }

  init();
})();
















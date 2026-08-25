(() => {
  'use strict';

  const STORAGE_KEY = 'source-desk-story-lab-v1';
  const RECOVERY_DB = 'source-desk-story-lab-recovery-v1';
  const RECOVERY_STORE = 'snapshots';
  const SOURCE_DESK_KEY = 'source-desk-state-v2';
  const READER_CASE_KEY = 'source-desk-reader-case-v1';
  const COLORS = ['#078979','#ef765d','#f2c454','#8fc9d7','#9a87ca','#4f8064','#d7779f','#7f91b3'];
  const VIEW_INFO = {
    overview:['CASE COMMAND','Story overview','The whole investigation at a glance: coverage, unresolved questions, and the next useful move.'],
    timeline:['CHRONOLOGY ENGINE','Timeline map','Overlapping threads, competing versions, date gaps, and causal sequence on one draggable map.'],
    board:['RELATIONSHIP CANVAS','Evidence board','A deliberately curated wall for the pivotal people, events, claims, notes, and connections.'],
    people:['ACTOR DIRECTORY','People & entities','Track roles, aliases, relationships, appearances, source coverage, and narrative importance.'],
    claims:['EVIDENCE LEDGER','Claims & contradictions','Separate what was said from what happened; group incompatible versions and trace every assertion to sources.'],
    outline:['STORY ARCHITECTURE','Story outline','Turn the investigation into chapters while measuring whether each narrative beat is actually supported.'],
    sources:['REFERENCE LIBRARY','Source library','The compact Source Desk catalog behind every event, person, claim, chapter, and note.'],
    notes:['WORKING MEMORY','Research notebook','Capture loose leads and questions without forcing them into the formal story too early.']
  };
  const TYPE_LABELS = { article:'Article','article-video':'Article + video',video:'Video',document:'PDF / document',image:'Image',social:'Social',other:'Other' };
  const CLAIM_STATUS = { supported:'Supported',disputed:'Disputed',unverified:'Unverified',resolved:'Resolved' };
  const CLAIM_COLORS = { supported:'#078979',disputed:'#ef765d',unverified:'#f2c454',resolved:'#8fc9d7' };
  const LINK_LABELS = { related:'Related',supports:'Supports',contradicts:'Contradicts',causes:'Causes / leads to',alibi:'Alibi / excludes',knows:'Knows / associated',located:'Located at' };
  const $ = (selector, root = document) => root.querySelector(selector);
  const $$ = (selector, root = document) => [...root.querySelectorAll(selector)];
  const els = {};
  let state;
  let currentView = 'overview';
  let saveTimer;
  let lastCheckpointAt = 0;
  let recoveryDbPromise;
  let history = [];
  let future = [];
  let activeEditor = null;
  let timelineDrag = null;
  let boardDrag = null;
  let claimDragId = null;
  let chapterDragId = null;
  let deskWindow = window.opener && !window.opener.closed ? window.opener : null;

  function uid(prefix) {
    return prefix + '_' + (crypto.randomUUID ? crypto.randomUUID() : Date.now().toString(36) + Math.random().toString(36).slice(2));
  }

  function defaultState() {
    const now = new Date().toISOString();
    return {
      labVersion:1,
      project:{ id:uid('story'), sourceProjectId:'', title:'Untitled story investigation', question:'', theory:'', objective:'', createdAt:now, updatedAt:now },
      sourceLibrary:[],
      threads:[{ id:uid('thread'), name:'Main chronology', color:COLORS[0], description:'The central sequence of events.', order:0 }],
      events:[], actors:[], claims:[], chapters:[], notes:[], links:[],
      activity:[{ id:uid('activity'), at:now, text:'Story Lab created.' }],
      ui:{ timelineZoom:2, timelineThread:'all', timelineBranch:'all', timelineConfidence:'all', actorFilter:'all', sourceFilter:'all', globalSearch:'', draft:null }
    };
  }

  function sanitizeState(raw) {
    const base = defaultState();
    if (!raw || typeof raw !== 'object') return base;
    const project = raw.project || {};
    base.labVersion = 1;
    base.project = { ...base.project, ...project, id:String(project.id || base.project.id), title:String(project.title || base.project.title) };
    base.sourceLibrary = Array.isArray(raw.sourceLibrary) ? raw.sourceLibrary.map(cleanSource) : [];
    base.threads = Array.isArray(raw.threads) && raw.threads.length ? raw.threads.map((item,index) => ({ id:item.id || uid('thread'), name:String(item.name || 'Timeline thread'), color:item.color || COLORS[index % COLORS.length], description:String(item.description || ''), order:Number.isFinite(item.order) ? item.order : index })) : base.threads;
    base.events = Array.isArray(raw.events) ? raw.events.map(cleanEvent) : [];
    base.actors = Array.isArray(raw.actors) ? raw.actors.map(cleanActor) : [];
    base.claims = Array.isArray(raw.claims) ? raw.claims.map(cleanClaim) : [];
    base.chapters = Array.isArray(raw.chapters) ? raw.chapters.map(cleanChapter) : [];
    base.notes = Array.isArray(raw.notes) ? raw.notes.map(cleanNote) : [];
    base.links = Array.isArray(raw.links) ? raw.links.map(cleanLink).filter(Boolean) : [];
    base.activity = Array.isArray(raw.activity) ? raw.activity.slice(-80) : base.activity;
    base.ui = { ...base.ui, ...(raw.ui || {}), draft:raw.ui?.draft || null };
    return base;
  }

  function cleanSource(source={}) {
    return { id:String(source.id || uid('source')), title:String(source.title || source.url || 'Untitled source'), url:String(source.url || ''), domain:String(source.domain || domainFromUrl(source.url)), type:TYPE_LABELS[source.type] ? source.type : 'other', status:source.status === 'inbox' ? 'inbox' : 'timeline', dateISO:source.dateISO || null, dateInput:String(source.dateInput || ''), datePrecision:String(source.datePrecision || 'unknown'), tags:Array.isArray(source.tags) ? source.tags.map(String) : [], credibility:String(source.credibility || 'unchecked'), relevance:Number(source.relevance) || 0, notes:String(source.notes || '').slice(0,3000), quote:String(source.quote || '').slice(0,1500), contentPreview:String(source.contentPreview || source.content || '').slice(0,1200), contentLength:Number(source.contentLength || String(source.content || '').length) || 0, attachments:Array.isArray(source.attachments) ? source.attachments.map(meta => ({ id:meta.id, name:String(meta.name || ''), type:String(meta.type || ''), size:Number(meta.size)||0 })) : [] };
  }
  function cleanEvent(item={}) { return { id:item.id || uid('event'), title:String(item.title || 'Untitled event'), dateISO:item.dateISO || null, dateInput:String(item.dateInput || ''), endDateISO:item.endDateISO || null, endDateInput:String(item.endDateInput || ''), precision:String(item.precision || 'exact'), confidence:['confirmed','probable','reported','disputed','unknown'].includes(item.confidence) ? item.confidence : 'reported', importance:Math.max(1,Math.min(5,Number(item.importance)||3)), threadId:item.threadId || '', branch:String(item.branch || 'Main version'), location:String(item.location || ''), summary:String(item.summary || ''), details:String(item.details || ''), actorIds:Array.isArray(item.actorIds) ? item.actorIds.map(String) : [], sourceIds:Array.isArray(item.sourceIds) ? item.sourceIds.map(String) : [], onBoard:Boolean(item.onBoard), x:Number(item.x)||0, y:Number(item.y)||0, createdAt:item.createdAt || new Date().toISOString(), updatedAt:item.updatedAt || new Date().toISOString() }; }
  function cleanActor(item={}) { return { id:item.id || uid('actor'), name:String(item.name || 'Unnamed person'), kind:['person','organization','place','other'].includes(item.kind) ? item.kind : 'person', role:String(item.role || ''), aliases:String(item.aliases || ''), summary:String(item.summary || ''), tags:Array.isArray(item.tags) ? item.tags.map(String) : parseTags(item.tags || ''), sourceIds:Array.isArray(item.sourceIds) ? item.sourceIds.map(String) : [], color:item.color || COLORS[0], onBoard:Boolean(item.onBoard), x:Number(item.x)||0, y:Number(item.y)||0, createdAt:item.createdAt || new Date().toISOString(), updatedAt:item.updatedAt || new Date().toISOString() }; }
  function cleanClaim(item={}) { return { id:item.id || uid('claim'), statement:String(item.statement || 'Untitled claim'), topic:String(item.topic || ''), status:CLAIM_STATUS[item.status] ? item.status : 'unverified', confidence:Math.max(0,Math.min(100,Number(item.confidence)||50)), notes:String(item.notes || ''), actorIds:Array.isArray(item.actorIds) ? item.actorIds.map(String) : [], eventIds:Array.isArray(item.eventIds) ? item.eventIds.map(String) : [], sourceIds:Array.isArray(item.sourceIds) ? item.sourceIds.map(String) : [], onBoard:Boolean(item.onBoard), x:Number(item.x)||0, y:Number(item.y)||0, createdAt:item.createdAt || new Date().toISOString(), updatedAt:item.updatedAt || new Date().toISOString() }; }
  function cleanChapter(item={}) { return { id:item.id || uid('chapter'), title:String(item.title || 'Untitled chapter'), status:['idea','researching','ready','drafted'].includes(item.status) ? item.status : 'idea', summary:String(item.summary || ''), eventIds:Array.isArray(item.eventIds) ? item.eventIds.map(String) : [], claimIds:Array.isArray(item.claimIds) ? item.claimIds.map(String) : [], sourceIds:Array.isArray(item.sourceIds) ? item.sourceIds.map(String) : [], order:Number.isFinite(item.order) ? item.order : 0, createdAt:item.createdAt || new Date().toISOString(), updatedAt:item.updatedAt || new Date().toISOString() }; }
  function cleanNote(item={}) { return { id:item.id || uid('note'), title:String(item.title || 'Untitled note'), type:['lead','question','observation','reminder'].includes(item.type) ? item.type : 'observation', body:String(item.body || ''), tags:Array.isArray(item.tags) ? item.tags.map(String) : parseTags(item.tags || ''), sourceIds:Array.isArray(item.sourceIds) ? item.sourceIds.map(String) : [], pinned:Boolean(item.pinned), onBoard:Boolean(item.onBoard), x:Number(item.x)||0, y:Number(item.y)||0, createdAt:item.createdAt || new Date().toISOString(), updatedAt:item.updatedAt || new Date().toISOString() }; }
  function cleanLink(item={}) { if (!item.from || !item.to) return null; return { id:item.id || uid('link'), from:String(item.from), to:String(item.to), type:LINK_LABELS[item.type] ? item.type : 'related', label:String(item.label || '') }; }

  function cacheElements() {
    ['labProjectTitle','saveStatus','syncSourcesButton','checkpointButton','exportLabButton','labMoreMenu','labNav','openNotesButton','quickNote','saveQuickNote','safetyLabel','healthBar','storageLabel','viewEyebrow','viewTitle','viewDescription','globalSearch','quickAddMenu','overviewView','timelineView','boardView','peopleView','claimsView','outlineView','sourcesView','notesView','overviewHero','overviewTimeline','overviewConflicts','overviewGaps','overviewActors','overviewActivity','timelineThreadFilter','timelineBranchFilter','timelineConfidenceFilter','timelineZoom','fitTimelineButton','timelineViewport','timelineCanvas','unknownEvents','arrangeBoardButton','evidenceBoard','boardLines','boardNodes','boardEmpty','actorTypeFilters','actorGrid','contradictionDeck','claimColumns','chapterList','sourceSearch','sourceAssignmentFilter','sourceStats','sourceLibrary','notesGrid','entityDrawer','closeDrawer','drawerEyebrow','drawerTitle','entityForm','drawerBody','deleteEntityButton','drawerSaveHint','projectDialog','projectForm','closeProjectDialog','cancelProjectDialog','briefTitle','briefQuestion','briefTheory','briefObjective','recoveryDialog','closeRecoveryDialog','recoveryList','labImportInput','labToast','navOverviewCount','navTimelineCount','navBoardCount','navPeopleCount','navClaimsCount','navOutlineCount','navSourcesCount'].forEach(id => { els[id] = document.getElementById(id); });
  }

  async function init() {
    cacheElements();
    bindEvents();
    try { state = sanitizeState(JSON.parse(localStorage.getItem(STORAGE_KEY) || 'null')); }
    catch { state = defaultState(); toast('The latest local copy was damaged. Open Recovery checkpoints to restore an earlier version.', 'warning', 7000); }
    els.labProjectTitle.value = state.project.title;
    els.globalSearch.value = state.ui.globalSearch || '';
    els.timelineZoom.value = state.ui.timelineZoom || 2;
    els.timelineConfidenceFilter.value = state.ui.timelineConfidence || 'all';
    renderAll();
    updateStorageHealth();
    openRecoveryDb().catch(() => { els.safetyLabel.textContent = 'LocalStorage only'; });
    if (!state.sourceLibrary.length) syncSources(false);
    requestDeskSnapshot();
    const requestedSource = new URLSearchParams(location.search).get('source');
    if (requestedSource) { setView('sources'); setTimeout(() => { els.sourceSearch.value = requestedSource; renderSources(); }, 50); }
    if (state.ui.draft) setTimeout(() => { toast('An unsaved editor draft was recovered.', 'warning'); openEditor(state.ui.draft.type, state.ui.draft.id, true); }, 350);
  }

  function bindEvents() {
    els.labProjectTitle.addEventListener('input', () => { state.project.title = els.labProjectTitle.value || 'Untitled story investigation'; scheduleSave(); });
    els.labProjectTitle.addEventListener('blur', () => { els.labProjectTitle.value = state.project.title; renderOverview(); });
    els.syncSourcesButton.addEventListener('click', () => syncSources(true));
    els.checkpointButton.addEventListener('click', () => createCheckpoint('manual', true));
    els.exportLabButton.addEventListener('click', exportLab);
    els.labMoreMenu.addEventListener('click', handleMoreMenu);
    els.labNav.addEventListener('click', event => { const button=event.target.closest('[data-view]'); if (button) setView(button.dataset.view); });
    document.addEventListener('click', event => {
      const go=event.target.closest('[data-go]'); if (go) setView(go.dataset.go);
      const add=event.target.closest('[data-new]'); if (add) { els.quickAddMenu.removeAttribute('open'); openEditor(add.dataset.new); }
      const edit=event.target.closest('[data-edit]'); if (edit) openEditor(edit.dataset.edit, edit.dataset.id);
      const read=event.target.closest('[data-read-source]'); if (read) openReaderSource(read.dataset.readSource);
      const use=event.target.closest('[data-use-source]'); if (use) { state.ui.seedSourceIds=[use.dataset.useSource]; openEditor('event'); }
      if (els.labMoreMenu.open && !els.labMoreMenu.contains(event.target)) els.labMoreMenu.removeAttribute('open');
      if (els.quickAddMenu.open && !els.quickAddMenu.contains(event.target)) els.quickAddMenu.removeAttribute('open');
    });
    els.globalSearch.addEventListener('input', () => { state.ui.globalSearch=els.globalSearch.value; scheduleSave(); renderCurrentView(); });
    els.saveQuickNote.addEventListener('click', saveQuickNote);
    els.openNotesButton.addEventListener('click', () => setView('notes'));
    els.timelineThreadFilter.addEventListener('change', () => { state.ui.timelineThread=els.timelineThreadFilter.value; scheduleSave(); renderTimeline(); });
    els.timelineBranchFilter.addEventListener('change', () => { state.ui.timelineBranch=els.timelineBranchFilter.value; scheduleSave(); renderTimeline(); });
    els.timelineConfidenceFilter.addEventListener('change', () => { state.ui.timelineConfidence=els.timelineConfidenceFilter.value; scheduleSave(); renderTimeline(); });
    els.timelineZoom.addEventListener('input', () => { state.ui.timelineZoom=Number(els.timelineZoom.value); scheduleSave(); renderTimeline(); });
    els.fitTimelineButton.addEventListener('click', () => { els.timelineZoom.value=1; state.ui.timelineZoom=1; scheduleSave(); renderTimeline(); els.timelineViewport.scrollLeft=0; });
    els.timelineCanvas.addEventListener('click', event => { const card=event.target.closest('.tl-event'); if (card && !card.dataset.dragged) openEditor('event',card.dataset.id); });
    els.timelineCanvas.addEventListener('pointerdown', startTimelineDrag);
    els.boardNodes.addEventListener('click', event => { const node=event.target.closest('.board-node'); if (node && !node.dataset.dragged) openEditor(node.dataset.kind,node.dataset.id); });
    els.boardNodes.addEventListener('pointerdown', startBoardDrag);
    els.arrangeBoardButton.addEventListener('click', autoArrangeBoard);
    els.actorTypeFilters.addEventListener('click', event => { const b=event.target.closest('[data-actor-filter]'); if (!b) return; state.ui.actorFilter=b.dataset.actorFilter; scheduleSave(); renderPeople(); });
    els.claimColumns.addEventListener('dragstart', event => { const card=event.target.closest('.claim-card'); if (card) { claimDragId=card.dataset.id; card.classList.add('dragging'); } });
    els.claimColumns.addEventListener('dragend', event => { event.target.closest('.claim-card')?.classList.remove('dragging'); claimDragId=null; $$('.claim-column').forEach(c=>c.classList.remove('over')); });
    els.claimColumns.addEventListener('dragover', event => { event.preventDefault(); event.target.closest('.claim-column')?.classList.add('over'); });
    els.claimColumns.addEventListener('dragleave', event => event.target.closest('.claim-column')?.classList.remove('over'));
    els.claimColumns.addEventListener('drop', handleClaimDrop);
    els.chapterList.addEventListener('dragstart', event => { const card=event.target.closest('.chapter-card'); if (card) { chapterDragId=card.dataset.id; card.classList.add('dragging'); } });
    els.chapterList.addEventListener('dragend', event => { event.target.closest('.chapter-card')?.classList.remove('dragging'); chapterDragId=null; });
    els.chapterList.addEventListener('dragover', event => event.preventDefault());
    els.chapterList.addEventListener('drop', handleChapterDrop);
    els.sourceSearch.addEventListener('input', renderSources);
    els.sourceAssignmentFilter.addEventListener('change', () => { state.ui.sourceFilter=els.sourceAssignmentFilter.value; scheduleSave(); renderSources(); });
    els.entityForm.addEventListener('submit', saveEditor);
    els.entityForm.addEventListener('input', captureDraft);
    els.entityForm.addEventListener('change', captureDraft);
    els.deleteEntityButton.addEventListener('click', deleteActiveEntity);
    els.closeDrawer.addEventListener('click', closeDrawer);
    $$('[data-close-drawer]').forEach(item => item.addEventListener('click', closeDrawer));
    els.drawerBody.addEventListener('input', event => { if (event.target.matches('[data-picker-search]')) filterPicker(event.target); if (event.target.matches('.masked-date')) maskDate(event.target); });
    els.projectForm.addEventListener('submit', saveProjectBrief);
    els.closeProjectDialog.addEventListener('click', () => els.projectDialog.close());
    els.cancelProjectDialog.addEventListener('click', () => els.projectDialog.close());
    els.closeRecoveryDialog.addEventListener('click', () => els.recoveryDialog.close());
    els.recoveryList.addEventListener('click', event => { const b=event.target.closest('[data-restore]'); if (b) restoreCheckpoint(b.dataset.restore); });
    els.labImportInput.addEventListener('change', importSelectedFile);
    window.addEventListener('message', handleDeskMessage);
    window.addEventListener('pointermove', handlePointerMove);
    window.addEventListener('pointerup', handlePointerUp);
    window.addEventListener('beforeunload', () => saveNow());
    window.addEventListener('storage', event => { if (event.key===SOURCE_DESK_KEY && event.newValue) syncSources(false); });
    document.addEventListener('keydown', handleKeyboard);
  }

  function handleKeyboard(event) {
    const typing=/INPUT|TEXTAREA|SELECT/.test(document.activeElement?.tagName);
    const mod=event.ctrlKey||event.metaKey;
    if (mod && event.key.toLowerCase()==='s') { event.preventDefault(); exportLab(); return; }
    if (mod && event.key.toLowerCase()==='z') { event.preventDefault(); event.shiftKey ? redo() : undo(); return; }
    if (mod && event.key.toLowerCase()==='y') { event.preventDefault(); redo(); return; }
    if (!typing && event.key==='/') { event.preventDefault(); els.globalSearch.focus(); return; }
    if (!typing && !mod && event.key.toLowerCase()==='e') openEditor('event');
    if (!typing && !mod && event.key.toLowerCase()==='a') openEditor('actor');
    if (!typing && !mod && event.key.toLowerCase()==='c') openEditor('claim');
    if (event.key==='Escape' && els.entityDrawer.classList.contains('open')) closeDrawer();
  }

  function setView(view) {
    if (!VIEW_INFO[view]) return;
    currentView=view;
    $$('.lab-nav [data-view]').forEach(button => button.classList.toggle('active',button.dataset.view===view));
    $$('.lab-view').forEach(section => { section.hidden = section.id !== view+'View'; });
    [els.viewEyebrow.textContent,els.viewTitle.textContent,els.viewDescription.textContent]=VIEW_INFO[view];
    renderCurrentView();
    window.scrollTo({top:0,behavior:'smooth'});
  }

  function renderAll() {
    renderNavCounts();
    renderThreadFilters();
    renderOverview(); renderTimeline(); renderBoard(); renderPeople(); renderClaims(); renderOutline(); renderSources(); renderNotes();
  }
  function renderCurrentView() { ({overview:renderOverview,timeline:renderTimeline,board:renderBoard,people:renderPeople,claims:renderClaims,outline:renderOutline,sources:renderSources,notes:renderNotes}[currentView]||renderOverview)(); renderNavCounts(); }
  function renderNavCounts() {
    els.navTimelineCount.textContent=state.events.length;
    els.navBoardCount.textContent=boardEntities().length;
    els.navPeopleCount.textContent=state.actors.length;
    els.navClaimsCount.textContent=state.claims.length;
    els.navOutlineCount.textContent=state.chapters.length;
    els.navSourcesCount.textContent=state.sourceLibrary.length;
    els.navOverviewCount.textContent='';
  }
  function matchesSearch(...parts) { const query=String(state.ui.globalSearch||'').trim().toLowerCase(); return !query || parts.join(' ').toLowerCase().includes(query); }

  function renderOverview() {
    if (!state) return;
    const referenced=referencedSourceIds();
    const conflicts=conflictGroups();
    const undated=state.events.filter(event=>!event.dateISO).length;
    els.overviewHero.innerHTML=`<div class="overview-northstar"><span>CASE NORTH STAR</span><h2>${escapeHtml(state.project.question || 'Define the central question that this investigation must answer.')}</h2><p>${escapeHtml(state.project.theory || 'Build chronology, actors, claims, and source-backed connections. The overview will continuously expose what is solid and what still needs proof.')}</p></div>${[[state.events.length,'events'],[state.actors.length,'actors'],[conflicts.length,'conflicts'],[referenced.size+'/'+state.sourceLibrary.length,'sources used']].map(([v,l])=>`<div class="overview-stat"><strong>${v}</strong><span>${l}</span></div>`).join('')}`;
    renderMiniTimeline();
    els.overviewConflicts.innerHTML=conflicts.length ? conflicts.slice(0,5).map(group=>`<div class="overview-row"><i style="--row-color:var(--coral)"></i><div><strong>${escapeHtml(group.topic)}</strong><span>${group.claims.length} incompatible or competing versions</span></div><b>${group.claims.filter(c=>c.status==='disputed').length}</b></div>`).join('') : '<div class="empty-mini">No grouped contradictions yet.</div>';
    const gaps=[];
    const eventNoSource=state.events.filter(e=>!e.sourceIds.length).length;if(eventNoSource)gaps.push([eventNoSource,'events without sources','Add evidence before treating them as established.']);
    const actorNoSource=state.actors.filter(a=>!a.sourceIds.length).length;if(actorNoSource)gaps.push([actorNoSource,'actors without source anchors','Confirm identities and roles.']);
    const unused=state.sourceLibrary.length-referenced.size;if(unused)gaps.push([unused,'unused sources','Review for missing events, claims, or counterpoints.']);
    if(undated)gaps.push([undated,'events without dates','Keep them visible in the verification lane.']);
    els.overviewGaps.innerHTML=gaps.length ? gaps.slice(0,5).map(([n,title,copy])=>`<div class="overview-row"><i style="--row-color:var(--yellow)"></i><div><strong>${n} ${escapeHtml(title)}</strong><span>${escapeHtml(copy)}</span></div></div>`).join('') : '<div class="empty-mini">No obvious structural gaps. Keep verifying.</div>';
    const central=[...state.actors].sort((a,b)=>actorWeight(b.id)-actorWeight(a.id)).slice(0,9);
    els.overviewActors.innerHTML=central.length ? central.map(a=>`<button class="actor-orbit" type="button" data-edit="actor" data-id="${a.id}"><i style="--actor-color:${a.color}">${escapeHtml(a.name.charAt(0).toUpperCase())}</i><span><strong>${escapeHtml(a.name)}</strong><span>${actorWeight(a.id)} links · ${escapeHtml(a.role||a.kind)}</span></span></button>`).join('') : '<div class="empty-mini">Add the first person or entity.</div>';
    els.overviewActivity.innerHTML=state.activity.slice(-7).reverse().map(item=>`<div class="activity-item"><time>${formatActivityTime(item.at)}</time><i></i><p>${escapeHtml(item.text)}</p></div>`).join('') || '<div class="empty-mini">No activity yet.</div>';
  }

  function renderMiniTimeline() {
    const items=state.events.filter(event=>event.dateISO).sort((a,b)=>a.dateISO.localeCompare(b.dateISO));
    if(!items.length){els.overviewTimeline.innerHTML='<div class="empty-mini">Add dated events to reveal the story shape.</div>';return;}
    const min=dateNumber(items[0].dateISO),max=dateNumber(items.at(-1).dateISO),span=Math.max(1,max-min);
    const marks=items.slice(0,18).map(event=>{
      const left=((dateNumber(event.dateISO)-min)/span)*92+3;
      const thread=threadById(event.threadId);
      const edge=left>88?' edge-right':left<8?' edge-left':'';
      return `<button class="mini-event${edge}" type="button" data-edit="event" data-id="${event.id}" title="${escapeAttribute(event.title+' · '+shortDate(event))}" style="left:${left}%;--event-color:${thread?.color||COLORS[0]}"><strong>${escapeHtml(event.title)}</strong><i></i><span>${escapeHtml(shortDate(event))}</span></button>`;
    }).join('');
    els.overviewTimeline.innerHTML=`<div class="mini-range"><span>${escapeHtml(shortDate(items[0]))}</span><span>${escapeHtml(shortDate(items.at(-1)))}</span></div>`+marks;
  }

  function renderThreadFilters() {
    const threads=orderedThreads();
    els.timelineThreadFilter.innerHTML='<option value="all">All threads</option>'+threads.map(t=>`<option value="${t.id}">${escapeHtml(t.name)}</option>`).join('');
    els.timelineThreadFilter.value=threads.some(t=>t.id===state.ui.timelineThread)?state.ui.timelineThread:'all';
    const branches=[...new Set(state.events.map(e=>e.branch).filter(Boolean))].sort();
    els.timelineBranchFilter.innerHTML='<option value="all">All versions</option>'+branches.map(branch=>`<option value="${escapeAttribute(branch)}">${escapeHtml(branch)}</option>`).join('');
    els.timelineBranchFilter.value=branches.includes(state.ui.timelineBranch)?state.ui.timelineBranch:'all';
  }

  function filteredEvents() {
    return state.events.filter(event=>matchesSearch(event.title,event.summary,event.details,event.location,event.branch) && (state.ui.timelineThread==='all'||event.threadId===state.ui.timelineThread) && (state.ui.timelineBranch==='all'||event.branch===state.ui.timelineBranch) && (state.ui.timelineConfidence==='all'||event.confidence===state.ui.timelineConfidence));
  }

  function renderTimeline() {
    if(!state)return;
    renderThreadFilters();
    const events=filteredEvents();
    const dated=events.filter(e=>e.dateISO).sort((a,b)=>a.dateISO.localeCompare(b.dateISO));
    const threads=orderedThreads().filter(thread=>state.ui.timelineThread==='all'||thread.id===state.ui.timelineThread);
    const fallbackThread=threads[0]||state.threads[0];
    if(!dated.length){els.timelineCanvas.style.width='100%';els.timelineCanvas.style.height='520px';els.timelineCanvas.innerHTML=`<div class="empty-view"><svg><use href="#b-timeline"></use></svg><h2>No dated events match this view.</h2><p>Add an event or clear the filters. Undated events remain below.</p><button class="lab-button button-dark" type="button" data-new="event">Add event</button></div>`;renderUnknownEvents(events);return;}
    let min=dateNumber(dated[0].dateISO),max=dateNumber(dated.at(-1).dateISO);if(min===max){min-=86400000*15;max+=86400000*15;}
    const spanDays=Math.max(1,(max-min)/86400000);const zoom=Number(state.ui.timelineZoom)||2;const width=Math.max(1150,Math.min(10000,900+spanDays*(spanDays>1200?.45:spanDays>365?1.2:4)*zoom));const height=46+Math.max(1,threads.length)*132;
    els.timelineCanvas.style.width=width+'px';els.timelineCanvas.style.height=Math.max(520,height)+'px';
    els.timelineCanvas.dataset.min=String(min);els.timelineCanvas.dataset.max=String(max);els.timelineCanvas.dataset.width=String(width);
    const ticks=Array.from({length:11},(_,i)=>{const ratio=i/10;const at=min+(max-min)*ratio;return `<div class="timeline-tick" style="left:${160+(width-210)*ratio}px"><span>${escapeHtml(formatTick(at,spanDays))}</span></div>`;}).join('');
    let html=`<div class="timeline-axis">${ticks}</div>`;
    threads.forEach((thread,index)=>{html+=`<div class="timeline-lane" data-thread-id="${thread.id}" style="top:${46+index*132}px"><div class="lane-label" style="--thread-color:${thread.color}"><i></i><div><strong>${escapeHtml(thread.name)}</strong><span>${state.events.filter(e=>e.threadId===thread.id).length} events</span></div></div></div>`;});
    const branchOffsets=new Map();
    dated.forEach(event=>{const threadIndex=Math.max(0,threads.findIndex(t=>t.id===(event.threadId||fallbackThread?.id)));const key=(event.threadId||'')+'|'+event.branch;if(!branchOffsets.has(key))branchOffsets.set(key,branchOffsets.size%3);const ratio=(dateNumber(event.dateISO)-min)/(max-min);const left=160+ratio*(width-380);const top=58+threadIndex*132+(branchOffsets.get(key)*16);const thread=threadById(event.threadId)||fallbackThread;html+=`<article class="tl-event ${event.confidence==='disputed'?'disputed':''}" data-id="${event.id}" style="left:${left}px;top:${top}px;--event-color:${thread?.color||COLORS[0]}"><time>${escapeHtml(shortDate(event))}</time><strong>${escapeHtml(event.title)}</strong><small><b>${escapeHtml(event.branch||'Main')}</b><span>${escapeHtml(event.confidence)}</span></small></article>`;});
    els.timelineCanvas.innerHTML=html;renderUnknownEvents(events);
  }
  function renderUnknownEvents(events){const undated=events.filter(e=>!e.dateISO);els.unknownEvents.innerHTML=undated.length?undated.map(e=>`<button class="unknown-event" type="button" data-edit="event" data-id="${e.id}"><strong>${escapeHtml(e.title)}</strong><span>${escapeHtml(e.branch)} · ${escapeHtml(threadById(e.threadId)?.name||'No thread')}</span></button>`).join(''):'<div class="empty-mini">Every visible event has a date.</div>';}

  function startTimelineDrag(event){const card=event.target.closest('.tl-event');if(!card||event.button!==0)return;pushHistory();const item=eventById(card.dataset.id);timelineDrag={card,item,startX:event.clientX,startY:event.clientY,left:parseFloat(card.style.left),top:parseFloat(card.style.top),moved:false};card.setPointerCapture?.(event.pointerId);event.preventDefault();}
  function startBoardDrag(event){const node=event.target.closest('.board-node');if(!node||event.button!==0)return;pushHistory();const item=entityByKind(node.dataset.kind,node.dataset.id);boardDrag={node,item,startX:event.clientX,startY:event.clientY,x:Number(item.x)||parseFloat(node.style.left),y:Number(item.y)||parseFloat(node.style.top),moved:false};node.setPointerCapture?.(event.pointerId);event.preventDefault();}
  function handlePointerMove(event){if(timelineDrag){const dx=event.clientX-timelineDrag.startX,dy=event.clientY-timelineDrag.startY;if(Math.abs(dx)+Math.abs(dy)>3)timelineDrag.moved=true;timelineDrag.card.classList.add('dragging');timelineDrag.card.style.left=Math.max(160,timelineDrag.left+dx)+'px';timelineDrag.card.style.top=Math.max(48,timelineDrag.top+dy)+'px';}if(boardDrag){const dx=event.clientX-boardDrag.startX,dy=event.clientY-boardDrag.startY;if(Math.abs(dx)+Math.abs(dy)>3)boardDrag.moved=true;boardDrag.node.style.left=Math.max(10,boardDrag.x+dx)+'px';boardDrag.node.style.top=Math.max(10,boardDrag.y+dy)+'px';renderBoardLines();}}
  function handlePointerUp(){if(timelineDrag){const d=timelineDrag;d.card.classList.remove('dragging');d.card.dataset.dragged=d.moved?'1':'';setTimeout(()=>delete d.card.dataset.dragged,0);if(d.moved){const width=Number(els.timelineCanvas.dataset.width),min=Number(els.timelineCanvas.dataset.min),max=Number(els.timelineCanvas.dataset.max),left=parseFloat(d.card.style.left);const ratio=Math.max(0,Math.min(1,(left-160)/(width-380)));const date=new Date(min+(max-min)*ratio);d.item.dateISO=date.toISOString().slice(0,10);d.item.dateInput=formatDmy(d.item.dateISO);const laneIndex=Math.max(0,Math.min(orderedThreads().length-1,Math.floor((parseFloat(d.card.style.top)-46)/132)));d.item.threadId=orderedThreads()[laneIndex]?.id||d.item.threadId;d.item.updatedAt=new Date().toISOString();activity(`Moved event “${d.item.title}” to ${d.item.dateInput}.`);scheduleSave(true);renderAll();}timelineDrag=null;}if(boardDrag){const d=boardDrag;d.node.dataset.dragged=d.moved?'1':'';setTimeout(()=>delete d.node.dataset.dragged,0);if(d.moved){d.item.x=Math.round(parseFloat(d.node.style.left));d.item.y=Math.round(parseFloat(d.node.style.top));d.item.updatedAt=new Date().toISOString();scheduleSave(true);renderBoardLines();}boardDrag=null;}}

  function boardEntities(){return [...state.actors.filter(x=>x.onBoard).map(item=>({kind:'actor',item})),...state.events.filter(x=>x.onBoard).map(item=>({kind:'event',item})),...state.claims.filter(x=>x.onBoard).map(item=>({kind:'claim',item})),...state.notes.filter(x=>x.onBoard).map(item=>({kind:'note',item}))];}
  function renderBoard(){if(!state)return;const nodes=boardEntities().filter(({item})=>matchesSearch(entityTitle(item),item.summary,item.details,item.notes,item.body));els.boardEmpty.hidden=nodes.length>0;els.boardNodes.innerHTML=nodes.map(({kind,item},index)=>{if(!item.x&&!item.y){item.x=40+(index%4)*270;item.y=45+Math.floor(index/4)*170;}const color=kind==='actor'?item.color:kind==='event'?(threadById(item.threadId)?.color||COLORS[1]):kind==='claim'?CLAIM_COLORS[item.status]:COLORS[3];const copy=kind==='actor'?item.summary:kind==='event'?(item.summary||item.details):kind==='claim'?item.notes:item.body;return `<article class="board-node ${kind}" data-kind="${kind}" data-id="${item.id}" style="left:${item.x}px;top:${item.y}px;--node-color:${color}"><em></em><span>${escapeHtml(kind.toUpperCase())}</span><strong>${escapeHtml(entityTitle(item))}</strong><p>${escapeHtml(copy||'No supporting note yet.')}</p></article>`;}).join('');requestAnimationFrame(renderBoardLines);}
  function renderBoardLines(){const entities=new Map(boardEntities().map(entry=>[entry.kind+':'+entry.item.id,entry]));const links=state.links.filter(link=>entities.has(link.from)&&entities.has(link.to));let paths='',labels='';links.forEach(link=>{const a=entities.get(link.from).item,b=entities.get(link.to).item;const x1=(a.x||0)+105,y1=(a.y||0)+52,x2=(b.x||0)+105,y2=(b.y||0)+52;const curve=Math.max(35,Math.abs(x2-x1)*.25);paths+=`<path class="board-line ${link.type}" d="M ${x1} ${y1} C ${x1+curve} ${y1}, ${x2-curve} ${y2}, ${x2} ${y2}"/>`;labels+=`<text class="board-line-label" x="${(x1+x2)/2}" y="${(y1+y2)/2-5}">${escapeHtml(link.label||LINK_LABELS[link.type])}</text>`;});els.boardLines.innerHTML=paths+labels;}
  function autoArrangeBoard(){pushHistory();const groups={actor:[],event:[],claim:[],note:[]};boardEntities().forEach(entry=>groups[entry.kind].push(entry.item));let row=0;Object.entries(groups).forEach(([kind,items],column)=>items.forEach((item,index)=>{item.x=40+column*310;item.y=45+index*155;row=Math.max(row,index);}));els.boardNodes.style.height=Math.max(800,(row+1)*170)+'px';activity('Auto-arranged the evidence board.');scheduleSave(true);renderBoard();}

  function renderPeople(){const filter=state.ui.actorFilter||'all';$$('[data-actor-filter]').forEach(b=>b.classList.toggle('active',b.dataset.actorFilter===filter));const actors=state.actors.filter(a=>(filter==='all'||a.kind===filter)&&matchesSearch(a.name,a.role,a.aliases,a.summary,a.tags.join(' ')));els.actorGrid.innerHTML=actors.length?actors.map(actor=>`<article class="actor-card" style="--actor-color:${actor.color}"><button type="button" data-edit="actor" data-id="${actor.id}" aria-label="Edit ${escapeAttribute(actor.name)}"></button><div class="actor-card-head"><div class="actor-monogram">${escapeHtml(actor.name.charAt(0).toUpperCase())}</div><div><h3>${escapeHtml(actor.name)}</h3><span>${escapeHtml(actor.role||actor.kind)}</span></div></div><p>${escapeHtml(actor.summary||'No profile summary yet.')}</p><div class="actor-card-meta">${actor.tags.slice(0,5).map(tag=>`<span>#${escapeHtml(tag)}</span>`).join('')}</div><div class="actor-card-foot"><span>${state.events.filter(e=>e.actorIds.includes(actor.id)).length} events</span><span>${actor.sourceIds.length} direct sources</span><span>${state.claims.filter(c=>c.actorIds.includes(actor.id)).length} claims</span></div></article>`).join(''):`<div class="empty-view"><svg><use href="#b-people"></use></svg><h2>No entities match this view.</h2><p>Add people, organizations, places, or other entities. Their event and claim appearances are counted automatically.</p><button class="lab-button button-dark" type="button" data-new="actor">Add entity</button></div>`;}

  function conflictGroups(){const groups=new Map();state.claims.forEach(claim=>{const topic=claim.topic.trim();if(!topic)return;if(!groups.has(topic.toLowerCase()))groups.set(topic.toLowerCase(),{topic,claims:[]});groups.get(topic.toLowerCase()).claims.push(claim);});return [...groups.values()].filter(group=>group.claims.length>1);}
  function renderClaims(){const conflicts=conflictGroups();els.contradictionDeck.innerHTML=conflicts.length?conflicts.map(group=>`<article class="conflict-card"><div class="conflict-head"><span>BRANCHING REPORT · ${group.claims.length} VERSIONS</span><h3>${escapeHtml(group.topic)}</h3></div><div class="conflict-versions">${group.claims.map(claim=>`<button class="conflict-version" type="button" data-edit="claim" data-id="${claim.id}"><strong>${escapeHtml(CLAIM_STATUS[claim.status])} · ${claim.confidence}%</strong><p>${escapeHtml(claim.statement)}</p><span>${claim.sourceIds.length} sources</span></button>`).join('')}</div></article>`).join(''):'<div class="lab-card"><div class="empty-mini">Give two or more claims the same conflict topic to compare competing versions here.</div></div>';
    els.claimColumns.innerHTML=Object.keys(CLAIM_STATUS).map(status=>{const claims=state.claims.filter(c=>c.status===status&&matchesSearch(c.statement,c.topic,c.notes));return `<section class="claim-column" data-status="${status}"><div class="claim-column-head"><span>${CLAIM_STATUS[status].toUpperCase()}</span><b>${claims.length}</b></div>${claims.map(claim=>`<article class="claim-card" draggable="true" data-id="${claim.id}" style="--claim-color:${CLAIM_COLORS[status]}"><button type="button" data-edit="claim" data-id="${claim.id}" aria-label="Edit claim"></button><span>${escapeHtml(claim.topic||'UNGROUPED CLAIM')}</span><p>${escapeHtml(claim.statement)}</p><small>${claim.confidence}% confidence · ${claim.sourceIds.length} sources</small></article>`).join('')}</section>`;}).join('');}
  function handleClaimDrop(event){event.preventDefault();const column=event.target.closest('.claim-column');if(!column||!claimDragId)return;const claim=claimById(claimDragId);if(claim&&claim.status!==column.dataset.status){pushHistory();claim.status=column.dataset.status;claim.updatedAt=new Date().toISOString();activity(`Moved claim to ${CLAIM_STATUS[claim.status]}.`);scheduleSave(true);renderClaims();renderOverview();}}

  function renderOutline(){const chapters=[...state.chapters].sort((a,b)=>a.order-b.order).filter(c=>matchesSearch(c.title,c.summary));els.chapterList.innerHTML=chapters.length?chapters.map((chapter,index)=>{const evidence=new Set([...chapter.sourceIds,...chapter.eventIds.flatMap(id=>eventById(id)?.sourceIds||[]),...chapter.claimIds.flatMap(id=>claimById(id)?.sourceIds||[])]);const beats=chapter.eventIds.length+chapter.claimIds.length;const coverage=beats?Math.min(100,Math.round((evidence.size/beats)*35+35)):0;return `<article class="chapter-card" draggable="true" data-id="${chapter.id}"><button type="button" data-edit="chapter" data-id="${chapter.id}" aria-label="Edit ${escapeAttribute(chapter.title)}"></button><div class="chapter-number">${String(index+1).padStart(2,'0')}</div><div class="chapter-main"><h3>${escapeHtml(chapter.title)}</h3><p>${escapeHtml(chapter.summary||'Describe the narrative purpose, reveal, and transition for this chapter.')}</p><div class="chapter-links"><span>${chapter.eventIds.length} events</span><span>${chapter.claimIds.length} claims</span><span>${evidence.size} sources</span></div></div><div class="chapter-coverage"><strong>Evidence coverage</strong><div class="coverage-bar"><i style="width:${coverage}%"></i></div><span>${coverage}% structural support</span></div><span class="chapter-status">${escapeHtml(chapter.status)}</span></article>`;}).join(''):`<div class="empty-view"><svg><use href="#b-outline"></use></svg><h2>No chapters yet.</h2><p>Start with broad narrative movements. Attach events and claims later; the coverage indicator will reveal unsupported beats.</p><button class="lab-button button-dark" type="button" data-new="chapter">Add first chapter</button></div>`;}
  function handleChapterDrop(event){event.preventDefault();const target=event.target.closest('.chapter-card');if(!target||!chapterDragId||target.dataset.id===chapterDragId)return;pushHistory();const ordered=[...state.chapters].sort((a,b)=>a.order-b.order);const from=ordered.findIndex(c=>c.id===chapterDragId),to=ordered.findIndex(c=>c.id===target.dataset.id);const [moved]=ordered.splice(from,1);ordered.splice(to,0,moved);ordered.forEach((c,i)=>c.order=i);activity('Reordered story chapters.');scheduleSave(true);renderOutline();}

  function referenceCounts(){const counts=new Map(state.sourceLibrary.map(s=>[s.id,0]));[...state.events,...state.actors,...state.claims,...state.chapters,...state.notes].forEach(item=>(item.sourceIds||[]).forEach(id=>counts.set(id,(counts.get(id)||0)+1)));return counts;}
  function referencedSourceIds(){return new Set([...referenceCounts()].filter(([,count])=>count>0).map(([id])=>id));}
  function renderSources(){const counts=referenceCounts(),query=els.sourceSearch.value.trim().toLowerCase(),filter=els.sourceAssignmentFilter.value||state.ui.sourceFilter||'all';els.sourceAssignmentFilter.value=filter;let sources=state.sourceLibrary.filter(source=>{const count=counts.get(source.id)||0;const matches=!query||`${source.id} ${source.title} ${source.domain} ${source.tags.join(' ')} ${source.notes} ${source.quote}`.toLowerCase().includes(query);return matches&&(filter==='all'||filter==='unassigned'&&!count||filter==='used'&&count||filter==='high'&&source.relevance>=4);});const used=[...counts.values()].filter(Boolean).length;els.sourceStats.innerHTML=[[state.sourceLibrary.length,'sources imported'],[used,'used in story'],[state.sourceLibrary.length-used,'unassigned'],[state.sourceLibrary.filter(s=>!s.dateISO).length,'dates to verify']].map(([v,l])=>`<div class="source-stat"><strong>${v}</strong><span>${l}</span></div>`).join('');els.sourceLibrary.innerHTML=sources.length?sources.map(source=>`<article class="source-card-lab"><div class="source-card-top"><span>${escapeHtml(source.domain)} · ${escapeHtml(shortSourceDate(source))}</span><b>${escapeHtml(TYPE_LABELS[source.type])}</b></div><h3>${escapeHtml(source.title)}</h3><p>${escapeHtml(source.tags.map(t=>'#'+t).join(' ')||source.url)}</p><div class="source-ref-bar"><span><strong>${counts.get(source.id)||0}</strong> story references · relevance ${source.relevance||0}/5</span><div><button type="button" data-use-source="${source.id}">Use in event</button><button type="button" data-read-source="${source.id}">Reading Room ↗</button><a href="${escapeAttribute(source.url)}" target="_blank" rel="noopener noreferrer">Original ↗</a></div></div></article>`).join(''):`<div class="empty-view"><svg><use href="#b-source"></use></svg><h2>${state.sourceLibrary.length?'No sources match this filter.':'No Source Desk case connected yet.'}</h2><p>Sync the open Source Desk, load its browser save, or import a .sourcedesk.json / case.js file.</p><button class="lab-button button-dark" type="button" data-lab-action="import">Import sources</button></div>`;}

  function renderNotes(){const notes=state.notes.filter(n=>matchesSearch(n.title,n.body,n.type,n.tags.join(' '))).sort((a,b)=>Number(b.pinned)-Number(a.pinned)||b.updatedAt.localeCompare(a.updatedAt));els.notesGrid.innerHTML=notes.length?notes.map((note,index)=>`<article class="note-card" style="--note-rotation:${(index%5-2)*.35}deg"><button type="button" data-edit="note" data-id="${note.id}" aria-label="Edit ${escapeAttribute(note.title)}"></button><span>${note.pinned?'PINNED · ':''}${escapeHtml(note.type.toUpperCase())}</span><h3>${escapeHtml(note.title)}</h3><p>${escapeHtml(note.body||'Empty note')}</p><small>${note.sourceIds.length} sources · ${formatActivityTime(note.updatedAt)}</small></article>`).join(''):`<div class="empty-view"><svg><use href="#b-note"></use></svg><h2>No notebook entries yet.</h2><p>Use quick notes for ideas that are too early to become formal events or claims.</p><button class="lab-button button-dark" type="button" data-new="note">Add note</button></div>`;}
  function saveQuickNote(){const body=els.quickNote.value.trim();if(!body)return;pushHistory();state.notes.push(cleanNote({title:body.split(/\n/)[0].slice(0,80),body,type:'observation',createdAt:new Date().toISOString(),updatedAt:new Date().toISOString()}));els.quickNote.value='';activity('Captured a quick research note.');scheduleSave(true);renderNotes();renderNavCounts();toast('Quick note kept.');}

  function openEditor(type,id,recoverDraft=false) {
    if(!['event','actor','claim','thread','chapter','note','link'].includes(type))return;
    const existing=id?entityByKind(type,id):null;
    const item=existing||newEntity(type);
    activeEditor={type,id:item.id,isNew:!existing,item};
    els.drawerEyebrow.textContent=(existing?'EDIT ':'ADD ')+type.toUpperCase();
    els.drawerTitle.textContent=existing?entityTitle(item):'New '+({actor:'person / entity',thread:'timeline thread',link:'connection'}[type]||type);
    els.deleteEntityButton.hidden=!existing;
    els.drawerBody.innerHTML=formHtml(type,item);
    els.entityDrawer.classList.add('open');els.entityDrawer.setAttribute('aria-hidden','false');document.body.style.overflow='hidden';
    if(recoverDraft&&state.ui.draft?.type===type&&state.ui.draft?.id===id)applyDraft(state.ui.draft.values);
    setTimeout(()=>$('input,textarea,select',els.drawerBody)?.focus(),50);
  }
  function newEntity(type){const thread=orderedThreads()[0];if(type==='event')return cleanEvent({id:uid('event'),threadId:thread?.id||'',sourceIds:state.ui.seedSourceIds||[]});if(type==='actor')return cleanActor({id:uid('actor'),color:COLORS[state.actors.length%COLORS.length]});if(type==='claim')return cleanClaim({id:uid('claim'),sourceIds:state.ui.seedSourceIds||[]});if(type==='thread')return {id:uid('thread'),name:'',color:COLORS[state.threads.length%COLORS.length],description:'',order:state.threads.length};if(type==='chapter')return cleanChapter({id:uid('chapter'),order:state.chapters.length});if(type==='note')return cleanNote({id:uid('note')});if(type==='link')return cleanLink({id:uid('link'),from:boardEntityOptions()[0]?.value||'',to:boardEntityOptions()[1]?.value||'',type:'related',label:''})||{id:uid('link'),from:'',to:'',type:'related',label:''};}

  function formHtml(type,item) {
    const text=(name,label,value='',span=true,extra='')=>`<label class="drawer-field ${span?'drawer-span-2':''}"><span>${label}</span><input name="${name}" value="${escapeAttribute(value)}" ${extra}></label>`;
    const area=(name,label,value='',rows=4)=>`<label class="drawer-field drawer-span-2"><span>${label}</span><textarea name="${name}" rows="${rows}">${escapeHtml(value)}</textarea></label>`;
    const select=(name,label,value,options,span=false)=>`<label class="drawer-field ${span?'drawer-span-2':''}"><span>${label}</span><select name="${name}">${options.map(([v,l])=>`<option value="${escapeAttribute(v)}" ${v===value?'selected':''}>${escapeHtml(l)}</option>`).join('')}</select></label>`;
    const check=(name,label,checked)=>`<label class="drawer-check drawer-span-2"><input name="${name}" type="checkbox" ${checked?'checked':''}><span>${label}</span></label>`;
    const picker=(name,label,items,selected,titleFn,metaFn)=>`<div class="drawer-field drawer-span-2"><span>${label}</span><input class="picker-search" data-picker-search="${name}" type="search" placeholder="Filter ${label.toLowerCase()}…"><div class="picker-list" data-picker-list="${name}">${items.map(entry=>`<label class="picker-option" data-picker-text="${escapeAttribute((titleFn(entry)+' '+metaFn(entry)).toLowerCase())}"><input type="checkbox" name="${name}" value="${escapeAttribute(entry.id)}" ${selected.includes(entry.id)?'checked':''}><strong>${escapeHtml(titleFn(entry))}</strong><span>${escapeHtml(metaFn(entry))}</span></label>`).join('')||'<div class="empty-mini">None available yet.</div>'}</div></div>`;
    const sourcePicker=picker('sourceIds','Sources',state.sourceLibrary,item.sourceIds||[],s=>s.title,s=>`${s.domain} · ${shortSourceDate(s)}`);
    const actorPicker=picker('actorIds','People / entities',state.actors,item.actorIds||[],a=>a.name,a=>a.role||a.kind);
    const eventPicker=picker('eventIds','Events',state.events,item.eventIds||[],e=>e.title,e=>shortDate(e));
    const claimPicker=picker('claimIds','Claims',state.claims,item.claimIds||[],c=>c.statement,c=>CLAIM_STATUS[c.status]);
    if(type==='event')return `<div class="drawer-grid">${text('title','Event title',item.title)}${text('dateInput','Start date',item.dateInput,false,'class="masked-date" inputmode="numeric" placeholder="DD/MM/YYYY"')}${text('endDateInput','End date / range',item.endDateInput,false,'class="masked-date" inputmode="numeric" placeholder="DD/MM/YYYY"')}${select('precision','Date confidence',item.precision,[['exact','Exact'],['approximate','Approximate'],['month','Month only'],['year','Year only'],['unknown','Unknown / verify']])}${select('confidence','Event confidence',item.confidence,[['confirmed','Confirmed'],['probable','Probable'],['reported','Reported'],['disputed','Disputed'],['unknown','Unknown']])}${select('importance','Narrative importance',String(item.importance),[['1','1 · Minor context'],['2','2'],['3','3 · Useful'],['4','4'],['5','5 · Pivotal']])}${select('threadId','Timeline thread',item.threadId,orderedThreads().map(t=>[t.id,t.name]))}${text('branch','Version / branch',item.branch,false,'placeholder="Main, official account, witness version…"')}${text('location','Location',item.location,false)}${area('summary','One-sentence event summary',item.summary,3)}${area('details','Detailed event record',item.details,7)}${actorPicker}${sourcePicker}${check('onBoard','Pin this event to the evidence board',item.onBoard)}</div>`;
    if(type==='actor')return `<div class="drawer-grid">${text('name','Name',item.name)}${select('kind','Entity type',item.kind,[['person','Person'],['organization','Organization'],['place','Place'],['other','Other']])}${text('role','Role in the story',item.role,false)}${text('aliases','Aliases / alternate spellings',item.aliases,false)}${area('summary','Profile, motives, stakes, and uncertainties',item.summary,7)}${text('tags','Tags',item.tags.join(', '))}<div class="drawer-field drawer-span-2"><span>Color code</span><div class="color-options">${COLORS.map(c=>`<label><input type="radio" name="color" value="${c}" ${item.color===c?'checked':''}><span style="--swatch:${c}"></span></label>`).join('')}</div></div>${sourcePicker}${check('onBoard','Pin this entity to the evidence board',item.onBoard)}</div>`;
    if(type==='claim')return `<div class="drawer-grid">${area('statement','Atomic claim / assertion',item.statement,4)}${text('topic','Conflict topic',item.topic,true,'placeholder="Use the same topic for competing versions"')}${select('status','Evidence state',item.status,Object.entries(CLAIM_STATUS))}${text('confidence','Confidence %',String(item.confidence),false,'type="number" min="0" max="100"')}${area('notes','Assessment, weaknesses, and verification work',item.notes,5)}${actorPicker}${eventPicker}${sourcePicker}${check('onBoard','Pin this claim to the evidence board',item.onBoard)}</div>`;
    if(type==='thread')return `<div class="drawer-grid">${text('name','Thread name',item.name)}${area('description','What this timeline tracks',item.description,5)}<div class="drawer-field drawer-span-2"><span>Thread color</span><div class="color-options">${COLORS.map(c=>`<label><input type="radio" name="color" value="${c}" ${item.color===c?'checked':''}><span style="--swatch:${c}"></span></label>`).join('')}</div></div></div>`;
    if(type==='chapter')return `<div class="drawer-grid">${text('title','Chapter / sequence title',item.title)}${select('status','Stage',item.status,[['idea','Idea'],['researching','Researching'],['ready','Evidence ready'],['drafted','Drafted']])}${area('summary','Narrative purpose, reveal, and transition',item.summary,6)}${eventPicker}${claimPicker}${sourcePicker}</div>`;
    if(type==='note')return `<div class="drawer-grid">${text('title','Note title',item.title)}${select('type','Note type',item.type,[['lead','Lead'],['question','Question'],['observation','Observation'],['reminder','Reminder']])}${area('body','Working note',item.body,10)}${text('tags','Tags',item.tags.join(', '))}${sourcePicker}${check('pinned','Pin this note near the top',item.pinned)}${check('onBoard','Pin this note to the evidence board',item.onBoard)}</div>`;
    const options=boardEntityOptions();return `<div class="drawer-grid">${select('from','From node',item.from,options.map(o=>[o.value,o.label]),true)}${select('to','To node',item.to,options.map(o=>[o.value,o.label]),true)}${select('type','Connection type',item.type,Object.entries(LINK_LABELS))}${text('label','Custom label',item.label,false,'placeholder="Optional"')}<div class="drawer-span-2"><p class="empty-mini">Only entities pinned to the evidence board can be connected.</p></div></div>`;
  }

  function captureDraft(){if(!activeEditor)return;state.ui.draft={type:activeEditor.type,id:activeEditor.id,values:serializeForm(els.entityForm),updatedAt:new Date().toISOString()};scheduleSave();}
  function serializeForm(form){const values={};new FormData(form).forEach((value,key)=>{if(values[key]!==undefined)values[key]=[].concat(values[key],value);else values[key]=value;});$$('input[type=checkbox]',form).forEach(input=>{if(!input.name)return;if(['sourceIds','actorIds','eventIds','claimIds'].includes(input.name)){if(values[input.name]===undefined)values[input.name]=[];}else values[input.name]=input.checked;});return values;}
  function applyDraft(values){Object.entries(values||{}).forEach(([name,value])=>{const fields=$$(`[name="${CSS.escape(name)}"]`,els.entityForm);if(!fields.length)return;if(fields[0].type==='checkbox'){if(Array.isArray(value))fields.forEach(field=>field.checked=value.includes(field.value));else fields[0].checked=Boolean(value);}else if(fields[0].type==='radio'){fields.forEach(field=>field.checked=field.value===value);}else fields[0].value=Array.isArray(value)?value[0]:value;});}
  function saveEditor(event){event.preventDefault();if(!activeEditor)return;const values=serializeForm(els.entityForm);const {type,item,isNew}=activeEditor;pushHistory();const list=collectionFor(type);if(type==='event'){Object.assign(item,{title:String(values.title||'Untitled event').trim(),dateInput:String(values.dateInput||''),dateISO:parseDmy(values.dateInput),endDateInput:String(values.endDateInput||''),endDateISO:parseDmy(values.endDateInput),precision:values.precision,confidence:values.confidence,importance:Number(values.importance)||3,threadId:values.threadId||orderedThreads()[0]?.id||'',branch:String(values.branch||'Main version').trim(),location:String(values.location||'').trim(),summary:String(values.summary||'').trim(),details:String(values.details||'').trim(),actorIds:arrayValue(values.actorIds),sourceIds:arrayValue(values.sourceIds),onBoard:Boolean(values.onBoard)});}
    if(type==='actor')Object.assign(item,{name:String(values.name||'Unnamed person').trim(),kind:values.kind,role:String(values.role||'').trim(),aliases:String(values.aliases||'').trim(),summary:String(values.summary||'').trim(),tags:parseTags(values.tags||''),sourceIds:arrayValue(values.sourceIds),color:values.color||item.color,onBoard:Boolean(values.onBoard)});
    if(type==='claim')Object.assign(item,{statement:String(values.statement||'Untitled claim').trim(),topic:String(values.topic||'').trim(),status:values.status,confidence:Math.max(0,Math.min(100,Number(values.confidence)||0)),notes:String(values.notes||'').trim(),actorIds:arrayValue(values.actorIds),eventIds:arrayValue(values.eventIds),sourceIds:arrayValue(values.sourceIds),onBoard:Boolean(values.onBoard)});
    if(type==='thread')Object.assign(item,{name:String(values.name||'Timeline thread').trim(),description:String(values.description||'').trim(),color:values.color||item.color});
    if(type==='chapter')Object.assign(item,{title:String(values.title||'Untitled chapter').trim(),status:values.status,summary:String(values.summary||'').trim(),eventIds:arrayValue(values.eventIds),claimIds:arrayValue(values.claimIds),sourceIds:arrayValue(values.sourceIds)});
    if(type==='note')Object.assign(item,{title:String(values.title||'Untitled note').trim(),type:values.type,body:String(values.body||'').trim(),tags:parseTags(values.tags||''),sourceIds:arrayValue(values.sourceIds),pinned:Boolean(values.pinned),onBoard:Boolean(values.onBoard)});
    if(type==='link')Object.assign(item,{from:values.from||'',to:values.to||'',type:values.type||'related',label:String(values.label||'').trim()});
    item.updatedAt=new Date().toISOString();if(isNew){item.createdAt=item.updatedAt;list.push(item);}state.ui.seedSourceIds=[];state.ui.draft=null;activity(`${isNew?'Added':'Updated'} ${type} “${entityTitle(item)}”.`);scheduleSave(true);closeDrawer(false);renderAll();toast(`${capitalize(type)} saved.`);}
  function closeDrawer(clearDraft=true){els.entityDrawer.classList.remove('open');els.entityDrawer.setAttribute('aria-hidden','true');document.body.style.overflow='';if(clearDraft&&state?.ui?.draft){state.ui.draft=null;scheduleSave();}activeEditor=null;}
  function deleteActiveEntity(){if(!activeEditor||activeEditor.isNew)return;const {type,id,item}=activeEditor;if(!confirm(`Delete this ${type}: “${entityTitle(item)}”? Exported backups remain unchanged.`))return;pushHistory();const list=collectionFor(type);const index=list.findIndex(x=>x.id===id);if(index>=0)list.splice(index,1);state.links=state.links.filter(link=>link.from!==type+':'+id&&link.to!==type+':'+id);if(type==='actor'){state.events.forEach(e=>e.actorIds=e.actorIds.filter(x=>x!==id));state.claims.forEach(c=>c.actorIds=c.actorIds.filter(x=>x!==id));}if(type==='event'){state.claims.forEach(c=>c.eventIds=c.eventIds.filter(x=>x!==id));state.chapters.forEach(c=>c.eventIds=c.eventIds.filter(x=>x!==id));}if(type==='claim')state.chapters.forEach(c=>c.claimIds=c.claimIds.filter(x=>x!==id));if(type==='thread')state.events.forEach(e=>{if(e.threadId===id)e.threadId=state.threads.find(t=>t.id!==id)?.id||'';});state.ui.draft=null;activity(`Deleted ${type} “${entityTitle(item)}”.`);scheduleSave(true);closeDrawer(false);renderAll();toast(`${capitalize(type)} deleted.`,'warning');}

  function filterPicker(input){const list=$(`[data-picker-list="${CSS.escape(input.dataset.pickerSearch)}"]`,els.drawerBody);const q=input.value.trim().toLowerCase();$$('.picker-option',list).forEach(option=>option.hidden=q&&!option.dataset.pickerText.includes(q));}
  function maskDate(input){const digits=input.value.replace(/\D/g,'').slice(0,8);input.value=digits.length<=2?digits:digits.length<=4?digits.slice(0,2)+'/'+digits.slice(2):digits.slice(0,2)+'/'+digits.slice(2,4)+'/'+digits.slice(4);}

  function handleMoreMenu(event){const action=event.target.closest('[data-lab-action]')?.dataset.labAction;if(!action)return;els.labMoreMenu.removeAttribute('open');if(action==='import')els.labImportInput.click();if(action==='markdown')exportMarkdown();if(action==='recovery')openRecoveryDialog();if(action==='project')openProjectDialog();}
  function openProjectDialog(){els.briefTitle.value=state.project.title;els.briefQuestion.value=state.project.question||'';els.briefTheory.value=state.project.theory||'';els.briefObjective.value=state.project.objective||'';els.projectDialog.showModal();}
  function saveProjectBrief(event){event.preventDefault();pushHistory();state.project.title=els.briefTitle.value.trim()||'Untitled story investigation';state.project.question=els.briefQuestion.value.trim();state.project.theory=els.briefTheory.value.trim();state.project.objective=els.briefObjective.value.trim();els.labProjectTitle.value=state.project.title;activity('Updated the case north star.');scheduleSave(true);els.projectDialog.close();renderOverview();}

  function scheduleSave(immediate=false){if(!state)return;els.saveStatus.className='save-status saving';els.saveStatus.innerHTML='<i></i>Saving…';clearTimeout(saveTimer);if(immediate)saveNow();else saveTimer=setTimeout(saveNow,120);}
  function saveNow(skipCheckpoint=false){if(!state)return;clearTimeout(saveTimer);state.project.updatedAt=new Date().toISOString();try{const serialized=JSON.stringify(state);localStorage.setItem(STORAGE_KEY,serialized);els.saveStatus.className='save-status';els.saveStatus.innerHTML='<i></i>Saved locally';updateStorageHealth(serialized.length);if(!skipCheckpoint&&Date.now()-lastCheckpointAt>15000){lastCheckpointAt=Date.now();createCheckpoint('autosave',false);}}catch(error){els.saveStatus.className='save-status error';els.saveStatus.innerHTML='<i></i>Save failed';toast('LocalStorage is full. Export now; recovery checkpoints may still be available.','error',8000);}}
  function updateStorageHealth(bytes){const length=bytes??JSON.stringify(state||{}).length;els.storageLabel.textContent=`Autosaved · ${formatBytes(length*2)} estimated`;const ratio=Math.min(1,(length*2)/(4.5*1024*1024));els.healthBar.style.width=(100-ratio*60)+'%';els.safetyLabel.textContent=ratio>.8?'Export recommended':ratio>.55?'Growing':'Protected';}
  function activity(text){state.activity.push({id:uid('activity'),at:new Date().toISOString(),text});state.activity=state.activity.slice(-80);}
  function pushHistory(){history.push(JSON.stringify(state));if(history.length>30)history.shift();future=[];}
  function undo(){if(!history.length)return;future.push(JSON.stringify(state));state=sanitizeState(JSON.parse(history.pop()));els.labProjectTitle.value=state.project.title;scheduleSave(true);renderAll();toast('Undid last structural change.');}
  function redo(){if(!future.length)return;history.push(JSON.stringify(state));state=sanitizeState(JSON.parse(future.pop()));els.labProjectTitle.value=state.project.title;scheduleSave(true);renderAll();toast('Redid change.');}

  function openRecoveryDb(){if(recoveryDbPromise)return recoveryDbPromise;recoveryDbPromise=new Promise((resolve,reject)=>{const request=indexedDB.open(RECOVERY_DB,1);request.onupgradeneeded=()=>{if(!request.result.objectStoreNames.contains(RECOVERY_STORE))request.result.createObjectStore(RECOVERY_STORE,{keyPath:'id'});};request.onsuccess=()=>resolve(request.result);request.onerror=()=>reject(request.error);});return recoveryDbPromise;}
  async function createCheckpoint(reason='manual',announce=true){try{saveNow(true);const db=await openRecoveryDb();const record={id:uid('snapshot'),at:new Date().toISOString(),reason,projectTitle:state.project.title,counts:{events:state.events.length,actors:state.actors.length,claims:state.claims.length},payload:JSON.parse(JSON.stringify(state))};await idbPut(db,record);lastCheckpointAt=Date.now();const all=await idbAll(db);for(const old of all.sort((a,b)=>b.at.localeCompare(a.at)).slice(20))await idbDelete(db,old.id);if(announce)toast('Recovery checkpoint created.');}catch{if(announce)toast('Could not create an IndexedDB checkpoint. LocalStorage autosave is still active.','warning');}}
  async function openRecoveryDialog(){try{const db=await openRecoveryDb();const all=(await idbAll(db)).sort((a,b)=>b.at.localeCompare(a.at));els.recoveryList.innerHTML=all.length?all.map(item=>`<div class="recovery-item"><div><strong>${escapeHtml(item.reason==='manual'?'Manual checkpoint':'Automatic checkpoint')}</strong><span>${new Date(item.at).toLocaleString()} · ${item.counts.events} events · ${item.counts.actors} actors · ${item.counts.claims} claims</span></div><button type="button" data-restore="${item.id}">Restore</button></div>`).join(''):'<div class="empty-mini">No checkpoints yet. LocalStorage autosave is still active.</div>';els.recoveryDialog.showModal();}catch{toast('Recovery storage is unavailable in this browser.','warning');}}
  async function restoreCheckpoint(id){if(!confirm('Restore this checkpoint? Export the current lab first if you may need it.'))return;const db=await openRecoveryDb();const record=await idbGet(db,id);if(!record?.payload)return;pushHistory();state=sanitizeState(record.payload);els.labProjectTitle.value=state.project.title;els.recoveryDialog.close();scheduleSave(true);renderAll();toast('Recovery checkpoint restored.');}
  function idbPut(db,value){return new Promise((resolve,reject)=>{const req=db.transaction(RECOVERY_STORE,'readwrite').objectStore(RECOVERY_STORE).put(value);req.onsuccess=()=>resolve();req.onerror=()=>reject(req.error);});}
  function idbAll(db){return new Promise((resolve,reject)=>{const req=db.transaction(RECOVERY_STORE,'readonly').objectStore(RECOVERY_STORE).getAll();req.onsuccess=()=>resolve(req.result||[]);req.onerror=()=>reject(req.error);});}
  function idbGet(db,id){return new Promise((resolve,reject)=>{const req=db.transaction(RECOVERY_STORE,'readonly').objectStore(RECOVERY_STORE).get(id);req.onsuccess=()=>resolve(req.result);req.onerror=()=>reject(req.error);});}
  function idbDelete(db,id){return new Promise((resolve,reject)=>{const req=db.transaction(RECOVERY_STORE,'readwrite').objectStore(RECOVERY_STORE).delete(id);req.onsuccess=()=>resolve();req.onerror=()=>reject(req.error);});}

  function requestDeskSnapshot(){if(deskWindow&&!deskWindow.closed)deskWindow.postMessage({type:'SOURCE_DESK_STORY_REQUEST'},'*');}
  function handleDeskMessage(event){if(event.data?.type!=='SOURCE_DESK_STORY_CASE')return;if(deskWindow&&event.source!==deskWindow)return;importSourceCase(event.data.payload?.data||event.data.payload,'Live from Source Desk',true);}
  function syncSources(showFeedback){
    let deskPayload=null, readerPayload=null;
    try{deskPayload=JSON.parse(localStorage.getItem(SOURCE_DESK_KEY)||'null');}catch{}
    try{readerPayload=JSON.parse(localStorage.getItem(READER_CASE_KEY)||'null');}catch{}
    const fromReader=new URLSearchParams(location.search).has('from')||new URLSearchParams(location.search).has('source');
    if(fromReader&&readerPayload?.data?.sources){importSourceCase(readerPayload.data,'Reading Room browser save',showFeedback);return;}
    if(deskPayload?.sources){importSourceCase(deskPayload,'Source Desk browser save',showFeedback);return;}
    if(readerPayload?.data?.sources){importSourceCase(readerPayload.data,'Reading Room browser save',showFeedback);return;}
    if(window.SOURCE_DESK_CASE?.data?.sources){importSourceCase(window.SOURCE_DESK_CASE.data,'Bundled case.js',showFeedback);return;}
    if(deskWindow&&!deskWindow.closed){requestDeskSnapshot();if(showFeedback)toast('Requesting the live research case…');return;}
    if(showFeedback)toast('No Source Desk case is available here. Import a saved case file instead.','warning',6500);
  }
  function importSourceCase(caseData,origin,announce=true){if(!caseData?.sources)return;const compact=caseData.sources.map(cleanSource);const existing=new Map(state.sourceLibrary.map(source=>[source.id,source]));compact.forEach(source=>existing.set(source.id,{...(existing.get(source.id)||{}),...source}));state.sourceLibrary=[...existing.values()];state.project.sourceProjectId=caseData.project?.id||state.project.sourceProjectId;if(!state.project.question&&caseData.project?.question)state.project.question=caseData.project.question;if(state.project.title==='Untitled story investigation'&&caseData.project?.title)state.project.title=caseData.project.title+' — Story Lab';els.labProjectTitle.value=state.project.title;localStorage.setItem('source-desk-reader-case-v1',JSON.stringify({app:'Source Desk',version:3,data:caseData}));activity(`Synchronized ${compact.length} sources from ${origin}.`);scheduleSave(true);renderAll();if(announce)toast(`${compact.length} sources synchronized from ${origin}.`);}
  async function importSelectedFile(){const file=els.labImportInput.files?.[0];els.labImportInput.value='';if(!file)return;try{const text=await file.text();let payload;if(/\.js$/i.test(file.name)||text.includes('window.SOURCE_DESK_CASE')){const match=text.match(/window\.SOURCE_DESK_CASE\s*=\s*([\s\S]*?);?\s*$/);if(!match)throw new Error('No Source Desk case object was found.');payload=JSON.parse(match[1].replace(/;\s*$/,''));}else payload=JSON.parse(text);if(payload.format==='story-lab'||payload.data?.labVersion||payload.labVersion){const incoming=sanitizeState(payload.data||payload);if(!confirm('Replace the current Story Lab with this file? Export the current lab first if needed.'))return;pushHistory();state=incoming;els.labProjectTitle.value=state.project.title;activity(`Imported Story Lab file ${file.name}.`);scheduleSave(true);renderAll();toast('Story Lab imported.');}else if(payload.data?.sources||payload.sources)importSourceCase(payload.data||payload, file.name, true);else throw new Error('This file contains neither a Story Lab nor a Source Desk case.');}catch(error){toast(error.message||'Could not import that file.','error',7000);}}
  function exportLab(){saveNow();const payload={app:'Source Desk Story Lab',format:'story-lab',version:1,exportedAt:new Date().toISOString(),data:state};download(`${slugify(state.project.title)}.storylab.json`,JSON.stringify(payload,null,2),'application/json');toast('Story Lab exported.');}
  function exportMarkdown(){let md=`# ${state.project.title}\n\n`;if(state.project.question)md+=`> ${state.project.question}\n\n`;if(state.project.theory)md+=`## Current theory\n\n${state.project.theory}\n\n`;md+=`## Chronology\n\n`;[...state.events].sort(sortEvents).forEach(event=>{md+=`### ${formatEventDate(event)} — ${event.title}\n\n`;md+=`- Thread: ${threadById(event.threadId)?.name||'Unassigned'}\n- Version: ${event.branch}\n- Confidence: ${event.confidence}\n`;if(event.location)md+=`- Location: ${event.location}\n`;if(event.summary)md+=`\n${event.summary}\n`;if(event.details)md+=`\n${event.details}\n`;if(event.sourceIds.length)md+=`\nSources: ${event.sourceIds.map(sourceCitation).join('; ')}\n`;md+='\n';});md+='## Claims and contradictions\n\n';state.claims.forEach(claim=>{md+=`### ${claim.topic||'Claim'} — ${CLAIM_STATUS[claim.status]}\n\n${claim.statement}\n\nConfidence: ${claim.confidence}%\n\n`;if(claim.notes)md+=claim.notes+'\n\n';if(claim.sourceIds.length)md+=`Sources: ${claim.sourceIds.map(sourceCitation).join('; ')}\n\n`;});md+='## Story outline\n\n';[...state.chapters].sort((a,b)=>a.order-b.order).forEach((chapter,index)=>{md+=`### ${index+1}. ${chapter.title}\n\n${chapter.summary||''}\n\n`;});download(`${slugify(state.project.title)}-narrative-brief.md`,md,'text/markdown');toast('Narrative brief exported.');}

  function collectionFor(type){return ({event:state.events,actor:state.actors,claim:state.claims,thread:state.threads,chapter:state.chapters,note:state.notes,link:state.links})[type];}
  function entityByKind(kind,id){return collectionFor(kind)?.find(item=>item.id===id)||null;}
  function entityTitle(item){return item?.title||item?.name||item?.statement||item?.label||'Connection';}
  function boardEntityOptions(){return boardEntities().map(({kind,item})=>({value:kind+':'+item.id,label:capitalize(kind)+' · '+entityTitle(item)}));}
  function eventById(id){return state.events.find(item=>item.id===id);}function actorById(id){return state.actors.find(item=>item.id===id);}function claimById(id){return state.claims.find(item=>item.id===id);}function sourceById(id){return state.sourceLibrary.find(item=>item.id===id);}function threadById(id){return state.threads.find(item=>item.id===id);}function orderedThreads(){return [...state.threads].sort((a,b)=>a.order-b.order);}
  function actorWeight(id){return state.events.filter(e=>e.actorIds.includes(id)).length+state.claims.filter(c=>c.actorIds.includes(id)).length+state.links.filter(l=>l.from==='actor:'+id||l.to==='actor:'+id).length;}
  function arrayValue(value){return value===undefined?[]:Array.isArray(value)?value.map(String):[String(value)];}
  function parseTags(value){return [...new Set(String(value||'').split(',').map(tag=>tag.trim().replace(/^#/,'').toLowerCase()).filter(Boolean))].slice(0,30);}
  function parseDmy(value){const match=String(value||'').trim().match(/^(0?[1-9]|[12]\d|3[01])\/(0?[1-9]|1[0-2])\/((?:19|20)\d{2})$/);if(!match)return null;const d=Number(match[1]),m=Number(match[2]),y=Number(match[3]),date=new Date(Date.UTC(y,m-1,d));return date.getUTCFullYear()===y&&date.getUTCMonth()===m-1&&date.getUTCDate()===d?`${match[3]}-${String(m).padStart(2,'0')}-${String(d).padStart(2,'0')}`:null;}
  function formatDmy(iso){if(!iso)return'';const [y,m,d]=iso.slice(0,10).split('-');return`${d}/${m}/${y}`;}
  function dateNumber(iso){return Date.parse(iso+'T00:00:00Z');}
  function shortDate(event){if(!event.dateISO)return'DATE TBC';const [y,m,d]=event.dateISO.split('-');return`${d}/${m}/${y}`;}
  function shortSourceDate(source){return source.dateInput||source.dateISO?.slice(0,10)||'Date TBC';}
  function formatEventDate(event){return event.dateInput||event.dateISO||'Date to verify';}
  function formatTick(ms,spanDays){const date=new Date(ms);return spanDays>730?String(date.getUTCFullYear()):spanDays>90?date.toLocaleDateString(undefined,{month:'short',year:'numeric',timeZone:'UTC'}):date.toLocaleDateString(undefined,{day:'2-digit',month:'short',year:'numeric',timeZone:'UTC'});}
  function sortEvents(a,b){if(!a.dateISO&&!b.dateISO)return a.createdAt.localeCompare(b.createdAt);if(!a.dateISO)return 1;if(!b.dateISO)return-1;return a.dateISO.localeCompare(b.dateISO);}
  function formatActivityTime(value){const date=new Date(value);const now=new Date();if(date.toDateString()===now.toDateString())return date.toLocaleTimeString([],{hour:'2-digit',minute:'2-digit'});return date.toLocaleDateString([],{month:'short',day:'numeric'});}
  function sourceCitation(id){const source=sourceById(id);return source?`${source.title} (${source.domain})`:'Missing source '+id;}
  function domainFromUrl(value){try{return new URL(value).hostname.replace(/^www\./,'');}catch{return'source';}}
  function openReaderSource(id){const url=new URL('./reader.html',location.href);url.searchParams.set('source',id);window.open(url.href,'sourceDeskReadingRoom');}
  function formatBytes(bytes){if(!bytes)return'0 B';const units=['B','KB','MB','GB'],index=Math.min(Math.floor(Math.log(bytes)/Math.log(1024)),units.length-1);return`${(bytes/1024**index).toFixed(index?1:0)} ${units[index]}`;}
  function download(filename,contents,type){const url=URL.createObjectURL(new Blob([contents],{type}));const link=document.createElement('a');link.href=url;link.download=filename;document.body.appendChild(link);link.click();link.remove();setTimeout(()=>URL.revokeObjectURL(url),1000);}
  function slugify(value){return String(value||'story-lab').toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'').slice(0,70)||'story-lab';}
  function capitalize(value){return String(value).charAt(0).toUpperCase()+String(value).slice(1);}
  function escapeHtml(value){return String(value??'').replace(/[&<>"]/g,char=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[char]));}
  function escapeAttribute(value){return escapeHtml(value).replace(/'/g,'&#39;');}
  function toast(message,type='',duration=3800){const item=document.createElement('div');item.className='lab-toast '+type;item.textContent=message;els.labToast.appendChild(item);setTimeout(()=>item.remove(),duration);}

  init();
})();



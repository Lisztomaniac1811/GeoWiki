const STAGE_WIDTH = 1500;
const STAGE_HEIGHT = 800;
const PHASE_ONE_FALLBACK_TEXT = {
  landingWelcome: "Welcome to the",
  landingIntro: "Welcome to the Bates Motel!<br/>We've renovated. Feel free to have a look around.",
  enterSite: "ENTER THE BATES MOTEL",
  visitShowPage: "VISIT AETV.COM",
  urlAbout: "http://www.aetv.com/bates-motel",
  urlAE: "http://www.aetv.com/",
  aboutButton: "About the show",
  tuneIn: "NEW SEASON MARCH 2015",
  btnSkip: "SKIP",
};

const PRELOADER_MANIFEST = [
  ["preLogoOn", "SWFs decompiled/preloader/images/3_BatesMotelSeason2Preloader_logoOn_BatesMotelSeason2Preloader_logoOn.jpg"],
  ["preLogoOff", "SWFs decompiled/preloader/images/4_BatesMotelSeason2Preloader_logoOff_BatesMotelSeason2Preloader_logoOff.jpg"],
  ["preDivider", "SWFs decompiled/preloader/images/1_BatesMotelSeason2Preloader_divider_BatesMotelSeason2Preloader_divider.png"],
];

const LANDING_MANIFEST = [
  ["landing_bg", "assets/bitmaps/landing_bg.jpg"],
  ["landing_no", "assets/bitmaps/landing_no.png"],
  ["fog", "assets/bitmaps/fog.png"],
  ["logo_main", "assets/bitmaps/logo_main_new.png"],
  ["logo_glow", "assets/bitmaps/logo_main_new.png"],
  ["logo_light", "assets/bitmaps/logo_main_new.png"],
  ["logo_divider", "assets/bitmaps/logo_divider.png"],
  ["btn_enter_up", "assets/bitmaps/btn_enter_up.png"],
  ["btn_enter_over", "assets/bitmaps/btn_enter_over.png"],
];

const NAV_MAP_PATH = [{"x":25,"y":17,"r":-135,"tR":3.37,"tL":2.04,"s":0},{"x":21,"y":14,"r":-45,"tR":2.75,"tL":3},{"x":13,"y":25,"r":30,"tR":9.8,"tL":16},{"x":57,"y":56,"r":45,"tR":11.43,"tL":11.42,"s":1},{"x":66,"y":111,"r":45,"tR":11.68,"tL":12.42},{"x":96,"y":151,"r":80,"tR":5,"tL":1},{"x":146,"y":151,"r":90,"tR":0.43,"tL":0.85},{"x":153,"y":136,"r":90,"tR":1.17,"tL":1.79,"s":2},{"x":165,"y":128,"r":0,"tR":2,"tL":1.5,"s":3},{"x":183,"y":128,"r":0,"tR":4.29,"tL":4.04,"s":4},{"x":220,"y":128,"r":0,"tR":1.25,"tL":0.92,"s":5},{"x":238,"y":128,"r":0,"tR":3.58,"tL":3.75,"s":6},{"x":275,"y":128,"r":0,"tR":1.04,"tL":1.21,"s":7},{"x":293,"y":128,"r":0,"tR":3.67,"tL":3.96,"s":8},{"x":330,"y":128,"r":0,"tR":1.13,"tL":0.79,"s":9},{"x":348,"y":128,"r":0,"tR":4.5,"tL":2.13,"s":10},{"x":384,"y":128,"r":0,"tR":0.73,"tL":0.58,"s":11},{"x":402,"y":120,"r":-45,"tR":0.73,"tL":0.58},{"x":412,"y":100,"r":-90,"tR":2.5,"tL":1.92,"s":12},{"x":412,"y":127,"r":-90,"tR":1.72,"tL":2.46,"s":13},{"x":412,"y":154,"r":-90,"tR":0,"tL":0,"s":14}];

const NAV_MAP_ENTER = [[{"x":25,"y":17,"t":3},{"x":30,"y":23,"t":4.8},{"x":35,"y":24,"t":3}],[{"x":146,"y":151,"t":0.5},{"x":96,"y":151,"t":0.5},{"x":66,"y":111,"t":0.5},{"x":57,"y":56,"t":0.5}],[{"x":153,"y":136,"t":2},{"x":140,"y":136,"t":2},{"x":127,"y":125,"t":2}],[{"x":165,"y":128,"t":1},{"x":165,"y":113,"t":1.5},{"x":160,"y":103,"t":2}],[{"x":183,"y":128,"t":1},{"x":183,"y":113,"t":1.5},{"x":188,"y":103,"t":2}],[{"x":220,"y":128,"t":1},{"x":220,"y":113,"t":1.5},{"x":216,"y":103,"t":2}],[{"x":238,"y":128,"t":1},{"x":238,"y":113,"t":1.5},{"x":243,"y":103,"t":2}],[{"x":275,"y":128,"t":1},{"x":275,"y":113,"t":1.5},{"x":270,"y":103,"t":2}],[{"x":293,"y":128,"t":1},{"x":293,"y":113,"t":1.5},{"x":298,"y":103,"t":2}],[{"x":330,"y":128,"t":1},{"x":330,"y":113,"t":1.5},{"x":325,"y":103,"t":2}],[{"x":348,"y":128,"t":1},{"x":348,"y":113,"t":1.5},{"x":353,"y":103,"t":2}],[{"x":384,"y":128,"t":1},{"x":384,"y":113,"t":1.5},{"x":380,"y":103,"t":2}],[{"x":412,"y":100,"t":1},{"x":429,"y":100,"t":1.5},{"x":438,"y":104,"t":2}],[{"x":412,"y":127,"t":1},{"x":429,"y":127,"t":1.5},{"x":438,"y":130,"t":2}],[{"x":412,"y":154,"t":1},{"x":429,"y":154,"t":1.5},{"x":438,"y":159,"t":2}]];

const app = document.getElementById("app");
const backgroundStage = document.getElementById("background-stage");
const overlayStage = document.getElementById("overlay-stage");
const screenRoot = document.getElementById("screen-root");

const state = {
  texts: new Map(),
  assets: new Map(),
  hasStartedMain: false,
  rooms: [],
  initialRoomId: 3,
  currentRoomId: 3,
  currentStep: 8,
  currentEnterStep: 0,
  isInRoom: false,
  outsideAmbientPath: "assets/sounds/exterior.mp3",
  isHelpActive: false,
};

let preloaderScreen;
let preloaderView;
let preloaderCounter;
let preloaderLogoOn;
let preloaderPercent = 0;
let flickerTimer = null;
let activeLandingFlickers = [];
let fogAnimations = [];
let outsideScreenState = null;

init().catch((error) => {
  console.error(error);
  screenRoot.innerHTML = `<div style="position:absolute;inset:0;display:grid;place-items:center;color:white;font-family:Arial,sans-serif;">Failed to load phase 1.</div>`;
});

async function init() {
  resizeStages();
  window.addEventListener("resize", resizeStages);
  renderPreloader();

  primeFallbackText();
  const xmlPromise = fetch("xml/batess2_config.xml")
    .then((response) => response.text())
    .catch(() => null);
  const fontPromise = Promise.all([
    document.fonts.load('24px "beon-medium"'),
    document.fonts.load('14px "helNeuLt-light"'),
    document.fonts.load('14px "helNeuLt-medium"'),
    document.fonts.load('15px "helNeuLt-bold"'),
  ]);

  const manifest = [...PRELOADER_MANIFEST, ...LANDING_MANIFEST];
  const total = manifest.length + 2;
  let loaded = 0;

  const stepLoaded = () => {
    loaded += 1;
    updatePreloaderCounter(Math.round((loaded / total) * 100));
  };

  const imagePromises = manifest.map(async ([key, src]) => {
    const image = await loadImage(src);
    state.assets.set(key, image);
    stepLoaded();
  });

  const xmlText = await xmlPromise.then((text) => {
    if (text) {
      parseConfig(text);
    }
    stepLoaded();
    return text;
  });

  await fontPromise.then(() => {
    stepLoaded();
  });

  await Promise.all(imagePromises);
  void xmlText;
  await delay(150);
  startPreloaderFade();
}

function resizeStages() {
  const width = window.innerWidth;
  const height = window.innerHeight;

  const isWide = width / height > 1.875;
  const bgScale = isWide ? width / STAGE_WIDTH : height / STAGE_HEIGHT;

  backgroundStage.style.transformOrigin = "top left";
  backgroundStage.style.transform = `scale(${bgScale})`;
  backgroundStage.style.width = `${STAGE_WIDTH}px`;
  backgroundStage.style.height = `${STAGE_HEIGHT}px`;
  backgroundStage.style.left = `${(width - STAGE_WIDTH * bgScale) / 2}px`;
  backgroundStage.style.top = `${(height - STAGE_HEIGHT * bgScale) / 2}px`;

  screenRoot.style.inset = "0";

  if (outsideScreenState) {
    applyOutsideLayout(outsideScreenState.stage);
  }
}

function renderPreloader() {
  preloaderScreen = createEl("div", "base-screen preloader-screen");
  preloaderView = createEl("div", "preloader-view");
  preloaderScreen.append(preloaderView);

  const logoOff = createEl("img", "preloader-logo-off");
  logoOff.src = "SWFs decompiled/preloader/images/4_BatesMotelSeason2Preloader_logoOff_BatesMotelSeason2Preloader_logoOff.jpg";
  preloaderView.append(logoOff);

  preloaderLogoOn = createEl("img", "preloader-logo-on");
  preloaderLogoOn.src = "SWFs decompiled/preloader/images/3_BatesMotelSeason2Preloader_logoOn_BatesMotelSeason2Preloader_logoOn.jpg";
  preloaderView.append(preloaderLogoOn);

  const divider = createEl("img", "preloader-divider");
  divider.src = "SWFs decompiled/preloader/images/1_BatesMotelSeason2Preloader_divider_BatesMotelSeason2Preloader_divider.png";
  preloaderView.append(divider);

  preloaderCounter = createEl("div", "preloader-counter", "0%");
  preloaderView.append(preloaderCounter);
  screenRoot.append(preloaderScreen);

  const layout = () => {
    const stageW = window.innerWidth;
    const stageH = window.innerHeight;
    const x = (stageW - 239) * 0.5;
    const y = stageH * 0.3;

    logoOff.style.left = `${x}px`;
    logoOff.style.top = `${y}px`;
    preloaderLogoOn.style.left = `${x}px`;
    preloaderLogoOn.style.top = `${y}px`;
    divider.style.left = `${(stageW - 352) * 0.5}px`;
    divider.style.top = `${y + 135}px`;
    preloaderCounter.style.left = `${stageW * 0.5 - 200}px`;
    preloaderCounter.style.top = `${y + 155}px`;
  };

  layout();
  window.addEventListener("resize", layout);

  flickerTimer = window.setInterval(() => {
    const random = Math.random() * 90;
    preloaderLogoOn.style.opacity = random < preloaderPercent ? "1" : "0";
  }, 75);
}

function updatePreloaderCounter(percent) {
  preloaderPercent = percent;
  preloaderCounter.textContent = `${percent}%`;
}

function startPreloaderFade() {
  if (state.hasStartedMain) {
    return;
  }

  state.hasStartedMain = true;
  window.clearInterval(flickerTimer);
  flickerTimer = null;

  let alpha = 1;
  const fadeStep = () => {
    alpha -= 0.5;
    preloaderView.style.opacity = String(Math.max(alpha, 0));
    if (alpha <= 0) {
      renderLanding();
      preloaderScreen.remove();
      return;
    }
    window.setTimeout(fadeStep, 33);
  };

  window.setTimeout(fadeStep, 33);
}

function renderLanding() {
  app.classList.remove("app-loading");
  const landing = createEl("div", "base-screen landing-screen landing-visible");
  screenRoot.append(landing);

  const bgStage = createEl("div", "landing-bg-stage");
  backgroundStage.replaceChildren(bgStage);

  const bg = createEl("div", "landing-bg");
  bgStage.append(bg);

  const bgMain = createImage("landing_bg", "landing-bg-main");
  bg.append(bgMain);

  const noSign = createImage("landing_no", "landing-no");
  bg.append(noSign);

  const fog1 = createImage("fog", "landing-fog");
  const fog2 = createImage("fog", "landing-fog");
  const fog3 = createImage("fog", "landing-fog");
  fog1.style.left = "0px";
  fog2.style.left = "1300px";
  fog3.style.left = "2600px";
  bg.append(fog1, fog2, fog3);

  const overlayScale = createEl("div", "landing-overlay-scale");
  const overlay = createEl("div", "landing-overlay");
  overlayScale.append(overlay);
  overlayStage.append(overlayScale);

  overlay.append(createImage("logo_divider", "landing-divider"));

  const logoWrap = createEl("div", "landing-logo-wrap");
  const logoMain = createImage("logo_main", "landing-logo-layer");
  const logoGlow = createImage("logo_glow", "landing-logo-layer");
  const logoLight = createImage("logo_light", "landing-logo-layer");
  logoWrap.append(logoMain, logoGlow, logoLight);
  overlay.append(logoWrap);

  overlay.append(createEl("div", "landing-welcome", text("landingWelcome")));
  overlay.append(createEl("div", "landing-intro", htmlText("landingIntro")));

  const enterButton = buildEnterButton();
  enterButton.style.top = "252px";
  overlay.append(enterButton);

  const showPageButton = buildNeonButton(
    text("visitShowPage"),
    "11px",
    "helNeuLt-medium"
  );
  showPageButton.style.top = "334px";
  showPageButton.addEventListener("click", () => {
    window.open(text("urlAbout"), "_blank", "noopener");
  });
  overlay.append(showPageButton);

  const bigEnterHit = createEl("button", "enter-hit");
  bigEnterHit.type = "button";
  overlay.append(bigEnterHit);

  const playIntro = () => {
    stopLandingLoops();
    overlay.classList.add("exit");
    bg.classList.add("exit");
    window.setTimeout(() => {
      backgroundStage.replaceChildren();
      overlayScale.remove();
      landing.remove();
      renderOutside();
    }, 1300);
  };

  enterButton.addEventListener("click", playIntro);
  bigEnterHit.addEventListener("click", playIntro);

  requestAnimationFrame(() => {
    bg.classList.add("is-visible");
    logoMain.style.transition = "opacity 0.5s linear";
    logoGlow.style.transition = "opacity 0.5s linear 0.1s";
    logoLight.style.transition = "opacity 0.5s linear 0.1s";
    logoMain.style.opacity = "1";
    logoGlow.style.opacity = "1";
    logoLight.style.opacity = "1";
  });

  const positionOverlay = () => {
    overlayScale.style.left = `${window.innerWidth / 2}px`;
    overlayScale.style.top = `${window.innerHeight / 2.5 - 255}px`;
    const uiScale = Math.min(window.innerWidth / STAGE_WIDTH, window.innerHeight / STAGE_HEIGHT);
    overlayScale.style.transform = `scale(${uiScale})`;
  };

  positionOverlay();
  window.addEventListener("resize", positionOverlay);

  requestAnimationFrame(() => {
    sizeEnterButton(enterButton);
    sizeNeonButton(showPageButton, 70);
  });

  rollFog(fog1, 0);
  rollFog(fog2, 1);
  rollFog(fog3, 2);

  window.setTimeout(() => {
    startLandingFlickers(noSign, logoGlow, logoLight, enterButton);
  }, 3500);
}

function renderPlaceholderOutside() {
  backgroundStage.replaceChildren();
  const outside = createEl("div", "base-screen placeholder-outside");
  outside.innerHTML = `
    <div class="placeholder-card">
      <h1 class="placeholder-title">Outside View Next</h1>
      <p class="placeholder-copy">Phase 1 is now wired end to end: preloader, landing page, and the original enter transition are in place. Phase 2 will rebuild the courtyard, hallway navigation, and door movement from the decompiled app logic.</p>
    </div>
  `;
  screenRoot.append(outside);
  requestAnimationFrame(() => outside.classList.add("is-visible"));
}

function renderOutside() {
  backgroundStage.replaceChildren();
  overlayStage.replaceChildren();
  screenRoot.replaceChildren();

  stopOutsideAudio();
  state.isInRoom = false;

  const outside = createEl("div", "base-screen outside-screen");
  const stage = createEl("div", "outside-stage");
  const fade = createEl("div", "outside-fade");
  const bg = createEl("div", "outside-bg");
  const doorsWrap = createEl("div", "");
  const numbersWrap = createEl("div", "outside-door-numbers");
  const hallwayVideoA = document.createElement("video");
  hallwayVideoA.className = "outside-hallway-video";
  hallwayVideoA.preload = "auto";
  hallwayVideoA.playsInline = true;
  const hallwayVideoB = document.createElement("video");
  hallwayVideoB.className = "outside-hallway-video";
  hallwayVideoB.preload = "auto";
  hallwayVideoB.playsInline = true;
  const enterVideo = document.createElement("video");
  enterVideo.className = "outside-enter-video";
  enterVideo.preload = "auto";
  enterVideo.playsInline = true;
  const doorHit = createEl("button", "outside-door-hit");
  doorHit.type = "button";
  const houseNote = createEl("div", "outside-note", htmlText("houseDoorText"));
  const basementNote = createEl("div", "outside-note", htmlText("basementDoorText"));
  const sidebar = buildOutsideSidebar();
  const miniMap = buildOutsideMiniMap();
  const helpOverlay = buildOutsideHelpOverlay();

  stage.append(bg, doorHit, hallwayVideoA, hallwayVideoB, enterVideo, fade);
  outside.append(stage, miniMap.root, sidebar.root, houseNote, basementNote, helpOverlay.root);
  screenRoot.append(outside);

  const doorEntries = [
    makeOutsideImage("assets/bitmaps/rooms/door_basement.jpg", "outside-door"),
    makeOutsideImage("assets/bitmaps/rooms/door_house.jpg", "outside-door"),
    makeOutsideImage("assets/bitmaps/rooms/door_office.jpg", "outside-door"),
    makeOutsideImage("assets/bitmaps/rooms/door_left.jpg", "outside-door"),
    makeOutsideImage("assets/bitmaps/rooms/door_right.jpg", "outside-door"),
  ];

  doorEntries[3].style.left = "-349px";
  doorEntries[3].style.top = "-76px";
  doorEntries.forEach((door) => doorsWrap.append(door));
  bg.append(doorsWrap);
  bg.append(numbersWrap);

  const numberEntries = [];
  for (let n = 1; n <= 12; n += 1) {
    const number = makeOutsideImage(`assets/bitmaps/rooms/num${n}.png`, "outside-number");
    numberEntries.push(number);
    numbersWrap.append(number);
  }

  const stageState = {
    root: outside,
    stage,
    bg,
    fade,
    hallwayVideos: [hallwayVideoA, hallwayVideoB],
    enterVideo,
    doorHit,
    sidebar,
    miniMap,
    helpOverlay,
    houseNote,
    basementNote,
    doorEntries,
    numberEntries,
    isTransitioning: false,
    audio: null,
    travel: null,
  };

  outsideScreenState = stageState;
  applyOutsideLayout(stage);

  sidebar.roomButtons.forEach((button) => {
    button.addEventListener("click", () => requestRoomMove(Number(button.dataset.roomId)));
  });
  sidebar.helpButton.addEventListener("click", () => toggleOutsideHelp());
  sidebar.soundButton.addEventListener("click", () => toggleOutsideSound());
  helpOverlay.okButton.addEventListener("click", () => toggleOutsideHelp(false));
  helpOverlay.dimButton.addEventListener("click", () => toggleOutsideHelp(false));
  miniMap.leftButton.addEventListener("click", () => requestRoomMove(state.currentRoomId - 1));
  miniMap.rightButton.addEventListener("click", () => requestRoomMove(state.currentRoomId + 1));
  miniMap.upButton.addEventListener("click", () => {
    if (state.currentRoomId === 1) {
      requestRoomMove(0);
    } else {
      enterCurrentRoom();
    }
  });
  miniMap.downButton.addEventListener("click", () => {
    if (state.currentRoomId === 0 && !state.isInRoom) {
      requestRoomMove(1);
    }
  });
  miniMap.skipButton.addEventListener("click", () => skipOutsideTravel());
  doorHit.addEventListener("click", () => {
    if (state.currentRoomId === 1) {
      requestRoomMove(0);
    } else {
      enterCurrentRoom();
    }
  });

  setOutsideRoom(state.currentRoomId, false);
  applyHelpState();

  requestAnimationFrame(() => {
    bg.classList.add("is-settled");
    fade.classList.add("is-clear");
  });

  playOutsideAmbient();
}

function applyOutsideLayout(stage) {
  if (!stage) {
    return;
  }

  const width = window.innerWidth;
  const height = window.innerHeight;
  const scale = Math.max(width / STAGE_WIDTH, height / STAGE_HEIGHT);
  stage.style.transform = `translate(${(width - STAGE_WIDTH * scale) / 2}px, ${(height - STAGE_HEIGHT * scale) / 2}px) scale(${scale})`;
}

function requestRoomMove(targetRoomId) {
  if (!outsideScreenState || outsideScreenState.isTransitioning) {
    return;
  }
  if (state.isHelpActive) {
    toggleOutsideHelp(false);
  }
  if (targetRoomId < 0 || targetRoomId >= state.rooms.length || targetRoomId === state.currentRoomId) {
    return;
  }

  moveOutsideToRoom(targetRoomId);
}

async function moveOutsideToRoom(targetRoomId) {
  const view = outsideScreenState;
  if (!view) {
    return;
  }

  view.isTransitioning = true;
  toggleOutsideNotes(null);
  updateOutsideControls(true);

  const isRight = targetRoomId - state.currentRoomId > 0;
  const travel = {
    skipped: false,
    targetRoomId,
    targetStep: stepForRoom(targetRoomId),
    directionRight: isRight,
    runId: (view.travel?.runId ?? 0) + 1,
  };
  view.travel = travel;
  resetHallwayVideos(view);
  toggleMapSkip(true);

  await Promise.all([
    animateHallwayTravel(view, targetRoomId, isRight, travel),
    animateMapTravel(view, travel.targetStep, isRight, travel),
  ]);

  if (outsideScreenState !== view) {
    return;
  }

  if (!travel.skipped) {
    finalizeOutsideTravel(targetRoomId, travel.targetStep);
  }
}

function setOutsideRoom(roomId, keepZoomed = false) {
  const room = state.rooms[roomId];
  const view = outsideScreenState;
  if (!room || !view) {
    return;
  }

  state.currentRoomId = roomId;

  view.doorEntries.forEach((door, index) => {
    door.classList.toggle("is-visible", index === room.doorImageId);
  });

  view.numberEntries.forEach((number, index) => {
    number.classList.toggle("is-visible", String(index + 3) === String(room.id));
  });

  const hitPositions = {
    0: 456,
    1: 459,
    2: 311,
    3: 482,
    4: 384,
  };
  view.doorHit.style.left = `${hitPositions[room.doorImageId] ?? 384}px`;

  view.enterVideo.src = room.doorEnterPath;
  view.enterVideo.classList.toggle("is-right-door", room.doorImageId === 4);

  if (!keepZoomed) {
    view.bg.classList.remove("is-settled");
    void view.bg.offsetWidth;
    view.bg.classList.add("is-settled");
  }

  updateOutsideControls(Boolean(view.travel));
  updateSidebarState();
  if (!view.travel) {
    applyMapPosition(view, state.currentStep, 0);
    toggleMapSkip(false);
    toggleOutsideNotes(roomId === 1 ? "house" : roomId === 0 ? "basement" : null);
  }
}

function updateOutsideControls(isBusy) {
  const view = outsideScreenState;
  if (!view) {
    return;
  }
  view.doorHit.disabled = isBusy;
  view.sidebar.roomButtons.forEach((button) => {
    button.disabled = isBusy || Number(button.dataset.roomId) === state.currentRoomId;
  });
  view.miniMap.leftButton.disabled = isBusy;
  view.miniMap.rightButton.disabled = isBusy;
  view.miniMap.upButton.disabled = isBusy;
  view.miniMap.downButton.disabled = isBusy;
  view.miniMap.skipButton.disabled = !isBusy;
}

function toggleOutsideNotes(which) {
  const view = outsideScreenState;
  if (!view) {
    return;
  }
  view.houseNote.classList.toggle("is-visible", which === "house");
  view.basementNote.classList.toggle("is-visible", which === "basement");
}

async function enterCurrentRoom() {
  const view = outsideScreenState;
  const room = state.rooms[state.currentRoomId];
  if (!view || !room || view.isTransitioning) {
    return;
  }
  if (state.isHelpActive) {
    toggleOutsideHelp(false);
  }

  view.isTransitioning = true;
  state.isInRoom = true;
  updateOutsideControls(true);
  toggleOutsideNotes(null);
  stopOutsideAudio();

  view.enterVideo.classList.add("is-visible");
  view.bg.style.opacity = "0";
  const videoStarted = playVideoOnce(view.enterVideo, room.doorEnterPath, true).catch(() => delay(4000));

  await Promise.race([videoStarted, delay(3500)]);

  view.root.remove();
  outsideScreenState = null;
  renderRoomPlaceholder(room);
}

function renderRoomPlaceholder(room) {
  backgroundStage.replaceChildren();
  overlayStage.replaceChildren();
  screenRoot.replaceChildren();

  const placeholder = createEl("div", "base-screen room-placeholder");
  placeholder.innerHTML = `
    <div class="room-placeholder-card">
      <h1 class="room-placeholder-title">${room.navText === "HOME" ? "Home" : `Room ${room.navText}`}</h1>
      <p class="room-placeholder-copy">The outside experience is now live with the original door art, room-number switching, hallway MP4 transitions, and room-entry video handoff. The next build phase is the actual interior room viewer and item exploration layer.</p>
      <button class="outside-enter-btn" type="button">BACK OUTSIDE</button>
    </div>
  `;
  screenRoot.append(placeholder);
  requestAnimationFrame(() => placeholder.classList.add("is-visible"));
  placeholder.querySelector("button")?.addEventListener("click", () => {
    state.isInRoom = false;
    placeholder.remove();
    renderOutside();
  });
}

function playOutsideAmbient() {
  const view = outsideScreenState;
  if (!view) {
    return;
  }

  const audio = new Audio(state.outsideAmbientPath);
  audio.loop = true;
  audio.volume = 0.3;
  view.audio = audio;
  audio.play().catch(() => {});
}

function stopOutsideAudio() {
  if (outsideScreenState?.audio) {
    outsideScreenState.audio.pause();
    outsideScreenState.audio.currentTime = 0;
    outsideScreenState.audio = null;
  }
}

async function animateHallwayTravel(view, targetRoomId, isRight, travel) {
  const clips = [];
  let current = state.currentRoomId;
  while (current !== targetRoomId && !travel.skipped) {
    const clipIndex = isRight ? current : current - 1;
    clips.push(`assets/videos/trans/${isRight ? "right" : "left"}_${clipIndex}.mp4`);
    current += isRight ? 1 : -1;
  }

  const [videoA, videoB] = view.hallwayVideos;
  let activeVideo = videoA;
  let standbyVideo = videoB;
  let currentRoom = state.currentRoomId;

  for (let i = 0; i < clips.length && !travel.skipped; i += 1) {
    const src = clips[i];
    await prepareVideo(activeVideo, src);

    const nextSrc = clips[i + 1];
    const preloadNext = nextSrc ? prepareVideo(standbyVideo, nextSrc) : Promise.resolve();

    activeVideo.classList.add("is-visible");
    activeVideo.style.opacity = "1";
    standbyVideo.style.opacity = "0";
    standbyVideo.classList.remove("is-visible");

    await preloadNext;
    await playVideoOnce(activeVideo, src, false, () => travel.skipped, true);

    if (travel.skipped) {
      break;
    }

    currentRoom += isRight ? 1 : -1;
    state.currentRoomId = currentRoom;
    setOutsideRoom(currentRoom, true);

    const previous = activeVideo;
    activeVideo = standbyVideo;
    standbyVideo = previous;
  }
}

async function animateMapTravel(view, endStep, isRight, travel) {
  while (state.currentStep !== endStep && !travel.skipped) {
    const nextStep = endStep > state.currentStep ? state.currentStep + 1 : state.currentStep - 1;
    const duration = (isRight ? NAV_MAP_PATH[nextStep - 1].tR : NAV_MAP_PATH[nextStep].tL) * 1000;
    state.currentStep = nextStep;
    applyMapPosition(view, nextStep, duration);
    await delay(duration);
  }
}

function finalizeOutsideTravel(targetRoomId, targetStep) {
  const view = outsideScreenState;
  if (!view) {
    return;
  }

  state.currentRoomId = targetRoomId;
  state.currentStep = targetStep;
  state.isInRoom = false;
  setOutsideRoom(targetRoomId, true);
  resetHallwayVideos(view);
  view.isTransitioning = false;
  view.travel = null;
  applyMapPosition(view, state.currentStep, 0);
  toggleMapSkip(false);
  toggleOutsideNotes(targetRoomId === 1 ? "house" : targetRoomId === 0 ? "basement" : null);
  updateOutsideControls(false);
}

function skipOutsideTravel() {
  const view = outsideScreenState;
  const travel = view?.travel;
  if (!view || !travel || travel.skipped) {
    return;
  }

  travel.skipped = true;
  resetHallwayVideos(view);
  view.miniMap.you.style.opacity = "0";

  const targetStep = stepForRoom(travel.targetRoomId);
  window.setTimeout(() => {
    if (outsideScreenState !== view) {
      return;
    }
    state.currentStep = targetStep;
    state.currentRoomId = travel.targetRoomId;
    applyMapPosition(view, targetStep, 500);
    setOutsideRoom(travel.targetRoomId, true);
    window.setTimeout(() => {
      if (outsideScreenState !== view) {
        return;
      }
      view.miniMap.you.style.opacity = "1";
      finalizeOutsideTravel(travel.targetRoomId, targetStep);
    }, 500);
  }, 500);
}

function buildOutsideSidebar() {
  const root = createEl("div", "outside-sidebar");
  const top = createEl("div", "outside-sidebar-top");
  const helpButton = createEl("button", "outside-sidebar-icon");
  helpButton.type = "button";
  const helpImg = makeOutsideImage("assets/bitmaps/btn_help.png", "outside-sidebar-help");
  helpButton.append(helpImg);

  const soundButton = createEl("button", "outside-sidebar-icon");
  soundButton.type = "button";
  const soundBg = makeOutsideImage("assets/bitmaps/btn_sound_bg.png", "outside-sidebar-sound-bg");
  const soundOn = makeOutsideImage("assets/bitmaps/btn_sound_on.png", "outside-sidebar-sound-on");
  const soundOff = makeOutsideImage("assets/bitmaps/btn_sound_off.png", "outside-sidebar-sound-off");
  soundButton.append(soundBg, soundOn, soundOff);
  top.append(helpButton, soundButton);

  const roomList = createEl("div", "outside-sidebar-room-list");
  const roomButtons = [];
  const roomsForBar = state.rooms.filter((room) => room.id >= 1);
  roomsForBar.forEach((room, index) => {
    const entry = createEl("div", "outside-room-nav");
    entry.style.top = `${(index + 1) * 40}px`;
    const bgName = index === 0 ? "nav_bg_first" : index === roomsForBar.length - 1 ? "nav_bg_last" : "nav_bg";
    entry.append(makeOutsideImage(`assets/bitmaps/${bgName}.png`, "outside-room-nav-bg"));
    entry.append(createEl("div", "outside-room-nav-label", room.navText));
    entry.append(makeOutsideImage("assets/bitmaps/nav_circle.png", "outside-room-nav-circle"));
    entry.append(createEl("div", "outside-room-nav-active"));
    const button = document.createElement("button");
    button.type = "button";
    button.dataset.roomId = String(room.id);
    entry.append(button);
    roomList.append(entry);
    roomButtons.push(button);
    window.setTimeout(() => entry.classList.add("is-visible"), 50 * index);
  });

  root.append(top, roomList);
  return { root, roomList, roomButtons, helpButton, soundButton };
}

function buildOutsideHelpOverlay() {
  const root = createEl("div", "outside-help-overlay");
  const dimButton = createEl("button", "outside-help-dim");
  dimButton.type = "button";
  dimButton.setAttribute("aria-label", "Close help");

  const card = createEl("div", "outside-help-card", htmlText("helpIntro"));
  const okButton = createEl("button", "outside-help-ok");
  okButton.type = "button";
  okButton.append(makeOutsideImage("assets/bitmaps/btn_ok.png", "outside-help-ok-image"));
  card.append(okButton);

  const mapTip = createEl("div", "outside-help-tip map", htmlText("helpMap"));
  const navTip = createEl("div", "outside-help-tip nav", htmlText("helpNavigation"));
  const soundTip = createEl("div", "outside-help-tip sound", htmlText("helpSound"));
  const previousTip = createEl("div", "outside-map-help left", htmlText("helpPrevious"));
  const nextTip = createEl("div", "outside-map-help right", htmlText("helpNext"));
  const enterTip = createEl("div", "outside-map-help up", htmlText("helpEnter"));
  const exitTip = createEl("div", "outside-map-help down", htmlText("helpExit"));

  root.append(dimButton, card, mapTip, navTip, soundTip, previousTip, nextTip, enterTip, exitTip);
  return {
    root,
    dimButton,
    okButton,
    previousTip,
    nextTip,
    enterTip,
    exitTip,
  };
}

function buildOutsideMiniMap() {
  const root = createEl("div", "outside-map-root");
  const shell = createEl("div", "outside-map-shell");
  const viewport = createEl("div", "outside-map-viewport");
  const rotator = createEl("div", "outside-map-rotator");
  const grounds = createEl("div", "outside-map-grounds");
  const groundsBg = makeOutsideImage("assets/bitmaps/map/grounds_bg.png", "outside-map-bg");
  const groundsLight = makeOutsideImage("assets/bitmaps/map/grounds_light.png", "outside-map-light");
  const stranger = makeOutsideImage("assets/bitmaps/map/stranger.png", "outside-map-stranger");
  grounds.append(groundsBg, groundsLight, stranger);
  rotator.append(grounds);
  viewport.append(rotator);
  const glass = makeOutsideImage("assets/bitmaps/map/glass.png", "outside-map-glass");
  const you = makeOutsideImage("assets/bitmaps/map/you.png", "outside-map-you");

  const left = buildMapArrow("left", 90);
  const right = buildMapArrow("right", -90);
  const up = buildMapArrow("up", 180);
  const down = buildMapArrow("down", 0);
  const skip = createEl("div", "outside-map-skip");
  const skipButton = document.createElement("button");
  skipButton.type = "button";
  skipButton.textContent = text("btnSkip");
  skip.append(skipButton);

  shell.append(viewport, glass, you, left.root, right.root, up.root, down.root, skip);
  root.append(shell);
  return {
    root,
    shell,
    viewport,
    glass,
    rotator,
    grounds,
    you,
    leftArrow: left.root,
    rightArrow: right.root,
    upArrow: up.root,
    downArrow: down.root,
    skip,
    leftButton: left.button,
    rightButton: right.button,
    upButton: up.button,
    downButton: down.button,
    skipButton,
  };
}

function buildMapArrow(direction, rotation) {
  const root = createEl("div", `outside-map-arrow ${direction}`);
  const button = document.createElement("button");
  button.type = "button";
  const arrow = makeOutsideImage("assets/bitmaps/map/arrow.png", "");
  arrow.style.transform = `rotate(${rotation}deg)`;
  button.append(arrow);
  root.append(button);
  return { root, button };
}

function updateSidebarState() {
  const view = outsideScreenState;
  if (!view) {
    return;
  }
  view.sidebar.roomButtons.forEach((button) => {
    const entry = button.parentElement;
    const roomId = Number(button.dataset.roomId);
    entry?.classList.toggle("is-active", roomId === state.currentRoomId);
    entry?.classList.toggle("is-in-room", roomId === state.currentRoomId && state.isInRoom);
  });
}

function applyMapPosition(view, step, durationMs) {
  const point = NAV_MAP_PATH[step];
  if (!point) {
    return;
  }
  view.miniMap.grounds.style.transition = durationMs ? `left ${durationMs}ms linear, top ${durationMs}ms linear` : "none";
  view.miniMap.rotator.style.transition = durationMs ? `transform ${durationMs}ms linear` : "none";
  view.miniMap.grounds.style.left = `${-point.x}px`;
  view.miniMap.grounds.style.top = `${-point.y}px`;
  view.miniMap.rotator.style.transform = `rotate(${point.r}deg)`;
}

function toggleMapSkip(skipOn) {
  const view = outsideScreenState;
  if (!view) {
    return;
  }
  if (skipOn) {
    setMapArrowState(false, false, false, false, true);
  } else if (state.currentStep < 4) {
    if (state.currentStep < 1) {
      setMapArrowState(false, false, true, true, false);
    } else {
      setMapArrowState(false, true, true, false, false);
    }
  } else if (state.currentStep > 19) {
    setMapArrowState(true, false, true, false, false);
  } else {
    setMapArrowState(true, true, true, false, false);
  }
}

function setMapArrowState(left, right, up, down, skip) {
  const view = outsideScreenState;
  const map = view?.miniMap;
  if (!map || !view?.helpOverlay) {
    return;
  }
  map.leftArrow.classList.toggle("is-visible", left);
  map.rightArrow.classList.toggle("is-visible", right);
  map.upArrow.classList.toggle("is-visible", up);
  map.downArrow.classList.toggle("is-visible", down);
  map.skip.classList.toggle("is-visible", skip);
  view.helpOverlay.previousTip.classList.toggle("is-visible", state.isHelpActive && left);
  view.helpOverlay.nextTip.classList.toggle("is-visible", state.isHelpActive && right);
  view.helpOverlay.enterTip.classList.toggle("is-visible", state.isHelpActive && up);
  view.helpOverlay.exitTip.classList.toggle("is-visible", state.isHelpActive && down);
}

function stepForRoom(roomId) {
  const match = NAV_MAP_PATH.find((point) => point.s === roomId);
  return match ? NAV_MAP_PATH.indexOf(match) : state.currentStep;
}

function toggleOutsideSound() {
  const view = outsideScreenState;
  if (!view?.audio) {
    return;
  }
  const shouldMute = !view.audio.muted;
  view.audio.muted = shouldMute;
  view.sidebar.soundButton.classList.toggle("is-muted", shouldMute);
}

function toggleOutsideHelp(force) {
  const next = typeof force === "boolean" ? force : !state.isHelpActive;
  state.isHelpActive = next;
  applyHelpState();
}

function applyHelpState() {
  const view = outsideScreenState;
  if (!view) {
    return;
  }
  view.root.classList.toggle("is-help-active", state.isHelpActive);
  view.sidebar.helpButton.classList.toggle("is-active", state.isHelpActive);
  view.helpOverlay.root.classList.toggle("is-visible", state.isHelpActive);
  toggleMapSkip(Boolean(view.travel));
}

function resetHallwayVideos(view) {
  if (!view?.hallwayVideos) {
    return;
  }
  view.hallwayVideos.forEach((video) => {
    video.pause();
    video.currentTime = 0;
    video.style.opacity = "0";
    video.classList.remove("is-visible");
    video.removeAttribute("src");
    video.dataset.preparedSrc = "";
    video.load();
  });
}

function prepareVideo(video, src) {
  return new Promise((resolve) => {
    if (video.dataset.preparedSrc === src && video.readyState >= 2) {
      resolve();
      return;
    }

    const cleanup = () => {
      video.removeEventListener("loadeddata", onReady);
      video.removeEventListener("error", onError);
    };

    const onReady = () => {
      cleanup();
      resolve();
    };

    const onError = () => {
      cleanup();
      resolve();
    };

    video.pause();
    video.currentTime = 0;
    video.dataset.preparedSrc = src;
    video.src = src;
    video.addEventListener("loadeddata", onReady, { once: true });
    video.addEventListener("error", onError, { once: true });
    video.load();
  });
}

function playVideoOnce(video, src, allowReject = false, shouldAbort = () => false, alreadyPrepared = false) {
  return new Promise((resolve, reject) => {
    const abortWatcher = window.setInterval(() => {
      if (shouldAbort()) {
        cleanup();
        resolve();
      }
    }, 50);

    const cleanup = () => {
      window.clearInterval(abortWatcher);
      video.removeEventListener("ended", onEnded);
      video.removeEventListener("error", onError);
    };

    const onEnded = () => {
      cleanup();
      resolve();
    };

    const onError = () => {
      cleanup();
      if (allowReject) {
        reject(new Error(`Failed to play video: ${src}`));
      } else {
        resolve();
      }
    };

    if (shouldAbort()) {
      resolve();
      return;
    }

    video.pause();
    video.currentTime = 0;
    if (!alreadyPrepared && video.getAttribute("src") !== src) {
      video.src = src;
      video.load();
    }
    video.addEventListener("ended", onEnded, { once: true });
    video.addEventListener("error", onError, { once: true });
    const playPromise = video.play();
    if (playPromise && typeof playPromise.catch === "function") {
      playPromise.catch(onError);
    }
  });
}

function makeOutsideImage(src, className) {
  const image = new Image();
  image.src = src;
  image.className = className;
  image.draggable = false;
  return image;
}

function buildEnterButton() {
  const button = createEl("button", "enter-cta neon-box");
  button.type = "button";

  const bg = createEl("div", "enter-cta-bg");
  button.append(bg);

  const copy = createEl("div", "enter-cta-copy");
  const textWrap = createEl("div", "");
  textWrap.style.position = "relative";
  const textOut = createEl("div", "enter-cta-text", text("enterSite"));
  const textGlow = createEl("div", "enter-cta-text-glow", text("enterSite"));
  textWrap.append(textOut, textGlow);

  const arrowWrap = createEl("div", "enter-cta-arrow-wrap");
  const arrow = createImage("btn_enter_up", "enter-cta-arrow");
  const arrowOver = createImage("btn_enter_over", "enter-cta-arrow-over");
  arrowWrap.append(arrow, arrowOver);

  copy.append(textWrap, arrowWrap);
  button.append(copy);

  flickerEnterAsset(button);
  return button;
}

function buildNeonButton(copyText, fontSize, fontFamily) {
  const button = createEl("button", "neon-button neon-box");
  button.type = "button";

  const copy = createEl("div", "neon-button-copy", copyText);
  copy.style.fontSize = fontSize;
  copy.style.fontFamily = `"${fontFamily}", Arial, sans-serif`;

  const glow = createEl("div", "neon-button-copy-glow", copyText);
  glow.style.fontSize = fontSize;
  glow.style.fontFamily = `"${fontFamily}", Arial, sans-serif`;

  button.append(copy, glow);
  return button;
}

function sizeEnterButton(button) {
  const textOut = button.querySelector(".enter-cta-text");
  const arrowWrap = button.querySelector(".enter-cta-arrow-wrap");
  if (!textOut || !arrowWrap) {
    return;
  }

  const width = Math.ceil(textOut.getBoundingClientRect().width + arrowWrap.getBoundingClientRect().width + 24);
  button.style.width = `${width}px`;
}

function sizeNeonButton(button, horizontalPadding) {
  const copy = button.querySelector(".neon-button-copy");
  const glow = button.querySelector(".neon-button-copy-glow");
  if (!copy || !glow) {
    return;
  }

  const width = Math.ceil(copy.getBoundingClientRect().width + horizontalPadding);
  button.style.width = `${width}px`;
  glow.style.width = `${copy.getBoundingClientRect().width}px`;
}

function startLandingFlickers(noSign, logoGlow, logoLight, enterButton) {
  activeLandingFlickers.push(scheduleLoop(() => flickerLogo(logoGlow, logoLight), () => Math.random() * 10000 + 2100));
  activeLandingFlickers.push(scheduleLoop(() => flickerEnterAsset(enterButton), () => Math.random() * 5000 + 2000));
  activeLandingFlickers.push(scheduleLoop(() => flickerNo(noSign), () => Math.random() * 1000 + 7000));
}

function stopLandingLoops() {
  activeLandingFlickers.forEach((timerId) => window.clearTimeout(timerId));
  activeLandingFlickers = [];
  fogAnimations.forEach((animation) => animation.cancel());
  fogAnimations = [];
}

function scheduleLoop(callback, nextDelay) {
  callback();
  return window.setTimeout(function run() {
    callback();
    activeLandingFlickers.push(window.setTimeout(run, nextDelay()));
  }, nextDelay());
}

function flickerLogo(logoGlow, logoLight) {
  sequenceAlpha(logoGlow, [
    [0.9, 75],
    [1, 75],
  ]);
  sequenceAlpha(logoLight, [
    [0.9, 75],
    [1, 75],
  ]);

  if (Math.random() > 0.75) {
    sequenceAlpha(logoGlow, [
      [0.8, 75, 150],
      [1, 75, 225],
    ]);
    sequenceAlpha(logoLight, [
      [0.8, 75, 150],
      [1, 75, 225],
    ]);
  }

  if (Math.random() > 0.875) {
    sequenceAlpha(logoGlow, [
      [0.9, 75, 300],
      [1, 75, 900],
    ]);
    sequenceAlpha(logoLight, [
      [0.9, 75, 300],
      [1, 75, 900],
    ]);
  }
}

function flickerEnterAsset(button) {
  const arrow = button.querySelector(".enter-cta-arrow");
  if (!arrow) {
    return;
  }

  sequenceAlpha(arrow, [
    [0.9, 75],
    [1, 75, 75],
  ]);

  if (Math.random() > 0.75) {
    sequenceAlpha(arrow, [
      [0.8, 75, 150],
      [1, 75, 225],
    ]);
  }

  if (Math.random() > 0.875) {
    sequenceAlpha(arrow, [
      [0.9, 75, 300],
      [1, 75, 900],
    ]);
  }
}

function flickerNo(noSign) {
  sequenceAlpha(noSign, [
    [0.9, 75],
    [1, 75, 75],
  ]);

  if (Math.random() > 0.3) {
    sequenceAlpha(noSign, [
      [0.8, 75, 150],
      [1, 75, 225],
    ]);
  }

  if (Math.random() > 0.5) {
    sequenceAlpha(noSign, [
      [0.9, 75, 300],
      [1, 75, 900],
    ]);
  }

  if (Math.random() > 0.75) {
    sequenceAlpha(noSign, [
      [0.3, 75, 1300],
      [0.35, 75, 1400],
      [0.3, 75, 1500],
      [0.35, 75, 2400],
      [0.3, 75, 2500],
      [0.7, 75, 5400],
      [0.4, 50, 5475],
      [1, 75, 5600],
    ]);
  }
}

function rollFog(fogEl, offset) {
  const startX = Number.parseFloat(fogEl.dataset.startX ?? fogEl.style.left ?? "0");
  const duration = (offset + 1) * 20000;
  const animation = fogEl.animate(
    [
      { left: `${startX}px` },
      { left: "-1500px" },
    ],
    {
      duration,
      easing: "linear",
      fill: "forwards",
    }
  );

  animation.addEventListener("finish", () => {
    fogEl.style.left = "1500px";
    fogEl.dataset.startX = "1500";
    rollFog(fogEl, 2);
  });

  fogAnimations.push(animation);
}

function sequenceAlpha(element, steps) {
  steps.forEach(([alpha, duration, delayMs = 0]) => {
    window.setTimeout(() => {
      element.style.transition = `opacity ${duration}ms linear`;
      element.style.opacity = String(alpha);
    }, delayMs);
  });
}

function parseConfig(xmlText) {
  const parser = new DOMParser();
  const xml = parser.parseFromString(xmlText, "application/xml");
  const textNodes = xml.querySelectorAll("TEXTS > TEXT");

  textNodes.forEach((node) => {
    const key = node.getAttribute("key");
    const value = node.getAttribute("value") ?? node.textContent ?? "";
    if (key) {
      state.texts.set(key, value.trim());
    }
  });

  const initialRoom = Number.parseInt(state.texts.get("initalRoom") ?? "3", 10);
  state.initialRoomId = Number.isNaN(initialRoom) ? 3 : initialRoom;
  state.currentRoomId = state.initialRoomId;
  state.currentStep = stepForRoom(state.currentRoomId);
  state.currentEnterStep = 0;

  const externalSound = xml.querySelector("EXTERNALSOUND SOUND");
  if (externalSound?.getAttribute("assetPath")) {
    state.outsideAmbientPath = externalSound.getAttribute("assetPath");
  }

  state.rooms = Array.from(xml.querySelectorAll("ROOMS > ROOM")).map((roomNode) => {
    const id = Number.parseInt(roomNode.getAttribute("id") ?? "0", 10);
    const doorEnter = roomNode.getAttribute("doorEnter") ?? "";
    return {
      id,
      navText: roomNode.getAttribute("text") ?? "",
      doorImageId: Number.parseInt(roomNode.getAttribute("doorImage") ?? "0", 10),
      doorEnterPath: doorEnter.replace(/\.flv$/i, ".mp4"),
    };
  });
}

function primeFallbackText() {
  Object.entries(PHASE_ONE_FALLBACK_TEXT).forEach(([key, value]) => {
    state.texts.set(key, value);
  });
}

function text(key) {
  return state.texts.get(key) ?? "";
}

function htmlText(key) {
  return (state.texts.get(key) ?? "").replace(/<br\s*\/?>/gi, "<br>");
}

function createImage(key, className) {
  const image = state.assets.get(key).cloneNode();
  image.className = className;
  image.draggable = false;
  return image;
}

function createEl(tag, className, content) {
  const el = document.createElement(tag);
  if (className) {
    el.className = className;
  }
  if (typeof content === "string") {
    if (content.includes("<br>")) {
      el.innerHTML = content;
    } else {
      el.textContent = content;
    }
  }
  return el;
}

function loadImage(src) {
  return new Promise((resolve, reject) => {
    const image = new Image();
    image.onload = () => resolve(image);
    image.onerror = reject;
    image.src = src;
  });
}

function delay(ms) {
  return new Promise((resolve) => window.setTimeout(resolve, ms));
}

import * as THREE from "./vendor/three.module.js";

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

const ROOM_EXIT_TUNING = {
  default: {
    targetFlatX: null,
    yawOffsetDeg: 0,
    targetDistance: 62,
    targetPitch: -4,
    pushRatio: 0,
  },
  0: {
    targetFlatX: null,
    yawOffsetDeg: 0,
    targetDistance: 1,
    targetPitch: -4,
    pushRatio: 0.52,
  },
  2: {
    // Office exit: tune the aim by editing targetFlatX directly.
    // 1944 is the raw SWF exitX; 2285 is roughly equivalent to the old +30deg test.
    targetFlatX: 2285,
    yawOffsetDeg: 0,
    targetDistance: 62,
    targetPitch: -4,
    pushRatio: 0,
  },
  3: {
    targetFlatX: null,
    yawOffsetDeg: 0,
    targetDistance: 1,
    targetPitch: -4,
    pushRatio: 0.52,
  },
  5: {
    targetFlatX: null,
    yawOffsetDeg: 0,
    targetDistance: 1,
    targetPitch: -4,
    pushRatio: 0.52,
  },
  6: {
    targetFlatX: null,
    yawOffsetDeg: 0,
    targetDistance: 1,
    targetPitch: -4,
    pushRatio: 0.52,
  },
  7: {
    targetFlatX: null,
    yawOffsetDeg: 0,
    targetDistance: 1,
    targetPitch: -4,
    pushRatio: 0.52,
  },
};

const HOVER_NOTE_FADE_MS = 900;
const ROOM_FLAVOR_LOCK_MS = 4200;
const FLASHLIGHT_REVEAL_INNER_RADIUS = 74;
const FLASHLIGHT_REVEAL_MID_RADIUS = 118;
const FLASHLIGHT_REVEAL_OUTER_RADIUS = 162;

const app = document.getElementById("app");
const backgroundStage = document.getElementById("background-stage");
const overlayStage = document.getElementById("overlay-stage");
const screenRoot = document.getElementById("screen-root");
const orientationOverlay = document.getElementById("orientation-overlay");

const state = {
  texts: new Map(),
  assets: new Map(),
  preloadedMedia: new Set(),
  failedMedia: new Set(),
  hasStartedMain: false,
  rooms: [],
  initialRoomId: 3,
  currentRoomId: 3,
  currentStep: 8,
  currentEnterStep: 0,
  isInRoom: false,
  outsideAmbientPath: "assets/sounds/exterior.mp3",
  isHelpActive: false,
  isMuted: false,
  isMobileUi: false,
  isPortraitMobile: false,
  isSidebarOpen: false,
  criticalMediaManifest: [],
  deferredMediaManifest: [],
  imageCache: new Map(),
};

let preloaderScreen;
let preloaderView;
let preloaderCounter;
let preloaderLogoOn;
let preloaderPercent = 0;
let flickerTimer = null;
let activeLandingFlickers = [];
let landingFogState = null;
let outsideScreenState = null;
let roomScreenState = null;
let roomEntryMapState = null;

init().catch((error) => {
  console.error(error);
  screenRoot.innerHTML = `<div style="position:absolute;inset:0;display:grid;place-items:center;color:white;font-family:Arial,sans-serif;">Failed to load phase 1.</div>`;
});

async function init() {
  resizeStages();
  window.addEventListener("resize", resizeStages);
  document.addEventListener("fullscreenchange", handleFullscreenChange);
  document.addEventListener("webkitfullscreenchange", handleFullscreenChange);
  document.addEventListener("contextmenu", (event) => {
    event.preventDefault();
  });
  document.addEventListener("dragstart", (event) => {
    event.preventDefault();
  });
  document.addEventListener("selectstart", (event) => {
    event.preventDefault();
  });
  renderPreloader();

  primeFallbackText();
  const xmlText = await fetch("xml/batess2_config.xml")
    .then((response) => response.text())
    .catch(() => null);
  if (xmlText) {
    parseConfig(xmlText);
  }

  const manifest = [...PRELOADER_MANIFEST, ...LANDING_MANIFEST];
  const total = manifest.length + state.criticalMediaManifest.length + 2;
  let loaded = 0;

  const stepLoaded = () => {
    loaded += 1;
    updatePreloaderCounter(Math.round((loaded / total) * 100));
  };

  stepLoaded();

  const fontPromise = Promise.all([
    document.fonts.load('24px "beon-medium"'),
    document.fonts.load('14px "helNeuLt-light"'),
    document.fonts.load('14px "helNeuLt-medium"'),
    document.fonts.load('15px "helNeuLt-bold"'),
  ]).finally(stepLoaded);

  const imagePromises = manifest.map(async ([key, src]) => {
    const image = await loadImage(src);
    state.assets.set(key, image);
    stepLoaded();
  });

  const criticalMediaPromise = preloadMediaManifest(state.criticalMediaManifest, {
    concurrency: state.isMobileUi ? 2 : 4,
    onItemComplete: stepLoaded,
  });

  await Promise.all([fontPromise, ...imagePromises, criticalMediaPromise]);
  void xmlText;
  await delay(150);
  startPreloaderFade();
  void preloadMediaManifest(state.deferredMediaManifest, {
    concurrency: state.isMobileUi ? 1 : 2,
  });
}

function resizeStages() {
  const width = window.innerWidth;
  const height = window.innerHeight;
  updateViewportMode(width, height);

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
    setOutsideSidebarOpen(state.isMobileUi ? state.isSidebarOpen : true);
  }
  if (roomScreenState) {
    applyRoomLayout(roomScreenState.stage);
    roomScreenState.three?.renderer.setSize(STAGE_WIDTH, STAGE_HEIGHT, false);
    applyModalLayout(roomScreenState.modal);
  }
}

function updateViewportMode(width = window.innerWidth, height = window.innerHeight) {
  const hasCoarsePointer = window.matchMedia("(pointer: coarse)").matches || navigator.maxTouchPoints > 0;
  const isMobileUi = (hasCoarsePointer && (width <= 1100 || height <= 860)) || width <= 720;
  const isPortraitMobile = isMobileUi && height > width;

  state.isMobileUi = isMobileUi;
  state.isPortraitMobile = isPortraitMobile;

  app.classList.toggle("is-mobile-ui", isMobileUi);
  app.classList.toggle("is-portrait-mobile", isPortraitMobile);
  app.classList.toggle("is-touch-ui", hasCoarsePointer);
  app.classList.toggle("is-fullscreen", isFullscreenActive());

  if (orientationOverlay) {
    orientationOverlay.hidden = !isPortraitMobile;
  }

  if (!isMobileUi) {
    state.isSidebarOpen = true;
  } else if (state.isSidebarOpen && isPortraitMobile) {
    state.isSidebarOpen = false;
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

  const fogLayerA = createImage("fog", "landing-fog-img fog-a");
  const fogLayerB = createImage("fog", "landing-fog-img fog-b");
  const fogLayerC = createImage("fog", "landing-fog-img fog-c");
  bg.append(fogLayerA, fogLayerB, fogLayerC);

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
      stopLandingFog();
      backgroundStage.replaceChildren();
      overlayScale.remove();
      landing.remove();
      renderOutside();
    }, 1300);
  };

  const setEnterHover = (active) => {
    enterButton.classList.toggle("is-hover", active);
  };

  enterButton.addEventListener("click", playIntro);
  enterButton.addEventListener("mouseenter", () => setEnterHover(true));
  enterButton.addEventListener("mouseleave", () => setEnterHover(false));
  enterButton.addEventListener("focus", () => setEnterHover(true));
  enterButton.addEventListener("blur", () => setEnterHover(false));
  bigEnterHit.addEventListener("click", playIntro);
  bigEnterHit.addEventListener("mouseenter", () => setEnterHover(true));
  bigEnterHit.addEventListener("mouseleave", () => setEnterHover(false));

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
    const width = window.innerWidth;
    const height = window.innerHeight;
    const uiScale = state.isMobileUi
      ? Math.min(width / 520, height / (state.isPortraitMobile ? 760 : 620), 1)
      : Math.min(width / STAGE_WIDTH, height / STAGE_HEIGHT);
    const top = state.isMobileUi
      ? Math.max(40, height * (state.isPortraitMobile ? 0.12 : 0.08))
      : height / 2.5 - 255;
    overlayScale.style.left = `${width / 2}px`;
    overlayScale.style.top = `${top}px`;
    overlayScale.style.transform = `scale(${uiScale})`;
  };

  positionOverlay();
  window.addEventListener("resize", positionOverlay);

  requestAnimationFrame(() => {
    sizeEnterButton(enterButton);
    sizeNeonButton(showPageButton, 70);
  });

  startLandingFog([fogLayerA, fogLayerB, fogLayerC]);

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
  if (roomScreenState?.rafId) {
    cancelAnimationFrame(roomScreenState.rafId);
  }
  disposeThreeRoom(roomScreenState);
  stopRoomAudio();
  roomScreenState = null;
  backgroundStage.replaceChildren();
  overlayStage.replaceChildren();
  screenRoot.replaceChildren();

  stopOutsideAudio();
  state.isInRoom = false;

  const outside = createEl("div", "base-screen outside-screen");
  const stage = createEl("div", "outside-stage");
  const fade = createEl("div", "outside-fade");
  const bg = createEl("div", "outside-bg");
  bg.style.visibility = "visible";
  const doorsWrap = createEl("div", "");
  const numbersWrap = createEl("div", "outside-door-numbers");
  const hallwayVideoA = document.createElement("video");
  hallwayVideoA.className = "outside-hallway-video";
  hallwayVideoA.preload = "auto";
  hallwayVideoA.playsInline = true;
  hallwayVideoA.muted = state.isMuted;
  const hallwayVideoB = document.createElement("video");
  hallwayVideoB.className = "outside-hallway-video";
  hallwayVideoB.preload = "auto";
  hallwayVideoB.playsInline = true;
  hallwayVideoB.muted = state.isMuted;
  const enterVideo = document.createElement("video");
  enterVideo.className = "outside-enter-video";
  enterVideo.preload = "auto";
  enterVideo.playsInline = true;
  enterVideo.muted = state.isMuted;
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
    button.addEventListener("click", () => {
      if (state.isMobileUi) {
        setOutsideSidebarOpen(false);
      }
      requestRoomMove(Number(button.dataset.roomId));
    });
  });
  sidebar.toggleButton?.addEventListener("click", () => {
    setOutsideSidebarOpen(!state.isSidebarOpen);
  });
  sidebar.helpButton.addEventListener("click", () => toggleOutsideHelp());
  sidebar.soundButton.addEventListener("click", () => toggleOutsideSound());
  sidebar.fullscreenButton?.addEventListener("click", () => toggleFullscreen());
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
  setOutsideSidebarOpen(state.isMobileUi ? false : true);
  syncMutedUi();
  syncFullscreenUi();

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

function applyRoomLayout(stage) {
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
    playbackStarted: createDeferred(),
    startedNotified: false,
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
  view.enterVideo.classList.remove("is-entering-room");
  view.bg.classList.remove("is-entering-room");
  view.bg.style.visibility = "visible";

  if (!keepZoomed) {
    view.bg.classList.remove("is-settled");
    void view.bg.offsetWidth;
    view.bg.classList.add("is-settled");
  }

  if (roomId === 0) {
    beginOutsideMapEnterMode(view);
  } else if (!state.isInRoom) {
    endOutsideMapEnterMode(view);
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
  if (view.sidebar.toggleButton) {
    view.sidebar.toggleButton.disabled = isBusy;
  }
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
  beginOutsideMapEnterMode(view);
  stopOutsideAudio();
  const roomVisualsPromise = preloadRoomVisuals(room);

  view.bg.classList.remove("is-settled");
  void view.bg.offsetWidth;
  view.bg.classList.add("is-entering-room");
  view.enterVideo.classList.add("is-visible");
  view.enterVideo.classList.add("is-entering-room");
  window.setTimeout(() => {
    if (outsideScreenState === view) {
      view.bg.style.visibility = "hidden";
    }
  }, 1200);
  const videoStarted = playVideoOnce(
    view.enterVideo,
    room.doorEnterPath,
    true,
    () => false,
    false,
    () => {
      if (outsideScreenState === view) {
        beginRoomEntryMapAnimation(view, room.id);
      }
    }
  ).catch(() => delay(4000));

  await Promise.race([videoStarted, delay(3500)]);
  await roomVisualsPromise;

  view.root.remove();
  outsideScreenState = null;
  renderRoom(room);
}

function beginOutsideMapEnterMode(view) {
  const map = view?.miniMap;
  if (!map) {
    return;
  }
  map.shell.classList.add("is-exit");
  map.viewport.classList.add("is-exit");
  map.glass.classList.add("is-exit");
  setMapArrowStateForMap(map, false, false, false, true, false);
}

function endOutsideMapEnterMode(view) {
  const map = view?.miniMap;
  if (!map) {
    return;
  }
  map.shell.classList.remove("is-exit");
  map.viewport.classList.remove("is-exit");
  map.glass.classList.remove("is-exit");
}

function renderRoom(room) {
  if (room?.id === 0 || room?.id === 2 || room?.id === 3 || room?.id === 4 || room?.id === 5 || room?.id === 6 || room?.id === 7) {
    renderInteractiveRoom(room);
    return;
  }
  renderRoomPlaceholder(room);
}

function renderRoomPlaceholder(room) {
  backgroundStage.replaceChildren();
  overlayStage.replaceChildren();
  screenRoot.replaceChildren();
  roomScreenState = null;

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

function renderInteractiveRoom(room) {
  backgroundStage.replaceChildren();
  overlayStage.replaceChildren();
  screenRoot.replaceChildren();
  stopRoomAudio();

  const screen = createEl("div", `base-screen room-screen ${room.id === 2 ? "office-room-screen" : "standard-room-screen"}`);
  const stage = createEl("div", "room-stage");
  const viewport = createEl("div", "room-viewport");
  const canvas = document.createElement("canvas");
  canvas.className = "room-panorama-canvas";
  canvas.width = STAGE_WIDTH;
  canvas.height = STAGE_HEIGHT;
  const flashCanvas = room.id === 4 || room.id === 7 ? document.createElement("canvas") : null;
  if (flashCanvas) {
    flashCanvas.className = "room-flashlight-canvas";
    flashCanvas.width = STAGE_WIDTH;
    flashCanvas.height = STAGE_HEIGHT;
  }
  const overlay = createEl("div", "room-overlay");
  const fade = createEl("div", "room-exit-fade");
  const hotspots = createEl("div", "room-hotspots");
  const note = createEl("div", "room-note");
  const exitButton = createEl("button", "room-exit-hotspot");
  exitButton.type = "button";
  const exitOut = makeOutsideImage("assets/bitmaps/rooms/exit_out.png", "room-exit-icon out");
  exitButton.append(exitOut);
  const sidebar = buildOutsideSidebar();
  const miniMap = buildOutsideMiniMap();

  const threeRoom = buildThreeRoom(room, canvas, flashCanvas);

  const projectedItems = [];
  room.items.forEach((item) => {
    if (shouldSuppressRoomItem(room.id, item.id)) {
      return;
    }
    if (!item.inRoomAssetPath) {
      return;
    }
    const useBakedVisual = usesBakedRoomVisual(room.id);
    const element = item.isActive ? createEl("button", "room-item") : createEl("div", "room-item is-passive");
    if (item.isActive) {
      element.type = "button";
    }
    element.dataset.itemId = item.id;
    if (item.useArc) {
      element.classList.add("is-arc");
    }
    if (item.type === "shadow") {
      element.classList.add("is-shadow");
    }
    if (useBakedVisual) {
      element.classList.add("is-hit-only");
    }

    if (!useBakedVisual) {
      const image = new Image();
      image.src = item.inRoomAssetPath;
      image.className = "room-item-image";
      image.draggable = false;
      element.append(image);
    }

    if (item.isActive) {
      element.addEventListener("mouseenter", () => {
        if (useBakedVisual) {
          setBakedRoomHoveredItem(item.id);
        }
        if (roomScreenState?.flavorLockUntil && performance.now() < roomScreenState.flavorLockUntil) {
          return;
        }
        showRoomNote(text(item.id));
      });
      element.addEventListener("mouseleave", () => {
        if (useBakedVisual) {
          setBakedRoomHoveredItem(null);
        }
        if (roomScreenState?.flavorLockUntil && performance.now() < roomScreenState.flavorLockUntil) {
          return;
        }
        showRoomNote("");
      });
      element.addEventListener("focus", () => {
        if (useBakedVisual) {
          setBakedRoomHoveredItem(item.id);
        }
        if (roomScreenState?.flavorLockUntil && performance.now() < roomScreenState.flavorLockUntil) {
          return;
        }
        showRoomNote(text(item.id));
      });
      element.addEventListener("blur", () => {
        if (useBakedVisual) {
          setBakedRoomHoveredItem(null);
        }
        if (roomScreenState?.flavorLockUntil && performance.now() < roomScreenState.flavorLockUntil) {
          return;
        }
        showRoomNote("");
      });
      element.addEventListener("click", (event) => {
        event.stopPropagation();
        openRoomItem(item);
      });
    }

    hotspots.append(element);
    const interactiveFlatX = getInteractiveFlatX(room.id, item.inRoomFlatX);
    projectedItems.push({
      item,
      element,
      center: flatToWorldPosition(interactiveFlatX, item.inRoomFlatY, item.defineRadius ?? 0.98),
      tangent: flatToWorldTangent(interactiveFlatX),
      width: item.inRoomAssetWidth,
      height: item.inRoomAssetHeight,
      fixedScale: room.id === 2 ? (item.id.includes("flyer") ? 2.55 : item.id.includes("ipad") ? 1.95 : null) : null,
      isOfficeActiveOverlay: room.id === 2 && item.isActive,
      useProjectedBox: room.id === 0 || room.id === 3 || room.id === 4 || room.id === 5 || room.id === 6 || room.id === 7,
    });
  });

  exitButton.addEventListener("click", () => beginRoomExit());

  overlay.append(note, fade);
  hotspots.append(exitButton);
  screen.append(sidebar.root);
  screen.append(miniMap.root);
  if (flashCanvas) {
    viewport.append(canvas, flashCanvas, hotspots, overlay);
  } else {
    viewport.append(canvas, hotspots, overlay);
  }
  stage.append(viewport);
  screen.append(stage);
  screenRoot.append(screen);

  roomScreenState = {
    room,
    root: screen,
    stage,
    viewport,
    canvas,
    flashCanvas,
    canvasContext: null,
    wallTextures: null,
    panoramaReady: true,
    note,
    fade,
    sidebar,
    miniMap,
    currentYRotation: room.id === 2 ? -14 : room.startYRotation,
    currentXRotation: 0,
    pointerX: 0,
    pointerY: 0,
    isDragging: false,
    dragStartX: 0,
    dragStartY: 0,
    dragStartYaw: room.id === 2 ? -14 : room.startYRotation,
    dragStartPitch: 0,
    rafId: 0,
    audio: null,
    itemAudio: null,
    playingItemId: null,
    modal: null,
    noteTimer: null,
    noteHideTimer: null,
    flavorLockUntil: 0,
    projectedItems,
    exitButton,
    focalLength: (STAGE_WIDTH * 0.5) / Math.tan(degToRad(55 * 0.5)),
    roomRadius: 150,
    cameraHeight: room.cameraHeight,
    cameraDistance: 1,
    targetCameraDistance: 1,
    currentExitPush: 0,
    three: threeRoom,
    pitchMin: room.id === 0 ? -28 : room.id === 2 ? -22.5 : room.id === 3 ? -28 : room.id === 4 ? -22 : room.id === 5 ? -28 : room.id === 6 ? -28 : room.id === 7 ? -28 : room.xRotationMin,
    pitchMax: room.id === 0 ? 8 : room.id === 2 ? 12 : room.id === 3 ? 8 : room.id === 4 ? 16 : room.id === 5 ? 8 : room.id === 6 ? 8 : room.id === 7 ? 8 : room.xRotationMax,
    mapEnterTimers: [],
    isExiting: false,
    exitState: null,
    exitFadeTimer: null,
    exitSoundPlayed: false,
    exitSoundAudio: null,
    exitSoundLastPlayedAt: 0,
    exitVisible: false,
    pendingTargetRoomId: null,
    roomLighting: room.id === 4 || room.id === 7 ? {
      introActive: true,
      introCount: 0,
      lightChange: 1,
      lightChangeOffset: 0.08,
      pointerScreenX: STAGE_WIDTH * 0.5,
      pointerScreenY: STAGE_HEIGHT * 0.5,
    } : null,
  };

  applyRoomLayout(stage);
  sidebar.roomButtons.forEach((button) => {
    button.addEventListener("click", () => {
      const targetRoomId = Number(button.dataset.roomId);
      if (targetRoomId === room.id) {
        return;
      }
      beginRoomExit(targetRoomId);
    });
  });
  sidebar.soundButton.addEventListener("click", () => toggleRoomSound());
  sidebar.helpButton.addEventListener("click", () => {});
  sidebar.toggleButton?.addEventListener("click", () => {
    sidebar.root.classList.toggle("is-open");
    sidebar.toggleButton.classList.toggle("is-active");
  });
  sidebar.root.classList.add("is-open");
  sidebar.root.classList.add("is-room-sidebar");
  sidebar.roomButtons.forEach((button) => {
    const active = Number(button.dataset.roomId) === room.id;
    button.disabled = active;
    button.parentElement?.classList.toggle("is-active", active);
    button.parentElement?.classList.toggle("is-in-room", active);
  });
  sidebar.fullscreenButton?.addEventListener("click", () => toggleFullscreen());
  applyMapPosition({ miniMap }, state.currentStep, 0);
  miniMap.shell.classList.add("is-exit");
  miniMap.viewport.classList.add("is-exit");
  miniMap.glass.classList.add("is-exit");
  setMapArrowStateForMap(miniMap, false, false, false, true, false);
  miniMap.downButton.addEventListener("click", () => beginRoomExit());
  syncMutedUi();
  syncFullscreenUi();
  applyRoomEntryMapFinal(roomScreenState);
  bindRoomPointer(roomScreenState);
  updateRoomLightingState(roomScreenState);
  updateRoomPanorama(roomScreenState);
  playRoomAmbient(room);
  prewarmRoomItemHover(roomScreenState);
  screen.classList.add("is-visible");
  prewarmRoomHoverExperience(roomScreenState);
  window.setTimeout(() => {
    if (roomScreenState?.root === screen) {
      showRoomFlavor(room);
    }
  }, 900);
}

function prewarmRoomHoverExperience(view) {
  if (!view?.note || !view?.viewport) {
    return;
  }
  const firstCopy = view.room.items
    .filter((item) => item.isActive)
    .map((item) => text(item.id))
    .find(Boolean);
  if (!firstCopy) {
    return;
  }
  const warmNote = createEl("div", "room-note is-visible");
  warmNote.style.visibility = "hidden";
  warmNote.style.left = "-9999px";
  warmNote.style.top = "-9999px";
  warmNote.style.transform = "none";
  warmNote.innerHTML = firstCopy.replace(/<br\s*\/?>/gi, "<br>");
  view.viewport.append(warmNote);
  void warmNote.offsetWidth;
  requestAnimationFrame(() => warmNote.remove());
}

function prewarmRoomItemHover(view) {
  const firstActive = view?.projectedItems?.find((entry) => entry.item?.isActive && entry.element);
  if (!firstActive) {
    return;
  }
  const { item, element } = firstActive;

  if (usesBakedRoomVisual(view.room.id)) {
    setBakedRoomHoveredItem(item.id);
    updateRoomPanorama(view);
    setBakedRoomHoveredItem(null);
    updateRoomPanorama(view);
  }

  element.classList.add("is-hovering");
  void element.offsetWidth;
  element.classList.remove("is-hovering");
}

function bindRoomPointer(view) {
  const onMouseMove = (event) => {
    if (state.isMobileUi || view.modal) {
      return;
    }
    const bounds = view.viewport.getBoundingClientRect();
    view.pointerX = event.clientX - (bounds.left + bounds.width * 0.5);
    view.pointerY = event.clientY - (bounds.top + bounds.height * 0.5);
  };

  const onTouchStart = (event) => {
    if (view.modal) {
      return;
    }
    const touch = event.touches[0];
    view.isDragging = true;
    view.dragStartX = touch.clientX;
    view.dragStartY = touch.clientY;
    view.dragStartYaw = view.currentYRotation;
    view.dragStartPitch = view.currentXRotation;
  };

  const onTouchMove = (event) => {
    if (!view.isDragging || view.modal) {
      return;
    }
    event.preventDefault();
    const touch = event.touches[0];
    const deltaX = touch.clientX - view.dragStartX;
    const deltaY = touch.clientY - view.dragStartY;
    const pitchSpan = view.pitchMax - view.pitchMin;
    const nextYaw = view.dragStartYaw - deltaX * 0.32;
    view.currentYRotation = view.room.id === 2
      ? clampNumber(nextYaw, view.room.yRotationMin, view.room.yRotationMax)
      : wrapDegrees(nextYaw);
    view.currentXRotation = clampNumber(
      view.dragStartPitch + deltaY * (pitchSpan / 360),
      view.pitchMin,
      view.pitchMax
    );
  };

  const onTouchEnd = () => {
    view.isDragging = false;
  };

  const onViewportClick = (event) => {
    if (view.modal || view.isExiting || !view.exitVisible) {
      return;
    }
    const target = event.target;
    if (target instanceof Element && target.closest(".room-item")) {
      return;
    }
    beginRoomExit();
  };

  view.viewport.addEventListener("mousemove", onMouseMove);
  view.viewport.addEventListener("touchstart", onTouchStart, { passive: true });
  view.viewport.addEventListener("touchmove", onTouchMove, { passive: false });
  view.viewport.addEventListener("touchend", onTouchEnd);
  view.viewport.addEventListener("touchcancel", onTouchEnd);
  view.viewport.addEventListener("click", onViewportClick);

  const tick = () => {
    if (!roomScreenState || roomScreenState !== view) {
      return;
    }
    if (view.isExiting) {
      updateRoomLightingState(view);
      updateRoomExit(view);
    } else if (!view.modal) {
      if (!state.isMobileUi) {
        view.currentXRotation = clampNumber(
          view.currentXRotation - 0.5 * view.pointerY / 800,
          view.pitchMin,
          view.pitchMax
        );
        const nextYaw = view.currentYRotation + 0.5 * view.pointerX / 800;
        view.currentYRotation = view.room.id === 2
          ? clampNumber(nextYaw, view.room.yRotationMin, view.room.yRotationMax)
          : wrapDegrees(nextYaw);
      }
      updateRoomLightingState(view);
      updateRoomPanorama(view);
    }
    view.rafId = requestAnimationFrame(tick);
  };

  view.rafId = requestAnimationFrame(tick);
}

function updateRoomPanorama(view) {
  if (view.three) {
    updateThreeRoom(view);
    updateProjectedHotspots(view);
    return;
  }

  if (!view.canvasContext || !view.panoramaReady || !view.wallTextures?.length) {
    return;
  }

  const ctx = view.canvasContext;
  const focal = view.focalLength;
  const halfWidth = STAGE_WIDTH * 0.5;
  const halfHeight = STAGE_HEIGHT * 0.5;
  const sliceWidth = state.isMobileUi ? 3 : 2;
  const camera = getRoomCameraState(view);

  ctx.clearRect(0, 0, STAGE_WIDTH, STAGE_HEIGHT);

  for (let screenX = 0; screenX < STAGE_WIDTH; screenX += sliceWidth) {
    const midX = screenX + sliceWidth * 0.5;
    const azimuth = camera.yaw + Math.atan((midX - halfWidth) / focal);
    const hit = intersectRoomCylinder(camera.x, camera.z, azimuth, view.roomRadius);
    if (!hit) {
      continue;
    }
    const sample = resolveWallSample(view.wallTextures, hit.angleDeg);
    if (!sample) {
      continue;
    }

    const topElevation = -camera.pitch + Math.atan((halfHeight - 0) / focal);
    const bottomElevation = -camera.pitch + Math.atan((halfHeight - STAGE_HEIGHT) / focal);
    const sourceTop = worldYToFlatY(camera.y + hit.distance * Math.tan(topElevation));
    const sourceBottom = worldYToFlatY(camera.y + hit.distance * Math.tan(bottomElevation));
    const top = clampNumber(Math.min(sourceTop, sourceBottom), 0, sample.image.naturalHeight - 1);
    const bottom = clampNumber(Math.max(sourceTop, sourceBottom), 0, sample.image.naturalHeight);
    const drawHeight = bottom - top;
    if (drawHeight <= 0.5) {
      continue;
    }

    const sourceX = clampNumber(sample.sourceX, 0, sample.image.naturalWidth - 1);
    ctx.drawImage(sample.image, sourceX, top, 1, drawHeight, screenX, 0, sliceWidth, STAGE_HEIGHT);
  }

  updateProjectedHotspots(view);
}

function updateRoomLightingState(view) {
  if ((view.room.id !== 4 && view.room.id !== 7) || !view.roomLighting) {
    return;
  }
  const lighting = view.roomLighting;
  lighting.pointerScreenX = STAGE_WIDTH * 0.5 + view.pointerX;
  lighting.pointerScreenY = STAGE_HEIGHT * 0.5 + view.pointerY;
  if (lighting.introActive) {
    if (lighting.introCount > 2 && lighting.lightChange === 0) {
      if (lighting.introCount > 10) {
        lighting.introActive = false;
      }
    } else if (lighting.introCount > 0) {
      if (lighting.introCount > 1) {
        lighting.lightChangeOffset = 0.12;
      }
      lighting.lightChange += Math.random() * 0.2 - lighting.lightChangeOffset;
      lighting.lightChange = clampNumber(lighting.lightChange, 0, 1);
    }
    lighting.introCount += 1;
  }
}

function getPointerLightFlatPosition(view) {
  const camera = getRoomCameraState(view);
  const screenX = STAGE_WIDTH * 0.5 + view.pointerX;
  const screenY = STAGE_HEIGHT * 0.5 + view.pointerY;
  const azimuth = camera.yaw + Math.atan((screenX - STAGE_WIDTH * 0.5) / view.focalLength);
  const hit = intersectRoomCylinder(camera.x, camera.z, azimuth, view.roomRadius);
  if (!hit) {
    return null;
  }

  const elevation = -camera.pitch + Math.atan((STAGE_HEIGHT * 0.5 - screenY) / view.focalLength);
  const worldY = camera.y + hit.distance * Math.tan(elevation);
  const worldAngleSigned = radToDeg(Math.atan2(hit.z, hit.x));
  const flatX = positiveMod(4096 - (((worldAngleSigned + 180) / 360) * 4096), 4096);
  const flatY = clampNumber(worldYToFlatY(worldY), 0, 1024);

  return { flatX, flatY };
}

function updateRoomExit(view) {
  const exitState = view.exitState ?? buildRoomExitState(view);
  view.exitState = exitState;
  const distance = shortestAngularDelta(exitState.targetYaw, view.currentYRotation);
  view.currentYRotation = wrapDegrees(view.currentYRotation + distance * 0.04);
  view.targetCameraDistance += (exitState.targetDistance - view.targetCameraDistance) * 0.02;
  view.currentXRotation += (exitState.targetPitch - view.currentXRotation) * 0.01;
  view.currentExitPush += ((exitState.pushRatio ?? 0) - view.currentExitPush) * 0.02;
  view.exitVisible = true;
  if (view.three?.exitMesh) {
    view.three.exitMesh.visible = true;
  }
  if (view.three?.flashExitMesh) {
    view.three.flashExitMesh.visible = true;
  }
  if (view.audio) {
    const nextVolume = Math.max(0, view.audio.volume - 0.01);
    view.audio.volume = nextVolume;
  }
  updateRoomPanorama(view);
}

function buildRoomExitState(view) {
  const exitTuning = ROOM_EXIT_TUNING[view.room.id] ?? ROOM_EXIT_TUNING.default;
  let targetYaw;
  let targetPosition = null;
  if (view.room.id === 2 && view.three?.exitMesh) {
    const angleDeg = radToDeg(Math.atan2(view.three.exitMesh.position.z, view.three.exitMesh.position.x));
    targetYaw = 270 - angleDeg;
    targetPosition = view.three.exitMesh.position.clone();
  } else {
    const targetFlatX = exitTuning.targetFlatX ?? view.room.exitX;
    targetYaw = ((targetFlatX / 4096) * 360 - 90) + (exitTuning.yawOffsetDeg ?? 0);
    if ((view.room.id === 0 || view.room.id === 3 || view.room.id === 4 || view.room.id === 5 || view.room.id === 6 || view.room.id === 7) && view.three?.exitMesh) {
      targetPosition = view.three.exitMesh.position.clone();
    }
  }
  return {
    targetYaw,
    targetDistance: exitTuning.targetDistance ?? 92,
    targetPitch: exitTuning.targetPitch ?? -4,
    pushRatio: exitTuning.pushRatio ?? 0,
    targetPosition,
  };
}

function buildThreeRoom(room, canvas, flashCanvas = null) {
  const renderer = new THREE.WebGLRenderer({
    canvas,
    antialias: true,
    alpha: false,
    powerPreference: "high-performance",
  });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
  renderer.setSize(STAGE_WIDTH, STAGE_HEIGHT, false);
  renderer.outputColorSpace = THREE.SRGBColorSpace;

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(55, STAGE_WIDTH / STAGE_HEIGHT, 0.1, 1000);
  camera.rotation.order = "YXZ";

  const wallTextureSources = room.bgObjects.map((textureInfo, index) => ({
    ...textureInfo,
    flashPath: room.bgFlashLightObjects?.[index]?.path ?? "",
  }));
  const buildWalls = (targetScene, targetRenderer, {
    useFlashTextures = false,
    includeItems = true,
    disableDynamicLighting = false,
  } = {}) => wallTextureSources.map((sourceInfo, wallIndex) => {
    const textureInfo = useFlashTextures && sourceInfo.flashPath
      ? { ...sourceInfo, path: sourceInfo.flashPath }
      : sourceInfo;
    const composite = usesBakedRoomVisual(room.id)
      ? createCompositeWallTexture(room, textureInfo, wallIndex, { includeItems, disableDynamicLighting })
      : null;
    const texture = composite
      ? composite.texture
      : createTextureFromImage(getCachedImage(textureInfo.path) || state.assets.get(textureInfo.path) || null, textureInfo.path);
    texture.colorSpace = THREE.SRGBColorSpace;
    texture.minFilter = THREE.LinearFilter;
    texture.magFilter = THREE.LinearFilter;
    texture.generateMipmaps = false;
    const geometry = createCurvedPlaneGeometry(150, 300, 64, 16, 0.5);
    const material = new THREE.MeshBasicMaterial({
      map: texture,
      side: THREE.BackSide,
    });
    if (composite) {
      composite.attachRenderer(targetRenderer);
      composite.attachMaterial(material);
    }
    const mesh = new THREE.Mesh(geometry, material);
    mesh.rotation.y = degToRad(sourceInfo.rotationY);
    mesh.rotation.z = Math.PI;
    targetScene.add(mesh);
    return { mesh, composite };
  });

  const walls = buildWalls(scene, renderer, {
    useFlashTextures: false,
    includeItems: room.id !== 4 && room.id !== 7,
    disableDynamicLighting: true,
  });

  let flashRenderer = null;
  let flashScene = null;
  let flashCamera = null;
  let flashWalls = null;
  if ((room.id === 4 || room.id === 7) && flashCanvas) {
    flashRenderer = new THREE.WebGLRenderer({
      canvas: flashCanvas,
      antialias: true,
      alpha: true,
      powerPreference: "high-performance",
    });
    flashRenderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    flashRenderer.setSize(STAGE_WIDTH, STAGE_HEIGHT, false);
    flashRenderer.outputColorSpace = THREE.SRGBColorSpace;
    flashScene = new THREE.Scene();
    flashCamera = new THREE.PerspectiveCamera(55, STAGE_WIDTH / STAGE_HEIGHT, 0.1, 1000);
    flashCamera.rotation.order = "YXZ";
    flashWalls = buildWalls(flashScene, flashRenderer, {
      useFlashTextures: true,
      includeItems: true,
      disableDynamicLighting: true,
    });
  }

  let exitMesh = null;
  let flashExitMesh = null;
  if (room.id === 0 || room.id === 2 || room.id === 3 || room.id === 4 || room.id === 5 || room.id === 6 || room.id === 7) {
    const exitTexture = createTextureFromImage(getCachedImage("assets/bitmaps/rooms/exit_out.png"), "assets/bitmaps/rooms/exit_out.png");
    exitTexture.colorSpace = THREE.SRGBColorSpace;
    exitTexture.minFilter = THREE.LinearFilter;
    exitTexture.magFilter = THREE.LinearFilter;
    exitTexture.generateMipmaps = false;
    const exitGeometry = new THREE.PlaneGeometry(32, 32);
    const exitMaterial = new THREE.MeshBasicMaterial({
      map: exitTexture,
      transparent: true,
      side: THREE.DoubleSide,
    });
    exitMesh = new THREE.Mesh(exitGeometry, exitMaterial);
    const exitVisualFlatX = getExitVisualFlatX(room.id, room.exitX);
    const exitPosition = flatToWorldPosition(exitVisualFlatX, room.exitY, 0.98);
    const exitFlippedFlatX = 4096 - exitVisualFlatX;
    const exitAngleFromSourceDegrees = (exitFlippedFlatX / 4096) * 360 - 180;
    const exitYRotation = 90 - exitAngleFromSourceDegrees;
    exitMesh.position.set(exitPosition.x, exitPosition.y, exitPosition.z);
    exitMesh.rotation.y = degToRad(exitYRotation + 180);
    exitMesh.visible = false;
    scene.add(exitMesh);
    if (flashScene && (room.id === 4 || room.id === 7)) {
      const flashExitMaterial = new THREE.MeshBasicMaterial({
        map: exitTexture,
        transparent: true,
        side: THREE.DoubleSide,
      });
      flashExitMesh = new THREE.Mesh(exitGeometry.clone(), flashExitMaterial);
      flashExitMesh.position.copy(exitMesh.position);
      flashExitMesh.rotation.copy(exitMesh.rotation);
      flashExitMesh.visible = false;
      flashScene.add(flashExitMesh);
    }
  }

  return { renderer, scene, camera, walls, exitMesh, flashExitMesh, flashRenderer, flashScene, flashCamera, flashWalls };
}

function createCompositeWallTexture(room, textureInfo, wallIndex, options = {}) {
  const canvas = document.createElement("canvas");
  canvas.width = 2048;
  canvas.height = 1024;
  const ctx = canvas.getContext("2d");
  const texture = new THREE.CanvasTexture(canvas);
  let hoveredItemId = null;
  const renderedStates = new Map();
  let dynamicLightingTexture = null;
  let attachedMaterial = null;
  let attachedRenderer = null;
  texture.colorSpace = THREE.SRGBColorSpace;
  texture.minFilter = THREE.LinearFilter;
  texture.magFilter = THREE.LinearFilter;
  texture.generateMipmaps = false;

  const baseImage = new Image();
  const flashImage = new Image();
  const includeItems = options.includeItems ?? true;
  const disableDynamicLighting = options.disableDynamicLighting ?? false;
  const usesMirroredBakedPlacement = usesBakedRoomVisual(room.id);
  const usesDynamicFlashlightLighting = !disableDynamicLighting && (room.id === 4 || room.id === 7) && Boolean(textureInfo.flashPath);
  const segmentItems = (includeItems ? room.items : [])
    .filter((item) => !shouldSuppressRoomItem(room.id, item.id))
    .filter((item) => item.inRoomAssetPath)
    .filter((item) => {
      const x = item.inRoomFlatX;
      if (!usesMirroredBakedPlacement) {
        return wallIndex === 0 ? x < 2048 : x >= 2048;
      }
      const seamPadding = item.inRoomAssetWidth * (2048 / (Math.PI * 150)) * 0.75;
      const overlapsLeftWall = x < 2048 + seamPadding;
      const overlapsRightWall = x >= 2048 - seamPadding;
      return wallIndex === 0 ? overlapsLeftWall : overlapsRightWall;
    })
    .sort((a, b) => {
      const aShadow = a.type === "shadow" ? 0 : 1;
      const bShadow = b.type === "shadow" ? 0 : 1;
      return aShadow - bShadow;
    });

  const itemImages = segmentItems.map((item) => {
    const image = getCachedImage(item.inRoomAssetPath) || new Image();
    if (!image.src) {
      image.src = item.inRoomAssetPath;
    }
    image.onload = () => {
      clearStateTextures();
      primeStates();
    };
    return { item, image };
  });

  const cachedBase = getCachedImage(textureInfo.path);
  if (cachedBase) {
    baseImage.src = cachedBase.src;
  }
  baseImage.onload = () => {
    clearStateTextures();
    primeStates();
  };
  if (!baseImage.src) {
    baseImage.src = textureInfo.path;
  }
  const cachedFlash = textureInfo.flashPath ? getCachedImage(textureInfo.flashPath) : null;
  if (cachedFlash) {
    flashImage.src = cachedFlash.src;
  }
  flashImage.onload = () => {
    clearStateTextures();
    primeStates();
  };
  if (textureInfo.flashPath && !flashImage.src) {
    flashImage.src = textureInfo.flashPath;
  }

  function clearStateTextures() {
    renderedStates.forEach((stateTexture) => stateTexture.dispose());
    renderedStates.clear();
  }

  function renderStateCanvas(targetHoveredItemId = null) {
    if (!baseImage.complete) {
      return null;
    }
    const stateCanvas = document.createElement("canvas");
    stateCanvas.width = canvas.width;
    stateCanvas.height = canvas.height;
    const stateCtx = stateCanvas.getContext("2d");
    stateCtx.clearRect(0, 0, canvas.width, canvas.height);
    stateCtx.drawImage(baseImage, 0, 0, canvas.width, canvas.height);
    const pxPerWorldX = canvas.width / (Math.PI * 150);
    const pxPerWorldY = canvas.height / 300;
    const lighting = roomScreenState?.room?.id === room.id ? roomScreenState.roomLighting : null;
    const introLight = usesDynamicFlashlightLighting && lighting?.introActive ? lighting.lightChange : 0;

    if (usesDynamicFlashlightLighting && flashImage.complete && (introLight > 0 || revealLight?.flatX != null)) {
      stateCtx.save();
      if (introLight > 0) {
        stateCtx.globalAlpha = introLight;
        stateCtx.drawImage(flashImage, 0, 0, canvas.width, canvas.height);
      }
      stateCtx.restore();
    }

    itemImages.forEach(({ item, image }) => {
      if (!image.complete) {
        return;
      }
      const localX = wallIndex === 0 ? item.inRoomFlatX : item.inRoomFlatX - 2048;
      const drawWidth = item.inRoomAssetWidth * pxPerWorldX;
      const drawHeight = item.inRoomAssetHeight * pxPerWorldY;
      const mirroredLocalX = usesMirroredBakedPlacement ? canvas.width - localX : localX;
      const drawX = mirroredLocalX - drawWidth * 0.5;
      const drawY = item.inRoomFlatY - drawHeight * 0.5;
      const hovered = usesMirroredBakedPlacement && item.isActive && item.id === targetHoveredItemId;
      const shouldRenderItem = !usesDynamicFlashlightLighting || introLight > 0;
      if (!shouldRenderItem) {
        return;
      }
      if (usesMirroredBakedPlacement) {
        const drawMirroredImage = (targetX) => {
          stateCtx.save();
          stateCtx.globalAlpha = 1;
          stateCtx.translate(targetX + drawWidth * 0.5, 0);
          stateCtx.scale(-1, 1);
          if (hovered) {
            const glow = numberToRgba(item.overColor || 7911637, item.overAlpha || 0.8);
            stateCtx.shadowColor = glow;
            stateCtx.shadowBlur = 18;
            stateCtx.drawImage(image, -drawWidth * 0.5, drawY, drawWidth, drawHeight);
            stateCtx.shadowBlur = 10;
            stateCtx.drawImage(image, -drawWidth * 0.5, drawY, drawWidth, drawHeight);
            stateCtx.shadowBlur = 0;
          }
          stateCtx.drawImage(image, -drawWidth * 0.5, drawY, drawWidth, drawHeight);
          stateCtx.restore();
        };

        drawMirroredImage(drawX);
        if (room.id !== 3) {
          if (drawX < 0) {
            drawMirroredImage(drawX + canvas.width);
          } else if (drawX + drawWidth > canvas.width) {
            drawMirroredImage(drawX - canvas.width);
          }
        }
      } else {
        stateCtx.drawImage(image, drawX, drawY, drawWidth, drawHeight);
      }
    });

    return stateCanvas;
  }

  function createStateTexture(targetHoveredItemId = null) {
    const renderedCanvas = renderStateCanvas(targetHoveredItemId);
    if (!renderedCanvas) {
      return null;
    }
    const stateTexture = new THREE.CanvasTexture(renderedCanvas);
    stateTexture.colorSpace = THREE.SRGBColorSpace;
    stateTexture.minFilter = THREE.LinearFilter;
    stateTexture.magFilter = THREE.LinearFilter;
    stateTexture.generateMipmaps = false;
    return stateTexture;
  }

  function getStateTexture(targetHoveredItemId = null) {
    if (usesDynamicFlashlightLighting) {
      const renderedCanvas = renderStateCanvas(targetHoveredItemId);
      if (!renderedCanvas) {
        return null;
      }
      if (!dynamicLightingTexture) {
        dynamicLightingTexture = new THREE.CanvasTexture(renderedCanvas);
        dynamicLightingTexture.colorSpace = THREE.SRGBColorSpace;
        dynamicLightingTexture.minFilter = THREE.LinearFilter;
        dynamicLightingTexture.magFilter = THREE.LinearFilter;
        dynamicLightingTexture.generateMipmaps = false;
        attachedRenderer?.initTexture?.(dynamicLightingTexture);
      } else {
        dynamicLightingTexture.image = renderedCanvas;
        dynamicLightingTexture.needsUpdate = true;
      }
      return dynamicLightingTexture;
    }
    const stateKey = `${targetHoveredItemId || "__base__"}`;
    if (!renderedStates.has(stateKey)) {
      const stateTexture = createStateTexture(targetHoveredItemId);
      if (!stateTexture) {
        return null;
      }
      attachedRenderer?.initTexture?.(stateTexture);
      renderedStates.set(stateKey, stateTexture);
    }
    return renderedStates.get(stateKey);
  }

  function applyCurrentState() {
    const activeTexture = getStateTexture(hoveredItemId);
    if (!activeTexture) {
      return;
    }
    if (attachedMaterial) {
      attachedMaterial.map = activeTexture;
      attachedMaterial.needsUpdate = true;
    } else {
      const sourceCanvas = activeTexture.image;
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      ctx.drawImage(sourceCanvas, 0, 0);
      texture.needsUpdate = true;
    }
  }

  function primeStates() {
    const activeIds = itemImages
      .map(({ item }) => item)
      .filter((item) => usesMirroredBakedPlacement && item.isActive)
      .map((item) => item.id);
    getStateTexture(null);
    activeIds.forEach((itemId) => {
      getStateTexture(itemId);
    });
    // Dark rooms use a live flashlight composite texture instead of cached
    // per-state textures. Pre-render the hovered variants once up front so the
    // first real hover doesn't incur a visible canvas/shadow-blur hitch.
    if (usesDynamicFlashlightLighting) {
      activeIds.forEach((itemId) => {
        renderStateCanvas(itemId);
      });
    }
    applyCurrentState();
  }

  return {
    texture,
    attachRenderer(renderer) {
      attachedRenderer = renderer;
      renderedStates.forEach((stateTexture) => attachedRenderer?.initTexture?.(stateTexture));
    },
    attachMaterial(material) {
      attachedMaterial = material;
      applyCurrentState();
    },
    setHoveredItem(itemId) {
      if (hoveredItemId === itemId) {
        return;
      }
      hoveredItemId = itemId;
      applyCurrentState();
    },
  };
}

function updateThreeRoom(view) {
  const three = view.three;
  if (!three) {
    return;
  }
  const { camera, renderer, scene } = three;
  const yaw = degToRad(view.currentYRotation);
  const pitch = degToRad(view.currentXRotation);
  camera.position.set(
    -Math.sin(yaw) * view.targetCameraDistance,
    view.cameraHeight,
    -Math.cos(yaw) * view.targetCameraDistance
  );
  if (view.isExiting && view.exitState?.targetPosition && view.currentExitPush > 0) {
    camera.position.lerp(view.exitState.targetPosition, view.currentExitPush);
  }
  camera.rotation.set(pitch, Math.PI - yaw, 0, "YXZ");
  camera.updateMatrixWorld(true);
  renderer.render(scene, camera);
  if (three.flashRenderer && view.flashCanvas && three.flashScene && three.flashCamera) {
    const { flashRenderer, flashScene, flashCamera } = three;
    flashCamera.position.copy(camera.position);
    flashCamera.rotation.copy(camera.rotation);
    flashCamera.updateMatrixWorld(true);
    flashRenderer.render(flashScene, flashCamera);
    const lighting = view.roomLighting;
    if (lighting?.introActive) {
      view.flashCanvas.style.opacity = `${lighting.lightChange}`;
      view.flashCanvas.style.webkitMaskImage = "none";
      view.flashCanvas.style.maskImage = "none";
    } else {
      const mask = `radial-gradient(circle at ${lighting?.pointerScreenX ?? STAGE_WIDTH * 0.5}px ${lighting?.pointerScreenY ?? STAGE_HEIGHT * 0.5}px, rgba(255,255,255,1) 0px, rgba(255,255,255,1) ${FLASHLIGHT_REVEAL_INNER_RADIUS}px, rgba(255,255,255,0.52) ${FLASHLIGHT_REVEAL_MID_RADIUS}px, rgba(255,255,255,0) ${FLASHLIGHT_REVEAL_OUTER_RADIUS}px)`;
      view.flashCanvas.style.opacity = "1";
      view.flashCanvas.style.webkitMaskImage = mask;
      view.flashCanvas.style.maskImage = mask;
    }
  }
}

function createCurvedPlaneGeometry(radius, height, segmentsW, segmentsH, portionOfCircle) {
  const geometry = new THREE.BufferGeometry();
  const positions = [];
  const uvs = [];
  const indices = [];
  const revolutionAngleDelta = (2 * Math.PI / segmentsW) * portionOfCircle;

  for (let yi = 0; yi <= segmentsH; yi += 1) {
    for (let xi = 0; xi <= segmentsW; xi += 1) {
      const revolutionAngle = revolutionAngleDelta * xi;
      const x = radius * Math.cos(revolutionAngle);
      const y = (yi / segmentsH - 0.5) * height;
      const z = radius * Math.sin(revolutionAngle);
      positions.push(x, y, z);
      uvs.push(xi / segmentsW, 1 - yi / segmentsH);

      if (xi < segmentsW && yi < segmentsH) {
        const base = xi + yi * (segmentsW + 1);
        const nextRow = base + segmentsW + 1;
        indices.push(base, nextRow, nextRow + 1);
        indices.push(base, nextRow + 1, base + 1);
      }
    }
  }

  geometry.setAttribute("position", new THREE.Float32BufferAttribute(positions, 3));
  geometry.setAttribute("uv", new THREE.Float32BufferAttribute(uvs, 2));
  geometry.setIndex(indices);
  geometry.computeVertexNormals();
  return geometry;
}

function disposeThreeRoom(view) {
  if (!view?.three) {
    return;
  }
  view.three.walls?.forEach((mesh) => {
    const wallMesh = mesh.mesh ?? mesh;
    wallMesh.geometry?.dispose?.();
    wallMesh.material?.map?.dispose?.();
    wallMesh.material?.dispose?.();
  });
  view.three.flashWalls?.forEach((mesh) => {
    const wallMesh = mesh.mesh ?? mesh;
    wallMesh.geometry?.dispose?.();
    wallMesh.material?.map?.dispose?.();
    wallMesh.material?.dispose?.();
  });
  view.three.exitMesh?.geometry?.dispose?.();
  view.three.exitMesh?.material?.map?.dispose?.();
  view.three.exitMesh?.material?.dispose?.();
  view.three.flashExitMesh?.geometry?.dispose?.();
  view.three.flashExitMesh?.material?.dispose?.();
  view.three.flashRenderer?.dispose?.();
  view.three.renderer?.dispose?.();
  view.three = null;
}

function updateProjectedHotspots(view) {
  view.projectedItems.forEach(({ element, center, tangent, width, height, item, fixedScale, isOfficeActiveOverlay, useProjectedBox }) => {
    const halfWidth = width * 0.5;
    const halfHeight = height * 0.5;
    const centerPoint = projectCartesianPoint(view, center.x, center.y, center.z);
    if (!centerPoint) {
      element.style.display = "none";
      return;
    }

    const leftPoint = projectCartesianPoint(view, center.x - tangent.x * halfWidth, center.y, center.z - tangent.z * halfWidth);
    const rightPoint = projectCartesianPoint(view, center.x + tangent.x * halfWidth, center.y, center.z + tangent.z * halfWidth);
    const topPoint = projectCartesianPoint(view, center.x, center.y - halfHeight, center.z);
    const bottomPoint = projectCartesianPoint(view, center.x, center.y + halfHeight, center.z);
    if (!leftPoint || !rightPoint || !topPoint || !bottomPoint) {
      element.style.display = "none";
      return;
    }

    const scaleX = Math.abs(rightPoint.x - leftPoint.x) / width;
    const scaleY = Math.abs(bottomPoint.y - topPoint.y) / height;
    const sampledScale = clampNumber((scaleX + scaleY) * 0.5, 0.12, 6);
    const displayScale = fixedScale ?? sampledScale;
    const sampledWidth = Math.max(8, Math.abs(rightPoint.x - leftPoint.x));
    const sampledHeight = Math.max(8, Math.abs(bottomPoint.y - topPoint.y));
    let boxWidth = isOfficeActiveOverlay || useProjectedBox ? sampledWidth : width * displayScale;
    let boxHeight = isOfficeActiveOverlay || useProjectedBox ? sampledHeight : height * displayScale;
    if ((view.room.id === 4 || view.room.id === 7) && item.isActive) {
      // Dark-room hotspots should hug the real lit object more tightly.
      // Using the full projected plane creates transient phantom clickable
      // patches in empty space as the flashlight passes nearby.
      boxWidth = clampNumber(width * displayScale * 1.08, 18, Math.min(sampledWidth, 220));
      boxHeight = clampNumber(height * displayScale * 1.08, 18, Math.min(sampledHeight, 320));
    }
    if (view.room.id === 6 && item.isActive) {
      // Room 4 is a standard bright baked room, so the interactive area should
      // track the visible object footprint rather than the larger projected plane.
      // This avoids leftover "ghost" hover zones in nearby empty space.
      boxWidth = clampNumber(width * displayScale * 1.06, 16, Math.min(sampledWidth, 180));
      boxHeight = clampNumber(height * displayScale * 1.06, 16, Math.min(sampledHeight, 220));
    }
    if (view.room.id === 5 && item.isActive) {
      boxWidth = Math.max(boxWidth, sampledWidth * 2.2, 44);
      boxHeight = Math.max(boxHeight, sampledHeight * 2.2, 44);
    }
    element.style.display = "block";
    element.style.left = `${centerPoint.x - boxWidth * 0.5}px`;
    element.style.top = `${centerPoint.y - boxHeight * 0.5}px`;
    if (isOfficeActiveOverlay || useProjectedBox) {
      element.style.width = `${boxWidth}px`;
      element.style.height = `${boxHeight}px`;
      element.style.transform = "none";
    } else {
      element.style.width = `${width}px`;
      element.style.height = `${height}px`;
      element.style.transform = `translate(-50%, -50%) scale(${displayScale})`;
    }
    if (isOfficeActiveOverlay) {
      const hoverImage = element.querySelector(".room-item-hover-image");
      if (hoverImage) {
        hoverImage.style.transform = "none";
      }
      const glowColor = numberToRgba(item.overColor || 7911637, item.overAlpha || 0.8);
      element.style.setProperty("--room-hover-color", glowColor);
    }
    if ((view.room.id === 4 || view.room.id === 7) && item.isActive && !view.roomLighting?.introActive) {
      const pointerX = view.roomLighting?.pointerScreenX ?? (STAGE_WIDTH * 0.5 + view.pointerX);
      const pointerY = view.roomLighting?.pointerScreenY ?? (STAGE_HEIGHT * 0.5 + view.pointerY);
      const hotspotRadius = FLASHLIGHT_REVEAL_OUTER_RADIUS + Math.max(boxWidth, boxHeight) * 0.22;
      const isLit = Math.hypot(centerPoint.x - pointerX, centerPoint.y - pointerY) <= hotspotRadius;
      element.style.pointerEvents = isLit ? "auto" : "none";
    } else if (item.isActive) {
      element.style.pointerEvents = "auto";
    }
    const depthOrder = Math.round((1000 - centerPoint.depth) + 200);
    element.style.zIndex = `${item.type === "shadow" ? depthOrder - 10 : depthOrder}`;
  });

  // Office visuals are mirrored in our browser reconstruction, so the visible
  // exit hotspot needs to use the mirrored visual flat X to line up with the door.
  const exitFlatX = getExitVisualFlatX(view.room.id, view.room.exitX);
  const exitCenterWorld = flatToWorldPosition(exitFlatX, view.room.exitY, 0.98);
  const exitLeftWorld = flatToWorldPosition(exitFlatX - (view.room.exitWidth || 270) * 0.5, view.room.exitY, 0.98);
  const exitRightWorld = flatToWorldPosition(exitFlatX + (view.room.exitWidth || 270) * 0.5, view.room.exitY, 0.98);
  const exitTangent = flatToWorldTangent(exitFlatX);
  const exitHalfPlane = 16;
  const exitCenter = projectCartesianPoint(view, exitCenterWorld.x, exitCenterWorld.y, exitCenterWorld.z);
  const exitLeft = projectCartesianPoint(view, exitLeftWorld.x, exitLeftWorld.y, exitLeftWorld.z);
  const exitRight = projectCartesianPoint(view, exitRightWorld.x, exitRightWorld.y, exitRightWorld.z);
  const exitPlaneLeft = projectCartesianPoint(
    view,
    exitCenterWorld.x - exitTangent.x * exitHalfPlane,
    exitCenterWorld.y,
    exitCenterWorld.z - exitTangent.z * exitHalfPlane
  );
  const exitPlaneRight = projectCartesianPoint(
    view,
    exitCenterWorld.x + exitTangent.x * exitHalfPlane,
    exitCenterWorld.y,
    exitCenterWorld.z + exitTangent.z * exitHalfPlane
  );
  const exitPlaneTop = projectCartesianPoint(
    view,
    exitCenterWorld.x,
    exitCenterWorld.y - exitHalfPlane,
    exitCenterWorld.z
  );
  const exitPlaneBottom = projectCartesianPoint(
    view,
    exitCenterWorld.x,
    exitCenterWorld.y + exitHalfPlane,
    exitCenterWorld.z
  );
  if (exitCenter && exitLeft && exitRight && exitPlaneLeft && exitPlaneRight && exitPlaneTop && exitPlaneBottom && !view.modal) {
    const signWidth = Math.max(88, Math.abs(exitPlaneRight.x - exitPlaneLeft.x) * 2.4);
    const signHeight = Math.max(88, Math.abs(exitPlaneBottom.y - exitPlaneTop.y) * 2.4);
    const hitWidth = Math.max(110, Math.abs(exitRight.x - exitLeft.x) + 135);
    const hitTop = 0;
    const hitHeight = STAGE_HEIGHT;
    const hitLeft = exitCenter.x - hitWidth * 0.5;
    const pointerScreenX = STAGE_WIDTH * 0.5 + view.pointerX;
    const pointerScreenY = STAGE_HEIGHT * 0.5 + view.pointerY;
    // Keep office exit hover in the mirrored visual space that matches the
    // already-correct door/sign placement, but bias the region downward to feel
    // closer to the SWF's forgiving door hover area.
    let pointerInsideExit =
      pointerScreenX >= hitLeft &&
      pointerScreenX <= hitLeft + hitWidth &&
      pointerScreenY >= hitTop &&
      pointerScreenY <= hitTop + hitHeight;
    if (view.room.id === 0) {
      const pointerFlat = getPointerLightFlatPosition(view);
      if (pointerFlat) {
        const mirroredPointerFlatX = mirrorFlatXInCurrentWall(pointerFlat.flatX);
        const flatThreshold = Math.max(220, (view.room.exitWidth || 270) * 1.15);
        const flatMatch = getWrappedFlatDistance(mirroredPointerFlatX, exitFlatX) <= flatThreshold;
        const horizontalMatch =
          pointerScreenX >= hitLeft - 60 &&
          pointerScreenX <= hitLeft + hitWidth + 60;
        pointerInsideExit = flatMatch && horizontalMatch;
      } else {
        pointerInsideExit = false;
      }
    }
    const shouldShowExit = view.isExiting ? true : pointerInsideExit;
    view.exitVisible = shouldShowExit;
    view.viewport.style.cursor = shouldShowExit && !view.isExiting ? "pointer" : "";
    if (view.three?.exitMesh) {
      view.three.exitMesh.visible = shouldShowExit;
    }
    if (view.three?.flashExitMesh) {
      view.three.flashExitMesh.visible = shouldShowExit;
    }
    view.exitButton.style.display = "block";
    view.exitButton.style.left = `${exitCenter.x}px`;
    view.exitButton.style.top = `${hitTop + hitHeight * 0.5}px`;
    view.exitButton.style.width = `${hitWidth}px`;
    view.exitButton.style.height = `${hitHeight}px`;
    view.exitButton.style.setProperty("--exit-sign-width", `${signWidth}px`);
    view.exitButton.style.setProperty("--exit-sign-height", `${signHeight}px`);
    view.exitButton.classList.toggle("is-visible", shouldShowExit);
    view.exitButton.style.pointerEvents = "none";
    if (pointerInsideExit && !view.isExiting && !view.exitSoundPlayed) {
      const exitSound = view.room.sounds.find((sound) => sound.triggerOnExit && sound.assetPath);
      const now = performance.now();
      if (exitSound && now - (view.exitSoundLastPlayedAt ?? 0) > 400) {
        if (view.exitSoundAudio) {
          view.exitSoundAudio.pause();
          view.exitSoundAudio.currentTime = 0;
        }
        const audio = new Audio(exitSound.assetPath);
        audio.volume = state.isMuted ? 0 : (exitSound.volume ?? 1);
        audio.muted = state.isMuted;
        audio.addEventListener("ended", () => {
          if (roomScreenState === view && view.exitSoundAudio === audio) {
            view.exitSoundAudio = null;
          }
        }, { once: true });
        view.exitSoundAudio = audio;
        view.exitSoundLastPlayedAt = now;
        audio.play().catch(() => {});
      }
      view.exitSoundPlayed = true;
    } else if (!pointerInsideExit) {
      view.exitSoundPlayed = false;
    }
  } else {
    view.exitButton.style.display = "block";
    view.exitButton.classList.remove("is-visible");
    view.exitButton.style.pointerEvents = "none";
    view.exitVisible = false;
    view.viewport.style.cursor = "";
    if (view.three?.exitMesh) {
      view.three.exitMesh.visible = false;
    }
    if (view.three?.flashExitMesh) {
      view.three.flashExitMesh.visible = false;
    }
    view.exitSoundPlayed = false;
  }
}

function getPointerWallHit(view) {
  const camera = getRoomCameraState(view);
  const screenX = STAGE_WIDTH * 0.5 + view.pointerX;
  const azimuth = camera.yaw + Math.atan((screenX - STAGE_WIDTH * 0.5) / view.focalLength);
  return intersectRoomCylinder(camera.x, camera.z, azimuth, view.roomRadius);
}

function numberToRgba(value, alpha = 1) {
  const int = Number(value) >>> 0;
  const r = (int >> 16) & 255;
  const g = (int >> 8) & 255;
  const b = int & 255;
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

function mirrorFlatXWithinWall(flatX) {
  const wrapped = positiveMod(flatX, 4096);
  if (wrapped < 2048) {
    return 2048 - wrapped;
  }
  return 2048 + (4096 - wrapped - 2048);
}

function usesBakedRoomVisual(roomId) {
  return roomId === 0 || roomId === 2 || roomId === 3 || roomId === 4 || roomId === 5 || roomId === 6 || roomId === 7;
}

function getExitVisualFlatX(roomId, flatX) {
  if (roomId === 0) {
    return mirrorFlatXInCurrentWall(flatX);
  }
  if (roomId === 6 || roomId === 7) {
    return mirrorFlatXInCurrentWall(flatX);
  }
  return usesBakedRoomVisual(roomId) ? mirrorFlatXWithinWall(flatX) : flatX;
}

function shouldSuppressRoomItem(roomId, itemId) {
  return roomId === 5 && itemId === "bed";
}

function getInteractiveFlatX(roomId, flatX) {
  if (!usesBakedRoomVisual(roomId)) {
    return flatX;
  }
  // Room 3 bakes item art mirrored *within the current wall half*, so the
  // hotspot must mirror within that same half rather than flipping to the
  // opposite spherical side of the room.
  if (roomId === 5 || roomId === 6 || roomId === 7) {
    return mirrorFlatXInCurrentWall(flatX);
  }
  return mirrorFlatXWithinWall(flatX);
}

function getWrappedFlatDistance(a, b) {
  const diff = Math.abs(positiveMod(a - b, 4096));
  return Math.min(diff, 4096 - diff);
}

function mirrorFlatXInCurrentWall(flatX) {
  const wrapped = positiveMod(flatX, 4096);
  if (wrapped < 2048) {
    return 2048 - wrapped;
  }
  return 6144 - wrapped;
}

function setBakedRoomHoveredItem(itemId) {
  const view = roomScreenState;
  if (!usesBakedRoomVisual(view?.room?.id) || !view?.three?.walls) {
    return;
  }
  view.three.walls.forEach((wall) => {
    wall.composite?.setHoveredItem(itemId);
  });
  view.three.flashWalls?.forEach((wall) => {
    wall.composite?.setHoveredItem(itemId);
  });
}

function getCachedImage(src) {
  return state.imageCache.get(src) ?? null;
}

function createTextureFromImage(image, fallbackSrc = "") {
  const texture = new THREE.Texture();
  texture.colorSpace = THREE.SRGBColorSpace;
  texture.minFilter = THREE.LinearFilter;
  texture.magFilter = THREE.LinearFilter;
  texture.generateMipmaps = false;
  if (image?.complete) {
    texture.image = image;
    texture.needsUpdate = true;
  } else if (fallbackSrc) {
    const loaderImage = image || new Image();
    loaderImage.onload = () => {
      texture.image = loaderImage;
      texture.needsUpdate = true;
    };
    loaderImage.src = fallbackSrc;
  }
  return texture;
}

function flatXToWorldAngle(flatX) {
  return degToRad((flatX / 4096) * 360 - 90);
}

function flatToWorldPosition(flatX, flatY, radiusMult = 0.98) {
  const angle = degToRad(((4096 - flatX) / 4096) * 360 - 180);
  const radius = 150 * radiusMult;
  return {
    x: Math.cos(angle) * radius,
    y: flatYToWorldY(flatY),
    z: Math.sin(angle) * radius,
  };
}

function flatToWorldTangent(flatX) {
  const angle = degToRad(((4096 - flatX) / 4096) * 360 - 180);
  return {
    x: Math.sin(angle),
    z: -Math.cos(angle),
  };
}

function angleToFlatX(angle) {
  return ((radToDeg(angle) + 90) / 360) * 4096;
}

function flatYToWorldY(flatY) {
  const yRatioFromCenter = (512 - flatY) / 512;
  return yRatioFromCenter * 150;
}

function worldYToFlatY(worldY) {
  return 512 - (worldY / 150) * 512;
}

function rotatePoint(x, z, angle) {
  return {
    x: x * Math.cos(angle) - z * Math.sin(angle),
    z: x * Math.sin(angle) + z * Math.cos(angle),
  };
}

function degToRad(deg) {
  return deg * (Math.PI / 180);
}

function radToDeg(rad) {
  return rad * (180 / Math.PI);
}

function positiveMod(value, mod) {
  return ((value % mod) + mod) % mod;
}

function projectWorldPoint(view, theta, worldY) {
  const dx = Math.cos(theta) * view.roomRadius;
  const dz = Math.sin(theta) * view.roomRadius;
  return projectCartesianPoint(view, dx, worldY, dz);
}

function projectCartesianPoint(view, worldX, worldY, worldZ) {
  if (view.three) {
    const vector = new THREE.Vector3(worldX, worldY, worldZ);
    vector.project(view.three.camera);
    if (vector.z < -1 || vector.z > 1) {
      return null;
    }
    return {
      x: (vector.x * 0.5 + 0.5) * STAGE_WIDTH,
      y: (-vector.y * 0.5 + 0.5) * STAGE_HEIGHT,
      depth: vector.z,
    };
  }

  const camera = getRoomCameraState(view);
  const relX = worldX - camera.x;
  const relY = worldY - camera.y;
  const relZ = worldZ - camera.z;
  const rel = rotatePoint(relX, relZ, -camera.yaw);
  if (rel.z <= 0.001) {
    return null;
  }

  const cosPitch = Math.cos(-camera.pitch);
  const sinPitch = Math.sin(-camera.pitch);
  const pitchedY = relY * cosPitch - rel.z * sinPitch;
  const pitchedDepth = relY * sinPitch + rel.z * cosPitch;
  if (pitchedDepth <= 0.001) {
    return null;
  }

  return {
    x: STAGE_WIDTH * 0.5 + (rel.x * view.focalLength) / pitchedDepth,
    y: STAGE_HEIGHT * 0.5 - (pitchedY * view.focalLength) / pitchedDepth,
    depth: pitchedDepth,
  };
}

function getRoomCameraState(view) {
  const yaw = degToRad(view.currentYRotation);
  const pitch = degToRad(view.currentXRotation);
  const distance = view.targetCameraDistance ?? view.cameraDistance ?? 1;
  return {
    yaw,
    pitch,
    x: -Math.sin(yaw) * distance,
    y: view.cameraHeight,
    z: -Math.cos(yaw) * distance,
  };
}

function intersectRoomCylinder(cameraX, cameraZ, azimuth, radius) {
  const dirX = Math.sin(azimuth);
  const dirZ = Math.cos(azimuth);
  const b = 2 * (cameraX * dirX + cameraZ * dirZ);
  const c = cameraX * cameraX + cameraZ * cameraZ - radius * radius;
  const discriminant = b * b - 4 * c;
  if (discriminant < 0) {
    return null;
  }
  const sqrtDisc = Math.sqrt(discriminant);
  const t0 = (-b - sqrtDisc) * 0.5;
  const t1 = (-b + sqrtDisc) * 0.5;
  const distance = t0 > 0 ? t0 : t1 > 0 ? t1 : null;
  if (!distance) {
    return null;
  }
  const hitX = cameraX + dirX * distance;
  const hitZ = cameraZ + dirZ * distance;
  return {
    distance,
    x: hitX,
    z: hitZ,
    angleDeg: positiveMod(radToDeg(Math.atan2(hitZ, hitX)), 360),
  };
}

function resolveWallSample(wallTextures, worldAngleDeg) {
  if (!wallTextures.length) {
    return null;
  }
  const wall = worldAngleDeg > 180 ? wallTextures[1] ?? wallTextures[0] : wallTextures[0];
  if (!wall?.image) {
    return null;
  }
  const sourceXRatio = worldAngleDeg > 180
    ? (360 - worldAngleDeg) / 180
    : (180 - worldAngleDeg) / 180;
  return {
    image: wall.image,
    sourceX: sourceXRatio * wall.image.naturalWidth,
  };
}

function openRoomItem(item) {
  const view = roomScreenState;
  if (!view || view.modal) {
    return;
  }

  if (item.type === "audio") {
    toggleRoomItemAudio(item);
    return;
  }

  showRoomNote("");
  const pausesAmbient = item.type === "ipad" || item.type === "video";
  if (pausesAmbient) {
    pauseRoomAudio();
  }
  stopRoomItemAudio();

  if (item.type === "ipad") {
    view.modal = buildIpadModal(item);
  } else if (item.type === "video") {
    view.modal = buildVideoModal(item);
  } else if (item.type === "panable") {
    view.modal = buildPanableModal(item);
  } else {
    view.modal = buildPhotoModal(item);
  }
  view.modal.pausesAmbient = pausesAmbient;

  view.root.append(view.modal.root);
  requestAnimationFrame(() => view.modal.root.classList.add("is-visible"));
}

function toggleRoomItemAudio(item) {
  const view = roomScreenState;
  if (!view) {
    return;
  }
  if (view.playingItemId === item.id) {
    stopRoomItemAudio();
    return;
  }
  stopRoomItemAudio();
  const audio = new Audio(item.largeViewAssetPaths[0]);
  audio.muted = state.isMuted;
  audio.addEventListener("ended", () => {
    if (roomScreenState?.itemAudio === audio) {
      stopRoomItemAudio();
    }
  }, { once: true });
  view.itemAudio = audio;
  view.playingItemId = item.id;
  const itemEl = view.projectedItems.find((entry) => entry.item.id === item.id)?.element;
  itemEl?.classList.add("is-audio-playing");
  audio.play().catch(() => {
    stopRoomItemAudio();
  });
}

function stopRoomItemAudio() {
  const view = roomScreenState;
  if (!view) {
    return;
  }
  if (view.itemAudio) {
    view.itemAudio.pause();
    view.itemAudio.currentTime = 0;
    view.itemAudio = null;
  }
  if (view.playingItemId) {
    const itemEl = view.projectedItems.find((entry) => entry.item.id === view.playingItemId)?.element;
    itemEl?.classList.remove("is-audio-playing");
  }
  view.playingItemId = null;
}

function buildPhotoModal(item) {
  const root = createEl("div", "room-modal");
  const dim = createEl("button", "room-modal-dim");
  dim.type = "button";
  const panel = createEl("div", "room-modal-panel photo");
  const close = buildModalCloseButton("room-modal-close");

  const itemView = createEl("div", "room-photo-item-view");
  const imagePaths = item.largeViewAssetPaths?.length ? item.largeViewAssetPaths : [item.inRoomAssetPath];
  const imageWrappers = imagePaths.slice(0, 2).map((src) => {
    const wrapper = createEl("div", "room-photo-face");
    const img = document.createElement("img");
    img.className = "room-modal-photo";
    img.src = src ?? "";
    img.draggable = false;
    wrapper.append(img);
    itemView.append(wrapper);
    return { wrapper, img };
  });

  const divider = makeOutsideImage("assets/bitmaps/item_view/divider.png", "room-photo-divider");
  const textBox = createHoverNote(text(item.id));
  const otherElements = createEl("div", "room-photo-other");
  const fbButton = buildPhotoSocialButton("assets/bitmaps/item_view/fb_out.png", "assets/bitmaps/item_view/fb_over.png", "Share on Facebook");
  const twButton = buildPhotoSocialButton("assets/bitmaps/item_view/twitter_out.png", "assets/bitmaps/item_view/twitter_over.png", "Share on Twitter");
  otherElements.append(divider, fbButton, twButton);

  panel.append(close, itemView, otherElements, textBox);
  const modalStage = createEl("div", "room-modal-stage");
  modalStage.append(panel);
  applyModalLayout({ stage: modalStage });
  root.append(dim, modalStage);

  const applyLayout = () => {
    const primaryImage = imageWrappers[0]?.img;
    const naturalWidth = primaryImage?.naturalWidth || 1;
    const naturalHeight = primaryImage?.naturalHeight || 1;
    const textBoxY = 447;
    const targetItemHeight = textBoxY - 40;
    const targetRatio = Math.min(targetItemHeight / naturalHeight, 1.5);
    const scaledWidth = naturalWidth * targetRatio;
    const scaledHeight = naturalHeight * targetRatio;
    itemView.style.width = `${scaledWidth}px`;
    itemView.style.height = `${scaledHeight}px`;
    imageWrappers.forEach(({ img }) => {
      img.style.width = `${scaledWidth}px`;
      img.style.height = `${scaledHeight}px`;
    });
    itemView.style.left = `${(STAGE_WIDTH - scaledWidth) * 0.5}px`;
    itemView.style.top = `${(textBoxY - scaledHeight) * 0.5}px`;
    close.style.right = "auto";
    close.style.left = `${750 + scaledWidth * 0.5 + 10}px`;
    close.style.top = `${Math.max(10, (textBoxY - scaledHeight) * 0.5)}px`;
  };

  const primaryImage = imageWrappers[0]?.img;
  if (primaryImage?.complete) {
    applyLayout();
  } else {
    primaryImage?.addEventListener("load", applyLayout, { once: true });
  }

  if (imageWrappers.length === 1) {
    imageWrappers[0].wrapper.classList.add("is-visible");
  }

  if (imageWrappers.length > 1) {
    itemView.classList.add("is-flippable");
    const [front, back] = imageWrappers;
    front.wrapper.classList.add("is-visible");
    back.wrapper.classList.remove("is-visible");
    back.img.style.transform = "scaleX(-1)";
    let showingFront = true;
    itemView.addEventListener("click", () => {
      showingFront = !showingFront;
      front.wrapper.classList.toggle("is-visible", showingFront);
      back.wrapper.classList.toggle("is-visible", !showingFront);
    });
  }

  const closeModal = () => closeRoomModal();
  dim.addEventListener("click", closeModal);
  close.addEventListener("click", closeModal);
  return { root, stage: modalStage, close: closeModal };
}

function buildVideoModal(item) {
  const root = createEl("div", "room-modal");
  const dim = createEl("button", "room-modal-dim");
  dim.type = "button";
  const panel = createEl("div", "room-modal-panel video");
  const close = buildModalCloseButton("room-modal-close video");

  const itemView = createEl("div", "room-video-item-view");
  const videoContainer = createEl("div", "room-video-container");
  const video = document.createElement("video");
  video.className = "room-modal-video";
  video.src = item.largeViewAssetPaths[0] ?? "";
  video.autoplay = true;
  video.controls = false;
  video.playsInline = true;
  video.muted = state.isMuted;
  videoContainer.append(video);
  itemView.append(videoContainer);

  const divider = makeOutsideImage("assets/bitmaps/item_view/divider.png", "room-photo-divider");
  const otherElements = createEl("div", "room-photo-other");
  const fbButton = buildPhotoSocialButton("assets/bitmaps/item_view/fb_out.png", "assets/bitmaps/item_view/fb_over.png", "Share on Facebook");
  const twButton = buildPhotoSocialButton("assets/bitmaps/item_view/twitter_out.png", "assets/bitmaps/item_view/twitter_over.png", "Share on Twitter");
  otherElements.append(divider, fbButton, twButton);

  panel.append(close, itemView, otherElements);
  const modalStage = createEl("div", "room-modal-stage");
  modalStage.append(panel);
  applyRoomLayout(modalStage);
  root.append(dim, modalStage);
  close.style.right = "auto";
  close.style.left = "1107px";
  close.style.top = "77px";

  const closeModal = () => {
    video.pause();
    closeRoomModal();
  };
  dim.addEventListener("click", closeModal);
  close.addEventListener("click", closeModal);
  return { root, stage: modalStage, close: closeModal };
}

function buildIpadModal(item) {
  const root = createEl("div", "room-modal");
  const dim = createEl("button", "room-modal-dim");
  dim.type = "button";
  const panel = createEl("div", "room-modal-panel ipad");
  const close = buildModalCloseButton("room-modal-close ipad");

  const shell = createEl("div", "room-ipad-shell");
  const shellBg = document.createElement("img");
  shellBg.className = "room-ipad-bg";
  shellBg.src = "assets/bitmaps/item_view/ipad_bg.png";
  shellBg.draggable = false;

  const videoFrame = createEl("div", "room-ipad-video-frame");
  const video = document.createElement("video");
  video.className = "room-ipad-video";
  video.src = item.largeViewAssetPaths[0];
  video.autoplay = true;
  video.playsInline = true;
  video.preload = "auto";
  video.controls = false;
  video.muted = state.isMuted;
  videoFrame.append(video);

  const header = createEl("div", "room-ipad-header", text("ipad_header"));
  const titleBar = createEl("div", "room-ipad-titlebar");
  titleBar.append(createEl("div", "room-ipad-title", text("ipad_title")));
  window.setTimeout(() => titleBar.classList.add("is-hidden"), 4000);

  const links = createEl("div", "room-ipad-links");
  item.largeViewNodes.slice(1).forEach((node) => {
    const card = createEl("a", "room-ipad-link");
    const path = node.path || node.getAttribute?.("path") || "";
    const copy = node.text || node.getAttribute?.("text") || "";
    const link = remapIpadLink(copy, node.link || node.getAttribute?.("link") || "#");
    card.href = link;
    card.target = "_blank";
    card.rel = "noopener";
    const image = document.createElement("img");
    image.src = path;
    image.className = "room-ipad-link-image";
    image.draggable = false;
    const label = createEl("div", "room-ipad-link-copy", copy);
    card.append(image, label);
    links.append(card);
  });

  shell.append(shellBg, videoFrame, header, links, titleBar);
  panel.append(close, shell);
  const modalStage = createEl("div", "room-modal-stage");
  modalStage.append(panel);
  applyRoomLayout(modalStage);
  root.append(dim, modalStage);

  const closeModal = () => {
    video.pause();
    closeRoomModal();
  };
  dim.addEventListener("click", closeModal);
  close.addEventListener("click", closeModal);
  return { root, stage: modalStage, close: closeModal };
}

function buildPanableModal(item) {
  const root = createEl("div", "room-modal");
  const dim = createEl("button", "room-modal-dim");
  dim.type = "button";
  const panel = createEl("div", "room-modal-panel video");
  const close = buildModalCloseButton("room-modal-close video");

  const itemView = createEl("div", "room-video-item-view room-panable-item-view");
  const imageMask = createEl("div", "room-panable-mask");
  const image = document.createElement("img");
  image.className = "room-panable-image";
  image.src = item.largeViewAssetPaths[0] ?? item.inRoomAssetPath;
  image.draggable = false;
  imageMask.append(image);
  itemView.append(imageMask);

  const divider = makeOutsideImage("assets/bitmaps/item_view/divider.png", "room-photo-divider");
  const otherElements = createEl("div", "room-photo-other");
  const fbButton = buildPhotoSocialButton("assets/bitmaps/item_view/fb_out.png", "assets/bitmaps/item_view/fb_over.png", "Share on Facebook");
  const twButton = buildPhotoSocialButton("assets/bitmaps/item_view/twitter_out.png", "assets/bitmaps/item_view/twitter_over.png", "Share on Twitter");
  otherElements.append(divider, fbButton, twButton);

  const directions = text("panableDirections");
  const note = createHoverNote(directions, "sm");
  note.classList.add("room-panable-note");

  panel.append(close, itemView, otherElements, note);
  const modalStage = createEl("div", "room-modal-stage");
  modalStage.append(panel);
  applyModalLayout({ stage: modalStage });
  root.append(dim, modalStage);
  close.style.right = "auto";
  close.style.left = "1107px";
  close.style.top = "77px";

  let rafId = 0;
  let noteTimer = 0;
  let pointerStageX = STAGE_WIDTH * 0.5;
  let pointerStageY = STAGE_HEIGHT * 0.5;
  let panX = 0;
  let panY = 0;
  let imageReady = false;

  const fitImage = () => {
    const targetWidth = Math.max(674, image.naturalWidth || 674);
    const targetHeight = Math.max(379, image.naturalHeight || 379);
    image.style.width = `${targetWidth}px`;
    image.style.height = `${targetHeight}px`;
    panX = 0;
    panY = 0;
    image.style.left = "0px";
    image.style.top = "0px";
    image.style.transform = "none";
    imageReady = true;
  };

  const updatePan = () => {
    if (!imageReady || !image.offsetWidth || !image.offsetHeight) {
      rafId = requestAnimationFrame(updatePan);
      return;
    }
    const minX = Math.min(0, imageMask.clientWidth - image.offsetWidth);
    const minY = Math.min(0, imageMask.clientHeight - image.offsetHeight);
    panX = clampNumber(panX - 0.25 * (pointerStageX - STAGE_WIDTH * 0.5) / 20, minX, 0);
    panY = clampNumber(panY - 0.25 * (pointerStageY - STAGE_HEIGHT * 0.5) / 10, minY, 0);
    image.style.left = `${panX}px`;
    image.style.top = `${panY}px`;
    rafId = requestAnimationFrame(updatePan);
  };

  const onPointerMove = (event) => {
    const bounds = root.getBoundingClientRect();
    pointerStageX = ((event.clientX - bounds.left) / bounds.width) * STAGE_WIDTH;
    pointerStageY = ((event.clientY - bounds.top) / bounds.height) * STAGE_HEIGHT;
  };

  const onTouchMove = (event) => {
    const touch = event.touches[0];
    if (!touch) {
      return;
    }
    event.preventDefault();
    onPointerMove(touch);
  };

  if (image.complete) {
    fitImage();
  } else {
    image.addEventListener("load", fitImage, { once: true });
  }

  imageMask.addEventListener("mousemove", onPointerMove);
  root.addEventListener("mousemove", onPointerMove);
  window.addEventListener("mousemove", onPointerMove);
  imageMask.addEventListener("touchstart", onTouchMove, { passive: false });
  imageMask.addEventListener("touchmove", onTouchMove, { passive: false });
  root.addEventListener("touchmove", onTouchMove, { passive: false });

  requestAnimationFrame(() => {
    note.classList.add("is-visible");
    rafId = requestAnimationFrame(updatePan);
    noteTimer = window.setTimeout(() => note.classList.remove("is-visible"), 3200);
  });

  const closeModal = () => {
    if (rafId) {
      cancelAnimationFrame(rafId);
    }
    if (noteTimer) {
      window.clearTimeout(noteTimer);
    }
    imageMask.removeEventListener("mousemove", onPointerMove);
    root.removeEventListener("mousemove", onPointerMove);
    window.removeEventListener("mousemove", onPointerMove);
    imageMask.removeEventListener("touchstart", onTouchMove);
    imageMask.removeEventListener("touchmove", onTouchMove);
    root.removeEventListener("touchmove", onTouchMove);
    closeRoomModal();
  };
  dim.addEventListener("click", closeModal);
  close.addEventListener("click", closeModal);
  return { root, stage: modalStage, close: closeModal };
}

function closeRoomModal() {
  const view = roomScreenState;
  if (!view?.modal) {
    return;
  }
  const modal = view.modal;
  view.modal = null;
  modal.root.classList.remove("is-visible");
  window.setTimeout(() => modal.root.remove(), 220);
  if (modal.pausesAmbient) {
    resumeRoomAudio();
  }
}

function showRoomNote(copy) {
  const view = roomScreenState;
  if (!view?.note) {
    return;
  }
  if (view.noteTimer) {
    window.clearTimeout(view.noteTimer);
    view.noteTimer = null;
  }
  if (view.noteHideTimer) {
    window.clearTimeout(view.noteHideTimer);
    view.noteHideTimer = null;
  }

  if (copy) {
    view.note.innerHTML = copy.replace(/<br\s*\/?>/gi, "<br>");
    view.note.classList.add("is-visible");
    return;
  }

  view.note.classList.remove("is-visible");
  view.noteHideTimer = window.setTimeout(() => {
    if (roomScreenState === view && !view.note.classList.contains("is-visible")) {
      view.note.innerHTML = "";
    }
    view.noteHideTimer = null;
  }, HOVER_NOTE_FADE_MS);
}

function showRoomFlavor(room) {
  const flavor = text(`${room.navText}_flavor`);
  if (!flavor) {
    return;
  }
  const view = roomScreenState;
  if (view) {
    view.flavorLockUntil = performance.now() + ROOM_FLAVOR_LOCK_MS;
  }
  showRoomNote(flavor);
  if (view) {
    view.noteTimer = window.setTimeout(() => {
      if (roomScreenState === view) {
        view.flavorLockUntil = 0;
        showRoomNote("");
      }
    }, ROOM_FLAVOR_LOCK_MS);
  }
}

function playRoomAmbient(room) {
  const ambient = room.sounds.find((sound) => sound.assetPath && !sound.triggerOnExit);
  if (!ambient || !roomScreenState) {
    return;
  }

  const audio = new Audio(ambient.assetPath);
  audio.loop = true;
  audio.volume = ambient.volume ?? 1;
  audio.muted = state.isMuted;
  roomScreenState.audio = audio;
  audio.play().catch(() => {});
}

function toggleRoomSound() {
  setGlobalMuted(!state.isMuted);
}

function pauseRoomAudio() {
  if (roomScreenState?.audio) {
    roomScreenState.audio.pause();
  }
}

function resumeRoomAudio() {
  if (roomScreenState?.audio) {
    roomScreenState.audio.play().catch(() => {});
  }
}

function stopRoomAudio() {
  if (roomScreenState?.audio) {
    roomScreenState.audio.pause();
    roomScreenState.audio.currentTime = 0;
    roomScreenState.audio = null;
  }
  if (roomScreenState?.exitSoundAudio) {
    roomScreenState.exitSoundAudio.pause();
    roomScreenState.exitSoundAudio.currentTime = 0;
    roomScreenState.exitSoundAudio = null;
  }
  stopRoomItemAudio();
}

function beginRoomExit(targetRoomId = null) {
  const view = roomScreenState;
  if (!view || view.isExiting) {
    return;
  }
  view.isExiting = true;
  view.pendingTargetRoomId = typeof targetRoomId === "number" ? targetRoomId : null;
  view.currentExitPush = 0;
  view.exitState = buildRoomExitState(view);
  stopRoomItemAudio();
  showRoomNote("");
  if (view.modal) {
    closeRoomModal();
  }
  // In the SWF, the minimap expands back to the regular outside map as soon as
  // the room-exit move begins, not after the outside scene is fully restored.
  view.miniMap.shell.classList.remove("is-exit");
  view.miniMap.viewport.classList.remove("is-exit");
  view.miniMap.glass.classList.remove("is-exit");
  syncRegularArrowStateForMap(view.miniMap);
  animateRoomExitMap(view);
  if (view.exitFadeTimer) {
    window.clearTimeout(view.exitFadeTimer);
  }
  view.exitFadeTimer = window.setTimeout(() => {
    if (roomScreenState === view) {
      view.fade.classList.add("is-visible");
    }
  }, 1000);
  window.setTimeout(() => {
    if (roomScreenState === view) {
      exitRoomToOutside(view.pendingTargetRoomId);
    }
  }, 2000);
}

function exitRoomToOutside(targetRoomId = null) {
  const view = roomScreenState;
  if (!view) {
    return;
  }

  if (view.rafId) {
    cancelAnimationFrame(view.rafId);
  }
  clearRoomMiniMapEnter(view);
  roomEntryMapState = null;
  disposeThreeRoom(view);
  stopRoomAudio();
  state.isInRoom = false;
  roomScreenState = null;
  view.root.remove();
  renderOutside();
  const queuedTargetRoomId = typeof targetRoomId === "number" ? targetRoomId : view.pendingTargetRoomId;
  if (typeof queuedTargetRoomId === "number" && queuedTargetRoomId !== state.currentRoomId) {
    requestAnimationFrame(() => requestRoomMove(queuedTargetRoomId));
  }
}

function playOutsideAmbient() {
  const view = outsideScreenState;
  if (!view) {
    return;
  }

  const audio = new Audio(state.outsideAmbientPath);
  audio.loop = true;
  audio.volume = 0.3;
  audio.muted = state.isMuted;
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
    await playVideoOnce(activeVideo, src, false, () => travel.skipped, true, () => {
      if (!travel.startedNotified) {
        travel.startedNotified = true;
        travel.playbackStarted.resolve();
      }
    });

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
  if (travel?.playbackStarted?.promise) {
    await Promise.race([travel.playbackStarted.promise, delay(2500)]);
  }
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
  view.fade.style.transition = "none";
  view.fade.classList.remove("is-clear");
  void view.fade.offsetWidth;

  const targetStep = stepForRoom(travel.targetRoomId);
  window.setTimeout(() => {
    if (outsideScreenState !== view) {
      return;
    }
    state.currentStep = targetStep;
    state.currentRoomId = travel.targetRoomId;
    applyMapPosition(view, targetStep, 320);
    setOutsideRoom(travel.targetRoomId, true);
    window.setTimeout(() => {
      if (outsideScreenState !== view) {
        return;
      }
      view.fade.style.transition = "opacity 260ms linear";
      view.fade.classList.add("is-clear");
      window.setTimeout(() => {
        if (outsideScreenState === view) {
          view.fade.style.transition = "opacity 1.5s linear";
        }
      }, 260);
      view.miniMap.you.style.opacity = "1";
      finalizeOutsideTravel(travel.targetRoomId, targetStep);
    }, 180);
  }, 180);
}

function buildOutsideSidebar() {
  const root = createEl("div", "outside-sidebar");
  const toggleButton = createEl("button", "outside-sidebar-toggle", "ROOMS");
  toggleButton.type = "button";
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
  const fullscreenButton = supportsFullscreen() ? createEl("button", "outside-sidebar-icon outside-sidebar-fullscreen") : null;
  if (fullscreenButton) {
    fullscreenButton.type = "button";
    fullscreenButton.setAttribute("aria-label", "Toggle fullscreen");
    fullscreenButton.append(createEl("span", "outside-sidebar-fullscreen-glyph"));
  }
  top.append(helpButton, soundButton);
  if (fullscreenButton) {
    top.append(fullscreenButton);
  }

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

  root.append(toggleButton, top, roomList);
  return { root, roomList, roomButtons, helpButton, soundButton, fullscreenButton, toggleButton };
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
  setGlobalMuted(!state.isMuted);
}

function setGlobalMuted(shouldMute) {
  state.isMuted = shouldMute;
  if (outsideScreenState?.audio) {
    outsideScreenState.audio.muted = shouldMute;
  }
  if (roomScreenState?.audio) {
    roomScreenState.audio.muted = shouldMute;
  }
  app.querySelectorAll("video").forEach((video) => {
    video.muted = shouldMute;
  });
  syncMutedUi();
}

function syncMutedUi() {
  outsideScreenState?.sidebar?.soundButton.classList.toggle("is-muted", state.isMuted);
  roomScreenState?.sidebar?.soundButton.classList.toggle("is-muted", state.isMuted);
}

function supportsFullscreen() {
  const target = document.documentElement;
  return Boolean(
    target.requestFullscreen ||
    target.webkitRequestFullscreen ||
    document.exitFullscreen ||
    document.webkitExitFullscreen
  );
}

function isFullscreenActive() {
  return Boolean(document.fullscreenElement || document.webkitFullscreenElement);
}

function handleFullscreenChange() {
  app.classList.toggle("is-fullscreen", isFullscreenActive());
  syncFullscreenUi();
  resizeStages();
}

async function toggleFullscreen() {
  if (!supportsFullscreen()) {
    return;
  }
  try {
    if (isFullscreenActive()) {
      if (document.exitFullscreen) {
        await document.exitFullscreen();
      } else if (document.webkitExitFullscreen) {
        document.webkitExitFullscreen();
      }
      return;
    }

    const target = document.documentElement;
    if (target.requestFullscreen) {
      try {
        await target.requestFullscreen({ navigationUI: "hide" });
      } catch {
        await target.requestFullscreen();
      }
    } else if (target.webkitRequestFullscreen) {
      target.webkitRequestFullscreen();
    }
  } catch (error) {
    console.warn("Fullscreen toggle failed", error);
  }
}

function syncFullscreenUi() {
  const active = isFullscreenActive();
  outsideScreenState?.sidebar?.fullscreenButton?.classList.toggle("is-active", active);
  roomScreenState?.sidebar?.fullscreenButton?.classList.toggle("is-active", active);
}

function clearRoomMiniMapEnter(view) {
  if (!view?.mapEnterTimers?.length) {
    return;
  }
  view.mapEnterTimers.forEach((timerId) => window.clearTimeout(timerId));
  view.mapEnterTimers = [];
}

function applyRoomEnterMapPosition(view, point, durationMs) {
  view.miniMap.grounds.style.transition = durationMs ? `left ${durationMs}ms linear, top ${durationMs}ms linear` : "none";
  view.miniMap.grounds.style.left = `${-point.x}px`;
  view.miniMap.grounds.style.top = `${-point.y}px`;
}

function animateRoomMiniMapEnter(view) {
  clearRoomMiniMapEnter(view);
  const sequence = NAV_MAP_ENTER[state.currentRoomId];
  if (!view?.miniMap || !sequence?.length) {
    return;
  }
  view.miniMap.you.style.opacity = "1";
  applyMapPosition(view, state.currentStep, 0);

  let elapsed = 0;
  sequence.forEach((point, index) => {
    const timerId = window.setTimeout(() => {
      if (roomScreenState !== view) {
        return;
      }
      applyRoomEnterMapPosition(view, point, (point.t ?? 0) * 1000);
    }, elapsed);
    view.mapEnterTimers.push(timerId);
    elapsed += (point.t ?? 0) * 1000;
  });
}

function beginRoomEntryMapAnimation(view, roomId) {
  const sequence = NAV_MAP_ENTER[roomId];
  if (!view?.miniMap || !sequence?.length) {
    roomEntryMapState = null;
    return;
  }
  roomEntryMapState = { roomId, finalPoint: sequence[sequence.length - 1] };
  view.miniMap.you.style.opacity = "1";
  const currentPoint = NAV_MAP_PATH[state.currentStep];
  const normalizedSequence = sequence.filter((point, index) => {
    if (index !== 0 || !currentPoint) {
      return true;
    }
    return point.x !== currentPoint.x || point.y !== currentPoint.y;
  });
  const enterSpeed = 1;
  const [firstPoint, ...rest] = normalizedSequence.length ? normalizedSequence : sequence.slice(-1);
  view.miniMap.grounds.style.transition = `left ${((firstPoint.t ?? 0) * 1000) * enterSpeed}ms linear, top ${((firstPoint.t ?? 0) * 1000) * enterSpeed}ms linear`;
  view.miniMap.grounds.style.left = `${-firstPoint.x}px`;
  view.miniMap.grounds.style.top = `${-firstPoint.y}px`;
  let elapsed = ((firstPoint.t ?? 0) * 1000) * enterSpeed;
  rest.forEach((point) => {
    window.setTimeout(() => {
      if (outsideScreenState !== view || state.currentRoomId !== roomId) {
        return;
      }
      view.miniMap.grounds.style.transition = `left ${((point.t ?? 0) * 1000) * enterSpeed}ms linear, top ${((point.t ?? 0) * 1000) * enterSpeed}ms linear`;
      view.miniMap.grounds.style.left = `${-point.x}px`;
      view.miniMap.grounds.style.top = `${-point.y}px`;
    }, elapsed);
    elapsed += ((point.t ?? 0) * 1000) * enterSpeed;
  });
}

function animateRoomExitMap(view) {
  const sequence = NAV_MAP_ENTER[view.room.id];
  if (!view?.miniMap || !sequence?.length) {
    return;
  }
  clearRoomMiniMapEnter(view);
  // Flash animEnter(false) starts from the current final enter point and moves
  // immediately to the previous point using the original point timings.
  const reversed = sequence.slice(0, -1).reverse();
  if (!reversed.length) {
    return;
  }
  let elapsed = 0;
  reversed.forEach((point) => {
    const duration = (point.t ?? 0) * 1000;
    const timerId = window.setTimeout(() => {
      if (roomScreenState !== view) {
        return;
      }
      applyRoomEnterMapPosition(view, point, duration);
    }, elapsed);
    view.mapEnterTimers.push(timerId);
    elapsed += duration;
  });
}

function applyRoomEntryMapFinal(view) {
  const point = roomEntryMapState?.roomId === view.room.id
    ? roomEntryMapState.finalPoint
    : NAV_MAP_ENTER[view.room.id]?.[NAV_MAP_ENTER[view.room.id].length - 1];
  if (!point) {
    return;
  }
  applyRoomEnterMapPosition(view, point, 0);
  view.miniMap.you.style.opacity = "1";
}

function createHoverNote(copy, size = "md") {
  const root = createEl("div", `hover-note hover-note-${size}`);
  const textEl = createEl("div", "hover-note-text", copy);
  root.append(textEl);
  return root;
}

function applyModalLayout(modal) {
  if (modal?.stage) {
    const width = window.innerWidth;
    const height = window.innerHeight;
    const isMobile = state.isMobileUi;
    const widthScale = width / STAGE_WIDTH;
    const heightScale = height / STAGE_HEIGHT;
    const baseScale = Math.min(widthScale, heightScale);
    const scale = isMobile ? Math.min(baseScale, 0.9) : baseScale;
    const safeTop = isMobile ? 14 + getSafeInsetTop() : 0;
    const safeBottom = isMobile ? 14 + getSafeInsetBottom() : 0;
    const centeredX = (width - STAGE_WIDTH * scale) / 2;
    const centeredY = (height - STAGE_HEIGHT * scale) / 2;
    const desktopOffsetY = 36;
    const mobileOffsetY = 10;
    let translateY = centeredY + (isMobile ? mobileOffsetY : desktopOffsetY);
    const minTop = safeTop;
    const maxTop = height - STAGE_HEIGHT * scale - safeBottom;
    if (isMobile) {
      translateY = clampNumber(translateY, minTop, Math.max(minTop, maxTop));
    }
    modal.stage.style.transform = `translate(${centeredX}px, ${translateY}px) scale(${scale})`;
  }
}

function getSafeInsetTop() {
  return state.isMobileUi ? 18 : 0;
}

function getSafeInsetBottom() {
  return state.isMobileUi ? 18 : 0;
}

function buildModalCloseButton(className) {
  const button = createEl("button", className);
  button.type = "button";
  const outImage = makeOutsideImage("assets/bitmaps/item_view/close_out.png", "room-modal-close-image out");
  const overImage = makeOutsideImage("assets/bitmaps/item_view/close_over.png", "room-modal-close-image over");
  button.append(outImage, overImage);
  let timers = [];
  const clearTimers = () => {
    timers.forEach((timer) => window.clearTimeout(timer));
    timers = [];
  };
  const sequence = (values) => {
    clearTimers();
    values.forEach(([alpha, delayMs]) => {
      timers.push(window.setTimeout(() => {
        overImage.style.opacity = String(alpha);
      }, delayMs));
    });
  };
  button.addEventListener("mouseenter", () => {
    sequence([
      [0.5, 0],
      [0.4, 50],
      [1, 100],
    ]);
  });
  button.addEventListener("mouseleave", () => {
    sequence([
      [0.5, 0],
      [0.6, 50],
      [0, 100],
    ]);
  });
  return button;
}

function remapIpadLink(copy, originalLink) {
  const normalized = (copy || "").trim().toLowerCase();
  if (normalized === "emma's blog") {
    return "https://batesmotel.fandom.com/wiki/Emma%27s_Blog";
  }
  if (normalized === "norman's blog") {
    return "https://batesmotel.fandom.com/wiki/Norman%27s_Blog";
  }
  if (normalized === "bates motel") {
    return "https://batesmotel.fandom.com/wiki/Bates_Motel_Oregon_Website";
  }
  return originalLink;
}

function preloadRoomVisuals(room) {
  if (!room) {
    return Promise.resolve();
  }
  const sources = [
    ...room.bgObjects.map((texture) => texture.path),
    ...room.items.map((item) => item.inRoomAssetPath),
  ].filter(Boolean);
  return Promise.all(sources.map((src) => loadImage(src).catch(() => null))).then(() => {});
}

function buildPhotoSocialButton(outSrc, overSrc, label) {
  const button = createEl("button", "room-photo-social");
  button.type = "button";
  button.setAttribute("aria-label", label);
  const outImage = makeOutsideImage(outSrc, "room-photo-social-out");
  const overImage = makeOutsideImage(overSrc, "room-photo-social-over");
  button.append(outImage, overImage);
  return button;
}

function toggleOutsideHelp(force) {
  const next = typeof force === "boolean" ? force : !state.isHelpActive;
  state.isHelpActive = next;
  if (next && state.isMobileUi) {
    setOutsideSidebarOpen(false);
  }
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

function setOutsideSidebarOpen(open) {
  const view = outsideScreenState;
  if (!view?.sidebar) {
    state.isSidebarOpen = open;
    return;
  }

  const shouldOpen = state.isMobileUi ? Boolean(open) : true;
  state.isSidebarOpen = shouldOpen;
  view.sidebar.root.classList.toggle("is-open", shouldOpen);
  view.sidebar.toggleButton?.classList.toggle("is-active", shouldOpen);
}

function setMapArrowStateForMap(map, left, right, up, down, skip) {
  if (!map) {
    return;
  }
  map.leftArrow.classList.toggle("is-visible", left);
  map.rightArrow.classList.toggle("is-visible", right);
  map.upArrow.classList.toggle("is-visible", up);
  map.downArrow.classList.toggle("is-visible", down);
  map.skip.classList.toggle("is-visible", skip);
}

function syncRegularArrowStateForMap(map) {
  if (!map) {
    return;
  }
  if (state.currentStep < 4) {
    if (state.currentStep < 1) {
      setMapArrowStateForMap(map, false, false, true, true, false);
    } else {
      setMapArrowStateForMap(map, false, true, true, false, false);
    }
  } else if (state.currentStep > 19) {
    setMapArrowStateForMap(map, true, false, true, false, false);
  } else {
    setMapArrowStateForMap(map, true, true, true, false, false);
  }
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

function playVideoOnce(video, src, allowReject = false, shouldAbort = () => false, alreadyPrepared = false, onStarted = null) {
  return new Promise((resolve, reject) => {
    let started = false;
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
      video.removeEventListener("playing", onPlaying);
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

    const onPlaying = () => {
      if (started) {
        return;
      }
      started = true;
      onStarted?.();
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
    video.addEventListener("playing", onPlaying, { once: true });
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

  const width = Math.ceil(textOut.getBoundingClientRect().width + arrowWrap.getBoundingClientRect().width + 42);
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
}

function stopLandingFog() {
  if (landingFogState?.rafId) {
    cancelAnimationFrame(landingFogState.rafId);
  }
  landingFogState = null;
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

function startLandingFog(layers) {
  stopLandingFog();
  const layerConfigs = [
    { initialX: 0, initialDuration: 20000 },
    { initialX: 1300, initialDuration: 40000 },
    { initialX: 2600, initialDuration: 60000 },
  ];
  landingFogState = {
    layers: layers.map((layer, index) => ({
      el: layer,
      ...layerConfigs[index],
      loopStartX: 1500,
      loopDuration: 60000,
    })),
    startTime: performance.now(),
    rafId: 0,
  };

  const updateFog = (now) => {
    if (!landingFogState) {
      return;
    }
    const elapsed = now - landingFogState.startTime;
    landingFogState.layers.forEach((layer) => {
      const x = computeLandingFogX(elapsed, layer.initialX, layer.initialDuration, layer.loopStartX, layer.loopDuration);
      layer.el.style.left = `${x}px`;
    });
    landingFogState.rafId = requestAnimationFrame(updateFog);
  };

  landingFogState.rafId = requestAnimationFrame(updateFog);
}

function computeLandingFogX(elapsedMs, initialX, initialDuration, loopStartX, loopDuration) {
  if (elapsedMs <= initialDuration) {
    const progress = clampNumber(elapsedMs / initialDuration, 0, 1);
    return initialX + (-1500 - initialX) * progress;
  }
  const loopElapsed = (elapsedMs - initialDuration) % loopDuration;
  const loopProgress = clampNumber(loopElapsed / loopDuration, 0, 1);
  return loopStartX + (-1500 - loopStartX) * loopProgress;
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
      doorEnterPath: normalizeMediaPath(doorEnter),
      startYRotation: Number.parseFloat(roomNode.getAttribute("startYRotation") ?? "0"),
      yRotationMin: Number.parseFloat(roomNode.getAttribute("yRotationMin") ?? "-360"),
      yRotationMax: Number.parseFloat(roomNode.getAttribute("yRotationMax") ?? "360"),
      xRotationMin: Number.parseFloat(roomNode.getAttribute("xRotationMin") ?? "-4"),
      xRotationMax: Number.parseFloat(roomNode.getAttribute("xRotationMax") ?? "23"),
      cameraHeight: Number.parseFloat(roomNode.getAttribute("cameraHeight") ?? "50"),
      exitX: Number.parseFloat(roomNode.getAttribute("exitX") ?? "100"),
      exitY: Number.parseFloat(roomNode.getAttribute("exitY") ?? "100"),
      exitWidth: Number.parseFloat(roomNode.getAttribute("exitWidth") ?? "270"),
      popAsset: roomNode.getAttribute("popAsset") ?? "",
      bgObjects: Array.from(roomNode.querySelectorAll(":scope > TEXTURES > TEXTURE")).map((textureNode) => ({
        path: textureNode.textContent?.trim() ?? "",
        rotationY: Number.parseFloat(textureNode.getAttribute("rotationY") ?? "0"),
      })),
      bgFlashLightObjects: Array.from(roomNode.querySelectorAll(":scope > FLASHLIGHT > TEXTURE, :scope > FLASHLIGHT > FLASHLIGHT")).map((textureNode) => ({
        path: textureNode.textContent?.trim() ?? "",
        rotationY: Number.parseFloat(textureNode.getAttribute("rotationY") ?? "0"),
      })),
      items: Array.from(roomNode.querySelectorAll(":scope > OBJECTS > OBJECT")).map((itemNode) => ({
        id: itemNode.getAttribute("id") ?? "",
        type: itemNode.getAttribute("type") ?? "photo",
        inRoomFlatX: Number.parseFloat(itemNode.getAttribute("xPos") ?? "0"),
        inRoomFlatY: Number.parseFloat(itemNode.getAttribute("yPos") ?? "0"),
        inRoomAssetPath: itemNode.getAttribute("assetPath") ?? "",
        inRoomAssetWidth: Number.parseFloat(itemNode.getAttribute("width") ?? "0"),
        inRoomAssetHeight: Number.parseFloat(itemNode.getAttribute("height") ?? "0"),
        largeViewAssetPaths: Array.from(itemNode.querySelectorAll(":scope > LARGEVIEWASSET")).map((node) => normalizeMediaPath(node.getAttribute("path") ?? "")),
        largeViewNodes: Array.from(itemNode.querySelectorAll(":scope > LARGEVIEWASSET")).map((node) => ({
          path: normalizeMediaPath(node.getAttribute("path") ?? ""),
          text: node.getAttribute("text") ?? "",
          link: node.getAttribute("link") ?? "",
        })),
        overColor: itemNode.getAttribute("overColor") ?? "",
        overAlpha: Number.parseFloat(itemNode.getAttribute("overAlpha") ?? "0.8"),
        useArc: itemNode.getAttribute("useArc") === "true",
        isActive: itemNode.getAttribute("isActive") !== "false",
        defineRadius: Number.parseFloat(itemNode.getAttribute("defineRadius") ?? "0.98"),
        special: itemNode.getAttribute("special") ?? "",
      })),
      sounds: Array.from(roomNode.querySelectorAll(":scope > SOUNDS > SOUND")).map((soundNode) => ({
        id: soundNode.getAttribute("id") ?? "",
        assetPath: normalizeMediaPath(soundNode.getAttribute("assetPath") ?? ""),
        direction: Number.parseFloat(soundNode.getAttribute("direction") ?? "0"),
        volume: Number.parseFloat(soundNode.getAttribute("volume") ?? "1"),
        triggerOnExit: soundNode.getAttribute("triggerOnExit") === "true",
      })),
    };
  });

  const criticalMedia = new Set();
  const deferredMedia = new Set();

  criticalMedia.add(normalizeMediaPath(state.outsideAmbientPath));
  state.rooms.forEach((room) => {
    criticalMedia.add(normalizeMediaPath(room.doorEnterPath));
  });
  for (let index = 0; index < 14; index += 1) {
    criticalMedia.add(`assets/videos/trans/right_${index}.mp4`);
    criticalMedia.add(`assets/videos/trans/left_${index}.mp4`);
  }

  xml.querySelectorAll("ROOMS > ROOM OBJECT LARGEVIEWASSET, ROOMS > ROOM SOUND, EXTERNALROOMSOUND > SOUND").forEach((node) => {
    const src = normalizeMediaPath(node.getAttribute("path") ?? node.getAttribute("assetPath") ?? "");
    if (!src || criticalMedia.has(src)) {
      return;
    }
    deferredMedia.add(src);
  });

  state.criticalMediaManifest = [...criticalMedia].filter(Boolean);
  state.deferredMediaManifest = [...deferredMedia].filter(Boolean);
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
    const cached = state.imageCache.get(src);
    if (cached?.complete) {
      resolve(cached);
      return;
    }
    const image = new Image();
    image.onload = () => {
      state.imageCache.set(src, image);
      resolve(image);
    };
    image.onerror = reject;
    image.src = src;
  });
}

async function preloadMediaManifest(manifest, options = {}) {
  const { concurrency = 3, onItemComplete = () => {} } = options;
  if (!manifest.length) {
    return;
  }

  let cursor = 0;
  const workerCount = Math.min(concurrency, manifest.length);
  await Promise.all(Array.from({ length: workerCount }, async () => {
    while (cursor < manifest.length) {
      const index = cursor;
      cursor += 1;
      const src = manifest[index];
      await warmMediaAsset(src);
      onItemComplete(src);
    }
  }));
}

async function warmMediaAsset(src) {
  if (!src || state.preloadedMedia.has(src) || state.failedMedia.has(src)) {
    return;
  }

  try {
    const response = await fetch(src, { cache: "force-cache" });
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    await response.blob();
    state.preloadedMedia.add(src);
  } catch (error) {
    state.failedMedia.add(src);
    console.warn(`Failed to preload media: ${src}`, error);
  }
}

function normalizeMediaPath(src) {
  return src.replace(/\.flv$/i, ".mp4").trim();
}

function delay(ms) {
  return new Promise((resolve) => window.setTimeout(resolve, ms));
}

function createDeferred() {
  let resolve;
  let reject;
  const promise = new Promise((res, rej) => {
    resolve = res;
    reject = rej;
  });
  return { promise, resolve, reject };
}

function clampNumber(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function wrapDegrees(value) {
  return positiveMod(value + 180, 360) - 180;
}

function shortestAngularDelta(target, current) {
  let delta = wrapDegrees(target) - wrapDegrees(current);
  if (delta > 180) {
    delta -= 360;
  }
  if (delta < -180) {
    delta += 360;
  }
  return delta;
}

function lerp(start, end, ratio) {
  return start + (end - start) * ratio;
}

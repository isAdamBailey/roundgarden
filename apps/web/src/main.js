import * as THREE from 'three';
import './style.css';

const app = document.querySelector('#app');
app.innerHTML = `
  <main class="game-shell" aria-label="Roundgarden game">
    <canvas class="world" aria-label="A three-dimensional garden surrounding you"></canvas>
    <div class="vignette" aria-hidden="true"></div>
    <header class="topbar">
      <a class="wordmark" href="#" aria-label="Roundgarden home"><span class="wordmark-icon"><i></i><i></i><i></i></span><span>roundgarden</span></a>
      <div class="round-state" id="roundState"><span class="state-dot"></span><span id="stateText">THE GARDEN IS RESTING</span></div>
      <div class="header-controls">
        <button class="pause-button" id="pauseButton" aria-label="Pause round" title="Pause round" hidden><svg class="pause-glyph" viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5v14M16 5v14"/></svg><span class="pause-text">Pause</span></button>
        <button class="sound-button" id="soundButton" aria-label="Toggle vaporization sounds" title="Toggle vaporization sounds"><svg viewBox="0 0 24 24"><path d="M4 10v4h4l5 4V6l-5 4H4Z"/><path d="M16 9a5 5 0 0 1 0 6M18.5 6.5a9 9 0 0 1 0 11"/></svg></button>
      </div>
    </header>

    <section class="game-hud" id="gameHud" aria-label="Round status">
      <div class="score-block"><span class="hud-label">SCORE</span><span class="score-number" id="score" aria-live="polite">0</span><span class="score-unit">POINTS</span></div>
      <div class="timer-block"><span class="hud-label">TIME LEFT</span><span class="timer-number" id="timer">01:00</span><div class="timer-track"><i id="timerFill"></i></div></div>
    </section>

    <div class="reticle" id="reticle" aria-hidden="true"><span class="reticle-ring"></span><span class="reticle-core"></span><span class="reticle-tick tick-top"></span><span class="reticle-tick tick-right"></span><span class="reticle-tick tick-bottom"></span><span class="reticle-tick tick-left"></span><span class="reticle-label" id="reticleLabel">LOOK ALL AROUND</span></div>
    <div class="catch-flash" id="catchFlash" aria-hidden="true">+100</div>

    <section class="welcome-panel" id="welcomePanel">
      <div class="welcome-copy">
        <div class="title-mark"><span></span><span></span><span></span><span></span><span></span></div>
        <h1>The garden <span class="mobile-title-break"><br /></span>goes all the way <em>around.</em></h1>
        <p class="intro">Float inside a whimsical garden that surrounds you. Look all around as strange garden oddities drift close.</p>
        <div class="howto">
          <div class="howto-step"><span class="step-glyph aim-glyph"><i></i></span><span><b>LOOK AROUND</b><small>Drag to turn. The garden goes all the way around.</small></span></div>
          <div class="howto-step"><span class="step-glyph catch-glyph"><i></i></span><span><b>VAPORIZE AN ODDITY</b><small>Center a nearby oddity and click or tap to turn it into light.</small></span></div>
        </div>
        <button class="start-button" id="startButton"><span>Enter the garden</span><svg viewBox="0 0 24 24"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></button>
        <div class="gentle-note"><span class="note-spark">✳</span><span>One minute. Look close. Score high.</span></div>
      </div>
    </section>

    <div class="sr-only" id="targetReadout" aria-live="polite" aria-atomic="true"></div>

    <section class="pause-panel is-hidden" id="pausePanel" aria-labelledby="pauseTitle" aria-live="polite">
      <h2 id="pauseTitle">Take a <em>breath.</em></h2>
      <p class="end-copy">Your time and score are waiting here.</p>
      <p class="round-summary"><span>SCORE <strong id="pausedScore">0</strong></span><span>TIME LEFT <strong id="pausedTime">01:00</strong></span></p>
      <div class="round-actions">
        <button class="start-button" id="resumeButton"><span>Resume round</span><svg viewBox="0 0 24 24"><path d="m8 5 11 7-11 7Z"/></svg></button>
        <button class="text-button" id="leaveButton">Leave round</button>
      </div>
    </section>

    <section class="end-panel is-hidden" id="endPanel" aria-live="polite">
      <div class="end-orb" aria-hidden="true"><span></span></div>
      <h2>One minute,<br /><em>gone in a blink.</em></h2>
      <p class="end-copy">Final score <strong id="finalScore">0</strong><br />Personal best <strong id="bestScore">0</strong></p>
      <div class="round-actions">
        <button class="start-button replay-button" id="replayButton"><span>Go around again</span><svg viewBox="0 0 24 24"><path d="M4 12h15m-6-6 6 6-6 6"/></svg></button>
        <button class="text-button" id="endLeaveButton">Leave round</button>
      </div>
    </section>
    <div class="bottom-hint" id="bottomHint"><span class="hint-icon">⌖</span><span>DRAG TO LOOK ALL AROUND</span><span class="hint-divider"></span><span>CLICK OR TAP A NEARBY ODDITY TO VAPORIZE IT</span></div>
    <div class="toast" id="toast" role="status"></div>
  </main>`;

const canvas = document.querySelector('.world');
const scene = new THREE.Scene();
scene.background = new THREE.Color('#070d13');
const camera = new THREE.PerspectiveCamera(74, 1, 0.1, 180);
camera.position.set(0, 0, 0);
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: false, powerPreference: 'high-performance' });
renderer.setPixelRatio(Math.min(devicePixelRatio, matchMedia('(max-width: 760px)').matches ? 1.35 : 1.75));
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
renderer.toneMappingExposure = 1.24;
renderer.shadowMap.enabled = true;
renderer.shadowMap.type = THREE.PCFSoftShadowMap;

const palette = ['#e5a744', '#ff8c6f', '#b4e86d', '#e881bd', '#8ddbd0', '#b68deb', '#df7360', '#d77fba', '#72a6dc'];
const colorObjects = palette.map((color) => new THREE.Color(color));
const clock = new THREE.Clock();
const raycaster = new THREE.Raycaster();
raycaster.far = 12.8;
let yaw = 0;
let pitch = 0;
let dragging = false;
let pointerMoved = false;
let active = false;
let paused = false;
let remaining = 60;
let score = 0;
let bestScore = 0;
let lastAnnouncedTarget = '';
let backgroundPausePending = false;
try { bestScore = Number(localStorage.getItem('roundgarden-best-score') || 0) || 0; } catch { /* Local best is optional when storage is unavailable. */ }
let soundOn = false;
let audioContext;
let lastChirp = 0;
const pods = [];
const pickables = [];
const velocities = [];

const domeMaterial = new THREE.ShaderMaterial({
  side: THREE.BackSide,
  transparent: true,
  opacity: .58,
  depthWrite: false,
  uniforms: { uTime: { value: 0 } },
  vertexShader: `varying vec3 vDir; varying vec3 vPos; void main(){ vDir=normalize(position); vPos=position; gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.0); }`,
  fragmentShader: `uniform float uTime; varying vec3 vDir; varying vec3 vPos; void main(){ float h=normalize(vDir).y; vec3 deep=vec3(.012,.032,.031); vec3 mid=vec3(.035,.105,.058); vec3 canopy=vec3(.095,.16,.075); vec3 c=mix(deep,mid,smoothstep(-.6,.22,h)); c=mix(c,canopy,smoothstep(.28,.98,h)); float dapples=sin(vPos.x*.62+sin(vPos.z*.18))*sin(vPos.y*.48+uTime*.025)*.025; c+=vec3(.17,.2,.075)*dapples; vec3 cell=floor(normalize(vDir)*320.0); float star=step(.9993,fract(sin(dot(cell,vec3(12.9898,78.233,37.719)))*43758.5453)); c+=vec3(.33,.42,.55)*star*.5; gl_FragColor=vec4(c,.82); }`
});
const dome = new THREE.Mesh(new THREE.SphereGeometry(58, 56, 40), domeMaterial);
scene.add(dome);

const ambient = new THREE.HemisphereLight('#fff0ce', '#425c2b', 1.15);
scene.add(ambient);
const keyLight = new THREE.DirectionalLight('#ffe7b4', 3.3);
keyLight.position.set(-12, 19, 8);
keyLight.target.position.set(0, 0, 0);
keyLight.castShadow = true;
const shadowResolution = matchMedia('(max-width: 760px)').matches ? 2048 : 4096;
keyLight.shadow.mapSize.set(shadowResolution, shadowResolution);
keyLight.shadow.camera.left = -58;
keyLight.shadow.camera.right = 58;
keyLight.shadow.camera.top = 58;
keyLight.shadow.camera.bottom = -58;
keyLight.shadow.camera.near = .5;
keyLight.shadow.camera.far = 120;
keyLight.shadow.camera.updateProjectionMatrix();
keyLight.shadow.bias = -.00008;
keyLight.shadow.normalBias = .018;
keyLight.shadow.radius = 2.2;
scene.add(keyLight);
scene.add(keyLight.target);
const warmLight = new THREE.PointLight('#ffc985', 8, 30, 2);
warmLight.position.set(5, -3, -6);
scene.add(warmLight);
const glassShell = new THREE.Mesh(new THREE.SphereGeometry(57.2, 40, 32), new THREE.MeshBasicMaterial({ color: '#d7e5ae', transparent: true, opacity: .035, side: THREE.BackSide, depthWrite: false }));
scene.add(glassShell);

function addGreenhouseRibs() {
  const material = new THREE.MeshStandardMaterial({ color: '#bbbe76', roughness: .58, metalness: .12, emissive: '#49472b', emissiveIntensity: .18, transparent: true, opacity: .28 });
  for (let i = 0; i < 7; i++) {
    const azimuth = (i / 7) * Math.PI;
    const points = [];
    for (let j = 0; j <= 100; j++) {
      const angle = (j / 100) * Math.PI * 2;
      points.push(new THREE.Vector3(Math.cos(angle) * Math.cos(azimuth) * 55, Math.sin(angle) * 55, Math.cos(angle) * Math.sin(azimuth) * 55));
    }
    const rib = new THREE.Mesh(new THREE.TubeGeometry(new THREE.CatmullRomCurve3(points), 100, .028, 4, false), material);
    scene.add(rib);
  }
}
addGreenhouseRibs();

function randUnit() {
  const y = Math.random() * 2 - 1;
  const a = Math.random() * Math.PI * 2;
  const radius = Math.sqrt(1 - y * y);
  return new THREE.Vector3(radius * Math.cos(a), y, radius * Math.sin(a));
}
function placeOnShell(object, radius) {
  object.position.copy(randUnit().multiplyScalar(radius));
  object.lookAt(0, 0, 0);
}
function makePollen() {
  const count = 120;
  const geometry = new THREE.IcosahedronGeometry(.075, 1);
  const material = new THREE.MeshBasicMaterial({ color: '#d4d778', transparent: true, opacity: .52 });
  const pollen = new THREE.InstancedMesh(geometry, material, count);
  const dummy = new THREE.Object3D();
  for (let i = 0; i < count; i++) {
    dummy.position.copy(randUnit().multiplyScalar(13 + Math.random() * 30));
    dummy.scale.setScalar(.45 + Math.random() * 1.5);
    dummy.rotation.set(Math.random() * 3, Math.random() * 3, Math.random() * 3);
    dummy.updateMatrix();
    pollen.setMatrixAt(i, dummy.matrix);
  }
  pollen.instanceMatrix.needsUpdate = true;
  scene.add(pollen);
  return pollen;
}
const pollenField = makePollen();

function makeLeafGeometry(across = 8, along = 12) {
  const geometry = new THREE.BufferGeometry();
  const positions = [];
  const indices = [];
  for (let row = 0; row <= along; row++) {
    const v = row / along;
    const halfWidth = Math.sin(Math.PI * v) * .24;
    for (let column = 0; column <= across; column++) {
      const u = column / across * 2 - 1;
      const cup = (1 - u * u) * .07;
      positions.push(u * halfWidth, (v - .5) * .82, cup + Math.sin(v * Math.PI) * .035);
    }
  }
  for (let row = 0; row < along; row++) {
    for (let column = 0; column < across; column++) {
      const a = row * (across + 1) + column;
      const b = a + across + 1;
      indices.push(a, a + 1, b, a + 1, b + 1, b);
    }
  }
  geometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
  geometry.setIndex(indices);
  geometry.computeVertexNormals();
  return geometry;
}
const leafGeometry = makeLeafGeometry();
const coverLeafGeometry = makeLeafGeometry(5, 7);
function makePlantCurve() {
  return new THREE.CatmullRomCurve3([
    new THREE.Vector3(0, 0, 0), new THREE.Vector3(.12, .7, .02),
    new THREE.Vector3(.36, 1.5, -.08), new THREE.Vector3(.22, 2.3, -.12),
    new THREE.Vector3(.52, 3.1, -.04), new THREE.Vector3(.85, 3.2, .12)
  ]);
}
function makeVineCurve() {
  const points = [];
  for (let i = 0; i <= 40; i++) {
    const t = i / 40;
    const angle = t * Math.PI * 2.3;
    const coil = .72 + .2 * Math.sin(t * Math.PI * 3);
    points.push(new THREE.Vector3(Math.cos(angle) * coil, t * 8.5, Math.sin(angle) * coil));
  }
  return new THREE.CatmullRomCurve3(points);
}
function makeGreenhouseGarden() {
  const plantCount = 900;
  const vineCount = 92;
  const stemMaterial = new THREE.MeshStandardMaterial({ color: '#789d3f', roughness: .78, emissive: '#344922', emissiveIntensity: .16 });
  const vineMaterial = new THREE.MeshStandardMaterial({ color: '#8baf45', roughness: .76, emissive: '#3a4c21', emissiveIntensity: .18 });
  const leafMaterials = ['#739d47', '#a4bd50', '#c5cc66', '#477f48', '#82ad70', '#4c9880', '#d0a45d', '#a96f64', '#887ba4'].map((color) => new THREE.MeshStandardMaterial({ color, roughness: .7, emissive: color, emissiveIntensity: .09, side: THREE.DoubleSide }));
  const veinMaterial = new THREE.MeshStandardMaterial({ color: '#d2e690', roughness: .72, emissive: '#6c913e', emissiveIntensity: .16 });
  const branchVeinMaterial = new THREE.MeshStandardMaterial({ color: '#9dbb63', roughness: .78, emissive: '#4d6d31', emissiveIntensity: .1 });
  const petalMaterials = ['#e88ba5', '#f1b850', '#bf9bdf', '#ee8866'].map((color) => new THREE.MeshStandardMaterial({ color, roughness: .58, emissive: color, emissiveIntensity: .14, side: THREE.DoubleSide }));
  const flowerCoreMaterial = new THREE.MeshStandardMaterial({ color: '#ffdb72', roughness: .48, emissive: '#bd7527', emissiveIntensity: .42 });
  const up = new THREE.Vector3(0, 1, 0);
  const leafCapacity = plantCount * 8 + vineCount * 12;
  const leafMeshes = leafMaterials.map((material) => {
    const mesh = new THREE.InstancedMesh(leafGeometry, material, leafCapacity);
    mesh.count = 0;
    mesh.castShadow = true;
    mesh.receiveShadow = true;
    mesh.instanceMatrix.setUsage(THREE.StaticDrawUsage);
    scene.add(mesh);
    return mesh;
  });
  const centralVeinGeometry = new THREE.TubeGeometry(new THREE.CatmullRomCurve3([
    new THREE.Vector3(0, -.4, .09), new THREE.Vector3(0, -.18, .13),
    new THREE.Vector3(0, .05, .13), new THREE.Vector3(0, .28, .12), new THREE.Vector3(0, .4, .075)
  ]), 18, .009, 5, false);
  const centralVeins = new THREE.InstancedMesh(centralVeinGeometry, veinMaterial, leafCapacity);
  centralVeins.count = 0;
  centralVeins.castShadow = true;
  centralVeins.instanceMatrix.setUsage(THREE.StaticDrawUsage);
  scene.add(centralVeins);
  const branchVeinGeometry = new THREE.CylinderGeometry(.0035, .006, 1, 5, 1, false);
  const branchesPerLeaf = 10;
  const branchVeins = new THREE.InstancedMesh(branchVeinGeometry, branchVeinMaterial, leafCapacity * branchesPerLeaf);
  branchVeins.count = 0;
  branchVeins.instanceMatrix.setUsage(THREE.StaticDrawUsage);
  scene.add(branchVeins);
  const leafMarker = new THREE.Object3D();
  const branchMarker = new THREE.Object3D();
  const leafMatrix = new THREE.Matrix4();
  const branchMatrix = new THREE.Matrix4();
  const localY = new THREE.Vector3(0, 1, 0);
  const branchStart = new THREE.Vector3();
  const branchEnd = new THREE.Vector3();
  const branchDirection = new THREE.Vector3();
  const addGrowth = (curve, leafSteps, isVine) => {
    const radial = randUnit();
    const group = new THREE.Group();
    const shellDepth = Math.random();
    const shellRadius = shellDepth < .2 ? 20 + Math.random() * 9 : 31 + Math.random() * 21;
    group.position.copy(radial).multiplyScalar(shellRadius);
    const inward = radial.clone().negate();
    let tangent = new THREE.Vector3().crossVectors(radial, randUnit());
    if (tangent.lengthSq() < .04) tangent.crossVectors(radial, new THREE.Vector3(0, 1, 0));
    tangent.normalize();
    const sideways = new THREE.Vector3().crossVectors(tangent, inward).normalize();
    const plantFrame = new THREE.Matrix4().makeBasis(sideways, tangent, inward);
    group.quaternion.setFromRotationMatrix(plantFrame);
    const scale = 1.02 + Math.random() * .88;
    group.scale.setScalar(scale);
    const stem = new THREE.Mesh(new THREE.TubeGeometry(curve, isVine ? 48 : 24, isVine ? .034 : .043, 6, false), isVine ? vineMaterial : stemMaterial);
    stem.castShadow = true;
    stem.receiveShadow = true;
    group.add(stem);
    group.updateMatrix();
    for (let i = 0; i < leafSteps; i++) {
      const t = .1 + i * (.8 / Math.max(leafSteps - 1, 1));
      const point = curve.getPoint(t);
      const side = i % 2 ? 1 : -1;
      const materialIndex = Math.floor(Math.random() * leafMaterials.length);
      leafMarker.position.set(point.x + side * (.1 + Math.random() * .1), point.y, point.z);
      leafMarker.rotation.set((Math.random() - .5) * .55, Math.random() * .65, side * (.8 + Math.random() * .8));
      const leafSize = (1.35 + Math.random() * 1.3) * (isVine ? .82 : 1.02);
      leafMarker.scale.set(leafSize, leafSize * (.74 + Math.random() * .32), leafSize);
      leafMarker.updateMatrix();
      leafMatrix.multiplyMatrices(group.matrix, leafMarker.matrix);
      const leaves = leafMeshes[materialIndex];
      leaves.setMatrixAt(leaves.count, leafMatrix);
      leaves.count++;
      centralVeins.setMatrixAt(centralVeins.count, leafMatrix);
      centralVeins.count++;
      for (let row = 0; row < branchesPerLeaf / 2; row++) {
        const t = .22 + row * .12;
        const y = (t - .5) * .82;
        const width = Math.sin(Math.PI * t) * .24 * .78;
        for (const sideSign of [-1, 1]) {
          branchStart.set(0, y, .119);
          branchEnd.set(sideSign * width, y + .065, .075 + Math.sin(Math.PI * t) * .025);
          branchDirection.subVectors(branchEnd, branchStart);
          const branchLength = branchDirection.length();
          branchMarker.position.copy(branchStart).add(branchEnd).multiplyScalar(.5);
          branchMarker.quaternion.setFromUnitVectors(localY, branchDirection.normalize());
          branchMarker.scale.set(1, branchLength, 1);
          branchMarker.updateMatrix();
          branchMatrix.multiplyMatrices(leafMatrix, branchMarker.matrix);
          branchVeins.setMatrixAt(branchVeins.count, branchMatrix);
          branchVeins.count++;
        }
      }
    }
    if (!isVine && Math.random() < .12) {
      const center = curve.getPoint(1).add(new THREE.Vector3(0, .08, 0));
      const flowerColor = petalMaterials[Math.floor(Math.random() * petalMaterials.length)];
      for (let i = 0; i < 5; i++) {
        const angle = (i / 5) * Math.PI * 2;
        const petal = new THREE.Mesh(leafGeometry, flowerColor);
        petal.position.set(center.x + Math.cos(angle) * .11, center.y + Math.sin(angle) * .06, center.z + Math.sin(angle) * .11);
        petal.rotation.set(.38, angle, Math.cos(angle) * .5);
        petal.scale.set(.27, .38, .27);
        group.add(petal);
      }
      const flowerCore = new THREE.Mesh(new THREE.SphereGeometry(.075, 10, 8), flowerCoreMaterial);
      flowerCore.position.copy(center);
      group.add(flowerCore);
    }
    scene.add(group);
  };
  for (let i = 0; i < plantCount; i++) addGrowth(makePlantCurve(), 8, false);
  for (let i = 0; i < vineCount; i++) addGrowth(makeVineCurve(), 12, true);

  // A second, shallow leaf layer hugs the inner glass between the larger
  // growths. It visually knits the garden together without adding more stems
  // or shadow casters, and its variation keeps the shell from reading as a wall.
  const compactCanopy = matchMedia('(max-width: 760px), (pointer: coarse)').matches;
  const coverClusters = compactCanopy ? 1800 : 2200;
  const leavesPerCluster = 7;
  const coverMeshes = leafMaterials.map((material) => {
    const mesh = new THREE.InstancedMesh(coverLeafGeometry, material, coverClusters * leavesPerCluster);
    mesh.count = 0;
    mesh.castShadow = false;
    mesh.receiveShadow = true;
    mesh.instanceMatrix.setUsage(THREE.StaticDrawUsage);
    scene.add(mesh);
    return mesh;
  });
  const coverMarker = new THREE.Object3D();
  const coverFrameMatrix = new THREE.Matrix4();
  const coverQuaternion = new THREE.Quaternion();
  const coverLocalRotation = new THREE.Quaternion();
  const coverTangent = new THREE.Vector3();
  const coverSideways = new THREE.Vector3();
  const coverInward = new THREE.Vector3();
  const coverOrigin = new THREE.Vector3();
  for (let i = 0; i < coverClusters; i++) {
    const y = 1 - 2 * ((i + .5) / coverClusters);
    const angle = i * 2.399963229728653;
    const ring = Math.sqrt(1 - y * y);
    const radial = new THREE.Vector3(Math.cos(angle) * ring, y, Math.sin(angle) * ring);
    coverTangent.crossVectors(radial, randUnit());
    if (coverTangent.lengthSq() < .04) coverTangent.crossVectors(radial, new THREE.Vector3(0, 1, 0));
    coverTangent.normalize();
    coverInward.copy(radial).negate();
    coverSideways.crossVectors(coverTangent, coverInward).normalize();
    coverOrigin.copy(radial).multiplyScalar(48.5 + Math.random() * 4.5);
    coverFrameMatrix.makeBasis(coverSideways, coverTangent, coverInward);
    coverQuaternion.setFromRotationMatrix(coverFrameMatrix);
    for (let j = 0; j < leavesPerCluster; j++) {
      const materialIndex = Math.floor(Math.random() * coverMeshes.length);
      const mesh = coverMeshes[materialIndex];
      const angle = (j / leavesPerCluster) * Math.PI * 2 + Math.random() * .48;
      const spread = .35 + Math.random() * 1.35;
      coverMarker.position.copy(coverOrigin)
        .addScaledVector(coverTangent, Math.cos(angle) * spread)
        .addScaledVector(coverSideways, Math.sin(angle) * spread);
      coverLocalRotation.setFromEuler(new THREE.Euler((Math.random() - .5) * .55, (Math.random() - .5) * .55, (Math.random() - .5) * .5));
      coverMarker.quaternion.copy(coverQuaternion).multiply(coverLocalRotation);
      const size = 1.8 + Math.random() * 1.5;
      coverMarker.scale.set(size, size * (.78 + Math.random() * .3), size);
      coverMarker.updateMatrix();
      mesh.setMatrixAt(mesh.count, coverMarker.matrix);
      mesh.count++;
    }
  }
  for (const mesh of coverMeshes) mesh.instanceMatrix.needsUpdate = true;
  for (const mesh of [...leafMeshes, centralVeins, branchVeins]) mesh.instanceMatrix.needsUpdate = true;
}
makeGreenhouseGarden();

// Woody runners follow the inner glass and split through the canopy. Instancing
// keeps the structural layer inexpensive while giving passing pods real depth.
function makeWoodyStructure() {
  const branchCount = 118;
  const segmentGeometry = new THREE.CylinderGeometry(1, 1, 1, 7, 1, false);
  const barkMaterial = new THREE.MeshStandardMaterial({ color: '#715332', roughness: .92, emissive: '#291e12', emissiveIntensity: .08 });
  const edgeMaterial = new THREE.MeshStandardMaterial({ color: '#a07a4b', roughness: .9 });
  const segments = new THREE.InstancedMesh(segmentGeometry, barkMaterial, branchCount * 12);
  const grooves = new THREE.InstancedMesh(segmentGeometry, edgeMaterial, branchCount * 5);
  const joints = new THREE.InstancedMesh(new THREE.IcosahedronGeometry(1, 1), barkMaterial, branchCount * 6);
  segments.castShadow = segments.receiveShadow = true;
  grooves.castShadow = true;
  joints.castShadow = joints.receiveShadow = true;
  const marker = new THREE.Object3D();
  const up = new THREE.Vector3(0, 1, 0);
  const start = new THREE.Vector3();
  const end = new THREE.Vector3();
  const direction = new THREE.Vector3();
  let segmentIndex = 0, grooveIndex = 0, jointIndex = 0;
  const putSegment = (mesh, index, a, b, radius, depth = radius) => {
    direction.subVectors(b, a);
    marker.position.copy(a).add(b).multiplyScalar(.5);
    marker.quaternion.setFromUnitVectors(up, direction.clone().normalize());
    marker.scale.set(radius, direction.length(), depth);
    marker.updateMatrix();
    mesh.setMatrixAt(index, marker.matrix);
  };
  for (let i = 0; i < branchCount; i++) {
    const radial = randUnit();
    let tangent = new THREE.Vector3().crossVectors(radial, randUnit()).normalize();
    if (tangent.lengthSq() < .1) tangent.set(1, 0, 0).cross(radial).normalize();
    const bitangent = new THREE.Vector3().crossVectors(radial, tangent).normalize();
    const origin = radial.clone().multiplyScalar(46 + Math.random() * 5);
    const length = 5.5 + Math.random() * 6.5;
    const bend = (Math.random() - .5) * 2.8;
    const points = [];
    for (let j = 0; j <= 4; j++) {
      const t = j / 4;
      const surface = origin.clone()
        .addScaledVector(tangent, length * t)
        .addScaledVector(bitangent, Math.sin(t * Math.PI) * bend)
        .addScaledVector(radial, -t * (1.8 + Math.random() * .5));
      surface.setLength(origin.length() - t * .8);
      points.push(surface);
      if (j > 0) {
        const radius = (.12 - t * .065) * (.72 + Math.random() * .56);
        putSegment(segments, segmentIndex++, points[j - 1], surface, radius, radius * .92);
        if (j === 2 || j === 4) {
          marker.position.copy(surface);
          const s = radius * 1.7;
          marker.scale.set(s, s, s);
          marker.updateMatrix();
          joints.setMatrixAt(jointIndex++, marker.matrix);
        }
        if (j === 2 && i % 3 === 0) {
          const forkDir = tangent.clone().multiplyScalar(Math.random() > .5 ? 1 : -1)
            .addScaledVector(bitangent, (Math.random() - .5) * .8)
            .addScaledVector(radial, -.2).normalize();
          const forkEnd = surface.clone().addScaledVector(forkDir, 3.5 + Math.random() * 3.5).setLength(surface.length() - .5);
          putSegment(segments, segmentIndex++, surface, forkEnd, radius * .68, radius * .62);
          marker.position.copy(surface).lerp(forkEnd, .48);
          marker.quaternion.setFromUnitVectors(up, forkDir);
          marker.scale.set(.018, 2.2, .018);
          marker.updateMatrix();
          grooves.setMatrixAt(grooveIndex++, marker.matrix);
        }
      }
    }
    if (i % 2 === 0) {
      const p = points[1].clone().lerp(points[2], .5);
      marker.position.copy(p);
      marker.quaternion.setFromUnitVectors(up, tangent);
      marker.scale.set(.013, 1.5, .013);
      marker.updateMatrix();
      grooves.setMatrixAt(grooveIndex++, marker.matrix);
    }
  }
  segments.count = segmentIndex;
  grooves.count = grooveIndex;
  joints.count = jointIndex;
  segments.instanceMatrix.needsUpdate = grooves.instanceMatrix.needsUpdate = joints.instanceMatrix.needsUpdate = true;
  scene.add(segments, grooves, joints);
}
makeWoodyStructure();

const fruitProfiles = [
  [[0, 0], [.1, .04], [.22, .12], [.37, .27], [.4, .42], [.34, .57], [.21, .7], [.13, .78], [.14, .93], [.08, 1.04], [.04, 1.08]],
  [[0, 0], [.06, .03], [.11, .16], [.18, .32], [.26, .51], [.31, .7], [.28, .85], [.19, .96], [.13, 1.04], [.12, 1.17], [.05, 1.22]],
  [[0, 0], [.17, .06], [.3, .18], [.38, .32], [.35, .49], [.25, .61], [.17, .65], [.15, .77], [.22, .88], [.16, 1], [.07, 1.04]],
  [[0, 0], [.09, .07], [.18, .21], [.27, .4], [.29, .59], [.24, .77], [.16, .87], [.17, 1], [.1, 1.1], [.04, 1.12]]
];
function makeFruitGeometry(index) {
  const geometry = new THREE.LatheGeometry(fruitProfiles[index % fruitProfiles.length].map(([radius, y]) => new THREE.Vector2(radius, y)), 36);
  const positions = geometry.attributes.position;
  for (let i = 0; i < positions.count; i++) {
    const x = positions.getX(i);
    const y = positions.getY(i);
    const z = positions.getZ(i);
    const angle = Math.atan2(z, x);
    const rib = 1 + Math.sin(angle * (index % 2 ? 5 : 4) + index) * .07;
    positions.setX(i, x * rib + Math.sin(y * 3.1 + index) * .045);
    positions.setZ(i, z * rib + Math.cos(y * 2.4 + index) * .035);
  }
  geometry.computeVertexNormals();
  return geometry;
}
const podHeart = new THREE.SphereGeometry(.12, 12, 10);
const freckleGeometry = new THREE.SphereGeometry(1, 6, 5);
const podMaterial = new THREE.MeshPhysicalMaterial({ roughness: .48, metalness: 0, clearcoat: .14, clearcoatRoughness: .45, emissiveIntensity: .22 });
const heartMaterial = new THREE.MeshStandardMaterial({ color: '#fff0ad', emissive: '#e8bd67', emissiveIntensity: 1.3, roughness: .25 });
const leafVeinGeometry = new THREE.TubeGeometry(new THREE.CatmullRomCurve3([
  new THREE.Vector3(0, -.36, .11), new THREE.Vector3(0, -.12, .14),
  new THREE.Vector3(0, .1, .14), new THREE.Vector3(0, .36, .1)
]), 12, .008, 4, false);
const podVeinMaterial = new THREE.MeshStandardMaterial({ color: '#d9e99a', roughness: .72, emissive: '#687b3e', emissiveIntensity: .12 });
function radiusAtProfile(profile, y) {
  for (let i = 1; i < profile.length; i++) {
    if (profile[i][1] >= y) {
      const [r0, y0] = profile[i - 1], [r1, y1] = profile[i];
      const t = (y - y0) / Math.max(.001, y1 - y0);
      return THREE.MathUtils.lerp(r0, r1, t);
    }
  }
  return profile[profile.length - 1][0];
}
function createPod(index, initial = false) {
  const group = new THREE.Group();
  const color = colorObjects[index % colorObjects.length];
  const core = new THREE.Mesh(makeFruitGeometry(index), podMaterial.clone());
  core.castShadow = true;
  core.receiveShadow = true;
  core.material.color.copy(color);
  core.material.emissive.copy(color).multiplyScalar(.42);
  const heart = new THREE.Mesh(podHeart, heartMaterial.clone());
  heart.castShadow = true;
  heart.position.set(.04, .54, .25);
  heart.scale.setScalar(.62);
  group.add(core, heart);
  for (let i = 0; i < 3; i++) {
    const leafColor = i === 1 ? '#d8eb75' : '#a0cb4c';
    const leaf = new THREE.Mesh(leafGeometry, new THREE.MeshStandardMaterial({ color: leafColor, roughness: .72, emissive: '#425328', emissiveIntensity: .15, side: THREE.DoubleSide }));
    leaf.scale.setScalar(.62 + Math.random() * .27);
    leaf.position.set(Math.cos(i * Math.PI * 2 / 3) * .15, .97, Math.sin(i * Math.PI * 2 / 3) * .15);
    leaf.rotation.z = -.85 + i * .55;
    leaf.rotation.x = i * .45;
    leaf.receiveShadow = true;
    group.add(leaf);
  }
  const detailGroup = new THREE.Group();
  const freckles = new THREE.InstancedMesh(freckleGeometry, new THREE.MeshStandardMaterial({ color: color.clone().multiplyScalar(.57), roughness: .88 }), 26);
  freckles.castShadow = false;
  const profile = fruitProfiles[index % fruitProfiles.length];
  const freckleMarker = new THREE.Object3D();
  for (let i = 0; i < 26; i++) {
    const y = .15 + Math.random() * .62;
    const angle = Math.random() * Math.PI * 2;
    const radius = radiusAtProfile(profile, y) * (1 + Math.sin(angle * (index % 2 ? 5 : 4) + index) * .065) + .006;
    freckleMarker.position.set(Math.cos(angle) * radius, y, Math.sin(angle) * radius);
    freckleMarker.scale.set(.009 + Math.random() * .011, .009 + Math.random() * .012, .009 + Math.random() * .011);
    freckleMarker.rotation.set(Math.random() * 3, angle, Math.random() * 3);
    freckleMarker.updateMatrix();
    freckles.setMatrixAt(i, freckleMarker.matrix);
  }
  freckles.instanceMatrix.needsUpdate = true;
  detailGroup.add(freckles);
  for (let i = 0; i < 3; i++) {
    const vein = new THREE.Mesh(leafVeinGeometry, podVeinMaterial);
    vein.position.set(Math.cos(i * Math.PI * 2 / 3) * .15, .97, Math.sin(i * Math.PI * 2 / 3) * .15 + .015);
    vein.rotation.z = -.85 + i * .55;
    vein.rotation.x = i * .45;
    vein.visible = false;
    detailGroup.add(vein);
  }
  detailGroup.visible = false;
  group.add(detailGroup);
  const tendrilCurve = new THREE.CatmullRomCurve3([
    new THREE.Vector3(0, .88, 0), new THREE.Vector3(-.08, 1.08, .02),
    new THREE.Vector3(-.24, 1.22, .08), new THREE.Vector3(-.13, 1.34, .13),
    new THREE.Vector3(.02, 1.29, .16)
  ]);
  const tendril = new THREE.Mesh(new THREE.TubeGeometry(tendrilCurve, 16, .018, 5, false), new THREE.MeshStandardMaterial({ color: '#b8d95b', emissive: '#536a21', emissiveIntensity: .18 }));
  tendril.castShadow = true;
  group.add(tendril);
  const direction = randUnit();
  const dist = initial ? 17 + Math.random() * 21 : 25 + Math.random() * 13;
  group.position.copy(direction.multiplyScalar(dist));
  group.quaternion.setFromUnitVectors(new THREE.Vector3(0, 1, 0), randUnit());
  group.scale.setScalar(.75 + Math.random() * .28);
  scene.add(group);
  const value = index >= 10 ? 500 : index >= 6 ? 250 : 100;
  heart.scale.setScalar(value === 500 ? .86 : value === 250 ? .73 : .62);
  const record = { group, core, heart, detailGroup, direction: group.position.clone().normalize(), speed: .33 + Math.random() * .13, phase: Math.random() * 8, caught: false, index, value };
  pods.push(record);
  pickables.push(core);
  return record;
}
for (let i = 0; i < 12; i++) createPod(i, true);

function resize() {
  const { clientWidth: width, clientHeight: height } = canvas;
  if (!width || !height) return;
  camera.aspect = width / height;
  camera.updateProjectionMatrix();
  renderer.setSize(width, height, false);
}
new ResizeObserver(resize).observe(canvas);
resize();

function updateCamera() {
  camera.rotation.order = 'YXZ';
  camera.rotation.y = yaw;
  camera.rotation.x = pitch;
}
function updateAiming() {
  raycaster.setFromCamera(new THREE.Vector2(0, 0), camera);
  const hit = raycaster.intersectObjects(pickables, false)[0];
  const candidate = hit && hit.distance < 12.8 ? pods.find((pod) => pod.core === hit.object) : null;
  const reachable = Boolean(active && !paused && candidate && hit.distance < 12.8);
  document.querySelector('#reticle').classList.toggle('is-ready', reachable);
  const multiplier = reachable ? proximityMultiplier(hit.distance) : 1;
  const targetCopy = reachable ? `${candidate.value} POINTS · ×${multiplier}` : 'LOOK ALL AROUND';
  document.querySelector('#reticleLabel').textContent = targetCopy;
  const readout = reachable ? `Garden oddity worth ${candidate.value} points. ${multiplier} times proximity multiplier.` : '';
  if (readout !== lastAnnouncedTarget) {
    document.querySelector('#targetReadout').textContent = readout;
    lastAnnouncedTarget = readout;
  }
  return reachable ? candidate : null;
}
function proximityMultiplier(distance) {
  if (distance <= 4.2) return 3;
  if (distance <= 8.5) return 2;
  return 1;
}
function vaporizePod() {
  const pod = updateAiming();
  if (!pod) {
    showToast('Center a nearby garden oddity to vaporize it.');
    return;
  }
  const hitDistance = raycaster.intersectObject(pod.core, false)[0]?.distance ?? pod.group.position.length();
  const multiplier = proximityMultiplier(hitDistance);
  const points = pod.value * multiplier;
  score += points;
  document.querySelector('#score').textContent = score.toLocaleString();
  pod.caught = true;
  pod.group.visible = false;
  document.querySelector('#catchFlash').textContent = `+${points.toLocaleString()}`;
  document.querySelector('#catchFlash').classList.remove('show');
  requestAnimationFrame(() => document.querySelector('#catchFlash').classList.add('show'));
  chirp(pod.index);
  showToast(`${pod.value} points ×${multiplier} · vaporized into light`);
  const burst = makeBurst(pod.group.position.clone(), colorObjects[pod.index % colorObjects.length]);
  setTimeout(() => { scene.remove(burst); burst.geometry.dispose(); burst.material.dispose(); }, 700);
  setTimeout(() => resetPod(pod), 760);
}
function resetPod(pod) {
  const direction = randUnit();
  pod.direction.copy(direction);
  pod.group.position.copy(direction.multiplyScalar(32 + Math.random() * 13));
  pod.group.visible = true;
  pod.caught = false;
  pod.speed = .31 + Math.random() * .19;
}
function makeBurst(position, color) {
  const count = 14;
  const geometry = new THREE.OctahedronGeometry(.085, 0);
  const material = new THREE.MeshBasicMaterial({ color, transparent: true, opacity: 1 });
  const burst = new THREE.InstancedMesh(geometry, material, count);
  const marker = new THREE.Object3D();
  const directions = [];
  for (let i = 0; i < count; i++) {
    directions.push(randUnit().multiplyScalar(.038 + Math.random() * .075));
    marker.position.copy(position);
    marker.updateMatrix();
    burst.setMatrixAt(i, marker.matrix);
  }
  burst.instanceMatrix.needsUpdate = true;
  burst.userData.directions = directions;
  burst.userData.age = 0;
  scene.add(burst);
  velocities.push(burst);
  setTimeout(() => velocities.splice(velocities.indexOf(burst), 1), 720);
  return burst;
}
function showToast(message) {
  const toast = document.querySelector('#toast');
  toast.textContent = message;
  toast.classList.add('show');
  clearTimeout(showToast.timeout);
  showToast.timeout = setTimeout(() => toast.classList.remove('show'), 1700);
}

function chirp(n) {
  if (!soundOn) return;
  const now = performance.now();
  if (now - lastChirp < 90) return;
  lastChirp = now;
  try {
    audioContext ??= new AudioContext();
    const osc = audioContext.createOscillator();
    const gain = audioContext.createGain();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(460 + (n % 5) * 72, audioContext.currentTime);
    osc.frequency.exponentialRampToValueAtTime(720 + (n % 4) * 88, audioContext.currentTime + .13);
    gain.gain.setValueAtTime(.0001, audioContext.currentTime);
    gain.gain.exponentialRampToValueAtTime(.11, audioContext.currentTime + .018);
    gain.gain.exponentialRampToValueAtTime(.0001, audioContext.currentTime + .32);
    osc.connect(gain); gain.connect(audioContext.destination);
    osc.start(); osc.stop(audioContext.currentTime + .34);
  } catch { /* Ambient sound is optional. */ }
}

function beginRound() {
  active = true;
  paused = false;
  remaining = 60;
  score = 0;
  document.querySelector('#score').textContent = '0';
  document.querySelector('#timer').textContent = '01:00';
  document.querySelector('#timer').classList.remove('is-urgent');
  document.querySelector('#timerFill').style.transform = 'scaleX(1)';
  document.querySelector('#welcomePanel').classList.add('is-hidden');
  document.querySelector('#endPanel').classList.add('is-hidden');
  document.querySelector('#pausePanel').classList.add('is-hidden');
  document.querySelector('#pauseButton').hidden = false;
  document.querySelector('#gameHud').classList.add('is-active');
  document.querySelector('#reticle').classList.add('is-live');
  document.querySelector('#roundState').classList.add('is-live');
  document.querySelector('#stateText').textContent = 'THE GARDEN IS AWAKE';
  document.querySelector('#bottomHint').classList.add('is-active');
  document.querySelector('#pauseButton').focus({ preventScroll: true });
  showToast('Look all around. The closer you wait, the more an oddity is worth.');
}
function pauseRound(fromBackground = false) {
  if (!active || paused) return;
  paused = true;
  document.querySelector('#pausedScore').textContent = score.toLocaleString();
  const seconds = Math.max(0, Math.ceil(remaining));
  document.querySelector('#pausedTime').textContent = `${String(Math.floor(seconds / 60)).padStart(2, '0')}:${String(seconds % 60).padStart(2, '0')}`;
  document.querySelector('#roundState').classList.remove('is-live');
  document.querySelector('#stateText').textContent = 'ROUND PAUSED';
  document.querySelector('#pausePanel').classList.remove('is-hidden');
  document.querySelector('#pauseButton').hidden = true;
  document.querySelector('#bottomHint').classList.remove('is-active');
  document.querySelector('#reticle').classList.remove('is-ready');
  document.querySelector('#reticleLabel').textContent = 'ROUND PAUSED';
  document.querySelector('#targetReadout').textContent = '';
  lastAnnouncedTarget = '';
  if (!fromBackground) document.querySelector('#resumeButton').focus({ preventScroll: true });
}
function resumeRound() {
  if (!active || !paused) return;
  paused = false;
  document.querySelector('#pausePanel').classList.add('is-hidden');
  document.querySelector('#pauseButton').hidden = false;
  document.querySelector('#roundState').classList.add('is-live');
  document.querySelector('#stateText').textContent = 'THE GARDEN IS AWAKE';
  document.querySelector('#bottomHint').classList.add('is-active');
  document.querySelector('#pauseButton').focus({ preventScroll: true });
}
function leaveRound() {
  active = false;
  paused = false;
  document.querySelector('#pausePanel').classList.add('is-hidden');
  document.querySelector('#endPanel').classList.add('is-hidden');
  document.querySelector('#pauseButton').hidden = true;
  document.querySelector('#gameHud').classList.remove('is-active');
  document.querySelector('#reticle').classList.remove('is-live', 'is-ready');
  document.querySelector('#roundState').classList.remove('is-live');
  document.querySelector('#stateText').textContent = 'THE GARDEN IS RESTING';
  document.querySelector('#bottomHint').classList.remove('is-active');
  document.querySelector('#welcomePanel').classList.remove('is-hidden');
  document.querySelector('#startButton').focus({ preventScroll: true });
}
function finishRound() {
  active = false;
  paused = false;
  document.querySelector('#roundState').classList.remove('is-live');
  document.querySelector('#stateText').textContent = 'THE GARDEN IS RESTING';
  document.querySelector('#gameHud').classList.remove('is-active');
  document.querySelector('#reticle').classList.remove('is-live');
  document.querySelector('#bottomHint').classList.remove('is-active');
  document.querySelector('#pauseButton').hidden = true;
  document.querySelector('#pausePanel').classList.add('is-hidden');
  bestScore = Math.max(bestScore, score);
  try { localStorage.setItem('roundgarden-best-score', String(bestScore)); } catch { /* The current round remains playable without storage. */ }
  document.querySelector('#finalScore').textContent = score.toLocaleString();
  document.querySelector('#bestScore').textContent = bestScore.toLocaleString();
  document.querySelector('#endPanel').classList.remove('is-hidden');
  document.querySelector('#replayButton').focus({ preventScroll: true });
}

document.querySelector('#startButton').addEventListener('click', beginRound);
document.querySelector('#replayButton').addEventListener('click', beginRound);
document.querySelector('#pauseButton').addEventListener('click', () => pauseRound());
document.querySelector('#resumeButton').addEventListener('click', resumeRound);
document.querySelector('#leaveButton').addEventListener('click', leaveRound);
document.querySelector('#endLeaveButton').addEventListener('click', leaveRound);
document.querySelector('#soundButton').addEventListener('click', () => {
  soundOn = !soundOn;
  document.querySelector('#soundButton').classList.toggle('is-on', soundOn);
  document.querySelector('#soundButton').setAttribute('aria-label', soundOn ? 'Mute vaporization sounds' : 'Enable vaporization sounds');
  if (soundOn) chirp(0);
});

let pointerStartX = 0;
let pointerStartY = 0;
let previousX = 0;
let previousY = 0;
canvas.addEventListener('pointerdown', (event) => {
  if (event.button !== 0 || paused) return;
  dragging = true;
  pointerMoved = false;
  pointerStartX = previousX = event.clientX;
  pointerStartY = previousY = event.clientY;
  canvas.setPointerCapture(event.pointerId);
});
canvas.addEventListener('pointermove', (event) => {
  if (!dragging || paused) return;
  const dx = event.clientX - previousX;
  const dy = event.clientY - previousY;
  previousX = event.clientX;
  previousY = event.clientY;
  if (Math.hypot(event.clientX - pointerStartX, event.clientY - pointerStartY) > 7) pointerMoved = true;
  if (pointerMoved) {
    yaw -= dx * .0038;
    pitch = THREE.MathUtils.clamp(pitch - dy * .0038, -1.45, 1.45);
    updateCamera();
  }
});
canvas.addEventListener('pointerup', () => {
  if (!dragging) return;
  dragging = false;
  if (!pointerMoved && active && !paused) vaporizePod();
});
canvas.addEventListener('pointercancel', () => { dragging = false; });
canvas.addEventListener('lostpointercapture', () => { dragging = false; });

function animate() {
  requestAnimationFrame(animate);
  const dt = Math.min(clock.getDelta(), .05);
  const t = clock.elapsedTime;
  domeMaterial.uniforms.uTime.value = t;
  pollenField.rotation.y = t * .006;
  pollenField.rotation.x = Math.sin(t * .09) * .045;
  for (const pod of pods) {
    if (pod.caught) continue;
    const approach = paused ? 0 : active ? 1 : .3;
    pod.group.position.addScaledVector(pod.direction, -pod.speed * approach * dt);
    const breathe = 1 + Math.sin(t * 2 + pod.phase) * .045;
    const dist = pod.group.position.length();
    const scale = THREE.MathUtils.clamp((31 / Math.max(dist, 1)) ** .4, .8, 1.85) * breathe;
    pod.group.scale.setScalar(scale);
    pod.detailGroup.visible = dist < 19;
    for (let i = 1; i < pod.detailGroup.children.length; i++) pod.detailGroup.children[i].visible = dist < 11.5;
    pod.group.rotation.y += dt * .15;
    const shimmer = .3 + Math.sin(t * 2.2 + pod.phase) * .14 + (dist < 12.8 ? .55 : 0);
    pod.core.material.emissiveIntensity = shimmer;
    pod.heart.material.emissiveIntensity = (pod.value === 500 ? 1.85 : pod.value === 250 ? 1.45 : 1.15) + shimmer;
    if (!paused && dist < 1.45) resetPod(pod);
  }
  const burstMarker = new THREE.Object3D();
  for (const burst of velocities) {
    burst.userData.age += dt;
    for (let i = 0; i < burst.userData.directions.length; i++) {
      const d = burst.userData.directions[i];
      burst.getMatrixAt(i, burstMarker.matrix);
      burstMarker.matrix.decompose(burstMarker.position, burstMarker.quaternion, burstMarker.scale);
      burstMarker.position.add(d);
      burstMarker.scale.multiplyScalar(.994);
      burstMarker.updateMatrix();
      burst.setMatrixAt(i, burstMarker.matrix);
    }
    burst.instanceMatrix.needsUpdate = true;
    burst.material.opacity = Math.max(0, 1 - burst.userData.age / .7);
  }
  if (active && !paused) {
    remaining -= dt;
    const display = Math.max(0, Math.ceil(remaining));
    const minutes = Math.floor(display / 60);
    const seconds = display % 60;
    document.querySelector('#timer').textContent = `${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
    document.querySelector('#timerFill').style.transform = `scaleX(${Math.max(0, remaining / 60)})`;
    if (remaining <= 10) document.querySelector('#timer').classList.toggle('is-urgent', display <= 10);
    if (remaining <= 0) finishRound();
    updateAiming();
  }
  renderer.render(scene, camera);
}
animate();

document.addEventListener('visibilitychange', () => {
  if (document.hidden && active && !paused) {
    pauseRound(true);
    backgroundPausePending = true;
  } else if (!document.hidden && backgroundPausePending && paused) {
    backgroundPausePending = false;
    document.querySelector('#resumeButton').focus({ preventScroll: true });
    showToast('Paused while you were away. Your time and score are safe.');
  }
});
document.addEventListener('keydown', (event) => {
  if (event.key !== 'Escape') return;
  if (active && paused) resumeRound();
  else if (active) pauseRound();
});

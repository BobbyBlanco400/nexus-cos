import * as THREE from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';

const scene = new THREE.Scene();
scene.background = new THREE.Color(0x03030a);

const camera = new THREE.PerspectiveCamera(
  60,
  window.innerWidth / window.innerHeight,
  0.1,
  100
);
camera.position.z = 6;

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// Hologram shader material
const holoUniforms = {
  time: { value: 0.0 }
};

const holoMaterial = new THREE.ShaderMaterial({
  uniforms: holoUniforms,
  vertexShader: `
    varying vec2 vUv;
    void main() {
      vUv = uv;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0);
    }
  `,
  fragmentShader: `
    uniform float time;
    varying vec2 vUv;

    float hash(vec2 p) {
      p = fract(p * vec2(123.34, 456.21));
      p += dot(p, p + 45.32);
      return fract(p.x * p.y);
    }

    void main() {
      // Gradient
      vec3 left = vec3(0.0, 0.94, 1.0);
      vec3 right = vec3(0.48, 0.0, 1.0);
      vec3 baseColor = mix(left, right, vUv.x);

      // Pulse
      float pulse = 0.5 + 0.5 * sin(time * 0.8);

      // Noise flicker
      float n = hash(vUv * 500.0 + time * 5.0);
      float flicker = mix(0.9, 1.1, n);

      // Rim approximation
      float centerDist = length(vUv - 0.5);
      float rim = smoothstep(0.6, 0.2, centerDist);

      vec3 color = baseColor;
      color *= pulse * flicker;
      color += vec3(0.0, 1.0, 1.0) * rim * 0.25;

      gl_FragColor = vec4(color, 0.95);
    }
  `,
  transparent: true
});

let logo = null;

// Load GLTF logo
const loader = new GLTFLoader();
loader.load(
  '../assets/3d/logo.glb',
  (gltf) => {
    logo = gltf.scene;
    logo.traverse((child) => {
      if (child.isMesh) {
        child.material = holoMaterial;
      }
    });
    scene.add(logo);
  },
  undefined,
  (error) => {
    console.error('Error loading GLTF:', error);
  }
);

function onWindowResize() {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
}
window.addEventListener('resize', onWindowResize);

function animate() {
  requestAnimationFrame(animate);
  holoUniforms.time.value += 0.01;

  if (logo) {
    logo.rotation.y += 0.005;
  }

  renderer.render(scene, camera);
}

animate();

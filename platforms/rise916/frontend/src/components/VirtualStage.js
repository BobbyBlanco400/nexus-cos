import React, { useRef } from 'react';
import { Canvas, useFrame } from '@react-three/fiber';
import { OrbitControls, PerspectiveCamera } from '@react-three/drei';

function Stage() {
  const meshRef = useRef();
  
  useFrame((state, delta) => {
    if (meshRef.current) {
      meshRef.current.rotation.y += delta * 0.2;
    }
  });
  
  return (
    <group>
      {/* Stage platform */}
      <mesh position={[0, 0, 0]} ref={meshRef}>
        <boxGeometry args={[5, 0.5, 5]} />
        <meshStandardMaterial color="#FF6F61" />
      </mesh>
      
      {/* Spotlights */}
      <pointLight position={[0, 5, 0]} intensity={1} color="#FFD700" />
      <pointLight position={[3, 3, 3]} intensity={0.5} color="#FF6F61" />
      <pointLight position={[-3, 3, 3]} intensity={0.5} color="#FF6F61" />
      
      {/* Ambient light */}
      <ambientLight intensity={0.3} />
    </group>
  );
}

function VirtualStage() {
  return (
    <div className="virtual-stage-container bg-black py-16">
      <div className="container mx-auto px-6">
        <h2 className="text-4xl font-bold text-center mb-8" style={{ color: '#FF6F61' }}>
          3D Virtual Performance Stage
        </h2>
        <div className="stage-canvas" style={{ height: '500px' }}>
          <Canvas>
            <PerspectiveCamera makeDefault position={[0, 5, 10]} />
            <OrbitControls enableZoom={true} />
            <Stage />
          </Canvas>
        </div>
        <p className="text-center mt-6 text-gray-300">
          Experience live performances in our browser-based 3D virtual stage
        </p>
      </div>
    </div>
  );
}

export default VirtualStage;

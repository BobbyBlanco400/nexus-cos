import React from 'react';
import Svg, { Defs, LinearGradient, Stop, Circle, Polygon, Line, Text } from 'react-native-svg';

interface NexusLogoProps {
  width?: number;
  height?: number;
}

export default function NexusLogo({ width = 60, height = 60 }: NexusLogoProps) {
  return (
    <Svg width={width} height={height} viewBox="0 0 200 200">
      <Defs>
        <LinearGradient id="nexusGradient" x1="0%" y1="0%" x2="100%" y2="100%">
          <Stop offset="0%" stopColor="#41D1FF" stopOpacity="1" />
          <Stop offset="50%" stopColor="#BD34FE" stopOpacity="1" />
          <Stop offset="100%" stopColor="#FFA800" stopOpacity="1" />
        </LinearGradient>
      </Defs>
      
      {/* Background circle */}
      <Circle cx="100" cy="100" r="95" fill="url(#nexusGradient)" opacity="0.1"/>
      
      {/* Main hexagon structure */}
      <Polygon 
        points="100,20 170,60 170,140 100,180 30,140 30,60" 
        fill="none" 
        stroke="url(#nexusGradient)" 
        strokeWidth="3"
      />
      
      {/* Inner connection nodes */}
      <Circle cx="100" cy="100" r="8" fill="url(#nexusGradient)"/>
      <Circle cx="100" cy="50" r="5" fill="url(#nexusGradient)"/>
      <Circle cx="150" cy="75" r="5" fill="url(#nexusGradient)"/>
      <Circle cx="150" cy="125" r="5" fill="url(#nexusGradient)"/>
      <Circle cx="100" cy="150" r="5" fill="url(#nexusGradient)"/>
      <Circle cx="50" cy="125" r="5" fill="url(#nexusGradient)"/>
      <Circle cx="50" cy="75" r="5" fill="url(#nexusGradient)"/>
      
      {/* Connection lines */}
      <Line x1="100" y1="100" x2="100" y2="50" stroke="url(#nexusGradient)" strokeWidth="2" opacity="0.7"/>
      <Line x1="100" y1="100" x2="150" y2="75" stroke="url(#nexusGradient)" strokeWidth="2" opacity="0.7"/>
      <Line x1="100" y1="100" x2="150" y2="125" stroke="url(#nexusGradient)" strokeWidth="2" opacity="0.7"/>
      <Line x1="100" y1="100" x2="100" y2="150" stroke="url(#nexusGradient)" strokeWidth="2" opacity="0.7"/>
      <Line x1="100" y1="100" x2="50" y2="125" stroke="url(#nexusGradient)" strokeWidth="2" opacity="0.7"/>
      <Line x1="100" y1="100" x2="50" y2="75" stroke="url(#nexusGradient)" strokeWidth="2" opacity="0.7"/>
      
      {/* Text */}
      <Text x="100" y="110" textAnchor="middle" fill="url(#nexusGradient)" fontFamily="Arial, sans-serif" fontSize="14" fontWeight="bold">NEXUS</Text>
      <Text x="100" y="125" textAnchor="middle" fill="url(#nexusGradient)" fontFamily="Arial, sans-serif" fontSize="10">COS</Text>
    </Svg>
  );
}
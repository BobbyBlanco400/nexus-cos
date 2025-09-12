import React from 'react';
import { View, Text, Image } from 'react-native';
import logo from '../../assets/logos/main_logo.png';

export default function Splash() {
  return (
    <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <Image source={logo} style={{ width: 200, height: 200 }} />
      <Text>Welcome to Nexus</Text>
    </View>
  );
}

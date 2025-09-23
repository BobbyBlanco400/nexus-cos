import React, { useEffect, useState } from "react";
import { NavigationContainer } from "@react-navigation/native";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { View, ActivityIndicator } from "react-native";

// Screens
import HomeScreen from "./screens/HomeScreen";
import BrowseScreen from "./screens/BrowseScreen";
import SearchScreen from "./screens/SearchScreen";
import ProfileScreen from "./screens/ProfileScreen";
import MediaPlayerScreen from "./screens/MediaPlayerScreen";
import SplashScreen from "./screens/SplashScreen";

// Navigation
import BottomTabs from "./navigation/BottomTabs";

// Media Player
import MediaPlayer from "./components/MediaPlayer";

const Tab = createBottomTabNavigator();

export default function App() {
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const timer = setTimeout(() => setIsLoading(false), 2000); // 2s splash
    return () => clearTimeout(timer);
  }, []);

  if (isLoading) {
    return <SplashScreen />;
  }

  return (
    <NavigationContainer>
      <View style={{ flex: 1 }}>
        <BottomTabs />
        <MediaPlayer />
      </View>
    </NavigationContainer>
  );
}

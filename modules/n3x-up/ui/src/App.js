import React, { useEffect } from "react";
import { AnchorIntro } from "./components/AnchorIntro";
import { GuestSpotlight } from "./components/GuestSpotlight";
import { CreativeSet } from "./components/CreativeSet";
import { WrapUp } from "./components/WrapUp";
import { AIHost } from "./components/AIHost";
import { AIEngine } from "./services/AIEngine";
import { SpatialIntegration } from "./services/SpatialIntegration";
import { SocialClipGenerator } from "./services/SocialClipGenerator";

export const App = () => {
  const aiHost = new AIHost();
  const aiEngine = new AIEngine();
  const spatial = new SpatialIntegration();
  const social = new SocialClipGenerator();

  useEffect(() => {
    aiHost.addPrompt(
      0,
      "Welcome to N3X-UP: Independently Launch Day Finale"
    );
    aiEngine.queuePrompt(
      5,
      "freestyle",
      "Rise Sacramento 916 — drop a line on independence"
    );
    aiEngine.queuePrompt(
      20,
      "freestyle",
      "Bobby Blanco live creative set — highlight culture"
    );
    aiEngine.queuePrompt(
      40,
      "motivational",
      "Big Wood — words of wisdom and inspiration"
    );
    aiEngine.queuePrompt(
      55,
      "wrapup",
      "Closeout Launch Day and celebrate creators"
    );

    spatial.addGuest("Rise Sacramento 916", "avatar1");
    spatial.addGuest("Big Wood", "avatar2");
    spatial.renderScene();

    social.addClip(5, "freestyle", "Rise Sacramento 916 independence bar pull");
    social.addClip(20, "freestyle", "Bobby Blanco culture highlight sequence");
    social.addClip(40, "motivational", "Big Wood faith and fitness moment");
    social.addClip(55, "wrapup", "Launch Day finale celebration reel");
    social.exportClips();
  }, []);

  return (
    <div className="app">
      <AnchorIntro />
      <GuestSpotlight guestName="Rise Sacramento 916" segmentTime={15} />
      <CreativeSet anchorName="Bobby Blanco" duration={15} />
      <GuestSpotlight
        guestName="Big Wood (Faith Through Fitness / CODE Movement)"
        segmentTime={15}
      />
      <WrapUp />
    </div>
  );
};

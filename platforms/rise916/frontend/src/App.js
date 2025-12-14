import React from 'react';
import NavBar from './components/NavBar';
import VirtualStage from './components/VirtualStage';
import ArtistShowcase from './components/ArtistShowcase';
import CommunityHub from './components/CommunityHub';
import './App.css';

function App() {
  return (
    <div className="App">
      <NavBar />
      <main>
        <section id="virtual-stage">
          <VirtualStage />
        </section>
        <section id="artist-showcase">
          <ArtistShowcase />
        </section>
        <section id="community-hub">
          <CommunityHub />
        </section>
      </main>
    </div>
  );
}

export default App;

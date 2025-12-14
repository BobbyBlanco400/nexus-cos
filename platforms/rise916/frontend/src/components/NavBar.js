import React from 'react';

function NavBar() {
  return (
    <nav className="bg-black text-white shadow-lg">
      <div className="container mx-auto px-6 py-4">
        <div className="flex justify-between items-center">
          <div className="flex items-center">
            <h1 className="text-2xl font-bold" style={{ color: '#FF6F61' }}>
              Rise Sacramento
            </h1>
            <span className="ml-2" style={{ color: '#FFD700' }}>
              VoicesOfThe916
            </span>
          </div>
          <div className="flex space-x-6">
            <a href="#virtual-stage" className="hover:text-orange-500 transition">
              Virtual Stage
            </a>
            <a href="#artist-showcase" className="hover:text-orange-500 transition">
              Artists
            </a>
            <a href="#community-hub" className="hover:text-orange-500 transition">
              Community
            </a>
            <a 
              href="https://www.instagram.com/risesacramento/" 
              target="_blank" 
              rel="noopener noreferrer"
              className="hover:text-orange-500 transition"
            >
              Instagram
            </a>
          </div>
        </div>
      </div>
    </nav>
  );
}

export default NavBar;

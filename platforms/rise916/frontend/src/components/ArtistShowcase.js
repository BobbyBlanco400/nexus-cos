import React, { useState, useEffect } from 'react';

function ArtistShowcase() {
  const [artists, setArtists] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  
  useEffect(() => {
    // Fetch artists from backend API
    fetch('http://localhost:3001/api/artists')
      .then(response => response.json())
      .then(data => {
        if (data.success) {
          setArtists(data.data);
        }
        setLoading(false);
      })
      .catch(err => {
        console.error('Error fetching artists:', err);
        setError('Failed to load artists');
        setLoading(false);
      });
  }, []);
  
  if (loading) {
    return (
      <div className="artist-showcase bg-gray-900 py-16">
        <div className="container mx-auto px-6">
          <h2 className="text-4xl font-bold text-center mb-12" style={{ color: '#FF6F61' }}>
            Featured Artists
          </h2>
          <p className="text-center text-gray-300">Loading artists...</p>
        </div>
      </div>
    );
  }
  
  if (error) {
    return (
      <div className="artist-showcase bg-gray-900 py-16">
        <div className="container mx-auto px-6">
          <h2 className="text-4xl font-bold text-center mb-12" style={{ color: '#FF6F61' }}>
            Featured Artists
          </h2>
          <p className="text-center text-red-400">{error}</p>
        </div>
      </div>
    );
  }
  
  return (
    <div className="artist-showcase bg-gray-900 py-16">
      <div className="container mx-auto px-6">
        <h2 className="text-4xl font-bold text-center mb-12" style={{ color: '#FF6F61' }}>
          Featured Artists from the 916
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {artists.map(artist => (
            <div 
              key={artist.id} 
              className="artist-card bg-gray-800 rounded-lg p-6 shadow-lg hover:shadow-2xl transition"
              style={{ borderTop: '3px solid #FF6F61' }}
            >
              <h3 className="text-2xl font-bold mb-2" style={{ color: '#FFD700' }}>
                {artist.name}
              </h3>
              <p className="text-gray-400 mb-2">
                <strong>Genre:</strong> {artist.genre}
              </p>
              <p className="text-gray-400 mb-2">
                <strong>Location:</strong> {artist.location}
              </p>
              <p className="text-gray-300 mb-4">{artist.bio}</p>
              {artist.socialMedia && artist.socialMedia.instagram && (
                <a 
                  href={artist.socialMedia.instagram}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-orange-500 hover:text-orange-400 transition"
                >
                  Follow on Instagram →
                </a>
              )}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default ArtistShowcase;

import React from 'react';

function CommunityHub() {
  const features = [
    {
      title: '916 Sound Map',
      description: 'Discover artists across Sacramento neighborhoods',
      icon: '🗺️'
    },
    {
      title: 'Community Pulse',
      description: 'Stories from the Sacramento music community',
      icon: '💓'
    },
    {
      title: 'Global Discovery',
      description: 'Connect Sacramento artists with the world',
      icon: '🌍'
    },
    {
      title: 'Impact Metrics',
      description: 'Track artist growth and community impact',
      icon: '📊'
    }
  ];
  
  return (
    <div className="community-hub bg-black py-16">
      <div className="container mx-auto px-6">
        <h2 className="text-4xl font-bold text-center mb-12" style={{ color: '#FF6F61' }}>
          Community & Story Hub
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {features.map((feature, index) => (
            <div 
              key={index}
              className="feature-card bg-gray-900 rounded-lg p-6 text-center hover:bg-gray-800 transition"
            >
              <div className="text-6xl mb-4">{feature.icon}</div>
              <h3 className="text-xl font-bold mb-3" style={{ color: '#FFD700' }}>
                {feature.title}
              </h3>
              <p className="text-gray-400">{feature.description}</p>
            </div>
          ))}
        </div>
        
        <div className="mt-16 text-center">
          <h3 className="text-2xl font-bold mb-4" style={{ color: '#FF6F61' }}>
            Join the Movement
          </h3>
          <p className="text-gray-300 max-w-2xl mx-auto mb-6">
            Rise Sacramento is more than a platform—it's a movement to amplify 
            Sacramento's creative voices and connect them with global audiences. 
            Join us in celebrating the 916's unique sound.
          </p>
          <button 
            className="bg-orange-600 hover:bg-orange-700 text-white font-bold py-3 px-8 rounded-lg transition"
            style={{ backgroundColor: '#FF6F61' }}
          >
            Get Involved
          </button>
        </div>
      </div>
    </div>
  );
}

export default CommunityHub;

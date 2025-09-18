const express = require('express');
const cors = require('cors');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3006;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Sample content data
const content = {
  movies: [
    { id: 1, title: 'Nexus Origins', genre: 'Sci-Fi', duration: '2h 15m', rating: '8.5' },
    { id: 2, title: 'Digital Dreams', genre: 'Drama', duration: '1h 45m', rating: '7.8' },
    { id: 3, title: 'Virtual Reality', genre: 'Documentary', duration: '1h 30m', rating: '9.1' }
  ],
  series: [
    { id: 1, title: 'COS Chronicles', genre: 'Adventure', seasons: 3, episodes: 24, rating: '8.9' },
    { id: 2, title: 'Tech Titans', genre: 'Biography', seasons: 2, episodes: 16, rating: '8.2' }
  ],
  live: [
    { id: 1, title: 'Nexus News', type: 'News', viewers: 1250, status: 'live' },
    { id: 2, title: 'Creator Spotlight', type: 'Talk Show', viewers: 892, status: 'live' }
  ]
};

// OTT Frontend Routes
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'OTT Frontend',
    features: ['Video Streaming', 'Content Management', 'User Profiles', 'Recommendations'],
    content_stats: {
      movies: content.movies.length,
      series: content.series.length,
      live_streams: content.live.length
    },
    timestamp: new Date().toISOString()
  });
});

app.get('/content/movies', (req, res) => {
  res.json({
    movies: content.movies,
    total: content.movies.length
  });
});

app.get('/content/series', (req, res) => {
  res.json({
    series: content.series,
    total: content.series.length
  });
});

app.get('/content/live', (req, res) => {
  res.json({
    live_streams: content.live,
    total_viewers: content.live.reduce((sum, stream) => sum + stream.viewers, 0)
  });
});

app.get('/content/featured', (req, res) => {
  res.json({
    featured: [
      { ...content.movies[0], type: 'movie', featured_reason: 'Trending Now' },
      { ...content.series[0], type: 'series', featured_reason: 'New Episodes' },
      { ...content.live[0], type: 'live', featured_reason: 'Breaking News' }
    ]
  });
});

app.get('/user/recommendations/:userId', (req, res) => {
  const { userId } = req.params;
  
  // Simulate personalized recommendations
  res.json({
    recommendations: [
      { ...content.movies[1], type: 'movie', reason: 'Based on your viewing history' },
      { ...content.series[1], type: 'series', reason: 'Similar to shows you liked' }
    ],
    user_id: userId
  });
});

app.post('/content/play', (req, res) => {
  const { contentId, contentType, userId } = req.body;
  
  res.json({
    success: true,
    stream_url: `https://stream.nexuscos.online/${contentType}/${contentId}/playlist.m3u8`,
    quality_options: ['1080p', '720p', '480p', '360p'],
    subtitles: ['en', 'es', 'fr', 'de'],
    session_id: `session_${Date.now()}`,
    user_id: userId
  });
});

app.listen(PORT, () => {
  console.log(`📺 OTT Frontend running on port ${PORT}`);
  console.log(`📍 Health: http://localhost:${PORT}/health`);
});
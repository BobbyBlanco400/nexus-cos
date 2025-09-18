const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { Server } = require('socket.io');
const http = require('http');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

const PORT = process.env.PORT || 3004;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Live streaming state
let activeStreams = [];
let viewers = new Map();

// Boom Boom Room Live Routes
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    service: 'Boom Boom Room Live',
    features: ['Live Streaming', 'Real-time Chat', 'Multi-stream Support', 'RTMP Ingestion'],
    activeStreams: activeStreams.length,
    timestamp: new Date().toISOString()
  });
});

app.get('/streams', (req, res) => {
  res.json({
    active: activeStreams,
    totalViewers: Array.from(viewers.values()).reduce((sum, count) => sum + count, 0)
  });
});

app.post('/stream/start', (req, res) => {
  const { streamId, title, streamer } = req.body;
  
  const stream = {
    id: streamId || Date.now().toString(),
    title: title || 'Untitled Stream',
    streamer: streamer || 'Anonymous',
    startTime: new Date().toISOString(),
    viewers: 0
  };
  
  activeStreams.push(stream);
  viewers.set(stream.id, 0);
  
  io.emit('stream_started', stream);
  
  res.json({ success: true, stream });
});

app.post('/stream/stop/:streamId', (req, res) => {
  const { streamId } = req.params;
  
  activeStreams = activeStreams.filter(stream => stream.id !== streamId);
  viewers.delete(streamId);
  
  io.emit('stream_ended', { streamId });
  
  res.json({ success: true, message: 'Stream stopped' });
});

// Socket.IO for real-time interactions
io.on('connection', (socket) => {
  console.log('🔴 User connected to Boom Boom Room:', socket.id);
  
  socket.on('join_stream', (streamId) => {
    socket.join(`stream_${streamId}`);
    
    const currentViewers = viewers.get(streamId) || 0;
    viewers.set(streamId, currentViewers + 1);
    
    // Update stream viewer count
    const stream = activeStreams.find(s => s.id === streamId);
    if (stream) {
      stream.viewers = viewers.get(streamId);
    }
    
    io.to(`stream_${streamId}`).emit('viewer_count_updated', {
      streamId,
      viewers: viewers.get(streamId)
    });
  });
  
  socket.on('leave_stream', (streamId) => {
    socket.leave(`stream_${streamId}`);
    
    const currentViewers = viewers.get(streamId) || 0;
    viewers.set(streamId, Math.max(0, currentViewers - 1));
    
    // Update stream viewer count
    const stream = activeStreams.find(s => s.id === streamId);
    if (stream) {
      stream.viewers = viewers.get(streamId);
    }
    
    io.to(`stream_${streamId}`).emit('viewer_count_updated', {
      streamId,
      viewers: viewers.get(streamId)
    });
  });
  
  socket.on('chat_message', (data) => {
    const { streamId, message, username } = data;
    
    io.to(`stream_${streamId}`).emit('new_chat_message', {
      username: username || 'Anonymous',
      message,
      timestamp: new Date().toISOString()
    });
  });
  
  socket.on('disconnect', () => {
    console.log('🔴 User disconnected from Boom Boom Room:', socket.id);
  });
});

server.listen(PORT, () => {
  console.log(`🔴 Boom Boom Room Live running on port ${PORT}`);
  console.log(`📍 Health: http://localhost:${PORT}/health`);
  console.log(`📺 RTMP Server: rtmp://localhost:1935/live`);
});
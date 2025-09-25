import React from 'react';
import { Container, Typography, Grid, Paper, Box } from '@mui/material';

function Home() {
  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Typography variant="h1" component="h1" gutterBottom>
        Welcome to Nexus COS
      </Typography>
      <Typography variant="h2" gutterBottom>
        Your Creative Operating System
      </Typography>

      <Grid container spacing={3} sx={{ mt: 4 }}>
        <Grid item xs={12} md={4}>
          <Paper
            sx={{
              p: 3,
              display: 'flex',
              flexDirection: 'column',
              height: 240,
            }}
          >
            <Typography variant="h3" gutterBottom>
              V-Stage
            </Typography>
            <Typography>
              Experience immersive virtual performances and events in real-time.
            </Typography>
          </Paper>
        </Grid>
        <Grid item xs={12} md={4}>
          <Paper
            sx={{
              p: 3,
              display: 'flex',
              flexDirection: 'column',
              height: 240,
            }}
          >
            <Typography variant="h3" gutterBottom>
              V-Screen
            </Typography>
            <Typography>
              Create and share stunning visual content with our advanced screen technology.
            </Typography>
          </Paper>
        </Grid>
        <Grid item xs={12} md={4}>
          <Paper
            sx={{
              p: 3,
              display: 'flex',
              flexDirection: 'column',
              height: 240,
            }}
          >
            <Typography variant="h3" gutterBottom>
              V-Caster
            </Typography>
            <Typography>
              Broadcast your content to a global audience with professional-grade tools.
            </Typography>
          </Paper>
        </Grid>
      </Grid>

      <Box sx={{ mt: 8, mb: 4 }}>
        <Typography variant="h2" gutterBottom>
          Why Choose Nexus COS?
        </Typography>
        <Typography variant="body1" paragraph>
          Nexus COS is your all-in-one creative platform, combining powerful tools
          for virtual performances, content creation, and broadcasting. Whether
          you're an artist, creator, or innovator, our system provides everything
          you need to bring your vision to life.
        </Typography>
      </Box>
    </Container>
  );
}

export default Home;
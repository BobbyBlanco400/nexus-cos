import React from 'react';
import { Container, Typography, Paper, Grid, Box } from '@mui/material';

function VStage() {
  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Typography variant="h2" gutterBottom>
        V-Stage
      </Typography>
      <Typography variant="h5" color="textSecondary" gutterBottom>
        Your Virtual Performance Platform
      </Typography>

      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Paper
            sx={{
              p: 3,
              display: 'flex',
              flexDirection: 'column',
              height: 400,
              backgroundColor: 'background.paper',
              position: 'relative',
              overflow: 'hidden',
            }}
          >
            <Box
              sx={{
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: 'rgba(0, 0, 0, 0.7)',
              }}
            >
              <Typography variant="h3" align="center" sx={{ color: 'primary.main' }}>
                Stage View Coming Soon
              </Typography>
            </Box>
          </Paper>
        </Grid>

        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" gutterBottom>
              Performance Controls
            </Typography>
            <Typography variant="body1">
              Stage controls and performance settings will be available here.
            </Typography>
          </Paper>
        </Grid>

        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" gutterBottom>
              Audience Interaction
            </Typography>
            <Typography variant="body1">
              Audience interaction features and chat will be integrated here.
            </Typography>
          </Paper>
        </Grid>
      </Grid>
    </Container>
  );
}

export default VStage;
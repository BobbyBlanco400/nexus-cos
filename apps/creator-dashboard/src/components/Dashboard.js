import React from 'react';
import {
  Grid,
  Paper,
  Typography,
  Box,
  Card,
  CardContent,
  LinearProgress,
} from '@mui/material';

function Dashboard() {
  return (
    <Box sx={{ flexGrow: 1 }}>
      <Typography variant="h4" gutterBottom>
        Welcome Back, Creator!
      </Typography>
      <Grid container spacing={3}>
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="h6">Views Today</Typography>
            <Typography variant="h3">2,547</Typography>
            <Typography variant="body2" color="text.secondary">
              +15% from yesterday
            </Typography>
          </Paper>
        </Grid>
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="h6">Revenue</Typography>
            <Typography variant="h3">$342.50</Typography>
            <Typography variant="body2" color="text.secondary">
              This month
            </Typography>
          </Paper>
        </Grid>
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 2 }}>
            <Typography variant="h6">Subscribers</Typography>
            <Typography variant="h3">12.8K</Typography>
            <Typography variant="body2" color="text.secondary">
              +124 this week
            </Typography>
          </Paper>
        </Grid>
        <Grid item xs={12}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Latest Content Performance
              </Typography>
              <Grid container spacing={2}>
                <Grid item xs={12}>
                  <Typography variant="subtitle1">
                    "Creating with Nexus COS"
                  </Typography>
                  <LinearProgress variant="determinate" value={75} />
                  <Typography variant="body2" color="text.secondary">
                    1.2K views • 2 hours ago
                  </Typography>
                </Grid>
                <Grid item xs={12}>
                  <Typography variant="subtitle1">
                    "Advanced Creator Tips"
                  </Typography>
                  <LinearProgress variant="determinate" value={60} />
                  <Typography variant="body2" color="text.secondary">
                    856 views • 1 day ago
                  </Typography>
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
}

export default Dashboard;
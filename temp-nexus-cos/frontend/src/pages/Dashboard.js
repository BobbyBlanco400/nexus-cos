import React from 'react';
import {
  Container,
  Grid,
  Paper,
  Typography,
  List,
  ListItem,
  ListItemText,
  CircularProgress,
  Box,
} from '@mui/material';

function Dashboard() {
  const services = [
    { name: 'V-Stage', status: 'Healthy', uptime: '99.9%' },
    { name: 'V-Screen', status: 'Healthy', uptime: '99.8%' },
    { name: 'V-Caster', status: 'Healthy', uptime: '99.7%' },
  ];

  const recentActivity = [
    { time: '2 minutes ago', action: 'V-Stage performance started' },
    { time: '5 minutes ago', action: 'New V-Screen content published' },
    { time: '10 minutes ago', action: 'V-Caster stream initiated' },
  ];

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Typography variant="h2" gutterBottom>
        System Dashboard
      </Typography>

      <Grid container spacing={3}>
        {/* System Status */}
        <Grid item xs={12} md={8}>
          <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
            <Typography variant="h6" gutterBottom>
              System Status
            </Typography>
            <Grid container spacing={3}>
              {services.map((service) => (
                <Grid item xs={12} sm={4} key={service.name}>
                  <Box sx={{ textAlign: 'center' }}>
                    <CircularProgress
                      variant="determinate"
                      value={parseFloat(service.uptime)}
                      color="primary"
                      size={80}
                      thickness={4}
                    />
                    <Typography variant="h6" sx={{ mt: 1 }}>
                      {service.name}
                    </Typography>
                    <Typography color="text.secondary">
                      {service.status}
                    </Typography>
                    <Typography color="text.secondary">
                      Uptime: {service.uptime}
                    </Typography>
                  </Box>
                </Grid>
              ))}
            </Grid>
          </Paper>
        </Grid>

        {/* Recent Activity */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
            <Typography variant="h6" gutterBottom>
              Recent Activity
            </Typography>
            <List>
              {recentActivity.map((activity, index) => (
                <ListItem key={index}>
                  <ListItemText
                    primary={activity.action}
                    secondary={activity.time}
                  />
                </ListItem>
              ))}
            </List>
          </Paper>
        </Grid>

        {/* Service Health */}
        <Grid item xs={12}>
          <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
            <Typography variant="h6" gutterBottom>
              Service Health
            </Typography>
            <Grid container spacing={3}>
              {services.map((service) => (
                <Grid item xs={12} sm={4} key={service.name}>
                  <Paper
                    sx={{
                      p: 2,
                      display: 'flex',
                      flexDirection: 'column',
                      height: 140,
                    }}
                  >
                    <Typography variant="h6" gutterBottom>
                      {service.name}
                    </Typography>
                    <Typography color="text.secondary" paragraph>
                      Status: {service.status}
                    </Typography>
                    <Typography color="text.secondary">
                      Performance: Optimal
                    </Typography>
                  </Paper>
                </Grid>
              ))}
            </Grid>
          </Paper>
        </Grid>
      </Grid>
    </Container>
  );
}

export default Dashboard;
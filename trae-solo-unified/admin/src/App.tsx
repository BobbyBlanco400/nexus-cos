import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { 
  Users, 
  BarChart3, 
  Settings, 
  Shield, 
  Database,
  LogOut 
} from 'lucide-react';

function AdminDashboard() {
  const stats = [
    { name: 'Total Users', value: '12,543', icon: Users },
    { name: 'Active Creators', value: '3,247', icon: BarChart3 },
    { name: 'Revenue (Month)', value: '$89,234', icon: Database },
    { name: 'System Alerts', value: '7', icon: Shield },
  ];

  return (
    <div className="min-h-screen bg-nexus-dark">
      <nav className="bg-nexus-light border-b border-nexus-gray px-8 py-4">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold text-nexus-primary">Nexus COS Admin</h1>
          <button className="flex items-center text-gray-300 hover:text-white">
            <LogOut className="w-5 h-5 mr-2" />
            Logout
          </button>
        </div>
      </nav>

      <div className="p-8">
        <div className="mb-8">
          <h2 className="text-3xl font-bold text-white mb-2">Admin Dashboard</h2>
          <p className="text-gray-400">System overview and management tools</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6 mb-8">
          {stats.map((stat) => (
            <div
              key={stat.name}
              className="bg-nexus-gray border border-nexus-light rounded-lg p-6"
            >
              <div className="flex items-center justify-between mb-4">
                <stat.icon className="w-8 h-8 text-nexus-primary" />
              </div>
              <h3 className="text-2xl font-bold text-white mb-1">{stat.value}</h3>
              <p className="text-gray-400 text-sm">{stat.name}</p>
            </div>
          ))}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <div className="bg-nexus-gray border border-nexus-light rounded-lg p-6">
            <h3 className="text-xl font-bold text-white mb-4 flex items-center">
              <Users className="w-5 h-5 mr-2 text-nexus-primary" />
              User Management
            </h3>
            <p className="text-gray-400 mb-4">
              Manage user accounts, permissions, and access levels.
            </p>
            <button className="w-full bg-nexus-primary text-white font-semibold py-2 px-4 rounded-lg hover:bg-nexus-secondary transition-colors">
              Manage Users
            </button>
          </div>

          <div className="bg-nexus-gray border border-nexus-light rounded-lg p-6">
            <h3 className="text-xl font-bold text-white mb-4 flex items-center">
              <BarChart3 className="w-5 h-5 mr-2 text-nexus-primary" />
              Analytics & Reports
            </h3>
            <p className="text-gray-400 mb-4">
              View system analytics, usage reports, and performance metrics.
            </p>
            <button className="w-full border border-nexus-primary text-nexus-primary font-semibold py-2 px-4 rounded-lg hover:bg-nexus-primary hover:text-white transition-colors">
              View Reports
            </button>
          </div>

          <div className="bg-nexus-gray border border-nexus-light rounded-lg p-6">
            <h3 className="text-xl font-bold text-white mb-4 flex items-center">
              <Settings className="w-5 h-5 mr-2 text-nexus-primary" />
              System Settings
            </h3>
            <p className="text-gray-400 mb-4">
              Configure system settings, integrations, and maintenance.
            </p>
            <button className="w-full border border-nexus-primary text-nexus-primary font-semibold py-2 px-4 rounded-lg hover:bg-nexus-primary hover:text-white transition-colors">
              System Settings
            </button>
          </div>
        </div>

        <div className="mt-8 bg-nexus-gray border border-nexus-light rounded-lg p-6">
          <h3 className="text-xl font-bold text-white mb-4">Recent Activity Log</h3>
          <div className="space-y-4">
            <div className="flex items-center justify-between py-3 border-b border-nexus-light">
              <div>
                <p className="text-white font-medium">New user registration</p>
                <p className="text-gray-400 text-sm">User: john_creator@email.com</p>
              </div>
              <span className="text-xs text-gray-500">2 hours ago</span>
            </div>
            <div className="flex items-center justify-between py-3 border-b border-nexus-light">
              <div>
                <p className="text-white font-medium">System backup completed</p>
                <p className="text-gray-400 text-sm">Database backup successful</p>
              </div>
              <span className="text-xs text-gray-500">4 hours ago</span>
            </div>
            <div className="flex items-center justify-between py-3">
              <div>
                <p className="text-white font-medium">Payment processing update</p>
                <p className="text-gray-400 text-sm">Stripe integration updated</p>
              </div>
              <span className="text-xs text-gray-500">6 hours ago</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<AdminDashboard />} />
      </Routes>
    </Router>
  );
}

export default App;

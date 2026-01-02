import { createBrowserRouter } from 'react-router-dom';
import App from './App';
import Dashboard from './pages/Dashboard';
import Founders from './pages/Founders';
import Desktop from './pages/Desktop';

// Handshake ID: 55-45-17
console.log('🔐 N3XUS COS Router Initialized | Handshake: 55-45-17');

export const router = createBrowserRouter([
  {
    path: '/',
    element: <App />,
  },
  {
    path: '/dashboard',
    element: <Dashboard />,
  },
  {
    path: '/founders',
    element: <Founders />,
  },
  {
    path: '/desktop',
    element: <Desktop />,
  },
]);

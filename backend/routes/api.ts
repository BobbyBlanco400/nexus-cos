/**
 * Nexus COS API Routes
 * Main API routing configuration
 */

import { Router } from 'express';
import { mainController } from '../controllers/mainController';

const router = Router();

// Main API endpoints
router.get('/', mainController.index);
router.get('/status', mainController.status);
router.get('/catalog', mainController.catalog);
router.get('/test', mainController.test);

// Streaming endpoints
router.get('/streaming', mainController.streaming);
router.get('/streaming/catalog', mainController.streamingCatalog);
router.get('/streaming/status', mainController.streamingStatus);
router.get('/streaming/test', mainController.streamingTest);

export default router;

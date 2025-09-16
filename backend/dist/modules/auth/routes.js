"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const router = (0, express_1.Router)();
// Example route (remove or update as needed)
router.get('/test', (req, res) => {
    res.json({ message: 'Auth router works!' });
});
exports.default = router;
//# sourceMappingURL=routes.js.map
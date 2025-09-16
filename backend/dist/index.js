"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const auth_1 = __importDefault(require("./routes/auth"));
const app = (0, express_1.default)();
const PORT = 5000;
// Middleware to parse JSON
app.use(express_1.default.json());
// Health check
app.get("/health", (req, res) => {
    res.json({ status: "ok", message: "Backend is running!" });
});
// Mount auth router
app.use("/api/auth", auth_1.default);
app.listen(PORT, () => {
    console.log(`✅ Backend running on port ${PORT}`);
});
//# sourceMappingURL=index.js.map
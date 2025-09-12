import express from "express";
import authRouter from "./routes/auth";

const app = express();
const PORT = 5000;

// Middleware to parse JSON
app.use(express.json());

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "ok", message: "Backend is running!" });
});

// Mount auth router
app.use("/api/auth", authRouter);

app.listen(PORT, () => {
  console.log(`✅ Backend running on port ${PORT}`);
});

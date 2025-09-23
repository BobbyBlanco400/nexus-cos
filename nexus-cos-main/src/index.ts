import express from "express";

const app = express();
const PORT = process.env.PORT || 5000;

app.use(express.json());

// ✅ Healthcheck route
app.get("/health", (req, res) => {
  res.json({ status: "ok", message: "Backend is running!" });
});

// Example root
app.get("/", (req, res) => {
  res.send("Welcome to PUABO-OS Backend API 🚀");
});

app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});

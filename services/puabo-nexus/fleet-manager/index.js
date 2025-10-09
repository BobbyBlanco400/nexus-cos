import express from "express";

const app = express();
const PORT = process.env.PORT || 8080;

app.get("/health", (req, res) => {
  res.status(200).json({ status: "Fleet Manager online ✅" });
});

app.listen(PORT, () => {
  console.log(`🚀 Fleet Manager service running on port ${PORT}`);
});

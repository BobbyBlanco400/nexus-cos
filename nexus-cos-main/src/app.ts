import express from "express";
const app = express();
const port = process.env.PORT || 3000;
app.get("/", (req, res) => { res.send("Welcome to PUAB OS!"); });
export function startApp() { app.listen(port, () => { console.log(`PUAB OS app listening at http://localhost:${port}`); }); }
export default app;

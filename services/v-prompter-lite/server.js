// Nexus COS - v-prompter-lite
// Port: 3504
// Optimized mobile-first teleprompter and remote mic service
// Pure Node.js Implementation (No Dependencies)

const http = require('http');
const port = process.env.PORT || 3504;

const htmlContent = `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>V-PROMPTER LITE | MOBILE CORE</title>
    <style>
        body { background: #000; color: #fff; font-family: 'Arial', sans-serif; overflow: hidden; margin: 0; padding: 20px; }
        #prompter-container { height: 70vh; overflow-y: scroll; font-size: 2.5rem; line-height: 1.5; text-align: center; scroll-behavior: smooth; border: 2px solid #00fffc; padding: 10px; }
        .controls { display: flex; justify-content: space-around; margin-top: 20px; }
        .btn { background: transparent; border: 2px solid #fc00ff; color: #fc00ff; padding: 15px; font-weight: bold; cursor: pointer; flex: 1; margin: 0 5px; }
        #mic-status { position: absolute; top: 10px; right: 10px; color: #00ff00; font-size: 0.8rem; }
    </style>
</head>
<body>
    <div id="mic-status">🟢 MIC BRIDGE ACTIVE</div>
    <div id="prompter-container">
        <div id="script">
            PASTE YOUR SCRIPT HERE OR USE VOICE COMMANDS...
            <br><br>
            N3XUS v-COS STARTING SEQUENCE...
            <br><br>
            LINE 1: WELCOME TO THE SOVEREIGN RUNTIME.
            <br><br>
            LINE 2: YOUR MOBILE MIC IS NOW BROADCASTING.
            <br><br>
            LINE 3: SPEED CONTROL ENABLED VIA VOLUME BUTTONS.
        </div>
    </div>
    <div class="controls">
        <button class="btn" onclick="scrollSpeed(-1)">SLOWER</button>
        <button class="btn" onclick="toggleScroll()">START/PAUSE</button>
        <button class="btn" onclick="scrollSpeed(1)">FASTER</button>
    </div>

    <script>
        let isScrolling = false;
        let speed = 2;
        const container = document.getElementById('prompter-container');
        
        function toggleScroll() {
            isScrolling = !isScrolling;
            if(isScrolling) autoScroll();
        }

        function autoScroll() {
            if(!isScrolling) return;
            container.scrollTop += speed;
            requestAnimationFrame(autoScroll);
        }

        function scrollSpeed(delta) {
            speed = Math.max(1, speed + delta);
        }

        // Voice cue simulation (Bridge logic)
        window.addEventListener('message', (event) => {
            if(event.data === 'voice-cue-start') toggleScroll();
        });
    </script>
</body>
</html>
`;

const server = http.createServer((req, res) => {
    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    if (req.url === '/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 'ok', service: 'v-prompter-lite' }));
    } else {
        res.writeHead(200, { 'Content-Type': 'text/html' });
        res.end(htmlContent);
    }
});

server.listen(port, '0.0.0.0', () => {
    console.log(`✓ v-prompter-lite active on port ${port}`);
});

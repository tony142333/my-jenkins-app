// index.js
const http = require('http');
const port = 3000;

const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Build Triggered by Jenkins on AWS!\n');
});

server.listen(port, () => {
    console.log(`Server running at http://localhost:${port}/`);
});
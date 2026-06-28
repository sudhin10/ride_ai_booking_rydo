const http = require('http');
const { Server } = require('socket.io');

const createApp = require('./src/app');
const connectDB = require('./src/config/db');
const env = require('./src/config/env');
const { registerTracking } = require('./src/sockets/tracking');

async function start() {
  await connectDB();

  const app = createApp();
  const server = http.createServer(app);

  const io = new Server(server, {
    cors: { origin: env.corsOrigins.includes('*') ? '*' : env.corsOrigins },
  });
  registerTracking(io);
  app.set('io', io);

  server.listen(env.port, () => {
    // eslint-disable-next-line no-console
    console.log(`[server] Rydo API running on http://localhost:${env.port} (${env.nodeEnv})`);
    console.log(`[server] Socket.IO ready for real-time tracking`);
  });
}

start().catch((err) => {
  // eslint-disable-next-line no-console
  console.error('[server] Failed to start:', err);
  process.exit(1);
});

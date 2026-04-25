import cors from 'cors';
import express from 'express';

const app = express();
app.use(cors());
app.use(express.json());

app.get('/api/health', (_req, res) => {
  res.json({ ok: true, service: 'sudoku-backend-demo' });
});

app.get('/api/history', (_req, res) => {
  res.json([
    { id: 1, date: '2026-03-31', time: '10:45', difficulty: 'Expert', completion: '06:42', status: 'success' },
    { id: 2, date: '2026-03-30', time: '21:12', difficulty: 'Hard', completion: '04:15', status: 'success' },
    { id: 3, date: '2026-03-30', time: '16:30', difficulty: 'Medium', completion: null, status: 'failed', reason: '3 Errors Limit' }
  ]);
});

app.get('/api/stats', (_req, res) => {
  res.json({ totalSolved: 1284, currentStreak: 12, globalRank: 1204, wins: 248 });
});

const port = process.env.PORT ? Number(process.env.PORT) : 5050;
app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`Backend demo listening on http://localhost:${port}`);
});


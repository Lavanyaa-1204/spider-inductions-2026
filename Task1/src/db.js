import { Pool } from 'pg';
const pool = new Pool({
  host: 'localhost',
  port: 5432,
  database: 'spiderdb',
  user: 'admin',
  password: 'postgres_r00t_p@ss',   
  max: 10,
  idleTimeoutMillis: 30000,
});
pool.on('connect', () => {
  console.log('[db] Connected to PostgreSQL');
});
pool.on('error', (err) => {
  console.error('[db] Unexpected error:', err);
  process.exit(-1);
});

export default pool;
// =====================================================
// Module de Connexion PostgreSQL
// =====================================================

import { Pool, PoolClient, QueryResult } from 'pg';

// Configuration de la connexion avec retry et meilleure gestion des erreurs
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  user: process.env.DB_USER || 'rirepair_user',
  password: process.env.DB_PASSWORD || 'rirepair_secure_password_change_this',
  database: process.env.DB_NAME || 'rirepair',
  max: 20, // Nombre maximum de connexions dans le pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000, // Augmenté à 10 secondes
  statement_timeout: 30000, // Timeout pour les requêtes
  query_timeout: 30000,
  // Retry automatique
  keepAlive: true,
  keepAliveInitialDelayMillis: 10000,
});

// Gestion des erreurs du pool
pool.on('error', (err) => {
  console.error('Erreur inattendue du pool PostgreSQL:', err);
});

// =====================================================
// Fonctions Utilitaires
// =====================================================

/**
 * Exécute une requête SQL avec retry automatique
 */
export async function query<T extends Record<string, any> = any>(
  text: string,
  params?: any[]
): Promise<QueryResult<T>> {
  const start = Date.now();
  const maxRetries = 3;
  let lastError: any;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const result = await pool.query<T>(text, params);
      const duration = Date.now() - start;
      
      if (process.env.NODE_ENV === 'development') {
        console.log('Query executed:', { text, duration, rows: result.rowCount, attempt });
      }
      
      return result;
    } catch (error: any) {
      lastError = error;
      console.error(`Database query error (attempt ${attempt}/${maxRetries}):`, {
        error: error.message,
        code: error.code,
        query: text.substring(0, 100)
      });
      
      // Ne pas retry sur certaines erreurs
      if (error.code === '23505' || // Violation de contrainte unique
          error.code === '23503' || // Violation de clé étrangère
          error.code === '42P01' || // Table n'existe pas
          error.code === '42703') { // Colonne n'existe pas
        throw error;
      }
      
      // Attendre avant de réessayer
      if (attempt < maxRetries) {
        await new Promise(resolve => setTimeout(resolve, 1000 * attempt));
      }
    }
  }
  
  throw lastError;
}

/**
 * Obtient un client du pool pour les transactions
 */
export async function getClient(): Promise<PoolClient> {
  return await pool.connect();
}

/**
 * Exécute une transaction
 */
export async function transaction<T>(
  callback: (client: PoolClient) => Promise<T>
): Promise<T> {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    const result = await callback(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

/**
 * Teste la connexion à la base de données
 */
export async function testConnection(): Promise<boolean> {
  try {
    const result = await query('SELECT NOW()');
    console.log('✅ Connexion PostgreSQL réussie:', result.rows[0]);
    return true;
  } catch (error) {
    console.error('❌ Erreur de connexion PostgreSQL:', error);
    return false;
  }
}

/**
 * Ferme le pool de connexions (à utiliser lors de l'arrêt de l'application)
 */
export async function closePool(): Promise<void> {
  await pool.end();
}

// =====================================================
// Helpers pour les requêtes courantes
// =====================================================

/**
 * Trouve un enregistrement par ID
 */
export async function findById<T extends Record<string, any> = any>(
  table: string,
  id: string
): Promise<T | null> {
  const result = await query<T>(
    `SELECT * FROM ${table} WHERE id = $1`,
    [id]
  );
  return result.rows[0] || null;
}

/**
 * Trouve tous les enregistrements d'une table
 */
export async function findAll<T extends Record<string, any> = any>(
  table: string,
  orderBy: string = 'created_at DESC'
): Promise<T[]> {
  const result = await query<T>(
    `SELECT * FROM ${table} ORDER BY ${orderBy}`
  );
  return result.rows;
}

/**
 * Insère un enregistrement
 */
export async function insert<T extends Record<string, any> = any>(
  table: string,
  data: Record<string, any>
): Promise<T> {
  const keys = Object.keys(data);
  const values = Object.values(data);
  const placeholders = keys.map((_, i) => `$${i + 1}`).join(', ');
  
  const result = await query<T>(
    `INSERT INTO ${table} (${keys.join(', ')}) VALUES (${placeholders}) RETURNING *`,
    values
  );
  
  return result.rows[0];
}

/**
 * Met à jour un enregistrement
 */
export async function update<T extends Record<string, any> = any>(
  table: string,
  id: string,
  data: Record<string, any>
): Promise<T | null> {
  const keys = Object.keys(data);
  const values = Object.values(data);
  const setClause = keys.map((key, i) => `${key} = $${i + 1}`).join(', ');
  
  const result = await query<T>(
    `UPDATE ${table} SET ${setClause}, updated_at = NOW() WHERE id = $${keys.length + 1} RETURNING *`,
    [...values, id]
  );
  
  return result.rows[0] || null;
}

/**
 * Supprime un enregistrement
 */
export async function deleteById(
  table: string,
  id: string
): Promise<boolean> {
  const result = await query(
    `DELETE FROM ${table} WHERE id = $1`,
    [id]
  );
  return (result.rowCount ?? 0) > 0;
}

/**
 * Compte les enregistrements
 */
export async function count(
  table: string,
  where?: string,
  params?: any[]
): Promise<number> {
  const whereClause = where ? `WHERE ${where}` : '';
  const result = await query<{ count: string }>(
    `SELECT COUNT(*) as count FROM ${table} ${whereClause}`,
    params
  );
  return parseInt(result.rows[0].count);
}

// Export du pool pour usage avancé si nécessaire
export default pool;

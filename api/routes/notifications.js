const express = require('express');
const router = express.Router();
const { Pool } = require('pg');

// Configuration PostgreSQL
const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: false,
});

// Créer une notification
router.post('/', async (req, res) => {
  try {
    const { user_id, title, message, type, data } = req.body;

    const result = await pool.query(
      `INSERT INTO notifications (user_id, title, message, type, data)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [user_id, title, message, type, data ? JSON.stringify(data) : null]
    );

    // Émettre la notification en temps réel via Socket.IO
    const io = req.app.get('io');
    if (io) {
      io.to(`user_${user_id}`).emit('notification', {
        id: result.rows[0].id,
        title,
        message,
        type,
        data,
        created_at: result.rows[0].created_at
      });
    }

    res.status(201).json(result.rows[0]);

  } catch (error) {
    console.error('Erreur création notification:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Récupérer les notifications d'un utilisateur
router.get('/user/:user_id', async (req, res) => {
  try {
    const { user_id } = req.params;
    const { limit = 20, offset = 0, unread_only = false } = req.query;

    let query = `
      SELECT * FROM notifications 
      WHERE user_id = $1
    `;
    const params = [user_id];

    if (unread_only === 'true') {
      query += ' AND is_read = false';
    }

    query += ' ORDER BY created_at DESC LIMIT $2 OFFSET $3';
    params.push(parseInt(limit), parseInt(offset));

    const result = await pool.query(query, params);
    res.json(result.rows);

  } catch (error) {
    console.error('Erreur récupération notifications:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Marquer une notification comme lue
router.put('/:id/read', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      `UPDATE notifications 
       SET is_read = true, read_at = CURRENT_TIMESTAMP 
       WHERE id = $1 
       RETURNING *`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Notification non trouvée' });
    }

    res.json(result.rows[0]);

  } catch (error) {
    console.error('Erreur marquer notification lue:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Marquer toutes les notifications d'un utilisateur comme lues
router.put('/user/:user_id/read-all', async (req, res) => {
  try {
    const { user_id } = req.params;

    const result = await pool.query(
      `UPDATE notifications 
       SET is_read = true, read_at = CURRENT_TIMESTAMP 
       WHERE user_id = $1 AND is_read = false
       RETURNING *`,
      [user_id]
    );

    res.json({
      message: 'Notifications marquées comme lues',
      count: result.rows.length
    });

  } catch (error) {
    console.error('Erreur marquer toutes notifications lues:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Supprimer une notification
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;

    const result = await pool.query(
      'DELETE FROM notifications WHERE id = $1 RETURNING *',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Notification non trouvée' });
    }

    res.json({ message: 'Notification supprimée avec succès' });

  } catch (error) {
    console.error('Erreur suppression notification:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Compter les notifications non lues d'un utilisateur
router.get('/user/:user_id/unread-count', async (req, res) => {
  try {
    const { user_id } = req.params;

    const result = await pool.query(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = $1 AND is_read = false',
      [user_id]
    );

    res.json({ unread_count: parseInt(result.rows[0].count) });

  } catch (error) {
    console.error('Erreur comptage notifications non lues:', error);
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// Fonction utilitaire pour créer des notifications automatiques
const createNotification = async (io, userId, title, message, type, data = null) => {
  try {
    const result = await pool.query(
      `INSERT INTO notifications (user_id, title, message, type, data)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [userId, title, message, type, data ? JSON.stringify(data) : null]
    );

    // Émettre en temps réel
    if (io) {
      io.to(`user_${userId}`).emit('notification', {
        id: result.rows[0].id,
        title,
        message,
        type,
        data,
        created_at: result.rows[0].created_at
      });
    }

    return result.rows[0];
  } catch (error) {
    console.error('Erreur création notification automatique:', error);
    throw error;
  }
};

module.exports = router;
module.exports.createNotification = createNotification;

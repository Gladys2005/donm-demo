const request = require('supertest');
const { Pool } = require('pg');
const app = require('../server');

// Mock de la base de données pour les tests
jest.mock('pg', () => ({
  Pool: jest.fn(() => ({
    query: jest.fn(),
    connect: jest.fn(),
    end: jest.fn(),
  })),
}));

describe('Auth API Tests', () => {
  let pool;

  beforeAll(() => {
    pool = new Pool();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('POST /api/auth/register', () => {
    it('devrait enregistrer un nouvel utilisateur avec succès', async () => {
      // Mock de la réponse de la base de données
      pool.query
        .mockResolvedValueOnce({
          rows: [{ id: 'user-123', email: 'test@example.com' }]
        })
        .mockResolvedValueOnce({ rows: [] }); // Pas d'utilisateur existant

      const userData = {
        username: 'testuser',
        email: 'test@example.com',
        phone: '+2250770000000',
        password: 'password123',
        first_name: 'Test',
        last_name: 'User',
        role: 'client'
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(201);

      expect(response.body).toHaveProperty('message', 'Utilisateur créé avec succès');
      expect(response.body.user).toHaveProperty('id', 'user-123');
      expect(response.body.user).toHaveProperty('email', 'test@example.com');
      expect(response.body).toHaveProperty('token');
    });

    it('devrait retourner une erreur si l\'email existe déjà', async () => {
      // Mock d'un utilisateur existant
      pool.query.mockResolvedValueOnce({
        rows: [{ id: 'existing-user', email: 'test@example.com' }]
      });

      const userData = {
        username: 'testuser',
        email: 'test@example.com',
        phone: '+2250770000000',
        password: 'password123',
        first_name: 'Test',
        last_name: 'User',
        role: 'client'
      };

      const response = await request(app)
        .post('/api/auth/register')
        .send(userData)
        .expect(400);

      expect(response.body).toHaveProperty('error', 'Cet email est déjà utilisé');
    });

    it('devrait valider les données requises', async () => {
      const response = await request(app)
        .post('/api/auth/register')
        .send({
          username: 'testuser',
          // email manquant
          phone: '+2250770000000',
          password: 'password123'
        })
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });
  });

  describe('POST /api/auth/login', () => {
    it('devrait connecter un utilisateur avec succès', async () => {
      // Mock de l'utilisateur existant avec mot de passe hashé
      const hashedPassword = '$2b$10$mockhashedpassword';
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'user-123',
          email: 'test@example.com',
          password_hash: hashedPassword,
          role: 'client'
        }]
      });

      const loginData = {
        email: 'test@example.com',
        password: 'password123'
      };

      const response = await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(200);

      expect(response.body).toHaveProperty('message', 'Connexion réussie');
      expect(response.body.user).toHaveProperty('id', 'user-123');
      expect(response.body.user).toHaveProperty('email', 'test@example.com');
      expect(response.body).toHaveProperty('token');
    });

    it('devrait retourner une erreur pour un email invalide', async () => {
      // Mock d'aucun utilisateur trouvé
      pool.query.mockResolvedValueOnce({ rows: [] });

      const loginData = {
        email: 'nonexistent@example.com',
        password: 'password123'
      };

      const response = await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(401);

      expect(response.body).toHaveProperty('error', 'Email ou mot de passe incorrect');
    });

    it('devrait retourner une erreur pour un mot de passe invalide', async () => {
      // Mock de l'utilisateur avec mot de passe incorrect
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'user-123',
          email: 'test@example.com',
          password_hash: '$2b$10$wronghashedpassword',
          role: 'client'
        }]
      });

      const loginData = {
        email: 'test@example.com',
        password: 'wrongpassword'
      };

      const response = await request(app)
        .post('/api/auth/login')
        .send(loginData)
        .expect(401);

      expect(response.body).toHaveProperty('error', 'Email ou mot de passe incorrect');
    });
  });

  describe('GET /api/auth/verify', () => {
    it('devrait vérifier un token valide', async () => {
      // Mock de l'utilisateur trouvé
      pool.query.mockResolvedValueOnce({
        rows: [{
          id: 'user-123',
          email: 'test@example.com',
          role: 'client'
        }]
      });

      const token = 'valid-jwt-token';
      
      const response = await request(app)
        .get('/api/auth/verify')
        .set('Authorization', `Bearer ${token}`)
        .expect(200);

      expect(response.body).toHaveProperty('message', 'Token valide');
      expect(response.body.user).toHaveProperty('id', 'user-123');
    });

    it('devrait retourner une erreur pour un token manquant', async () => {
      const response = await request(app)
        .get('/api/auth/verify')
        .expect(401);

      expect(response.body).toHaveProperty('error', 'Token d\'authentification requis');
    });

    it('devrait retourner une erreur pour un token invalide', async () => {
      const invalidToken = 'invalid-jwt-token';
      
      const response = await request(app)
        .get('/api/auth/verify')
        .set('Authorization', `Bearer ${invalidToken}`)
        .expect(403);

      expect(response.body).toHaveProperty('error', 'Token invalide ou expiré');
    });
  });

  describe('POST /api/auth/logout', () => {
    it('devrait déconnecter un utilisateur avec succès', async () => {
      const token = 'valid-jwt-token';
      
      const response = await request(app)
        .post('/api/auth/logout')
        .set('Authorization', `Bearer ${token}`)
        .expect(200);

      expect(response.body).toHaveProperty('message', 'Déconnexion réussie');
    });
  });
});

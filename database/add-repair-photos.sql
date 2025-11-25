-- =====================================================
-- Migration: Ajout de la table repair_photos
-- Description: Stockage des photos avant/après réparation
-- Date: 2024
-- =====================================================

-- Créer la table repair_photos
CREATE TABLE IF NOT EXISTS repair_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  appointment_id UUID NOT NULL,
  photo_type VARCHAR(10) NOT NULL CHECK (photo_type IN ('before', 'after')),
  photo_url TEXT NOT NULL,
  photo_order INTEGER DEFAULT 1 CHECK (photo_order >= 1 AND photo_order <= 3),
  uploaded_by VARCHAR(100),
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  file_size INTEGER,
  file_name TEXT,
  thumbnail_url TEXT,
  
  -- Contrainte de clé étrangère
  CONSTRAINT fk_repair_photos_appointment 
    FOREIGN KEY (appointment_id) 
    REFERENCES appointments(id) 
    ON DELETE CASCADE,
  
  -- Contrainte unique pour éviter les doublons
  CONSTRAINT unique_photo_per_appointment_type_order 
    UNIQUE (appointment_id, photo_type, photo_order)
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_repair_photos_appointment 
  ON repair_photos(appointment_id);

CREATE INDEX IF NOT EXISTS idx_repair_photos_type 
  ON repair_photos(photo_type);

CREATE INDEX IF NOT EXISTS idx_repair_photos_uploaded_at 
  ON repair_photos(uploaded_at DESC);

-- Commentaires pour la documentation
COMMENT ON TABLE repair_photos IS 'Stockage des photos avant/après réparation pour chaque rendez-vous';
COMMENT ON COLUMN repair_photos.id IS 'Identifiant unique de la photo';
COMMENT ON COLUMN repair_photos.appointment_id IS 'Référence au rendez-vous';
COMMENT ON COLUMN repair_photos.photo_type IS 'Type de photo: before (avant) ou after (après)';
COMMENT ON COLUMN repair_photos.photo_url IS 'URL de la photo originale';
COMMENT ON COLUMN repair_photos.photo_order IS 'Ordre d''affichage (1-3)';
COMMENT ON COLUMN repair_photos.uploaded_by IS 'Nom de l''admin qui a uploadé';
COMMENT ON COLUMN repair_photos.uploaded_at IS 'Date et heure d''upload';
COMMENT ON COLUMN repair_photos.file_size IS 'Taille du fichier en octets';
COMMENT ON COLUMN repair_photos.file_name IS 'Nom original du fichier';
COMMENT ON COLUMN repair_photos.thumbnail_url IS 'URL de la miniature (optionnel)';

-- Fonction pour limiter le nombre de photos par type
CREATE OR REPLACE FUNCTION check_photo_limit()
RETURNS TRIGGER AS $$
BEGIN
  IF (SELECT COUNT(*) 
      FROM repair_photos 
      WHERE appointment_id = NEW.appointment_id 
        AND photo_type = NEW.photo_type) >= 3 THEN
    RAISE EXCEPTION 'Maximum 3 photos par type (avant/après) atteint';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger pour appliquer la limite
DROP TRIGGER IF EXISTS trigger_check_photo_limit ON repair_photos;
CREATE TRIGGER trigger_check_photo_limit
  BEFORE INSERT ON repair_photos
  FOR EACH ROW
  EXECUTE FUNCTION check_photo_limit();

-- Données de test (optionnel)
-- INSERT INTO repair_photos (appointment_id, photo_type, photo_url, photo_order, uploaded_by, file_name)
-- VALUES 
--   ('existing-appointment-id', 'before', '/uploads/repairs/test/before/photo-1.jpg', 1, 'admin', 'before-1.jpg'),
--   ('existing-appointment-id', 'after', '/uploads/repairs/test/after/photo-1.jpg', 1, 'admin', 'after-1.jpg');

-- Afficher le résultat
SELECT 'Table repair_photos créée avec succès!' AS status;
SELECT 'Index créés avec succès!' AS status;
SELECT 'Triggers créés avec succès!' AS status;

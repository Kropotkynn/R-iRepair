-- =====================================================
-- Migration: Ajouter support des images
-- =====================================================

-- Ajouter colonne image_url à device_types
ALTER TABLE device_types 
ADD COLUMN IF NOT EXISTS image_url TEXT;

-- Renommer logo en image_url pour brands (pour cohérence)
ALTER TABLE brands 
RENAME COLUMN logo TO image_url;

-- La colonne image existe déjà pour models, on la renomme pour cohérence
ALTER TABLE models 
RENAME COLUMN image TO image_url;

-- Commentaires
COMMENT ON COLUMN device_types.image_url IS 'URL de l''image du type d''appareil';
COMMENT ON COLUMN brands.image_url IS 'URL du logo de la marque';
COMMENT ON COLUMN models.image_url IS 'URL de l''image du modèle';

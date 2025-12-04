-- =====================================================
-- Migration: Création de la table gallery_photos
-- Description: Stockage des photos avant/après pour la galerie publique
-- Date: 2024
-- =====================================================

-- Créer la table gallery_photos (sans dépendance aux appointments)
CREATE TABLE IF NOT EXISTS gallery_photos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  photo_type VARCHAR(10) NOT NULL CHECK (photo_type IN ('before', 'after')),
  photo_url TEXT NOT NULL,
  photo_order INTEGER DEFAULT 1,
  device_info TEXT,
  repair_description TEXT,
  uploaded_by VARCHAR(100) DEFAULT 'admin',
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  file_size INTEGER,
  file_name TEXT,
  is_public BOOLEAN DEFAULT true,
  display_order INTEGER DEFAULT 0,
  
  -- Métadonnées optionnelles
  device_type VARCHAR(100),
  device_brand VARCHAR(100),
  device_model VARCHAR(100),
  repair_date DATE,
  
  CONSTRAINT check_photo_order CHECK (photo_order >= 1)
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_gallery_photos_type 
  ON gallery_photos(photo_type);

CREATE INDEX IF NOT EXISTS idx_gallery_photos_public 
  ON gallery_photos(is_public);

CREATE INDEX IF NOT EXISTS idx_gallery_photos_uploaded_at 
  ON gallery_photos(uploaded_at DESC);

CREATE INDEX IF NOT EXISTS idx_gallery_photos_display_order 
  ON gallery_photos(display_order DESC);

-- Commentaires pour la documentation
COMMENT ON TABLE gallery_photos IS 'Stockage des photos avant/après pour la galerie publique';
COMMENT ON COLUMN gallery_photos.id IS 'Identifiant unique de la photo';
COMMENT ON COLUMN gallery_photos.photo_type IS 'Type de photo: before (avant) ou after (après)';
COMMENT ON COLUMN gallery_photos.photo_url IS 'URL de la photo';
COMMENT ON COLUMN gallery_photos.photo_order IS 'Ordre d''affichage dans le groupe';
COMMENT ON COLUMN gallery_photos.device_info IS 'Information sur l''appareil réparé';
COMMENT ON COLUMN gallery_photos.repair_description IS 'Description de la réparation';
COMMENT ON COLUMN gallery_photos.uploaded_by IS 'Nom de l''admin qui a uploadé';
COMMENT ON COLUMN gallery_photos.uploaded_at IS 'Date et heure d''upload';
COMMENT ON COLUMN gallery_photos.file_size IS 'Taille du fichier en octets';
COMMENT ON COLUMN gallery_photos.file_name IS 'Nom original du fichier';
COMMENT ON COLUMN gallery_photos.is_public IS 'Photo visible sur la galerie publique';
COMMENT ON COLUMN gallery_photos.display_order IS 'Ordre d''affichage global (0 = plus récent)';

-- Vue pour regrouper les photos avant/après
CREATE OR REPLACE VIEW gallery_photo_sets AS
SELECT 
  COALESCE(b.device_info, a.device_info) as device_info,
  COALESCE(b.device_type, a.device_type) as device_type,
  COALESCE(b.device_brand, a.device_brand) as device_brand,
  COALESCE(b.device_model, a.device_model) as device_model,
  COALESCE(b.repair_date, a.repair_date) as repair_date,
  COALESCE(b.repair_description, a.repair_description) as repair_description,
  json_agg(
    json_build_object(
      'id', b.id,
      'photo_url', b.photo_url,
      'photo_order', b.photo_order,
      'file_name', b.file_name,
      'uploaded_at', b.uploaded_at
    ) ORDER BY b.photo_order
  ) FILTER (WHERE b.id IS NOT NULL) as before_photos,
  json_agg(
    json_build_object(
      'id', a.id,
      'photo_url', a.photo_url,
      'photo_order', a.photo_order,
      'file_name', a.file_name,
      'uploaded_at', a.uploaded_at
    ) ORDER BY a.photo_order
  ) FILTER (WHERE a.id IS NOT NULL) as after_photos,
  GREATEST(MAX(b.uploaded_at), MAX(a.uploaded_at)) as latest_upload
FROM gallery_photos b
FULL OUTER JOIN gallery_photos a 
  ON b.device_info = a.device_info 
  AND b.photo_type = 'before' 
  AND a.photo_type = 'after'
WHERE (b.is_public = true OR b.is_public IS NULL)
  AND (a.is_public = true OR a.is_public IS NULL)
GROUP BY 
  COALESCE(b.device_info, a.device_info),
  COALESCE(b.device_type, a.device_type),
  COALESCE(b.device_brand, a.device_brand),
  COALESCE(b.device_model, a.device_model),
  COALESCE(b.repair_date, a.repair_date),
  COALESCE(b.repair_description, a.repair_description)
ORDER BY latest_upload DESC;

-- Fonction pour nettoyer les anciennes photos (optionnel)
CREATE OR REPLACE FUNCTION cleanup_old_photos(days_old INTEGER DEFAULT 365)
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM gallery_photos
  WHERE uploaded_at < CURRENT_TIMESTAMP - (days_old || ' days')::INTERVAL
    AND is_public = false;
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Données de test (optionnel - décommenter pour tester)
/*
INSERT INTO gallery_photos (photo_type, photo_url, device_info, device_type, device_brand, device_model, repair_description, file_name)
VALUES 
  ('before', '/uploads/gallery/before-1.jpg', 'iPhone 12 Pro', 'Smartphone', 'Apple', 'iPhone 12 Pro', 'Remplacement écran', 'before-iphone12.jpg'),
  ('after', '/uploads/gallery/after-1.jpg', 'iPhone 12 Pro', 'Smartphone', 'Apple', 'iPhone 12 Pro', 'Remplacement écran', 'after-iphone12.jpg'),
  ('before', '/uploads/gallery/before-2.jpg', 'Samsung Galaxy S21', 'Smartphone', 'Samsung', 'Galaxy S21', 'Réparation batterie', 'before-samsung.jpg'),
  ('after', '/uploads/gallery/after-2.jpg', 'Samsung Galaxy S21', 'Smartphone', 'Samsung', 'Galaxy S21', 'Réparation batterie', 'after-samsung.jpg');
*/

-- Afficher le résultat
SELECT 'Table gallery_photos créée avec succès!' AS status;
SELECT 'Index créés avec succès!' AS status;
SELECT 'Vue gallery_photo_sets créée avec succès!' AS status;
SELECT 'Fonction cleanup_old_photos créée avec succès!' AS status;

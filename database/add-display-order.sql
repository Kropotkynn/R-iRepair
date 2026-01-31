-- =====================================================
-- Migration: Ajouter le champ display_order
-- =====================================================
-- Description: Ajoute le champ display_order aux tables device_types, 
-- brands et models pour permettre un tri personnalisé

-- Ajouter display_order aux types d'appareils
ALTER TABLE device_types ADD COLUMN display_order INTEGER DEFAULT 0;

-- Ajouter display_order aux marques
ALTER TABLE brands ADD COLUMN display_order INTEGER DEFAULT 0;

-- Ajouter display_order aux modèles
ALTER TABLE models ADD COLUMN display_order INTEGER DEFAULT 0;

-- Créer des index pour optimiser les tris
CREATE INDEX idx_device_types_display_order ON device_types(display_order);
CREATE INDEX idx_brands_display_order ON brands(display_order);
CREATE INDEX idx_models_display_order ON models(display_order);

-- Initialiser les display_order en fonction de l'ordre de création
UPDATE device_types SET display_order = row_number() OVER (ORDER BY created_at ASC) - 1;
UPDATE brands SET display_order = row_number() OVER (ORDER BY created_at ASC) - 1;
UPDATE models SET display_order = row_number() OVER (ORDER BY created_at ASC) - 1;

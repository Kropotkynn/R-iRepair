-- =====================================================
-- Ajout du champ display_order pour le tri des modèles
-- =====================================================

-- Ajouter la colonne display_order à la table models
ALTER TABLE models ADD COLUMN IF NOT EXISTS display_order INTEGER DEFAULT 0;

-- Créer un index pour améliorer les performances de tri
CREATE INDEX IF NOT EXISTS idx_models_display_order ON models(brand_id, display_order);

-- Initialiser les valeurs display_order pour les modèles existants
-- Les modèles seront ordonnés par ordre alphabétique au sein de chaque marque
WITH ranked_models AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (PARTITION BY brand_id ORDER BY name) as row_num
  FROM models
)
UPDATE models
SET display_order = ranked_models.row_num
FROM ranked_models
WHERE models.id = ranked_models.id;

-- Commentaire sur la colonne
COMMENT ON COLUMN models.display_order IS 'Ordre d''affichage des modèles (par marque). Plus petit = affiché en premier.';

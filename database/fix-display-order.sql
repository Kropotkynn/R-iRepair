-- =====================================================
-- Script de correction pour display_order
-- Vérifie et ajoute la colonne si elle n'existe pas
-- =====================================================

-- Vérifier et ajouter la colonne display_order
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'models' 
        AND column_name = 'display_order'
    ) THEN
        -- Ajouter la colonne
        ALTER TABLE models ADD COLUMN display_order INTEGER DEFAULT 0;
        
        -- Créer l'index
        CREATE INDEX idx_models_display_order ON models(brand_id, display_order);
        
        -- Initialiser les valeurs
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
        
        -- Ajouter le commentaire
        COMMENT ON COLUMN models.display_order IS 'Ordre d''affichage des modèles (par marque). Plus petit = affiché en premier.';
        
        RAISE NOTICE 'Colonne display_order ajoutée avec succès';
    ELSE
        RAISE NOTICE 'Colonne display_order existe déjà';
    END IF;
END $$;

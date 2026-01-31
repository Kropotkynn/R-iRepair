-- =====================================================
-- Ajout de display_order pour types et marques
-- =====================================================

DO $$
BEGIN
    -- Ajouter display_order à device_types si elle n'existe pas
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'device_types' AND column_name = 'display_order'
    ) THEN
        ALTER TABLE device_types ADD COLUMN display_order INTEGER DEFAULT 0;
        
        -- Initialiser les valeurs de display_order pour device_types
        WITH numbered_types AS (
            SELECT id, ROW_NUMBER() OVER (ORDER BY name ASC) as rn
            FROM device_types
        )
        UPDATE device_types dt
        SET display_order = nt.rn
        FROM numbered_types nt
        WHERE dt.id = nt.id;
        
        -- Créer un index pour device_types
        CREATE INDEX IF NOT EXISTS idx_device_types_display_order ON device_types(display_order);
        
        RAISE NOTICE 'Colonne display_order ajoutée à device_types avec succès';
    ELSE
        RAISE NOTICE 'Colonne display_order existe déjà dans device_types';
    END IF;

    -- Ajouter display_order à brands si elle n'existe pas
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'brands' AND column_name = 'display_order'
    ) THEN
        ALTER TABLE brands ADD COLUMN display_order INTEGER DEFAULT 0;
        
        -- Initialiser les valeurs de display_order pour brands (par device_type)
        WITH numbered_brands AS (
            SELECT id, ROW_NUMBER() OVER (PARTITION BY device_type_id ORDER BY name ASC) as rn
            FROM brands
        )
        UPDATE brands b
        SET display_order = nb.rn
        FROM numbered_brands nb
        WHERE b.id = nb.id;
        
        -- Créer un index pour brands
        CREATE INDEX IF NOT EXISTS idx_brands_display_order ON brands(device_type_id, display_order);
        
        RAISE NOTICE 'Colonne display_order ajoutée à brands avec succès';
    ELSE
        RAISE NOTICE 'Colonne display_order existe déjà dans brands';
    END IF;
END $$;

-- =====================================================
-- Migration : Ajout du champ adresse pour les rendez-vous
-- =====================================================
-- Pour un réparateur à domicile, il est essentiel d'avoir l'adresse du client

-- Ajout du champ adresse dans la table appointments
ALTER TABLE appointments 
ADD COLUMN IF NOT EXISTS customer_address TEXT;

-- Ajout d'un commentaire pour documenter le champ
COMMENT ON COLUMN appointments.customer_address IS 'Adresse complète du client pour la réparation à domicile';

-- Optionnel : Ajouter des champs séparés pour une meilleure structure
ALTER TABLE appointments 
ADD COLUMN IF NOT EXISTS customer_street VARCHAR(255),
ADD COLUMN IF NOT EXISTS customer_city VARCHAR(100),
ADD COLUMN IF NOT EXISTS customer_postal_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS customer_country VARCHAR(100) DEFAULT 'France';

-- Commentaires pour les nouveaux champs
COMMENT ON COLUMN appointments.customer_street IS 'Rue et numéro de l''adresse';
COMMENT ON COLUMN appointments.customer_city IS 'Ville';
COMMENT ON COLUMN appointments.customer_postal_code IS 'Code postal';
COMMENT ON COLUMN appointments.customer_country IS 'Pays';

-- Index pour rechercher par ville ou code postal
CREATE INDEX IF NOT EXISTS idx_appointments_city ON appointments(customer_city);
CREATE INDEX IF NOT EXISTS idx_appointments_postal_code ON appointments(customer_postal_code);

-- Afficher un message de confirmation
DO $$
BEGIN
    RAISE NOTICE 'Migration terminée : Champs d''adresse ajoutés à la table appointments';
END $$;

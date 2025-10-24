# 🔧 Solution au Problème de Réseau Docker

## ❌ Erreur Rencontrée

```bash
failed to create network rirepair_rirepair-network: Error response from daemon: 
invalid pool request: Pool overlaps with other one on this address space
```

## 🔍 Cause du Problème

Le réseau Docker défini dans `docker-compose.yml` (172.20.0.0/16) entre en conflit avec un réseau existant sur votre système.

## ✅ Solutions (3 Méthodes)

---

### 🎯 Solution 1 : Nettoyer les Réseaux Docker (RECOMMANDÉ)

```bash
# 1. Arrêter tous les conteneurs
docker-compose down

# 2. Lister tous les réseaux Docker
docker network ls

# 3. Supprimer les réseaux inutilisés
docker network prune -f

# 4. Si le réseau rirepair existe encore, le supprimer manuellement
docker network rm rirepair_rirepair-network 2>/dev/null || true
docker network rm rirepair_default 2>/dev/null || true

# 5. Redémarrer
docker-compose up -d
```

---

### 🎯 Solution 2 : Changer la Plage d'Adresses

Si la solution 1 ne fonctionne pas, modifiez la plage d'adresses dans `docker-compose.yml`.

#### Étape 1 : Identifier les Réseaux Existants
```bash
# Voir tous les réseaux et leurs plages
docker network inspect $(docker network ls -q) | grep -E "Name|Subnet"
```

#### Étape 2 : Modifier docker-compose.yml

Changez la ligne du subnet dans `docker-compose.yml` :

```yaml
# AVANT
networks:
  rirepair-network:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16

# APRÈS (choisissez une plage libre)
networks:
  rirepair-network:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.25.0.0/16  # Ou 172.30.0.0/16, 172.35.0.0/16
```

#### Étape 3 : Redémarrer
```bash
docker-compose down
docker-compose up -d
```

---

### 🎯 Solution 3 : Utiliser le Réseau par Défaut

Simplifiez en utilisant le réseau par défaut de Docker.

#### Modifier docker-compose.yml

Supprimez la configuration réseau personnalisée :

```yaml
# SUPPRIMER cette section à la fin du fichier:
networks:
  rirepair-network:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16

# REMPLACER PAR:
networks:
  rirepair-network:
    driver: bridge
```

Ou encore plus simple, supprimez complètement la section networks et utilisez le réseau par défaut.

---

## 🚀 Procédure Complète de Correction

### Étape 1 : Diagnostic
```bash
# Voir les réseaux existants
docker network ls

# Voir les détails des réseaux
docker network inspect bridge
docker network inspect $(docker network ls -q)

# Voir les conteneurs en cours
docker ps -a
```

### Étape 2 : Nettoyage Complet
```bash
# Arrêter tous les conteneurs R iRepair
docker-compose down

# Supprimer les conteneurs arrêtés
docker container prune -f

# Supprimer les réseaux inutilisés
docker network prune -f

# Supprimer spécifiquement le réseau rirepair
docker network rm rirepair_rirepair-network 2>/dev/null || true
docker network rm rirepair_default 2>/dev/null || true
```

### Étape 3 : Vérification
```bash
# Vérifier qu'il n'y a plus de réseau rirepair
docker network ls | grep rirepair
# Ne doit rien retourner
```

### Étape 4 : Redémarrage
```bash
# Créer le lien .env si pas déjà fait
ln -sf .env.production .env

# Redémarrer avec les nouvelles configurations
docker-compose up -d postgres redis

# Attendre
sleep 15

# Vérifier
docker-compose ps
docker network ls | grep rirepair
```

### Étape 5 : Tests
```bash
# PostgreSQL
docker-compose exec postgres pg_isready -U rirepair_user
# ✅ Doit retourner: accepting connections

# Redis
docker-compose exec redis redis-cli -a Rahim7878_ ping
# ✅ Doit retourner: PONG

# Réseau
docker network inspect rirepair_rirepair-network
# ✅ Doit afficher les détails du réseau
```

---

## 🔍 Commandes de Diagnostic Avancé

### Identifier le Conflit
```bash
# Lister tous les réseaux avec leurs plages
docker network ls --format "{{.Name}}" | while read net; do
    echo "=== $net ==="
    docker network inspect $net | grep -A 5 "IPAM"
done

# Voir les plages utilisées
docker network inspect $(docker network ls -q) | grep -E "Subnet|Gateway"
```

### Voir les Conteneurs Utilisant un Réseau
```bash
# Voir quels conteneurs utilisent rirepair_rirepair-network
docker network inspect rirepair_rirepair-network | grep -A 10 "Containers"
```

### Forcer la Suppression
```bash
# Si un réseau refuse de se supprimer
docker network disconnect -f rirepair_rirepair-network CONTAINER_ID
docker network rm rirepair_rirepair-network
```

---

## 📝 Script de Nettoyage Automatique

Créez un fichier `cleanup-docker.sh` :

```bash
#!/bin/bash

echo "🧹 Nettoyage Docker pour R iRepair..."

# Arrêter les services
echo "1. Arrêt des services..."
docker-compose down 2>/dev/null

# Supprimer les conteneurs arrêtés
echo "2. Suppression des conteneurs arrêtés..."
docker container prune -f

# Supprimer les réseaux inutilisés
echo "3. Suppression des réseaux inutilisés..."
docker network prune -f

# Supprimer spécifiquement les réseaux rirepair
echo "4. Suppression des réseaux rirepair..."
docker network rm rirepair_rirepair-network 2>/dev/null || true
docker network rm rirepair_default 2>/dev/null || true

# Supprimer les images non utilisées (optionnel)
echo "5. Suppression des images non utilisées..."
docker image prune -f

echo "✅ Nettoyage terminé!"
echo ""
echo "Vous pouvez maintenant redémarrer avec:"
echo "  docker-compose up -d"
```

Utilisation :
```bash
chmod +x cleanup-docker.sh
./cleanup-docker.sh
```

---

## 🎯 Solution Rapide (Copier-Coller)

```bash
# Nettoyage complet
docker-compose down
docker container prune -f
docker network prune -f
docker network rm rirepair_rirepair-network 2>/dev/null || true

# Créer le lien .env
ln -sf .env.production .env

# Redémarrer
docker-compose up -d

# Attendre
sleep 20

# Vérifier
docker-compose ps
docker-compose exec postgres pg_isready -U rirepair_user
docker-compose exec redis redis-cli --no-auth-warning -a Rahim7878_ ping
```

---

## ⚠️ Si le Problème Persiste

### Option 1 : Utiliser un Réseau Différent

Modifiez `docker-compose.yml` pour utiliser une plage différente :

```yaml
networks:
  rirepair-network:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.28.0.0/16  # Changez cette valeur
```

Plages disponibles généralement :
- 172.25.0.0/16
- 172.28.0.0/16
- 172.30.0.0/16
- 192.168.100.0/24

### Option 2 : Supprimer la Configuration Réseau

Dans `docker-compose.yml`, remplacez :

```yaml
networks:
  rirepair-network:
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/16
```

Par simplement :

```yaml
networks:
  rirepair-network:
```

Docker choisira automatiquement une plage disponible.

---

## 📞 Vérification Finale

Après avoir appliqué une solution :

```bash
# 1. Vérifier les réseaux
docker network ls
# ✅ rirepair_rirepair-network doit apparaître

# 2. Vérifier les conteneurs
docker-compose ps
# ✅ Tous doivent être "Up"

# 3. Tester la connectivité
docker-compose exec postgres pg_isready -U rirepair_user
docker-compose exec redis redis-cli --no-auth-warning -a Rahim7878_ ping
curl http://localhost:8000/api/health

# 4. Voir les détails du réseau
docker network inspect rirepair_rirepair-network
# ✅ Doit afficher la configuration et les conteneurs connectés
```

---

## 🎉 Résumé

**Problème :** Conflit de plage d'adresses réseau Docker

**Solution Rapide :**
```bash
docker-compose down
docker network prune -f
docker-compose up -d
```

**Si ça ne marche pas :** Changez la plage d'adresses dans docker-compose.yml (172.20.0.0/16 → 172.28.0.0/16)

**Vérification :** `docker network ls` et `docker-compose ps`

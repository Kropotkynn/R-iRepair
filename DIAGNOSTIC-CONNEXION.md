# 🔍 Diagnostic : Impossible d'Accéder à l'Application

## ❌ Problème

Vous voyez : "Le délai d'attente est dépassé" ou "Le serveur met trop de temps à répondre"

## 🎯 Causes Possibles

### 1. Utilisation de l'IP Privée au lieu de l'IP Publique ⚠️

**Vous utilisez probablement :** `http://172.31.25.178:3000`
- ❌ C'est une IP **privée AWS** (non accessible depuis Internet)

**Vous devez utiliser :** L'IP **publique** de votre instance EC2

---

## ✅ SOLUTION : Trouver et Utiliser l'IP Publique

### Sur le Serveur Ubuntu

```bash
# Méthode 1 : Obtenir l'IP publique
curl -4 ifconfig.me

# Méthode 2 : Via AWS metadata
curl http://169.254.169.254/latest/meta-data/public-ipv4

# Méthode 3 : Via hostname
curl http://checkip.amazonaws.com
```

### Depuis la Console AWS

1. Connectez-vous à AWS Console
2. Allez dans **EC2 > Instances**
3. Sélectionnez votre instance
4. Regardez **"Public IPv4 address"** ou **"Public IPv4 DNS"**

---

## 🌐 Accès Correct à l'Application

Une fois l'IP publique obtenue (exemple: `54.123.45.67`) :

```
Frontend:  http://54.123.45.67:3000
Admin:     http://54.123.45.67:3000/admin/login
API:       http://54.123.45.67:3000/api/health
```

---

## 🔒 Vérifier les Security Groups AWS

### Problème Fréquent : Ports Bloqués

Votre Security Group doit autoriser :

| Port | Type | Source | Description |
|------|------|--------|-------------|
| 22 | SSH | Votre IP | Connexion SSH |
| 80 | HTTP | 0.0.0.0/0 | Web (Nginx) |
| 443 | HTTPS | 0.0.0.0/0 | Web SSL |
| 3000 | Custom | 0.0.0.0/0 | Frontend Next.js |

### Vérifier depuis AWS Console

1. **EC2 > Instances** > Sélectionnez votre instance
2. Onglet **"Security"**
3. Cliquez sur le **Security Group**
4. Onglet **"Inbound rules"**

### Ajouter la Règle pour le Port 3000

```bash
# Via AWS CLI (si installé)
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxxxxxx \
  --protocol tcp \
  --port 3000 \
  --cidr 0.0.0.0/0
```

**OU via Console AWS :**

1. Security Groups > Votre groupe
2. **"Inbound rules"** > **"Edit inbound rules"**
3. **"Add rule"**
   - Type: Custom TCP
   - Port: 3000
   - Source: 0.0.0.0/0 (Anywhere IPv4)
4. **"Save rules"**

---

## 🧪 Tests de Diagnostic

### Sur le Serveur Ubuntu

```bash
# 1. Vérifier que le frontend écoute sur le port 3000
sudo netstat -tulpn | grep 3000
# Devrait afficher : tcp 0.0.0.0:3000

# 2. Tester localement
curl http://localhost:3000
# Devrait retourner du HTML

# 3. Vérifier le statut des conteneurs
docker-compose -f docker-compose.simple.yml ps
# frontend doit être "Up (healthy)"

# 4. Voir les logs du frontend
docker-compose -f docker-compose.simple.yml logs frontend
```

### Depuis Votre Ordinateur

```bash
# 1. Ping l'IP publique
ping 54.123.45.67

# 2. Tester le port 3000
telnet 54.123.45.67 3000
# OU
nc -zv 54.123.45.67 3000

# 3. Tester avec curl
curl -v http://54.123.45.67:3000
```

---

## 🔧 Solutions par Scénario

### Scénario 1 : Security Group Bloque le Port 3000

**Symptôme :** Timeout, pas de réponse

**Solution :**
```bash
# Ajouter la règle dans AWS Security Group
# Port 3000, TCP, Source: 0.0.0.0/0
```

### Scénario 2 : Frontend Ne Démarre Pas

**Symptôme :** Container "Exited" ou "Unhealthy"

**Solution :**
```bash
# Voir les logs
docker-compose -f docker-compose.simple.yml logs frontend

# Redémarrer
docker-compose -f docker-compose.simple.yml restart frontend

# Reconstruire si nécessaire
docker-compose -f docker-compose.simple.yml up -d --build frontend
```

### Scénario 3 : Firewall Ubuntu Bloque

**Symptôme :** Fonctionne en local mais pas depuis l'extérieur

**Solution :**
```bash
# Vérifier UFW
sudo ufw status

# Autoriser le port 3000
sudo ufw allow 3000/tcp

# Recharger
sudo ufw reload
```

### Scénario 4 : Frontend Écoute sur 127.0.0.1 au lieu de 0.0.0.0

**Symptôme :** `curl localhost:3000` fonctionne mais pas depuis l'extérieur

**Solution :**
```bash
# Vérifier
sudo netstat -tulpn | grep 3000

# Si vous voyez 127.0.0.1:3000 au lieu de 0.0.0.0:3000
# Modifier docker-compose.simple.yml
# ports:
#   - "0.0.0.0:3000:3000"  # Forcer 0.0.0.0
```

---

## 📋 Checklist de Diagnostic Complète

Exécutez ces commandes sur le serveur :

```bash
#!/bin/bash

echo "=== 1. IP Publique ==="
curl -s http://checkip.amazonaws.com

echo -e "\n=== 2. Statut des Conteneurs ==="
docker-compose -f docker-compose.simple.yml ps

echo -e "\n=== 3. Ports en Écoute ==="
sudo netstat -tulpn | grep -E ':(80|443|3000|5432|6379)'

echo -e "\n=== 4. Test Local Frontend ==="
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:3000

echo -e "\n=== 5. Firewall UFW ==="
sudo ufw status

echo -e "\n=== 6. Logs Frontend (dernières 20 lignes) ==="
docker-compose -f docker-compose.simple.yml logs --tail=20 frontend
```

Sauvegardez ce script :
```bash
nano diagnostic.sh
chmod +x diagnostic.sh
./diagnostic.sh
```

---

## 🎯 Solution Rapide

**Exécutez ces commandes dans l'ordre :**

```bash
# 1. Obtenir l'IP publique
echo "Votre IP publique est:"
curl http://checkip.amazonaws.com

# 2. Vérifier que le frontend fonctionne
docker-compose -f docker-compose.simple.yml ps | grep frontend

# 3. Tester localement
curl http://localhost:3000

# 4. Autoriser le port 3000 dans le firewall
sudo ufw allow 3000/tcp
sudo ufw reload

# 5. Vérifier les Security Groups AWS
echo "Vérifiez que le port 3000 est ouvert dans AWS Security Groups"
```

**Ensuite, accédez à :** `http://[VOTRE_IP_PUBLIQUE]:3000`

---

## 🆘 Si Rien Ne Fonctionne

### Option 1 : Utiliser un Tunnel SSH (Temporaire)

```bash
# Depuis votre ordinateur local
ssh -L 3000:localhost:3000 ubuntu@54.123.45.67

# Puis accédez à : http://localhost:3000
```

### Option 2 : Redéployer Complètement

```bash
cd ~/R-iRepair
docker-compose -f docker-compose.simple.yml down
docker-compose -f docker-compose.simple.yml up -d --build
docker-compose -f docker-compose.simple.yml logs -f
```

### Option 3 : Vérifier les Logs Détaillés

```bash
# Logs de tous les services
docker-compose -f docker-compose.simple.yml logs

# Logs en temps réel
docker-compose -f docker-compose.simple.yml logs -f frontend

# Entrer dans le conteneur
docker-compose -f docker-compose.simple.yml exec frontend sh
# Puis : curl localhost:3000
```

---

## 📞 Informations à Fournir pour Support

Si le problème persiste, fournissez :

```bash
# 1. IP publique
curl http://checkip.amazonaws.com

# 2. Statut des conteneurs
docker-compose -f docker-compose.simple.yml ps

# 3. Ports en écoute
sudo netstat -tulpn | grep 3000

# 4. Logs frontend
docker-compose -f docker-compose.simple.yml logs --tail=50 frontend

# 5. Test local
curl -v http://localhost:3000

# 6. Security Group (depuis AWS Console)
# Capture d'écran des Inbound Rules
```

---

## ✅ Résultat Attendu

Après correction, vous devriez voir :

```bash
# Test local
$ curl http://localhost:3000
<!DOCTYPE html>...  # HTML de la page

# Test externe (depuis votre PC)
$ curl http://54.123.45.67:3000
<!DOCTYPE html>...  # HTML de la page

# Dans le navigateur
http://54.123.45.67:3000
→ Page d'accueil R iRepair s'affiche
```

---

## 🎉 Prochaines Étapes

Une fois l'accès fonctionnel :

1. ✅ Tester l'interface admin
2. ✅ Créer un rendez-vous de test
3. 🔒 Configurer SSL (Certbot)
4. 🔐 Changer le mot de passe admin
5. 📊 Activer le monitoring

**La cause la plus probable : Vous utilisez l'IP privée (172.31.x.x) au lieu de l'IP publique AWS !**

# Projet-LoadBalancing

# 🌐 Projet Load Balancing - DNS & Web Cluster

## 📌 Description

Ce projet a été réalisé dans le cadre du **Projet de Fin de Module d'Administration Réseau**. Il consiste à mettre en place une **infrastructure hautement disponible** avec :

- Une **racine DNS en cluster** (2 serveurs DNS) avec répartition de charge
- Une **ferme web en cluster** (2 serveurs web) avec répartition de charge
- Un **load balancing** assuré par **iptables** (DNAT et NAT)
- Une **émulation réseau** sous **Kathara**

---

## 🏗️ Architecture

```
                    ┌─────────────────┐
                    │   RÉSEAU A      │
                    │  100.0.0.0/24   │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
         client1        client2           pc1
        (100.0.0.10)  (100.0.0.11)   (100.0.0.12)
              │              │              │
              └──────────────┼──────────────┘
                             │
              ┌──────────────┴──────────────┐
              │                              │
    ┌─────────▼─────────┐          ┌─────────▼─────────┐
    │   DNS LOAD        │          │   WEB LOAD        │
    │   BALANCER        │          │   BALANCER        │
    │   dns_lb          │          │   ws_random       │
    │   100.0.0.2       │          │   100.0.0.3       │
    │   10.0.0.5        │          │   10.0.1.5        │
    └─────────┬─────────┘          └─────────┬─────────┘
              │                               │
    ┌─────────▼─────────┐          ┌─────────▼─────────┐
    │   RÉSEAU B        │          │   RÉSEAU C        │
    │  10.0.0.0/24      │          │  10.0.1.0/24      │
    └─────────┬─────────┘          └─────────┬─────────┘
              │                               │
    ┌─────────┴─────────┐          ┌─────────┴─────────┐
    │ dnsroot1  dnsroot2│          │ server1   server2 │
    │ 10.0.0.1  10.0.0.2│          │10.0.1.1  10.0.1.2 │
    └───────────────────┘          └───────────────────┘
```

---

## 📋 Table d'adressage IP

| Machine | Rôle | Interface | Adresse IP | Passerelle |
|---------|------|-----------|------------|------------|
| **client1** | Client test | eth0 | 100.0.0.10/24 | 100.0.0.2 |
| **client2** | Client test | eth0 | 100.0.0.11/24 | 100.0.0.2 |
| **pc1** | Client test | eth0 | 100.0.0.12/24 | 100.0.0.2 |
| **dns_lb** | Load balancer DNS | eth0 | 100.0.0.2/24 | — |
| | | eth1 | 10.0.0.5/24 | — |
| **dnsroot1** | Serveur DNS racine 1 | eth0 | 10.0.0.1/24 | 10.0.0.5 |
| **dnsroot2** | Serveur DNS racine 2 | eth0 | 10.0.0.2/24 | 10.0.0.5 |
| **ws_random** | Load balancer web | eth0 | 100.0.0.3/24 | — |
| | | eth1 | 10.0.1.5/24 | — |
| **server1** | Serveur web 1 | eth0 | 10.0.1.1/24 | 10.0.1.5 |
| **server2** | Serveur web 2 | eth0 | 10.0.1.2/24 | 10.0.1.5 |

---

## 🛠️ Technologies utilisées

| Technologie | Rôle |
|-------------|------|
| **Kathara** | Émulation réseau |
| **iptables** | Load balancing (NAT/DNAT) |
| **BIND 9.11** | Serveur DNS racine |
| **Apache2** | Serveur web |
| **Linux** | Système d'exploitation des conteneurs |

---

## 📂 Structure du projet

```
📂 Projet-LoadBalancing/
├── 📄 lab.conf                 # Configuration du laboratoire Kathara
├── 📄 client1.startup          # Script de démarrage client1
├── 📄 client2.startup          # Script de démarrage client2
├── 📄 pc1.startup              # Script de démarrage pc1
├── 📄 dns_lb.startup           # Script de démarrage load balancer DNS
├── 📄 dnsroot1.startup         # Script de démarrage serveur DNS 1
├── 📄 dnsroot2.startup         # Script de démarrage serveur DNS 2
├── 📄 ws_random.startup        # Script de démarrage load balancer Web
├── 📄 server1.startup          # Script de démarrage serveur web 1
├── 📄 server2.startup          # Script de démarrage serveur web 2
├── 📄 monitor_web.sh           # Script de monitoring web (optionnel)
├── 📄 monitor_dns.sh           # Script de monitoring DNS (optionnel)
├── 📄 README.md                # Documentation du projet
└── 📄 Rapport.pdf              # Rapport complet du projet
```

---

## 🚀 Installation et lancement

### 1. Prérequis

- **Kathara** installé sur votre machine
- **Docker** (nécessaire pour Kathara)
- Connexion Internet pour télécharger les images Docker

### 2. Cloner le dépôt

```bash
git clone https://github.com/TankRoot29/Projet-LoadBalancing.git
cd Projet-LoadBalancing
```

### 3. Lancer le laboratoire

```bash
kathara lstart
```

### 4. Se connecter aux machines

```bash
# Se connecter à un client
kathara connect client1

# Se connecter au load balancer DNS
kathara connect dns_lb

# Se connecter au load balancer web
kathara connect ws_random

# Se connecter à un serveur DNS
kathara connect dnsroot1

# Se connecter à un serveur web
kathara connect server1
```

### 5. Arrêter le laboratoire

```bash
kathara lclean
```

---

## 🧪 Tests

### 1. Test de connectivité (ping)

```bash
# Depuis client1
ping -c 4 100.0.0.2   # DNS Load Balancer
ping -c 4 100.0.0.3   # Web Load Balancer
```

### 2. Test load balancing DNS

```bash
# 10 requêtes DNS
for i in {1..10}; do
    dig @100.0.0.2 . NS +short | head -1
done

# 100 requêtes avec comptage
(for i in {1..100}; do 
    dig @100.0.0.2 . NS +short 2>/dev/null | head -1
done) | sort | uniq -c
```

### 3. Test load balancing Web

```bash
# 10 requêtes Web
for i in {1..10}; do
    curl -s -H "Connection: close" http://100.0.0.3/ | grep "Serveur Web"
done

# 100 requêtes avec comptage
(for i in {1..100}; do 
    curl -s -H "Connection: close" http://100.0.0.3/ 2>/dev/null | grep "Serveur Web"
done) | sort | uniq -c
```

### 4. Statistiques en temps réel

```bash
# Statistiques DNS
watch -n 1 'iptables-legacy -t nat -L PREROUTING -n -v | grep -E "10.0.0.[12]"'

# Statistiques Web
watch -n 1 'iptables-legacy -t nat -L PREROUTING -n -v | grep -E "10.0.1.[12]"'

# Voir les logs Apache (sur server1 ou server2)
tail -f /var/log/apache2/access.log
```

---

## 📊 Résultats des tests

| Service | Serveurs | Répartition |
|---------|----------|-------------|
| **DNS** | dnsroot1 (10.0.0.1) | ~50% |
| | dnsroot2 (10.0.0.2) | ~50% |
| **Web** | server1 (10.0.1.1) | ~50% |
| | server2 (10.0.1.2) | ~50% |

---

## ⚙️ Fonctionnement du load balancing

### Load balancing DNS (dns_lb)

```bash
iptables-legacy --table nat --append PREROUTING \
  --destination 100.0.0.2 -p udp --dport 53 \
  -m statistic --mode random --probability 0.5 \
  --jump DNAT --to-destination 10.0.0.1:53

iptables-legacy --table nat --append PREROUTING \
  --destination 100.0.0.2 -p udp --dport 53 \
  --jump DNAT --to-destination 10.0.0.2:53
```

### Load balancing Web (ws_random)

```bash
iptables-legacy --table nat --append PREROUTING \
  --destination 100.0.0.3 -p tcp --dport 80 \
  -m statistic --mode random --probability 0.5 \
  --jump DNAT --to-destination 10.0.1.1:80

iptables-legacy --table nat --append PREROUTING \
  --destination 100.0.0.3 -p tcp --dport 80 \
  --jump DNAT --to-destination 10.0.1.2:80
```

---

## ⚠️ Limitations

- **Absence de health checks** : si un serveur tombe, le LB continue d'envoyer du trafic
- **Configuration statique** : ajout manuel des règles pour nouveaux serveurs
- **Pas de persistance de session** : sticky sessions non implémentées
- **Monitoring basique** : uniquement les compteurs iptables

---

## 🚀 Perspectives d'amélioration

- ✅ Health checks automatisés
- ✅ Migration vers HAProxy/Nginx
- ✅ Monitoring avec Prometheus/Grafana
- ✅ Haute disponibilité des load balancers (Keepalived)
- ✅ Déploiement sous Kubernetes

---

## 👤 Auteur

**AGBENONZAN Kossivi Jacques Junior**  
📧 junioragbenonzan31@gmail.com  
🎓 Licence 3 - Réseaux Informatique Sécurité et Télécommunications  
🏛️ Université Félix Houphouët-Boigny

---

## 📚 Encadrement

**Dr Diallo**  
Enseignant-chercheur - Département RIST

---

## 📅 Année universitaire

**2025-2026**

---

## 📝 Licence

Ce projet est réalisé dans un cadre académique. Toute reproduction ou utilisation doit être autorisée par l'auteur.

---

## 🙏 Remerciements

Je remercie :
- **Dr Diallo** pour son encadrement et ses conseils
- L'**Université Félix Houphouët-Boigny** pour la formation
- Tous les enseignants du département RIST

---

## 🔗 Liens utiles

- [Kathara](https://www.kathara.org/)
- [Documentation iptables](https://linux.die.net/man/8/iptables)
- [BIND 9](https://www.isc.org/bind/)
- [Apache2](https://httpd.apache.org/)

---

**Merci pour votre attention !** 🎓
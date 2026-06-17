#!/bin/bash
echo "========================================="
echo "📊 TEST COMPLET DU LOAD BALANCING"
echo "========================================="

echo -e "\n1️⃣  TEST DNS (10 requêtes)"
echo "--------------------------"
for i in {1..10}; do
    dig @100.0.0.2 . NS +short | head -1
done

echo -e "\n2️⃣  TEST WEB (10 requêtes)"
echo "--------------------------"
for i in {1..10}; do
    curl -s -H "Connection: close" http://100.0.0.3/ | grep "Serveur Web"
done

echo -e "\n3️⃣  STATISTIQUES DNS (100 requêtes)"
echo "---------------------------------"
(for i in {1..100}; do 
    dig @100.0.0.2 . NS +short 2>/dev/null | head -1
done) | sort | uniq -c

echo -e "\n4️⃣  STATISTIQUES WEB (100 requêtes)"
echo "---------------------------------"
(for i in {1..100}; do 
    curl -s -H "Connection: close" http://100.0.0.3/ 2>/dev/null | grep "Serveur Web"
done) | sort | uniq -c
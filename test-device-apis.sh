#!/bin/bash

echo "🔍 Test des APIs Devices"
echo "========================"
echo ""

echo "1️⃣ Test API Types:"
echo "-------------------"
curl -s http://localhost:3000/api/devices/types | jq '.' || curl -s http://localhost:3000/api/devices/types
echo ""
echo ""

echo "2️⃣ Test API Brands:"
echo "-------------------"
curl -s http://localhost:3000/api/devices/brands | jq '.' || curl -s http://localhost:3000/api/devices/brands
echo ""
echo ""

echo "3️⃣ Test API Models:"
echo "-------------------"
curl -s http://localhost:3000/api/devices/models | jq '.' || curl -s http://localhost:3000/api/devices/models
echo ""
echo ""

echo "✅ Tests terminés"

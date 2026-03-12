#!/bin/bash

echo "🧪 Testing Doctors API..."
echo ""

# Check if backend is running
echo "1️⃣ Checking backend status..."
curl -s http://localhost:5000/api/test/stats > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Backend is running"
else
    echo "❌ Backend is not running. Please start it first with ./run_dev.sh"
    exit 1
fi

echo ""
echo "2️⃣ Creating sample doctors..."
curl -X POST http://localhost:5000/api/test/create-sample-doctors \
  -H "Content-Type: application/json" \
  | python3 -m json.tool

echo ""
echo "3️⃣ Fetching all doctors..."
curl -s http://localhost:5000/api/test/doctors | python3 -m json.tool

echo ""
echo "4️⃣ Fetching doctors via main API..."
curl -s http://localhost:5000/api/doctors/get_all_doctors | python3 -m json.tool

echo ""
echo "✅ Test complete!"

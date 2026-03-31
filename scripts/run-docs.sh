#!/bin/bash

echo "🔄 Pulling latest DB schema..."
supabase db pull --db-url "$DB_URL"

echo "🧠 Generating JSON..."
node scripts/generate-json.js

echo "🧠 Generating systems..."
node scripts/generate-systems.js

echo "📘 Generating docs..."
node scripts/generate-docs-from-systems.js

echo "⚙️ Generating internals..."
node scripts/generate-internals.js

echo "✅ Docs fully updated!"

echo "⚡ Generating flows..."
node scripts/generate-flows.js
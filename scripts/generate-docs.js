const fs = require("fs");
const path = require("path");

const migrationsDir = "supabase/migrations";
const outputFile = "docs/schema/schema.md";

const files = fs.readdirSync(migrationsDir);

let output = "# 📦 Database Schema (Auto Generated)\n\n";

files.forEach((file) => {
  const content = fs.readFileSync(path.join(migrationsDir, file), "utf-8");

  const tables = content.split("CREATE TABLE").slice(1);

  tables.forEach((table) => {
    const nameMatch = table.match(/public\.(\w+)/);
    if (!nameMatch) return;

    const tableName = nameMatch[1];

    output += `## 🧱 ${tableName}\n\n`;

    // Extract columns (basic)
    const columns = table.split("\n").slice(1, 15);

    columns.forEach((col) => {
      const clean = col.trim().replace(",", "");
      if (clean && !clean.startsWith("CONSTRAINT")) {
        output += `- ${clean}\n`;
      }
    });

    output += "\n---\n\n";
  });
});

fs.writeFileSync(outputFile, output);

console.log("✅ Docs generated!");

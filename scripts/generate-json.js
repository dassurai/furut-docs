const fs = require("fs");
const path = require("path");

const migrationsDir = "supabase/migrations";
const outputFile = "docs/engine/schema.json";

const files = fs.readdirSync(migrationsDir);

const db = {
  tables: {},
  functions: {},
  triggers: [],
};

files.forEach((file) => {
  const content = fs.readFileSync(path.join(migrationsDir, file), "utf-8");

  // 🧱 TABLES (LINE-BY-LINE SAFE PARSER)
  const lines = content.split("\n");

  let currentTable = null;

  lines.forEach((line) => {
    const clean = line.trim();

    // Detect table start
    const tableMatch = clean.match(/^create table "public"\."(\w+)"/i);
    if (tableMatch) {
      currentTable = tableMatch[1];
      db.tables[currentTable] = { columns: [] };
      return;
    }

    // Detect end of table
    if (currentTable && clean.startsWith(");")) {
      currentTable = null;
      return;
    }

    // Capture columns
    if (currentTable) {
      if (
        clean &&
        !clean.toLowerCase().startsWith("constraint") &&
        !clean.toLowerCase().startsWith("primary key") &&
        !clean.toLowerCase().startsWith("unique") &&
        !clean.toLowerCase().startsWith("check")
      ) {
        const colMatch = clean.match(/^"(\w+)"\s+(.+)/);
        if (colMatch) {
          const colName = colMatch[1];
          const colType = colMatch[2].replace(",", "");
          db.tables[currentTable].columns.push(`${colName} ${colType}`);
        }
      }
    }
  });

  // ⚙️ FUNCTIONS
  const functions = content.match(
    /CREATE\s+(OR REPLACE\s+)?FUNCTION\s+public\.(\w+)/gi,
  );

  if (functions) {
    functions.forEach((fn) => {
      const name = fn.match(/FUNCTION public\.(\w+)/i)?.[1];
      if (!name) return;
      db.functions[name] = { name };
    });
  }

  // ⚡ TRIGGERS
  const triggers = content.match(/CREATE TRIGGER[\s\S]*?;/gi);

  if (triggers) {
    triggers.forEach((tr) => {
      const table = tr.match(/ON public\.(\w+)/i)?.[1];
      const fn = tr.match(/EXECUTE FUNCTION public\.(\w+)/i)?.[1];
      const timingMatch = tr.match(/(BEFORE|AFTER)\s+(INSERT|UPDATE|DELETE)/i);

      db.triggers.push({
        table: table || null,
        function: fn || null,
        timing: timingMatch ? `${timingMatch[1]} ${timingMatch[2]}` : null,
      });
    });
  }
});

fs.writeFileSync(outputFile, JSON.stringify(db, null, 2));

console.log("🧠 JSON schema generated CLEAN & ACCURATE!");

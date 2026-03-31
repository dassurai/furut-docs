const fs = require("fs");
const path = require("path");

const migrationsDir = "supabase/migrations";
const outputFile = "docs/internals/internals.md";

const files = fs.readdirSync(migrationsDir);

let output = "# ⚙️ Database Internals (Auto Generated)\n\n";

files.forEach((file) => {
  const content = fs.readFileSync(path.join(migrationsDir, file), "utf-8");

  // Extract functions
  const functions = content.match(/CREATE OR REPLACE FUNCTION[\s\S]*?\$\$;/g);

  if (functions) {
    output += "## 🔧 Functions\n\n";

    functions.forEach((fn) => {
      const nameMatch = fn.match(/FUNCTION\s+(\w+)/);
      const name = nameMatch ? nameMatch[1] : "unknown_function";

      output += `### ${name}\n`;
      output += "```sql\n" + fn + "\n```\n\n";
    });
  }

  // Extract triggers
  const triggers = content.match(/CREATE TRIGGER[\s\S]*?;/g);

  if (triggers) {
    output += "## ⚡ Triggers\n\n";

    triggers.forEach((tr) => {
      output += "```sql\n" + tr + "\n```\n\n";
    });
  }

  // Extract RLS policies
  const policies = content.match(/CREATE POLICY[\s\S]*?;/g);

  if (policies) {
    output += "## 🔐 RLS Policies\n\n";

    policies.forEach((policy) => {
      output += "```sql\n" + policy + "\n```\n\n";
    });
  }
});

fs.writeFileSync(outputFile, output);

console.log("✅ Internals docs generated!");

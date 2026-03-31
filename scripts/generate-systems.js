const fs = require("fs");

const input = JSON.parse(fs.readFileSync("docs/engine/schema.json", "utf-8"));

const systems = {};

Object.keys(input.tables).forEach((table) => {
  let system = 'core';

if (table.startsWith('account')) system = 'accounts';
else if (table.startsWith('property')) system = 'properties';
else if (table.startsWith('unit')) system = 'units';
else if (table.startsWith('experience')) system = 'experiences';
else if (table.includes('rule')) system = 'rules';
else if (table.includes('media')) system = 'media';
else if (table.includes('address')) system = 'location';
else if (table.includes('user')) system = 'users';
else if (table.includes('plan') || table.includes('subscription')) system = 'billing';

  if (!systems[system]) {
    systems[system] = {
      tables: [],
      triggers: [],
    };
  }

  systems[system].tables.push(table);
});

// Attach triggers
input.triggers.forEach((tr) => {
  const table = tr.table;

  Object.keys(systems).forEach((system) => {
    if (systems[system].tables.includes(table)) {
      systems[system].triggers.push(tr);
    }
  });
});

fs.writeFileSync("docs/engine/systems.json", JSON.stringify(systems, null, 2));

console.log("🧠 Systems generated!");

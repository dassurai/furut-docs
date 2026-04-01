const fs = require("fs");

const schema = JSON.parse(fs.readFileSync("docs/engine/schema.json", "utf-8"));

const intelligence = JSON.parse(
  fs.readFileSync("docs/engine/intelligence.json", "utf-8"),
);

// Match helper
function matchesPattern(name, pattern) {
  const regex = new RegExp(pattern.replace(/\*/g, ".*"));
  return regex.test(name);
}

// Group detection
function getGroup(table) {
  for (const group in intelligence.groups) {
    const patterns = intelligence.groups[group];

    for (const pattern of patterns) {
      if (matchesPattern(table, pattern)) {
        return group;
      }
    }
  }
  return null;
}

// Explain function
function explain(fn) {
  for (const key in intelligence.function_meanings) {
    if (fn.includes(key)) {
      return intelligence.function_meanings[key];
    }
  }
  return "Execute system logic";
}

// Infer target
function inferTarget(fn) {
  // 🔥 FIRST: check explicit mapping
  if (intelligence.function_effects && intelligence.function_effects[fn]) {
    return intelligence.function_effects[fn];
  }

  // fallback to inference
  const tables = Object.keys(schema.tables);

  for (const table of tables) {
    if (fn.includes(table)) {
      return table;
    }
  }

  return null;
}

// Build edges
const edges = schema.triggers.map((tr) => ({
  source: tr.table,
  target: inferTarget(tr.function),
  meaning: explain(tr.function),
  group: getGroup(tr.table),
}));

// Build adjacency map
const adjacency = {};

edges.forEach((edge) => {
  if (!adjacency[edge.source]) {
    adjacency[edge.source] = [];
  }
  adjacency[edge.source].push(edge);
});

// Build chains
function buildChain(start, visited = new Set()) {
  if (visited.has(start)) return [];

  visited.add(start);

  const nextEdges = adjacency[start] || [];

  let chains = [];

  nextEdges.forEach((edge) => {
    let chain = [`${edge.source} → ${edge.meaning}`];

    if (edge.target) {
      const next = buildChain(edge.target, visited);
      next.forEach((n) => {
        chain = chain.concat(n);
      });
    }

    chains.push(chain);
  });

  return chains.length ? chains : [[start]];
}

// Generate output
let output = "# 🧠 System Intelligence Flows (v7 - Chained Reasoning)\n\n";

const groups = {};

edges.forEach((edge) => {
  if (!edge.group) return;

  if (!groups[edge.group]) {
    groups[edge.group] = new Set();
  }

  groups[edge.group].add(edge.source);
});

Object.keys(groups).forEach((group) => {
  output += `## 🔗 ${group.toUpperCase()} SYSTEM FLOW\n\n`;

  const tables = Array.from(groups[group]);

  tables.forEach((table) => {
    const chains = buildChain(table);

    chains.forEach((chain) => {
      output += "- " + chain.join(" → ") + "\n";
    });
  });

  output += "\n---\n\n";
});

fs.writeFileSync("docs/flows-v7.md", output);

console.log("🧠 Flow Engine v7 generated!");

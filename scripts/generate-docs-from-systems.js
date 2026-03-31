const fs = require("fs");

const systems = JSON.parse(
  fs.readFileSync("docs/engine/systems.json", "utf-8"),
);

function describeSystem(name) {
  if (name === "accounts")
    return "Manages user accounts, roles, and lifecycle.";
  if (name === "properties")
    return "Handles property listings, ownership, and structure.";
  if (name === "units")
    return "Controls unit-level pricing, availability, and configurations.";
  if (name === "rules")
    return "Defines configurable policies and rule engines.";
  if (name === "media") return "Stores and links media assets across entities.";
  if (name === "experiences")
    return "Manages experiences linked to properties and units.";
  if (name === "location") return "Handles geo data and address management.";
  if (name === "users") return "Stores user identity and profile data.";
  if (name === "billing") return "Handles plans, subscriptions, and limits.";
  return "Core supporting system.";
}

function explainTrigger(tr) {
  const fn = tr.function;

  if (fn.includes("assign_default_subscription"))
    return "Automatically assigns a subscription when an account is created.";
  if (fn.includes("audit")) return "Logs activity for audit tracking.";
  if (fn.includes("kyc"))
    return "Updates account verification based on KYC status.";
  if (fn.includes("payout")) return "Handles payout verification updates.";
  if (fn.includes("prevent"))
    return "Prevents restricted actions to enforce system rules.";
  if (fn.includes("location"))
    return "Syncs or updates location data automatically.";
  if (fn.includes("timestamp"))
    return "Updates timestamps automatically on changes.";

  return "Executes automated system logic.";
}

let output = "# 🧠 System Documentation (Auto Generated)\n\n";

Object.keys(systems).forEach((system) => {
  const data = systems[system];

  output += `## 🔹 ${system.toUpperCase()} SYSTEM\n\n`;

  // 💡 Meaning
  output += `### 💡 Purpose\n${describeSystem(system)}\n\n`;

  // 📦 Tables
  output += "### 📦 Tables\n";
  data.tables.forEach((t) => {
    output += `- ${t}\n`;
  });

  // ⚡ Behaviors
  if (data.triggers.length) {
    output += "\n### ⚡ Behaviors\n";
    data.triggers.forEach((tr) => {
      output += `- ${tr.timing} on ${tr.table} → ${tr.function}()\n`;
      output += `  → ${explainTrigger(tr)}\n`;
    });
  }

  output += "\n---\n\n";
});

fs.writeFileSync("docs/system-overview.md", output);

console.log("📘 Smart system docs generated!");

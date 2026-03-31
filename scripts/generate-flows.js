const fs = require("fs");

const schema = JSON.parse(fs.readFileSync("docs/engine/schema.json", "utf-8"));

const systems = JSON.parse(
  fs.readFileSync("docs/engine/systems.json", "utf-8"),
);

const flows = [];

// 🧠 Helper: Human readable meaning
function explain(fn) {
  if (!fn) return "System action occurs";

  if (fn.includes("assign_default_subscription"))
    return "Assign default subscription to account";
  if (fn.includes("audit")) return "Log audit event";
  if (fn.includes("account_created")) return "Handle account creation logic";
  if (fn.includes("kyc")) return "Update KYC verification status";
  if (fn.includes("payout")) return "Update payout verification";
  if (fn.includes("prevent")) return "Prevent restricted operation";
  if (fn.includes("location")) return "Sync or update location data";
  if (fn.includes("timestamp")) return "Update timestamp";
  if (fn.includes("claim_property")) return "Handle property claim process";
  if (fn.includes("transfer")) return "Handle ownership transfer";
  if (fn.includes("create")) return "Create related entity";

  return "Execute system logic";
}

// 🧠 Build flows from triggers
schema.triggers.forEach((tr) => {
  if (!tr.table) return;

  const flowName = `${tr.table} ${tr.timing} flow`;

  let flow = flows.find((f) => f.name === flowName);

  if (!flow) {
    flow = {
      name: flowName,
      steps: [],
    };
    flows.push(flow);
  }

  flow.steps.push({
    action: `${tr.timing} on ${tr.table}`,
    result: explain(tr.function),
  });
});

// 🧠 Generate Markdown
let output = "# ⚡ System Flows (Auto Generated)\n\n";

flows.forEach((flow) => {
  output += `## 🔄 ${flow.name}\n\n`;

  flow.steps.forEach((step, i) => {
    output += `${i + 1}. ${step.action}\n`;
    output += `   → ${step.result}\n`;
  });

  output += "\n---\n\n";
});

fs.writeFileSync("docs/flows.md", output);

console.log("⚡ Flow docs generated!");

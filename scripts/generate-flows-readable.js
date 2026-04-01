const fs = require("fs");

const raw = fs.readFileSync("docs/flows-v7.md", "utf-8");

let output = "# 🧠 System Flows (Readable Intelligence)\n\n";

// Split sections
const sections = raw.split("## ").slice(1);

sections.forEach((section) => {
  const lines = section
    .split("\n")
    .map((l) => l.trim())
    .filter(Boolean);

  const title = lines[0].replace("🔗 ", "").replace(" SYSTEM FLOW", "");

  const flows = lines
    .slice(1)
    .filter((l) => l.startsWith("-") && !l.includes("---"));

  if (!flows.length) return;

  output += `## 🔹 ${title}\n\n`;

  let flowIndex = 1;

  flows.forEach((flow) => {
    let steps = flow.replace("- ", "").split(" → ");

    // 🧠 Remove consecutive duplicates
    steps = steps.filter((step, i) => step !== steps[i - 1]);

    // 🧠 Remove useless steps
    steps = steps.filter((step) => step !== "---");

    if (steps.length < 2) return;

    output += `${flowIndex}. Trigger: ${steps[0]}\n`;

    // Remaining steps
    const seen = new Set();

    steps.slice(1).forEach((step) => {
      if (!seen.has(step)) {
        output += `   → ${step}\n`;
        seen.add(step);
      }
    });

    output += "\n";
    flowIndex++;
  });

  output += "---\n\n";
});

fs.writeFileSync("docs/flows-readable.md", output);

console.log("🧠 Clean readable flows generated!");

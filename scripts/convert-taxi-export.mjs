/**
 * Converts taxi-license `questions-export.json` → Road Master `assets/taxi/bank/questions.json`.
 *
 * Usage (from Road Master repo root):
 *   node scripts/convert-taxi-export.mjs [path/to/questions-export.json] [--copy-images]
 *
 * Default import path (if arg omitted):
 *   ../taxi-license-main/questions-export.json
 *
 * Image paths in output: `assets/taxi/bank/images/<filename>`
 * Use `--copy-images` to copy only referenced PNGs from taxi-license `src/assets/`.
 */

import { readFileSync, writeFileSync, mkdirSync, copyFileSync, existsSync } from "fs";
import { dirname, join, basename } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(__dirname, "..");
const outJson = join(repoRoot, "assets/taxi/bank/questions.json");
const outImagesDir = join(repoRoot, "assets/taxi/bank/images");

const defaultExport = join(repoRoot, "..", "taxi-license-main", "questions-export.json");

function parseArgs(argv) {
  const copyImages = argv.includes("--copy-images");
  const positional = argv.slice(2).filter((a) => a !== "--copy-images");
  const exportFile = positional[0] ?? defaultExport;
  return { exportFile, copyImages };
}

const { exportFile: exportPath, copyImages } = parseArgs(process.argv);

const IMAGE_PREFIX = "assets/taxi/bank/images/";

function toAssetPaths(imageField) {
  if (imageField == null) return [];
  if (Array.isArray(imageField)) {
    return imageField
      .map((f) => (typeof f === "string" && f ? `${IMAGE_PREFIX}${basename(f)}` : null))
      .filter(Boolean);
  }
  if (typeof imageField === "string" && imageField) {
    return [`${IMAGE_PREFIX}${basename(imageField)}`];
  }
  return [];
}

function main() {
  if (!existsSync(exportPath)) {
    console.error(`Export file not found:\n  ${exportPath}\n\nPass path as first argument.`);
    process.exit(1);
  }

  const raw = readFileSync(exportPath, "utf-8");
  const groups = JSON.parse(raw);
  if (!Array.isArray(groups)) {
    console.error("Expected top-level array of groups.");
    process.exit(1);
  }

  const out = [];
  for (const group of groups) {
    const categories = group.categories ?? [];
    for (const cat of categories) {
      const moduleId = cat.id;
      const sections = cat.sections ?? [];
      let setNumber = 0;
      for (const sec of sections) {
        setNumber += 1;
        const questions = sec.questions ?? [];
        const totalInSet = questions.length;
        let qn = 0;
        for (const q of questions) {
          qn += 1;
          const expPaths = toAssetPaths(q.explanationImage);
          const qImg = q.questionImage;
          const imageAssetPath =
            typeof qImg === "string" && qImg ? `${IMAGE_PREFIX}${basename(qImg)}` : null;

          out.push({
            id: q.id,
            moduleId,
            setNumber,
            questionNumber: qn,
            totalInSet,
            categoryTag: sec.name ?? "",
            prompt: q.text ?? "",
            options: Array.isArray(q.options) ? q.options.map(String) : [],
            correctOptionIndex: typeof q.correctIndex === "number" ? q.correctIndex : 0,
            explanationText: null,
            explanationImageAssetPaths: expPaths,
            explanationImageUrls: [],
            imageAssetPath,
            imageNetworkUrl: null,
            imageSemanticLabel: null,
            designIllustrationPrompt: null,
          });
        }
      }
    }
  }

  mkdirSync(dirname(outJson), { recursive: true });
  writeFileSync(
    outJson,
    JSON.stringify({ version: 1, source: "taxi-license questions-export.json", questions: out }, null, 2),
    "utf-8",
  );

  const allRefs = new Set();
  for (const g of groups) {
    for (const c of g.categories ?? []) {
      for (const s of c.sections ?? []) {
        for (const q of s.questions ?? []) {
          if (q.questionImage) allRefs.add(basename(q.questionImage));
          const ei = q.explanationImage;
          if (typeof ei === "string") allRefs.add(basename(ei));
          if (Array.isArray(ei)) for (const x of ei) if (x) allRefs.add(basename(x));
        }
      }
    }
  }

  const taxiAssets = join(dirname(exportPath), "src", "assets");

  console.log(`✓ Wrote ${out.length} questions → ${outJson}`);
  console.log(`  Unique image files referenced: ${allRefs.size}`);

  if (copyImages) {
    mkdirSync(outImagesDir, { recursive: true });
    let copied = 0;
    let missing = 0;
    for (const name of allRefs) {
      const src = join(taxiAssets, name);
      const dest = join(outImagesDir, name);
      if (existsSync(src)) {
        copyFileSync(src, dest);
        copied++;
      } else {
        missing++;
        if (missing <= 10) console.warn(`  missing: ${src}`);
      }
    }
    if (missing > 350) console.warn(`  (${missing} total missing — check ASSETS path)`);
    console.log(`✓ --copy-images: copied ${copied} files (${missing} missing)`);
  } else {
    console.log("");
    console.log(`Copy PNGs (e.g. all): mkdir -p "${outImagesDir}" && cp "${taxiAssets}/"*.png "${outImagesDir}/"`);
    console.log(`Or re-run with: node scripts/convert-taxi-export.mjs "${exportPath}" --copy-images`);
  }

  console.log("");
  console.log("Ensure pubspec.yaml includes:");
  console.log(`  - assets/taxi/bank/images/`);
  console.log("Then: flutter pub get && flutter run");
}

main();

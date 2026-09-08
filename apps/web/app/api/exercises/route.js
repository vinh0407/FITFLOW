import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { NextResponse } from "next/server";

export const revalidate = 3600;

// The source index is only 341 KB, but repeatedly reading and parsing it on
// every filter request is avoidable work on slower serverless instances.
let cachedIndex;
let cachedHomeDeck;
const guideExerciseNames = new Set([
  "barbell bench press",
  "barbell incline bench press",
  "band shoulder press",
  "band front lateral raise",
  "cable triceps pushdown (v-bar)",
  "alternate lateral pulldown",
  "cable low seated row",
  "barbell one arm bent over row",
  "cable rear delt row (with rope)",
  "barbell high bar squat",
  "lever alternate leg press",
  "barbell romanian deadlift",
  "lever lying leg curl",
  "band single leg calf raise",
  "dumbbell one arm chest fly on exercise ball",
  "dumbbell arnold press",
  "cable overhead triceps extension (rope attachment)",
  "assisted pull-up",
  "barbell bent over row",
  "barbell rear delt row",
  "dumbbell alternate seated hammer curl",
  "barbell deadlift",
  "barbell good morning",
  "lever leg extension",
  "front plank with twist",
]);

function getExerciseIndex() {
  if (!cachedIndex) {
    cachedIndex = JSON.parse(
      readFileSync(
        resolve(process.cwd(), "public/data/exercises-index.json"),
        "utf8",
      ),
    );
    cachedHomeDeck = buildHomeDeck(cachedIndex);
  }
  return cachedIndex;
}

function matchesType(exercise, type) {
  if (!type) return true;
  if (type === "CARDIO") return exercise.category === "cardio";
  if (type === "STRETCHING")
    return exercise.name.toLowerCase().includes("stretch");
  if (type === "BODY WEIGHT") return exercise.equipment === "body weight";
  return exercise.category !== "cardio";
}

function matchesEquipment(exercise, equipment) {
  if (!equipment || equipment === "ALL") return true;
  const usesNoEquipment = exercise.equipment === "body weight";
  if (equipment === "NONE") return usesNoEquipment;
  if (equipment === "REQUIRED") return !usesNoEquipment;
  return true;
}

function buildHomeDeck(index) {
  const byBodyPart = new Map();
  for (const exercise of index) {
    const key = exercise.body_part || "other";
    const bucket = byBodyPart.get(key) || [];
    if (bucket.length < 8) bucket.push(exercise);
    byBodyPart.set(key, bucket);
  }
  const homeDeck = [...byBodyPart.values()].flat();
  const guideDeck = index.filter((exercise) =>
    guideExerciseNames.has(exercise.name),
  );
  return [
    ...new Map(
      [...homeDeck, ...guideDeck].map((exercise) => [exercise.id, exercise]),
    ).values(),
  ];
}

export function GET(request) {
  try {
    const index = getExerciseIndex();
    const params = request.nextUrl.searchParams;
    const scope = params.get("scope");
    if (scope === "home") {
      return NextResponse.json(
        { items: cachedHomeDeck, total: index.length },
        {
          headers: {
            "Cache-Control":
              "public, max-age=3600, stale-while-revalidate=86400",
          },
        },
      );
    }

    const page = Math.max(
      1,
      Number.parseInt(params.get("page") || "1", 10) || 1,
    );
    const pageSize = Math.min(
      36,
      Math.max(1, Number.parseInt(params.get("pageSize") || "9", 10) || 9),
    );
    const body = (params.get("body") || "").toUpperCase();
    const type = (params.get("type") || "").toUpperCase();
    const equipment = (params.get("equipment") || "ALL").toUpperCase();
    const query = (params.get("q") || "").trim().toLowerCase();
    const filtered = index.filter((exercise) => {
      const matchesBody =
        !body || body === "ALL" || exercise.body_part?.toUpperCase() === body;
      const matchesQuery =
        !query ||
        `${exercise.name} ${exercise.category} ${exercise.body_part} ${exercise.equipment} ${exercise.target}`
          .toLowerCase()
          .includes(query);
      return (
        matchesBody &&
        matchesType(exercise, type) &&
        matchesEquipment(exercise, equipment) &&
        matchesQuery
      );
    });
    const offset = (page - 1) * pageSize;
    return NextResponse.json(
      {
        items: filtered.slice(offset, offset + pageSize),
        total: filtered.length,
        page,
        pageSize,
      },
      {
        headers: {
          "Cache-Control": "public, max-age=3600, stale-while-revalidate=86400",
        },
      },
    );
  } catch {
    return NextResponse.json(
      { error: "Exercise index unavailable" },
      { status: 503 },
    );
  }
}

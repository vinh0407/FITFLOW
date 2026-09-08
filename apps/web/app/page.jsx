"use client";

import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import {
  STORAGE_KEYS,
  readStorage,
  readUserStorage,
  writeStorage,
  writeUserStorage,
} from "../lib/storage";
import { getCurrentUser, logout, updateProfile } from "../lib/auth";
import {
  BMI_PROFILES,
  createWorkoutLog,
  generateTrainingPlan,
  getExercisePrescription,
} from "@fitflow/contracts";
import { useScrollReveal } from "../lib/scroll-reveal";
import { useModalAccessibility } from "../lib/modal-accessibility";
import WorkoutWizardModal from "../components/WorkoutWizardModal";

const bodyParts = [
  "ALL",
  "CHEST",
  "BACK",
  "SHOULDERS",
  "UPPER ARMS",
  "WAIST",
  "UPPER LEGS",
];
const types = ["STRENGTH", "BODY WEIGHT", "CARDIO", "STRETCHING"];
const equipmentOptions = [
  { value: "ALL", label: "ALL" },
  { value: "NONE", label: "NO EQUIPMENT" },
  { value: "REQUIRED", label: "EQUIPMENT NEEDED" },
];
const pageSize = 9;
const calculatorCards = [
  {
    id: "bmi",
    category: "BODY COMPOSITION",
    title: "BMI CALCULATOR",
    description: "Calculate your Body Mass Index from height and weight.",
    formula: "WEIGHT (KG) / HEIGHT (M)²",
  },
  {
    id: "tdee",
    category: "NUTRITION",
    title: "TDEE CALCULATOR",
    description:
      "Estimate your daily energy expenditure from your profile and activity.",
    formula: "MIFFLIN-ST JEOR BMR × ACTIVITY",
  },
  {
    id: "oneRm",
    category: "STRENGTH",
    title: "ONE REP MAX (1RM)",
    description: "Estimate a one-rep maximum for a lift from a working set.",
    formula: "WEIGHT × (1 + REPS / 30)",
  },
  {
    id: "macro",
    category: "NUTRITION",
    title: "MACRO CALCULATOR",
    description:
      "Set a practical protein, carbohydrate, and fat target for your day.",
    formula: "PROTEIN 2G / KG · FAT 25% KCAL",
  },
  {
    id: "bodyFat",
    category: "BODY COMPOSITION",
    title: "BODY FAT CALCULATOR",
    description:
      "Estimate body-fat percentage with the U.S. Navy circumference method.",
    formula: "U.S. NAVY CIRCUMFERENCE METHOD",
  },
  {
    id: "heartRate",
    category: "CARDIO",
    title: "HEART RATE ZONES",
    description:
      "Estimate five training zones from age and resting heart rate.",
    formula: "MAX HR = 220 − AGE",
  },
];
const calculatorDefaults = {
  bmiHeight: "170",
  bmiWeight: "70",
  tdeeAge: "25",
  tdeeHeight: "170",
  tdeeWeight: "70",
  tdeeSex: "male",
  tdeeActivity: "1.375",
  oneRmWeight: "60",
  oneRmReps: "8",
  macroWeight: "70",
  macroTdee: "2200",
  macroGoal: "maintain",
  bodyFatSex: "male",
  bodyFatHeight: "170",
  bodyFatNeck: "38",
  bodyFatWaist: "82",
  bodyFatHip: "95",
  heartAge: "25",
  heartResting: "60",
};

function titleCase(value = "") {
  return value.replace(/\b\w/g, (letter) => letter.toUpperCase());
}

function exerciseMediaUrl(exercise) {
  const fileName = exercise?.gif_url?.split("/").pop();
  return fileName ? `/media-transparent/${fileName}` : "";
}

function markMediaUnavailable(event) {
  event.currentTarget.hidden = true;
  event.currentTarget.parentElement?.classList.add("media-failed");
}

function exerciseBenefit(exercise) {
  const focus = titleCase(
    exercise?.target || exercise?.body_part || "full body",
  );
  return `Supports ${focus.toLowerCase()} strength, control, and movement confidence when practiced with steady form.`;
}

function shuffle(items) {
  return [...items].sort(() => Math.random() - 0.5);
}

function getBmiProfile(bmi) {
  return BMI_PROFILES.find((profile) => profile.bmi === bmi) || null;
}

function getHistoryStats(history = []) {
  const now = Date.now();
  const dayStart = new Date(now);
  dayStart.setHours(0, 0, 0, 0);
  const weekStart = new Date(dayStart);
  weekStart.setDate(weekStart.getDate() - 6);
  const validHistory = history.filter(
    (entry) => entry?.date || entry?.completedAt,
  );
  const timestamp = (entry) => Date.parse(entry.date || entry.completedAt) || 0;
  return {
    today: validHistory.filter(
      (entry) => timestamp(entry) >= dayStart.getTime(),
    ).length,
    week: validHistory.filter(
      (entry) => timestamp(entry) >= weekStart.getTime(),
    ).length,
    total: validHistory.length,
  };
}

function getProgressStats(history = []) {
  const logs = history.flatMap((entry) => entry?.logs || []);
  const sessionsWithRecordedDuration = history.filter(
    (entry) => Number(entry?.durationSeconds) > 0,
  );
  const sessionsWithKcalEstimate = sessionsWithRecordedDuration.filter(
    (entry) => Number(entry?.estimatedKcal) > 0,
  );
  return {
    workouts: history.length,
    exercises: logs.length,
    duration: Math.round(
      sessionsWithRecordedDuration.reduce(
        (sum, entry) => sum + Number(entry.durationSeconds),
        0,
      ) / 60,
    ),
    durationRecorded: sessionsWithRecordedDuration.length > 0,
    kcal: Math.round(
      sessionsWithKcalEstimate.reduce(
        (sum, entry) => sum + Number(entry.estimatedKcal),
        0,
      ),
    ),
    kcalEstimated: sessionsWithKcalEstimate.length > 0,
    volume: logs.reduce(
      (sum, log) =>
        sum +
        (Number(log.weight) || 0) *
          Number(log.sets || 0) *
          Number(log.reps || 0),
      0,
    ),
  };
}

function ExerciseSkeletons() {
  return (
    <div
      className="exercise-grid exercise-grid-skeleton"
      aria-label="Loading exercises"
    >
      {Array.from({ length: pageSize }, (_, index) => (
        <div className="exercise-skeleton" key={index}>
          <div className="skeleton-art" />
          <div className="skeleton-line skeleton-line-wide" />
          <div className="skeleton-line skeleton-line-short" />
        </div>
      ))}
    </div>
  );
}

function GuideMovement({ label, exercises, onOpen }) {
  const [resolving, setResolving] = useState(false);
  const aliases = {
    "bench press": ["barbell bench press"],
    "incline dumbbell press": ["barbell incline bench press"],
    "shoulder press": ["band shoulder press"],
    "lateral raise": ["band front lateral raise"],
    "triceps pushdown": ["cable triceps pushdown (v-bar)"],
    "lat pulldown": ["alternate lateral pulldown"],
    "seated cable row": ["cable low seated row"],
    "one-arm dumbbell row": ["barbell one arm bent over row"],
    "face pull": ["cable rear delt row (with rope)"],
    squat: ["barbell high bar squat"],
    "leg press": ["lever alternate leg press"],
    "leg curl": ["lever lying leg curl"],
    "calf raise": ["band single leg calf raise"],
    "chest fly": ["dumbbell one arm chest fly on exercise ball"],
    "arnold press": ["dumbbell arnold press"],
    "overhead triceps extension": [
      "cable overhead triceps extension (rope attachment)",
    ],
    "pull-up / assisted pull-up": ["assisted pull-up"],
    "barbell row": ["barbell bent over row"],
    "cable row": ["cable low seated row"],
    "rear delt fly": ["barbell rear delt row"],
    "hammer curl": ["dumbbell alternate seated hammer curl"],
    deadlift: ["barbell deadlift"],
    "leg extension": ["lever leg extension"],
    "bulgarian split squat": ["barbell good morning"],
    plank: ["front plank"],
  };
  const normalized = label.toLowerCase();
  const candidates = aliases[normalized] || [normalized];
  const exercise =
    candidates
      .map((candidate) =>
        exercises.find(
          (item) =>
            item.name.toLowerCase() === candidate ||
            item.name.toLowerCase().includes(candidate),
        ),
      )
      .find(Boolean) ||
    exercises.find((item) =>
      normalized
        .split(/\s+|\//)
        .filter((word) => word.length > 2)
        .every((word) => item.name.toLowerCase().includes(word)),
    );
  const displayName = exercise ? titleCase(exercise.name) : label;
  const openMovement = async () => {
    if (exercise) {
      onOpen(exercise);
      return;
    }
    if (normalized === "easy walk, mobility, and rest") return;
    setResolving(true);
    try {
      for (const candidate of candidates) {
        const params = new URLSearchParams({
          q: candidate,
          page: "1",
          pageSize: "9",
        });
        const response = await fetch(`/api/exercises?${params}`);
        if (!response.ok) continue;
        const data = await response.json();
        const resolved = (data.items || []).find(
          (item) =>
            item.name.toLowerCase() === candidate ||
            item.name.toLowerCase().includes(candidate),
        );
        if (resolved) {
          onOpen(resolved);
          return;
        }
      }
    } finally {
      setResolving(false);
    }
  };
  return (
    <button
      type="button"
      className="guide-movement"
      onClick={openMovement}
      disabled={resolving || normalized === "easy walk, mobility, and rest"}
      aria-busy={resolving || undefined}
      aria-label={
        exercise || normalized !== "easy walk, mobility, and rest"
          ? `Open details for ${displayName}`
          : `${displayName} is a recovery activity without a video guide`
      }
    >
      {displayName}
      <span aria-hidden="true">↗</span>
    </button>
  );
}

function CalculatorField({ label, name, value, onChange, ...props }) {
  return (
    <label className="calculator-field">
      {label}
      <input
        name={name}
        value={value}
        onChange={(event) => onChange(name, event.target.value)}
        {...props}
      />
    </label>
  );
}

function CalculatorModal({ calculatorId, values, onChange, onClose }) {
  const calculator = calculatorCards.find((item) => item.id === calculatorId);
  if (!calculator) return null;
  const number = (name) => Number(values[name]) || 0;
  const metric = (label, value, note) => (
    <div className="calculator-metric">
      <strong>{value}</strong>
      <span>{label}</span>
      {note ? <small>{note}</small> : null}
    </div>
  );
  let fields = null;
  let result = null;

  if (calculatorId === "bmi") {
    const height = number("bmiHeight") / 100;
    const bmi = height ? number("bmiWeight") / (height * height) : 0;
    const status =
      bmi < 18.5
        ? "BELOW RANGE"
        : bmi < 25
          ? "STANDARD RANGE"
          : bmi < 30
            ? "ABOVE RANGE"
            : "HIGHER RANGE";
    fields = (
      <>
        <CalculatorField
          label="HEIGHT / CM"
          name="bmiHeight"
          value={values.bmiHeight}
          onChange={onChange}
          type="number"
          min="100"
          max="250"
        />
        <CalculatorField
          label="WEIGHT / KG"
          name="bmiWeight"
          value={values.bmiWeight}
          onChange={onChange}
          type="number"
          min="25"
          max="300"
        />
      </>
    );
    result = metric("BMI", bmi ? bmi.toFixed(1) : "—", status);
  } else if (calculatorId === "tdee") {
    const weight = number("tdeeWeight");
    const height = number("tdeeHeight");
    const age = number("tdeeAge");
    const bmr =
      values.tdeeSex === "female"
        ? 10 * weight + 6.25 * height - 5 * age - 161
        : 10 * weight + 6.25 * height - 5 * age + 5;
    const tdee = bmr * number("tdeeActivity");
    fields = (
      <>
        <CalculatorField
          label="AGE"
          name="tdeeAge"
          value={values.tdeeAge}
          onChange={onChange}
          type="number"
          min="14"
          max="100"
        />
        <CalculatorField
          label="HEIGHT / CM"
          name="tdeeHeight"
          value={values.tdeeHeight}
          onChange={onChange}
          type="number"
          min="100"
          max="250"
        />
        <CalculatorField
          label="WEIGHT / KG"
          name="tdeeWeight"
          value={values.tdeeWeight}
          onChange={onChange}
          type="number"
          min="25"
          max="300"
        />
        <label className="calculator-field">
          SEX
          <select
            value={values.tdeeSex}
            onChange={(event) => onChange("tdeeSex", event.target.value)}
          >
            <option value="male">MALE</option>
            <option value="female">FEMALE</option>
          </select>
        </label>
        <label className="calculator-field">
          ACTIVITY
          <select
            value={values.tdeeActivity}
            onChange={(event) => onChange("tdeeActivity", event.target.value)}
          >
            <option value="1.2">LOW / 1.2×</option>
            <option value="1.375">LIGHT / 1.375×</option>
            <option value="1.55">MODERATE / 1.55×</option>
            <option value="1.725">HIGH / 1.725×</option>
          </select>
        </label>
      </>
    );
    result = metric(
      "ESTIMATED DAILY KCAL",
      tdee ? `${Math.round(tdee)}` : "—",
      "Mifflin-St Jeor estimate",
    );
  } else if (calculatorId === "oneRm") {
    const weight = number("oneRmWeight");
    const reps = number("oneRmReps");
    const epley = weight * (1 + reps / 30);
    const brzycki = reps < 37 ? (weight * 36) / (37 - reps) : 0;
    fields = (
      <>
        <CalculatorField
          label="WORKING WEIGHT / KG"
          name="oneRmWeight"
          value={values.oneRmWeight}
          onChange={onChange}
          type="number"
          min="1"
          max="500"
        />
        <CalculatorField
          label="REPS"
          name="oneRmReps"
          value={values.oneRmReps}
          onChange={onChange}
          type="number"
          min="1"
          max="36"
        />
      </>
    );
    result = (
      <div className="calculator-results">
        {metric("EPLEY 1RM", epley ? `${Math.round(epley)} KG` : "—")}
        {metric("BRZYCKI 1RM", brzycki ? `${Math.round(brzycki)} KG` : "—")}
      </div>
    );
  } else if (calculatorId === "macro") {
    const weight = number("macroWeight");
    const base = number("macroTdee");
    const multiplier =
      values.macroGoal === "cut" ? 0.85 : values.macroGoal === "gain" ? 1.1 : 1;
    const calories = base * multiplier;
    const protein = weight * 2;
    const fat = (calories * 0.25) / 9;
    const carbs = Math.max(0, (calories - protein * 4 - fat * 9) / 4);
    fields = (
      <>
        <CalculatorField
          label="WEIGHT / KG"
          name="macroWeight"
          value={values.macroWeight}
          onChange={onChange}
          type="number"
          min="25"
          max="300"
        />
        <CalculatorField
          label="TDEE / KCAL"
          name="macroTdee"
          value={values.macroTdee}
          onChange={onChange}
          type="number"
          min="1000"
          max="7000"
        />
        <label className="calculator-field">
          GOAL
          <select
            value={values.macroGoal}
            onChange={(event) => onChange("macroGoal", event.target.value)}
          >
            <option value="cut">CUT</option>
            <option value="maintain">MAINTAIN</option>
            <option value="gain">GAIN</option>
          </select>
        </label>
      </>
    );
    result = (
      <div className="calculator-results">
        {metric("DAILY KCAL", calories ? Math.round(calories) : "—")}
        {metric("PROTEIN", protein ? `${Math.round(protein)} G` : "—")}
        {metric("CARBS", carbs ? `${Math.round(carbs)} G` : "—")}
        {metric("FAT", fat ? `${Math.round(fat)} G` : "—")}
      </div>
    );
  } else if (calculatorId === "bodyFat") {
    const height = number("bodyFatHeight");
    const neck = number("bodyFatNeck");
    const waist = number("bodyFatWaist");
    const hip = number("bodyFatHip");
    const logTerm =
      values.bodyFatSex === "female" ? waist + hip - neck : waist - neck;
    const bodyFat =
      logTerm > 0 && height > 0
        ? values.bodyFatSex === "female"
          ? 495 /
              (1.29579 -
                0.35004 * Math.log10(logTerm) +
                0.221 * Math.log10(height)) -
            450
          : 495 /
              (1.0324 -
                0.19077 * Math.log10(logTerm) +
                0.15456 * Math.log10(height)) -
            450
        : 0;
    fields = (
      <>
        <label className="calculator-field">
          SEX
          <select
            value={values.bodyFatSex}
            onChange={(event) => onChange("bodyFatSex", event.target.value)}
          >
            <option value="male">MALE</option>
            <option value="female">FEMALE</option>
          </select>
        </label>
        <CalculatorField
          label="HEIGHT / CM"
          name="bodyFatHeight"
          value={values.bodyFatHeight}
          onChange={onChange}
          type="number"
          min="100"
          max="250"
        />
        <CalculatorField
          label="NECK / CM"
          name="bodyFatNeck"
          value={values.bodyFatNeck}
          onChange={onChange}
          type="number"
          min="20"
          max="80"
        />
        <CalculatorField
          label="WAIST / CM"
          name="bodyFatWaist"
          value={values.bodyFatWaist}
          onChange={onChange}
          type="number"
          min="40"
          max="200"
        />
        {values.bodyFatSex === "female" ? (
          <CalculatorField
            label="HIP / CM"
            name="bodyFatHip"
            value={values.bodyFatHip}
            onChange={onChange}
            type="number"
            min="40"
            max="220"
          />
        ) : null}
      </>
    );
    result = metric(
      "ESTIMATED BODY FAT",
      bodyFat ? `${Math.max(0, bodyFat).toFixed(1)}%` : "—",
      "U.S. Navy estimate",
    );
  } else {
    const age = number("heartAge");
    const resting = number("heartResting");
    const max = Math.max(0, 220 - age);
    const zone = (low, high) =>
      resting > 0
        ? `${Math.round((max - resting) * low + resting)}–${Math.round((max - resting) * high + resting)}`
        : `${Math.round(max * low)}–${Math.round(max * high)}`;
    fields = (
      <>
        <CalculatorField
          label="AGE"
          name="heartAge"
          value={values.heartAge}
          onChange={onChange}
          type="number"
          min="14"
          max="100"
        />
        <CalculatorField
          label="RESTING HR / BPM"
          name="heartResting"
          value={values.heartResting}
          onChange={onChange}
          type="number"
          min="30"
          max="120"
        />
      </>
    );
    result = (
      <div className="calculator-results calculator-zones">
        {metric("ZONE 1 · 50–60%", `${zone(0.5, 0.6)} BPM`)}
        {metric("ZONE 2 · 60–70%", `${zone(0.6, 0.7)} BPM`)}
        {metric("ZONE 3 · 70–80%", `${zone(0.7, 0.8)} BPM`)}
        {metric("ZONE 4 · 80–90%", `${zone(0.8, 0.9)} BPM`)}
        {metric("ZONE 5 · 90–100%", `${zone(0.9, 1)} BPM`)}
      </div>
    );
  }

  return (
    <div className="modal-backdrop" onClick={onClose}>
      <section
        className="calculator-modal"
        role="dialog"
        aria-modal="true"
        aria-labelledby="calculator-title"
        onClick={(event) => event.stopPropagation()}
      >
        <button
          type="button"
          className="close-modal"
          onClick={onClose}
          aria-label="Close calculator"
        >
          ×
        </button>
        <span className="footer-label">FITFLOW / {calculator.category}</span>
        <h2 id="calculator-title">{calculator.title}</h2>
        <p>{calculator.description}</p>
        <div className="calculator-form">{fields}</div>
        <div className="calculator-output" aria-live="polite">
          {result}
        </div>
        <small className="calculator-note">
          Estimate only — not medical advice. Use consistent measurements and
          consult a qualified professional where needed.
        </small>
      </section>
    </div>
  );
}

export default function Home() {
  useScrollReveal(".site-shell");
  const [allExercises, setAllExercises] = useState([]);
  const [catalogExercises, setCatalogExercises] = useState([]);
  const [catalogTotal, setCatalogTotal] = useState(0);
  const [bodyFilter, setBodyFilter] = useState("ALL");
  const [typeFilter, setTypeFilter] = useState("");
  const [equipmentFilter, setEquipmentFilter] = useState("ALL");
  const [query, setQuery] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [exerciseError, setExerciseError] = useState("");
  const [exerciseStatus, setExerciseStatus] = useState("idle");
  const exerciseRequest = useRef(0);
  const exerciseAbortController = useRef(null);
  const [page, setPage] = useState(1);
  const [hydrated, setHydrated] = useState(false);
  const [currentUser, setCurrentUser] = useState(null);
  const [profileOpen, setProfileOpen] = useState(false);
  const [mobileNavOpen, setMobileNavOpen] = useState(false);
  const [profileDraft, setProfileDraft] = useState(null);
  const [profileSaved, setProfileSaved] = useState(false);
  const [profileError, setProfileError] = useState("");
  const [dark, setDark] = useState(false);
  const [savedProfile, setSavedProfile] = useState(null);
  const [savedPlan, setSavedPlan] = useState(null);
  const [workoutHistory, setWorkoutHistory] = useState([]);
  const historyView = useMemo(() => {
    let damaged = false;
    const isRecord = (value) => value && typeof value === "object" && !Array.isArray(value);
    const entries = workoutHistory.filter((entry) => {
      if (!isRecord(entry)) damaged = true;
      return isRecord(entry);
    }).map((entry) => {
      if (entry.logs != null && !Array.isArray(entry.logs)) damaged = true;
      const logs = (Array.isArray(entry.logs) ? entry.logs : []).filter((log) => {
        if (!isRecord(log)) damaged = true;
        return isRecord(log);
      });
      return { ...entry, logs };
    });
    return { entries, damaged };
  }, [workoutHistory]);
  const [historyStats, setHistoryStats] = useState({
    today: 0,
    week: 0,
    total: 0,
  });
  const [progressStats, setProgressStats] = useState({
    workouts: 0,
    exercises: 0,
    duration: 0,
    durationRecorded: false,
    kcal: 0,
    kcalEstimated: false,
    volume: 0,
  });
  const [height, setHeight] = useState("170");
  const [weight, setWeight] = useState("70");
  const [planReady, setPlanReady] = useState(false);
  const [currentDay, setCurrentDay] = useState(1);
  const [planSaved, setPlanSaved] = useState(false);
  const [exportBusy, setExportBusy] = useState(false);
  const [exportError, setExportError] = useState("");
  const [workoutOpen, setWorkoutOpen] = useState(false);
  const [workoutIndex, setWorkoutIndex] = useState(0);
  const [completedSets, setCompletedSets] = useState(0);
  const [workoutSeconds, setWorkoutSeconds] = useState(0);
  const [sessionExercises, setSessionExercises] = useState([]);
  const [selectedExercise, setSelectedExercise] = useState(null);
  const [exerciseDetailStatus, setExerciseDetailStatus] = useState("idle");
  const [exerciseDetailRetry, setExerciseDetailRetry] = useState(0);
  const [customDayCount, setCustomDayCount] = useState("7");
  const [customPlanReady, setCustomPlanReady] = useState(false);
  const [customCurrentDay, setCustomCurrentDay] = useState(1);
  const [customPlanSaved, setCustomPlanSaved] = useState(false);
  const [customExerciseIds, setCustomExerciseIds] = useState(null);
  const [customQuery, setCustomQuery] = useState("");
  const [calorieOpen, setCalorieOpen] = useState(false);
  const [calculatorCategory, setCalculatorCategory] = useState("ALL");
  const [activeCalculator, setActiveCalculator] = useState(null);
  const [calculatorInputs, setCalculatorInputs] = useState(calculatorDefaults);
  const [calorieAge, setCalorieAge] = useState("25");
  const [calorieSex, setCalorieSex] = useState("male");
  const [calorieActivity, setCalorieActivity] = useState("1.375");
  const [calorieGoal, setCalorieGoal] = useState("maintain");
  const [donateOpen, setDonateOpen] = useState(false);
  const [plan365Open, setPlan365Open] = useState(false);
  const [logoutConfirmOpen, setLogoutConfirmOpen] = useState(false);
  const [wizardOpen, setWizardOpen] = useState(false);

  useEffect(() => {
    if (typeof window !== "undefined") {
      const params = new URLSearchParams(window.location.search);
      if (params.get("wizard") === "1" || params.get("onboarding") === "1") {
        setWizardOpen(true);
      }
    }
  }, []);

  const loadExercises = () => {
    const requestId = exerciseRequest.current + 1;
    exerciseRequest.current = requestId;
    exerciseAbortController.current?.abort();
    const controller = new AbortController();
    exerciseAbortController.current = controller;
    setExerciseStatus("loading");
    setLoading(true);
    setExerciseError("");
    const timeout = window.setTimeout(() => {
      if (exerciseRequest.current === requestId) {
        setExerciseStatus("error");
        setExerciseError("MOVEMENT DATA TIMED OUT.");
        setLoading(false);
      }
    }, 12000);
    const params = new URLSearchParams({
      page: String(page),
      pageSize: String(pageSize),
    });
    if (bodyFilter && bodyFilter !== "ALL") params.set("body", bodyFilter);
    if (typeFilter) params.set("type", typeFilter);
    if (equipmentFilter !== "ALL") params.set("equipment", equipmentFilter);
    if (searchQuery) params.set("q", searchQuery);
    fetch(`/api/exercises?${params}`, {
      cache: "force-cache",
      signal: controller.signal,
    })
      .then((response) => {
        if (!response.ok) throw new Error("Exercise data unavailable");
        return response.json();
      })
      .then((data) => {
        if (exerciseRequest.current !== requestId) return;
        const next = Array.isArray(data?.items) ? data.items : [];
        setCatalogExercises(next);
        setCatalogTotal(Number(data?.total) || 0);
        setExerciseStatus(next.length ? "success" : "empty");
      })
      .catch((error) => {
        if (
          error?.name === "AbortError" ||
          exerciseRequest.current !== requestId
        )
          return;
        setCatalogExercises([]);
        setCatalogTotal(0);
        setExerciseStatus("error");
        setExerciseError("MOVEMENT DATA COULD NOT LOAD.");
      })
      .finally(() => {
        window.clearTimeout(timeout);
        if (exerciseRequest.current === requestId) setLoading(false);
      });
  };

  useEffect(() => {
    loadExercises();
    return () => {
      exerciseRequest.current += 1;
      exerciseAbortController.current?.abort();
    };
  }, [page, bodyFilter, typeFilter, equipmentFilter, searchQuery]);
  useEffect(() => {
    fetch("/api/exercises?scope=home&guide=1", { cache: "force-cache" })
      .then((response) => (response.ok ? response.json() : null))
      .then((data) =>
        setAllExercises(Array.isArray(data?.items) ? data.items : []),
      )
      .catch(() => setAllExercises([]));
  }, []);
  useEffect(() => {
    if (!selectedExercise?.id) return undefined;
    if (selectedExercise.instruction_steps) {
      setExerciseDetailStatus("success");
      return undefined;
    }
    const controller = new AbortController();
    setExerciseDetailStatus("loading");
    fetch(`/api/exercises/${selectedExercise.id}`, {
      signal: controller.signal,
      cache: "force-cache",
    })
      .then((response) => {
        if (!response.ok) throw new Error("Exercise instructions unavailable");
        return response.json();
      })
      .then((details) => {
        if (details)
          setSelectedExercise((current) =>
            current?.id === selectedExercise.id
              ? { ...current, ...details }
              : current,
          );
      })
      .catch((error) => {
        if (error.name !== "AbortError") setExerciseDetailStatus("error");
      });
    return () => controller.abort();
  }, [selectedExercise?.id, selectedExercise?.instruction_steps, exerciseDetailRetry]);
  useEffect(() => {
    const timer = window.setTimeout(() => setSearchQuery(query), 300);
    return () => window.clearTimeout(timer);
  }, [query]);

  useEffect(() => {
    const profile = readUserStorage(STORAGE_KEYS.profile, null);
    const plan = readUserStorage(STORAGE_KEYS.plan, null);
    const history = readUserStorage(STORAGE_KEYS.workoutHistory, []);
    setCurrentUser(getCurrentUser());
    setDark(readStorage(STORAGE_KEYS.theme, "light") === "dark");
    setSavedProfile(profile);
    setSavedPlan(plan);
    setWorkoutHistory(Array.isArray(history) ? history : []);
    setHeight(String(profile?.height || "170"));
    setWeight(String(profile?.weight || "70"));
    setPlanReady(Boolean(plan));
    setPlanSaved(Boolean(plan));
    setHydrated(true);
  }, []);

  useEffect(() => {
    if (hydrated) setHistoryStats(getHistoryStats(historyView.entries));
  }, [hydrated, historyView]);

  const closeTopModal = useCallback(() => {
    if (logoutConfirmOpen) setLogoutConfirmOpen(false);
    else if (wizardOpen) setWizardOpen(false);
    else if (activeCalculator) setActiveCalculator(null);
    else if (workoutOpen) setWorkoutOpen(false);
    else if (selectedExercise) setSelectedExercise(null);
    else if (profileOpen) setProfileOpen(false);
    else if (plan365Open) setPlan365Open(false);
    else if (donateOpen) setDonateOpen(false);
  }, [
    logoutConfirmOpen,
    wizardOpen,
    activeCalculator,
    workoutOpen,
    selectedExercise,
    profileOpen,
    plan365Open,
    donateOpen,
  ]);
  useModalAccessibility(
    Boolean(
      wizardOpen ||
      workoutOpen ||
      selectedExercise ||
      profileOpen ||
      donateOpen ||
      plan365Open ||
      activeCalculator ||
      logoutConfirmOpen,
    ),
    closeTopModal,
  );
  useEffect(() => {
    if (hydrated) setProgressStats(getProgressStats(historyView.entries));
  }, [hydrated, historyView]);

  useEffect(() => {
    if (!hydrated) return;
    document.documentElement.dataset.theme = dark ? "dark" : "light";
    writeStorage(STORAGE_KEYS.theme, dark ? "dark" : "light");
  }, [dark, hydrated]);

  const featured = useMemo(() => {
    if (!allExercises.length) return null;
    const today = new Date();
    const daySeed =
      Date.UTC(today.getFullYear(), today.getMonth(), today.getDate()) /
      86400000;
    return allExercises[Math.abs(Math.floor(daySeed)) % allExercises.length];
  }, [allExercises]);
  const filteredExercises = catalogExercises;
  const pageCount = Math.max(1, Math.ceil(catalogTotal / pageSize));
  const visibleExercises = catalogExercises;
  const hasCatalogFilters = Boolean(searchQuery || bodyFilter !== "ALL" || typeFilter || equipmentFilter !== "ALL");
  const clearCatalogFilters = () => {
    setBodyFilter("ALL");
    setTypeFilter("");
    setEquipmentFilter("ALL");
    setQuery("");
    setSearchQuery("");
    setPage(1);
  };
  const pageNumbers = Array.from(
    { length: pageCount },
    (_, index) => index + 1,
  ).filter(
    (number) =>
      number === 1 || number === pageCount || Math.abs(number - page) <= 1,
  );
  const changeBodyFilter = (value) => {
    setBodyFilter(value);
    setPage(1);
  };
  const changeTypeFilter = (value) => {
    setTypeFilter(value);
    setPage(1);
  };
  const changeEquipmentFilter = (value) => {
    setEquipmentFilter(value);
    setPage(1);
  };
  const bmi =
    Number(height) > 0 && Number(weight) > 0
      ? Number(weight) / (Number(height) / 100) ** 2
      : 0;
  const roundedBmi = Math.round(bmi);
  const bmiProfile = bmi ? getBmiProfile(roundedBmi) : null;
  const smartPlan = generateTrainingPlan({
    age: currentUser?.profile?.age,
    height,
    weight,
    trainingLevel: currentUser?.profile?.trainingLevel,
    trainingGoal: currentUser?.profile?.trainingGoal,
    daysPerWeek: currentUser?.profile?.daysPerWeek,
  });
  useEffect(() => {
    if (!planReady || !bmiProfile) return;
    const profile = {
      ...(savedProfile || {}),
      height: Number(height),
      weight: Number(weight),
      bmi: roundedBmi,
      goal: smartPlan.goal,
      level: smartPlan.level,
      daysPerWeek: smartPlan.daysPerWeek,
      savedAt: new Date().toISOString(),
    };
    writeUserStorage(STORAGE_KEYS.profile, profile);
    setSavedProfile(profile);
  }, [
    planReady,
    bmiProfile,
    height,
    weight,
    roundedBmi,
    smartPlan.goal,
    smartPlan.level,
    smartPlan.daysPerWeek,
  ]);
  const planExercises = useMemo(() => {
    if (!bmiProfile) return [];
    const preferred = bmiProfile.preferred;
    const goalTypes = {
      weight_loss: ["cardio", "body weight"],
      muscle_gain: ["strength", "barbell", "dumbbell"],
      maintenance: ["body weight", "dumbbell", "cable"],
      general_fitness: ["body weight", "cable", "dumbbell"],
    };
    const goalPreferred =
      goalTypes[smartPlan.goal] || goalTypes.general_fitness;
    const goalMatches = allExercises.filter((exercise) =>
      goalPreferred.some(
        (term) => exercise.category === term || exercise.equipment === term,
      ),
    );
    const compatible = [
      ...goalMatches,
      ...allExercises.filter(
        (exercise) =>
          preferred.includes(exercise.equipment) &&
          !goalMatches.includes(exercise),
      ),
    ];
    const offset = (roundedBmi - 18) * 2;
    return [...compatible.slice(offset), ...compatible.slice(0, offset)].slice(
      0,
      6,
    );
  }, [allExercises, roundedBmi, bmiProfile, smartPlan.goal]);
  const planDays = smartPlan.sessions.map((session, index) => ({
    day: session.day,
    rest: session.isRest,
    focus: session.focus,
    sets: session.sets,
    reps: session.reps,
    durationMinutes: session.durationMinutes,
    exercises: session.isRest
      ? []
      : Array.from(
          { length: session.exerciseCount },
          (_, offset) =>
            planExercises[
              (index * 3 + offset) % Math.max(planExercises.length, 1)
            ],
        ).filter(Boolean),
  }));
  const selectedDay = planDays[currentDay - 1];
  const download365Plan = async () => {
    if (exportBusy) return;
    setExportBusy(true);
    setExportError("");
    try {
      const response = await fetch("/api/plan-export", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ profile: { height, weight }, sessions: planDays }),
      });
      if (!response.ok) throw new Error("Export failed");
      const blob = await response.blob();
      const url = URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = "FITFLOW_365_DAYS.xlsx";
      document.body.appendChild(link);
      link.click();
      setTimeout(() => {
        URL.revokeObjectURL(url);
        link.remove();
      }, 0);
    } catch {
      setExportError("Could not download the plan. Check your connection and try again.");
    } finally {
      setExportBusy(false);
    }
  };
  const savePlan = () => {
    const profile = {
      height: Number(height),
      weight: Number(weight),
      bmi: roundedBmi,
      goal: smartPlan.goal,
      level: smartPlan.level,
      daysPerWeek: smartPlan.daysPerWeek,
      savedAt: new Date().toISOString(),
    };
    const plan = {
      ...profile,
      focus: smartPlan.focus,
      days: planDays,
      savedAt: new Date().toISOString(),
    };
    writeUserStorage(STORAGE_KEYS.profile, profile);
    writeUserStorage(STORAGE_KEYS.plan, plan);
    setSavedProfile(profile);
    setSavedPlan(plan);
    setPlanSaved(true);
  };
  const openProfile = () => {
    setProfileError("");
    setProfileDraft(
      currentUser
        ? { ...(currentUser.profile || {}), name: currentUser.name }
        : null,
    );
    setProfileSaved(false);
    setProfileOpen(true);
  };
  const saveProfile = (event) => {
    event.preventDefault();
    setProfileSaved(false);
    setProfileError("");
    const result = updateProfile({
      name: profileDraft.name,
      profile: profileDraft,
    });
    if (!result.ok) {
      setProfileError(result.error);
      return;
    }
    setCurrentUser(result.user);
    setProfileDraft({ ...result.user.profile, name: result.user.name });
    setProfileSaved(true);
    const nextHeight = Number(result.user.profile.heightCm);
    const nextWeight = Number(result.user.profile.weightKg);
    if (nextHeight > 0 && nextWeight > 0) {
      setHeight(String(nextHeight));
      setWeight(String(nextWeight));
      writeUserStorage(STORAGE_KEYS.profile, {
        height: nextHeight,
        weight: nextWeight,
        bmi: Math.round(nextWeight / (nextHeight / 100) ** 2),
        savedAt: new Date().toISOString(),
      });
    }
  };
  const updateProfileField = (field) => (event) => {
    setProfileSaved(false);
    setProfileError("");
    setProfileDraft((current) => ({ ...current, [field]: event.target.value }));
  };
  const customPool =
    customExerciseIds === null
      ? allExercises.slice(0, 8)
      : allExercises.filter((exercise) =>
          customExerciseIds.includes(exercise.id),
        );
  const customPickerExercises = useMemo(() => {
    const needle = customQuery.trim().toLowerCase();
    return allExercises
      .filter(
        (exercise) =>
          !needle ||
          `${exercise.name} ${exercise.body_part} ${exercise.equipment} ${exercise.target}`
            .toLowerCase()
            .includes(needle),
      )
      .slice(0, 18);
  }, [allExercises, customQuery]);
  const customDays = Array.from(
    { length: Math.min(7, Math.max(1, Number(customDayCount) || 1)) },
    (_, index) => ({
      day: index + 1,
      exercises: Array.from(
        { length: index % 2 === 0 ? 4 : 3 },
        (_, offset) =>
          customPool[(index * 2 + offset) % Math.max(customPool.length, 1)],
      ).filter(Boolean),
    }),
  );
  const customSelectedDay = customDays[customCurrentDay - 1];
  const todayWorkoutMinutes = 20;
  const todayWorkoutExerciseMinutes = 4;
  const todayWorkoutTargetSeconds = todayWorkoutMinutes * 60;
  const todayWorkoutExerciseTargetSeconds = todayWorkoutExerciseMinutes * 60;
  const calorieBmr =
    calorieSex === "male"
      ? 10 * Number(weight) + 6.25 * Number(height) - 5 * Number(calorieAge) + 5
      : 10 * Number(weight) +
        6.25 * Number(height) -
        5 * Number(calorieAge) -
        161;
  const calorieAdjustment =
    calorieGoal === "cut" ? -350 : calorieGoal === "gain" ? 250 : 0;
  const calorieTarget = Math.max(
    1200,
    Math.round(calorieBmr * Number(calorieActivity) + calorieAdjustment),
  );
  const toggleCustomExercise = (id) => {
    const current =
      customExerciseIds === null
        ? allExercises.slice(0, 8).map((exercise) => exercise.id)
        : customExerciseIds;
    setCustomExerciseIds(
      current.includes(id)
        ? current.filter((item) => item !== id)
        : [...current, id],
    );
    setCustomPlanReady(false);
    setCustomPlanSaved(false);
  };
  const workoutExercises = sessionExercises.length
    ? sessionExercises
    : planExercises.length
      ? planExercises.slice(0, 4)
      : allExercises.slice(0, 4);
  const activeExercise = workoutExercises[workoutIndex];
  const activePrescription = activeExercise
    ? getExercisePrescription(activeExercise, {
        height,
        weight,
        trainingLevel: currentUser?.profile?.trainingLevel,
        trainingGoal: currentUser?.profile?.trainingGoal,
      })
    : null;
  useEffect(() => {
    if (!workoutOpen) return undefined;
    const timer = setInterval(
      () => setWorkoutSeconds((value) => value + 1),
      1000,
    );
    return () => clearInterval(timer);
  }, [workoutOpen]);
  const makeNextRep = () => {
    const cardio = shuffle(
      allExercises.filter((exercise) => exercise.category === "cardio"),
    )[0];
    const bodyMoves = shuffle(
      allExercises.filter((exercise) => exercise.category !== "cardio"),
    );
    const uniqueBodyMoves = [];
    const seenParts = new Set();
    bodyMoves.forEach((exercise) => {
      if (uniqueBodyMoves.length < 4 && !seenParts.has(exercise.body_part)) {
        seenParts.add(exercise.body_part);
        uniqueBodyMoves.push(exercise);
      }
    });
    return shuffle([...uniqueBodyMoves, cardio].filter(Boolean));
  };
  const startWorkout = (exercises = null) => {
    setSessionExercises(exercises?.length ? exercises : makeNextRep());
    setWorkoutIndex(0);
    setCompletedSets(0);
    setWorkoutSeconds(0);
    setWorkoutOpen(true);
  };
  const finishSet = () => {
    if (completedSets < 3) setCompletedSets((value) => value + 1);
    else if (workoutIndex < workoutExercises.length - 1) {
      setWorkoutIndex((value) => value + 1);
      setCompletedSets(0);
    } else {
      const workoutId = `session-${Date.now()}`;
      const duration = workoutSeconds > 0 ? workoutSeconds : null;
      const kcal = duration ? Math.round(duration * 0.12) : null;
      const logs = workoutExercises.map((exercise) =>
        createWorkoutLog({
          workoutId,
          date: new Date().toISOString(),
          exerciseId: exercise.id,
          exerciseName: exercise.name,
          sets: getExercisePrescription(exercise, {
            height,
            weight,
            trainingLevel: currentUser?.profile?.trainingLevel,
            trainingGoal: currentUser?.profile?.trainingGoal,
          }).sets,
          reps:
            getExercisePrescription(exercise, {
              height,
              weight,
              trainingLevel: currentUser?.profile?.trainingLevel,
              trainingGoal: currentUser?.profile?.trainingGoal,
            }).reps || 0,
          weight: null,
          duration:
            getExercisePrescription(exercise, {
              height,
              weight,
              trainingLevel: currentUser?.profile?.trainingLevel,
              trainingGoal: currentUser?.profile?.trainingGoal,
            }).mode === "seconds"
              ? getExercisePrescription(exercise, {
                  height,
                  weight,
                  trainingLevel: currentUser?.profile?.trainingLevel,
                  trainingGoal: currentUser?.profile?.trainingGoal,
                }).seconds
              : duration
                ? Math.round(duration / Math.max(workoutExercises.length, 1))
                : null,
          kcal: kcal
            ? Math.round(kcal / Math.max(workoutExercises.length, 1))
            : null,
          kcalEstimated: Boolean(kcal),
          notes: "",
          completed: true,
        }),
      );
      const entry = {
        workoutId,
        date: new Date().toISOString(),
        completedAt: new Date().toISOString(),
        durationSeconds: duration,
        exerciseCount: workoutExercises.length,
        exerciseIds: workoutExercises.map((exercise) => exercise.id),
        exercises: workoutExercises.map((exercise) => ({
          id: exercise.id,
          name: exercise.name,
          bodyPart: exercise.body_part,
          setsCompleted: 4,
        })),
        logs,
        estimatedKcal: kcal,
        kcalEstimated: Boolean(kcal),
        note: "",
      };
      const nextHistory = [entry, ...workoutHistory].slice(0, 50);
      writeUserStorage(STORAGE_KEYS.workoutHistory, nextHistory);
      setWorkoutHistory(nextHistory);
      setWorkoutOpen(false);
    }
  };
  const formatTime = (value) =>
    `${String(Math.floor(value / 60)).padStart(2, "0")}:${String(value % 60).padStart(2, "0")}`;
  const formatTarget = () =>
    activePrescription?.mode === "reps"
      ? `${activePrescription.sets} × ${activePrescription.reps} REPS`
      : formatTime(
          activePrescription?.seconds || todayWorkoutExerciseTargetSeconds,
        );
  const visibleCalculators = calculatorCards.filter(
    (calculator) =>
      calculatorCategory === "ALL" ||
      calculator.category === calculatorCategory,
  );
  const updateCalculatorInput = (name, value) =>
    setCalculatorInputs((current) => ({ ...current, [name]: value }));
  return (
    <main className="site-shell">
      <a className="skip-link" href="#top">
        SKIP TO CONTENT
      </a>
      <div
        className="storage-strip"
        role="status"
        aria-label="FITFLOW operational telemetry"
      >
        <span className="ticker-badge">● PROTOCOL / LOCAL-FIRST</span>
        <span className="ticker-item">
          PROFILE: <b>{savedProfile ? "READY" : "SETUP NEEDED"}</b>
        </span>
        <span className="ticker-item">
          PLAN: <b>{savedPlan ? "ACTIVE" : "7-DAY STARTER"}</b>
        </span>
        <span className="ticker-telemetry">
          {historyStats.today > 0 ? (
            <b className="ticker-highlight">{historyStats.today} COMPLETED TODAY</b>
          ) : (
            "TODAY: READY TO TRAIN"
          )}{" "}
          · {historyStats.week} THIS WEEK · {historyStats.total} TOTAL SESSIONS
        </span>
      </div>
      <header className="site-header">
        <a className="wordmark" href="#top" aria-label="FITFLOW home">
          <span className="mark">F</span> FITFLOW <span className="os-tag">// OS</span>
        </a>
        <nav
          className={`main-nav ${mobileNavOpen ? "is-open" : ""}`}
          id="mobile-main-nav"
          aria-label="Main navigation"
        >
          <a href="#about" onClick={() => setMobileNavOpen(false)}>
            ABOUT
          </a>
          <a href="#workouts" onClick={() => setMobileNavOpen(false)}>
            WORKOUTS
          </a>
          <a href="#library" onClick={() => setMobileNavOpen(false)}>
            EXERCISES
          </a>
          <a href="#plans" onClick={() => setMobileNavOpen(false)}>
            PLANS
          </a>
          <a href="/nutrition">NUTRITION</a>
          <a href="#custom-plan" onClick={() => setMobileNavOpen(false)}>
            GUIDE
          </a>
        </nav>
        {currentUser ? (
          <button className="auth-nav-link" onClick={openProfile}>
            {currentUser.name}
          </button>
        ) : (
          <a className="auth-nav-link" href="/auth">
            SIGN IN
          </a>
        )}
        <button
          className="theme-toggle"
          aria-label="Toggle dark mode"
          onClick={() => setDark((value) => !value)}
        >
          {dark ? "☼" : "☾"}
        </button>
        <button className="donate-button" onClick={() => setDonateOpen(true)}>
          DONATE <span>↗</span>
        </button>
        <button
          className="mobile-nav-toggle"
          type="button"
          aria-controls="mobile-main-nav"
          aria-expanded={mobileNavOpen}
          aria-label={
            mobileNavOpen ? "Close navigation menu" : "Open navigation menu"
          }
          onClick={() => setMobileNavOpen((value) => !value)}
        >
          {mobileNavOpen ? "CLOSE" : "MENU"}
        </button>
      </header>

      <section className="hero" id="top">
        <div className="hero-feature">
          <div className="hero-art">
            {featured ? (
              <>
                <span className="registration">
                  FITFLOW / DAILY {featured.id}
                </span>
                <img
                  fetchPriority="high"
                  decoding="async"
                  src={exerciseMediaUrl(featured)}
                  alt={`Demonstration of ${featured.name}`}
                  onError={markMediaUnavailable}
                />
                <span className="art-label">EXERCISE OF THE DAY</span>
              </>
            ) : (
              <span className="loading-label">LOADING MOVEMENT...</span>
            )}
          </div>
          <div className="hero-caption">
            <span className="hero-number">01</span>
            <h1>
              START
              <br />
              <i>WHERE YOU ARE.</i>
            </h1>
            <p>
              Simple training plans, clear exercise guidance, and no pressure to
              be anyone but yourself.
            </p>
            <div className="hero-action-group">
              <button
                type="button"
                className="red-action hero-start-btn"
                onClick={() => startWorkout()}
              >
                START WORKOUT <span>→</span>
              </button>
              <a href="#library" className="text-link">
                EXPLORE LIBRARY <span>→</span>
              </a>
            </div>
          </div>
        </div>
        <div className="hero-stack">
          <a className="poster poster-red" href="#plans">
            <span>PROGRAM / 07 DAYS</span>
            <strong>
              BUILD
              <br />A BASE
            </strong>
            <small>STARTER PLAN →</small>
          </a>
          <a className="poster poster-ink" href="#workouts">
            <span>WORKOUT / 20 MIN</span>
            <strong>
              NO
              <br />
              EXCUSES
            </strong>
            <small>BODYWEIGHT SESSION →</small>
          </a>
        </div>
      </section>

      <section className="promise" id="about">
        <span>01 / THE FITFLOW PROMISE</span>
        <h2>
          TRAINING SHOULD
          <br />
          <em>FEEL POSSIBLE.</em>
        </h2>
        <div className="about-copy">
          <p>
            FITFLOW is for the days when you want to move forward but need a
            clear place to begin. No perfect routine, expensive gym, or outside
            pressure—just a simple plan, honest form, and a pace you can return
            to.
          </p>
          <p>
            Built for people training on their own, FITFLOW turns one small
            decision into momentum. Start where you are, listen to your body,
            and let the next rep be yours.
          </p>
          <a href="/about" className="about-more-link">
            MORE ABOUT FITFLOW <span aria-hidden="true">→</span>
          </a>
        </div>
      </section>

      <section className="catalog-section" id="library">
        <aside className="catalog-aside">
          <p className="catalog-count">
            {loading ? "..." : catalogTotal.toLocaleString()} EXERCISES
            <br />
            <small>IN THE DATABASE</small>
          </p>
          <label htmlFor="search">SEARCH</label>
          <input
            id="search"
            type="search"
            autoComplete="off"
            value={query}
            onChange={(event) => {
              setQuery(event.target.value);
              setPage(1);
            }}
            placeholder="Find an exercise"
          />
          <div className="filter-group">
            <span>BODY PART</span>
            {bodyParts.map((item) => (
              <button
                type="button"
                aria-pressed={bodyFilter === item}
                className={bodyFilter === item ? "selected" : ""}
                key={item}
                onClick={() => changeBodyFilter(item)}
              >
                {item}
              </button>
            ))}
          </div>
          <div className="filter-group">
            <span>TYPE</span>
            {types.map((item) => (
              <button
                type="button"
                aria-pressed={typeFilter === item}
                className={typeFilter === item ? "selected" : ""}
                key={item}
                onClick={() => changeTypeFilter(item)}
              >
                {item}
              </button>
            ))}
          </div>
          <div className="filter-group">
            <span>EQUIPMENT</span>
            {equipmentOptions.map((item) => (
              <button
                type="button"
                aria-pressed={equipmentFilter === item.value}
                className={equipmentFilter === item.value ? "selected" : ""}
                key={item.value}
                onClick={() => changeEquipmentFilter(item.value)}
              >
                {item.label}
              </button>
            ))}
          </div>
          <button
            type="button"
            className="clear-filter"
            onClick={clearCatalogFilters}
          >
            CLEAR FILTERS
          </button>
        </aside>
        <div className="catalog-main">
          <div className="section-title">
            <h2>EXERCISE LIBRARY</h2>
            <span aria-live="polite">
              {visibleExercises.length.toLocaleString()} SHOWN /{" "}
              {catalogTotal.toLocaleString()}
            </span>
          </div>
          {exerciseStatus === "loading" || exerciseStatus === "idle" ? (
            <ExerciseSkeletons />
          ) : exerciseStatus === "error" ? (
            <div className="catalog-error" role="alert">
              <strong>UNABLE TO LOAD EXERCISES.</strong>
              <span>
                We could not load the movement data. Check your connection and
                try again.
              </span>
              <button
                type="button"
                className="clear-filter"
                onClick={loadExercises}
              >
                RETRY
              </button>
            </div>
          ) : exerciseStatus === "empty" ? (
            <div className="catalog-error empty-catalog" role="status">
              <strong>{hasCatalogFilters ? "NO EXERCISES MATCH THESE FILTERS." : "NO EXERCISES AVAILABLE."}</strong>
              <span>
                {hasCatalogFilters ? "Try another search or clear the filters to see all movements." : "The movement library is currently empty. Try again shortly."}
              </span>
              <button
                type="button"
                className="clear-filter"
                onClick={hasCatalogFilters ? clearCatalogFilters : loadExercises}
              >
                {hasCatalogFilters ? "CLEAR FILTERS" : "RETRY"}
              </button>
            </div>
          ) : (
            <>
              <div className="exercise-grid">
                {visibleExercises.map((exercise) => (
                  <button
                    type="button"
                    className="exercise-card"
                    key={exercise.id}
                    aria-label={`Open details for ${titleCase(exercise.name)}`}
                    onClick={() => setSelectedExercise(exercise)}
                  >
                    <div className="card-art">
                      <span>{exercise.id}</span>
                      <img
                        loading="lazy"
                        decoding="async"
                        src={exerciseMediaUrl(exercise)}
                        alt={`Video demonstration of ${exercise.name}`}
                        onError={markMediaUnavailable}
                      />
                      <span className="media-fallback" aria-hidden="true">
                        MEDIA UNAVAILABLE
                      </span>
                    </div>
                    <div className="card-info">
                      <h3>{titleCase(exercise.name)}</h3>
                      <p>
                        {titleCase(exercise.body_part)} ·{" "}
                        {titleCase(exercise.equipment)}
                      </p>
                      <span className="card-arrow">↗</span>
                    </div>
                  </button>
                ))}
              </div>
              {catalogTotal === 0 ? (
                <div className="empty-catalog">
                  NO EXERCISES MATCH THESE FILTERS.
                </div>
              ) : (
                <div className="pagination" aria-label="Exercise library pages">
                  <button
                    type="button"
                    aria-label="Previous exercise page"
                    disabled={page === 1}
                    onClick={() => setPage((value) => value - 1)}
                  >
                    ← PREV
                  </button>
                  {pageNumbers.map((number, index) => (
                    <span key={number}>
                      {index > 0 && number - pageNumbers[index - 1] > 1 ? (
                        <b>…</b>
                      ) : null}
                      <button
                        type="button"
                        aria-label={`Exercise page ${number}`}
                        aria-current={page === number ? "page" : undefined}
                        className={page === number ? "current" : ""}
                        onClick={() => setPage(number)}
                      >
                        {number}
                      </button>
                    </span>
                  ))}
                  <button
                    type="button"
                    aria-label="Next exercise page"
                    disabled={page === pageCount}
                    onClick={() => setPage((value) => value + 1)}
                  >
                    NEXT →
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      </section>

      <section className="closing" id="workouts">
        <div>
          <span>02 / TODAY&apos;S WORKOUT</span>
          <h2>
            MAKE THE
            <br />
            <span className="closing-headline-tail">
              <em>NEXT REP</em>
              <br />
              COUNT.
            </span>
          </h2>
        </div>
        <div className="closing-action">
          <button className="red-action" onClick={() => startWorkout()}>
            LET&apos;S START <span>→</span>
          </button>
        </div>
      </section>
      <section
        className="workout-log-section"
        aria-labelledby="workout-log-title"
      >
        <div className="workout-log-heading">
          <span className="footer-label">03 / PROGRESS DASHBOARD</span>
          <h2 id="workout-log-title">
            KEEP THE
            <br />
            <em>RECEIPT.</em>
          </h2>
          <p>
            Only recorded time is counted. Calorie figures are estimates and
            appear after FITFLOW records a session duration.
          </p>
          <div className="progress-stat-grid">
            <strong>
              {progressStats.workouts}
              <small>WORKOUTS</small>
            </strong>
            <strong>
              {progressStats.exercises}
              <small>EXERCISES</small>
            </strong>
            <strong>
              {progressStats.durationRecorded ? progressStats.duration : "—"}
              <small>
                {progressStats.durationRecorded
                  ? "RECORDED MINUTES"
                  : "TIME NOT RECORDED"}
              </small>
            </strong>
            <strong>
              {progressStats.kcalEstimated ? progressStats.kcal : "—"}
              <small>
                {progressStats.kcalEstimated
                  ? "EST. KCAL"
                  : "KCAL NOT ESTIMATED"}
              </small>
            </strong>
          </div>
        </div>
        <div className="workout-log-list">
          {historyView.damaged && <p role="status">Some workout records could not be displayed. Your original data is still stored on this device.</p>}
          {historyView.entries.length ? (
            historyView.entries.slice(0, 5).map((entry) => {
              const hasRecordedDuration = Number(entry.durationSeconds) > 0;
              const hasKcalEstimate =
                hasRecordedDuration && Number(entry.estimatedKcal) > 0;
              return (
                <article className="workout-log-entry" key={entry.workoutId}>
                  <header>
                    <div>
                      <span>
                        {new Date(
                          entry.date || entry.completedAt,
                        ).toLocaleDateString()}
                      </span>
                      <strong>
                        {entry.exerciseCount || entry.logs?.length || 0}{" "}
                        MOVEMENTS ·{" "}
                        {hasRecordedDuration
                          ? `${Math.max(1, Math.round(Number(entry.durationSeconds) / 60))} MIN RECORDED`
                          : "TIME NOT RECORDED"}
                      </strong>
                    </div>
                    <b>
                      {hasKcalEstimate
                        ? `${entry.estimatedKcal} EST. KCAL`
                        : "KCAL NOT ESTIMATED"}
                    </b>
                  </header>
                  <div className="workout-log-items">
                    {(entry.logs || []).map((log) => (
                      <div
                        className="workout-log-item"
                        key={`${entry.workoutId}-${log.exerciseId}`}
                      >
                        <strong>{titleCase(log.exerciseName)}</strong>
                        <span>
                          {log.sets} SETS × {log.reps} REPS
                        </span>
                        <span>
                          {log.kcalEstimated && Number(log.kcal) > 0
                            ? `${log.kcal} EST. KCAL`
                            : "KCAL NOT ESTIMATED"}
                        </span>
                        <small>{log.notes || "NO NOTE"}</small>
                      </div>
                    ))}
                  </div>
                </article>
              );
            })
          ) : (
            <div className="workout-log-empty">
              <strong>NO COMPLETED WORKOUTS YET.</strong>
              <span>
                Start today&apos;s session and your sets will appear here.
              </span>
              <button
                type="button"
                className="let-start-button"
                onClick={() => setWizardOpen(true)}
              >
                LET&apos;S START <span>→</span>
              </button>
            </div>
          )}
        </div>
      </section>
      {workoutOpen && activeExercise && (
        <div className="workout-overlay">
          <section
            className="active-workout"
            role="dialog"
            aria-modal="true"
            aria-labelledby="active-workout-title"
          >
            <header>
              <span>FITFLOW / ACTIVE SESSION</span>
              <button
                onClick={() => setWorkoutOpen(false)}
                aria-label="Close workout"
              >
                ×
              </button>
            </header>
            <div className="workout-status">
              <span>
                EXERCISE {workoutIndex + 1} / {workoutExercises.length}
              </span>
              <strong>{formatTime(workoutSeconds)}</strong>
            </div>
            <div className="workout-target">
              <span>
                SESSION TARGET / {formatTime(todayWorkoutTargetSeconds)}
              </span>
              <strong>THIS MOVEMENT / {formatTarget()}</strong>
            </div>
            <div className="workout-media">
              <img
                src={exerciseMediaUrl(activeExercise)}
                alt={`Video demonstration of ${activeExercise.name}`}
                onError={markMediaUnavailable}
              />
            </div>
            <h2 id="active-workout-title">{titleCase(activeExercise.name)}</h2>
            <p className="workout-meta">
              {titleCase(activeExercise.body_part)} ·{" "}
              {titleCase(activeExercise.equipment)} ·{" "}
              {titleCase(activeExercise.target)}
            </p>
            <div className="set-tracker">
              {[0, 1, 2, 3].map((set) => (
                <span className={set < completedSets ? "done" : ""} key={set}>
                  SET {set + 1}
                </span>
              ))}
            </div>
            <button className="complete-set" onClick={finishSet}>
              {completedSets < 3
                ? `COMPLETE SET ${completedSets + 1}`
                : workoutIndex < workoutExercises.length - 1
                  ? "NEXT EXERCISE →"
                  : "FINISH WORKOUT ✓"}
            </button>
          </section>
        </div>
      )}
      {selectedExercise && (
        <div
          className="modal-backdrop"
          onClick={() => setSelectedExercise(null)}
        >
          <section
            className="exercise-modal"
            role="dialog"
            aria-modal="true"
            aria-label={`Exercise details: ${titleCase(selectedExercise.name)}`}
            onClick={(event) => event.stopPropagation()}
          >
            <button
              className="close-modal"
              onClick={() => setSelectedExercise(null)}
              aria-label="Close exercise details"
            >
              ×
            </button>
            <div className="exercise-modal-media">
              <img
                src={exerciseMediaUrl(selectedExercise)}
                alt={`Video demonstration of ${selectedExercise.name}`}
                onError={markMediaUnavailable}
              />
            </div>
            <span className="footer-label">
              EXERCISE {selectedExercise.id} / VIDEO GUIDE
            </span>
            <h2 id="exercise-detail-title">
              {titleCase(selectedExercise.name)}
            </h2>
            <p className="workout-meta">
              {titleCase(selectedExercise.body_part)} ·{" "}
              {titleCase(selectedExercise.equipment)} · TARGET:{" "}
              {titleCase(selectedExercise.target)}
            </p>
            <div className="exercise-detail-columns">
              <div>
                <h3>WHY IT MATTERS</h3>
                <p>{exerciseBenefit(selectedExercise)}</p>
              </div>
              <div>
                <h3>HOW TO DO IT</h3>
                {exerciseDetailStatus === "loading" && <p role="status">Loading instructions…</p>}
                {exerciseDetailStatus === "error" && (
                  <div>
                    <p role="alert">Instructions could not load. Check your connection and try again.</p>
                    <button className="clear-filter" onClick={() => setExerciseDetailRetry((value) => value + 1)}>
                      RETRY INSTRUCTIONS
                    </button>
                  </div>
                )}
                <ol>
                  {(
                    selectedExercise.instruction_steps?.en || [
                      selectedExercise.instructions?.en,
                    ]
                  )
                    .filter(Boolean)
                    .map((step, index) => (
                      <li key={`${selectedExercise.id}-${index}`}>{step}</li>
                    ))}
                </ol>
              </div>
            </div>
          </section>
        </div>
      )}
      <section className="plan-section" id="plans">
        <div className="plan-intro">
          <span className="footer-label">03 / 7-DAY PLAN BUILDER</span>
          <h2>
            YOUR
            <br />
            <em>STARTING LINE.</em>
          </h2>
          <p>
            Enter your height and weight. FITFLOW rounds BMI to the nearest
            whole number and builds a gradual 7-day plan for BMI 18–35.
          </p>
          <div className="plan-form">
            <label>
              HEIGHT / CM
              <input
                type="number"
                min="100"
                max="250"
                value={height}
                onChange={(event) => {
                  setHeight(event.target.value);
                  setPlanReady(false);
                  setPlanSaved(false);
                }}
              />
            </label>
            <label>
              WEIGHT / KG
              <input
                type="number"
                min="25"
                max="300"
                value={weight}
                onChange={(event) => {
                  setWeight(event.target.value);
                  setPlanReady(false);
                  setPlanSaved(false);
                }}
              />
            </label>
            <button
              className="red-action"
              onClick={() => {
                setCurrentDay(1);
                setPlanReady(true);
                setPlanSaved(false);
              }}
            >
              BUILD MY 7 DAYS <span>→</span>
            </button>
          </div>
          <small className="medical-note">
            BMI is rounded normally: 20.4 → 20, 20.5 → 21. Supported range:
            18–35. BMI is a screening measure, not a diagnosis. Consult a
            qualified health professional if you have a condition, injury, or
            uncertainty.
          </small>
        </div>
        <div className="plan-result">
          {bmiProfile ? (
            <>
              <div className="bmi-readout">
                <span>BMI / ROUNDED</span>
                <strong>{roundedBmi}</strong>
                <b>{bmiProfile.label}</b>
              </div>
              <div className="plan-focus">
                <span>PROFILE {roundedBmi} / 18 CASES</span>
                <strong>{bmiProfile.tone}</strong>
                <p>
                  {bmiProfile.focus} · {bmiProfile.note}
                </p>
              </div>
              {planReady && selectedDay && (
                <>
                  <div className="day-toolbar">
                    <button
                      disabled={currentDay === 1}
                      onClick={() => setCurrentDay((value) => value - 1)}
                    >
                      ← PREVIOUS DAY
                    </button>
                    <strong>
                      DAY {String(currentDay).padStart(2, "0")} / 7
                    </strong>
                    <button
                      disabled={currentDay === 7}
                      onClick={() => setCurrentDay((value) => value + 1)}
                    >
                      NEXT DAY →
                    </button>
                  </div>
                  <div className="plan-day-detail">
                    <div className="day-detail-heading">
                      <span>
                        {selectedDay.rest
                          ? "RECOVERY DAY"
                          : `${selectedDay.exercises.length} MOVEMENTS / TODAY`}
                      </span>
                      <b>
                        {selectedDay.rest
                          ? "RESTORE / 15 MIN"
                          : "COMPLETE IN YOUR PACE"}
                      </b>
                    </div>
                    {selectedDay.rest ? (
                      <div className="rest-message">
                        LIGHT MOBILITY, WALKING, BREATHING.
                        <br />
                        <small>Recovery keeps the next session useful.</small>
                      </div>
                    ) : (
                      <div className="day-exercises">
                        {selectedDay.exercises.map((exercise, index) => (
                          <article key={`${selectedDay.day}-${exercise.id}`}>
                            <span>0{index + 1}</span>
                            <img
                              loading="lazy"
                              src={exerciseMediaUrl(exercise)}
                              alt={`Video demonstration of ${exercise.name}`}
                              onError={markMediaUnavailable}
                            />
                            <div>
                              <strong>{titleCase(exercise.name)}</strong>
                              <small>
                                {titleCase(exercise.body_part)} ·{" "}
                                {titleCase(exercise.equipment)}
                              </small>
                            </div>
                          </article>
                        ))}
                      </div>
                    )}
                  </div>
                  <button
                    className="save-plan"
                    onClick={() => startWorkout(selectedDay.exercises)}
                    disabled={!selectedDay.exercises.length}
                  >
                    LET&apos;S START DAY {currentDay} <span>→</span>
                  </button>
                  <button className="save-plan" onClick={savePlan}>
                    {planSaved ? "✓ TRAINING PLAN SAVED" : "SAVE TRAINING PLAN"}
                  </button>
                  <button
                    className="save-plan plan-365-action"
                    onClick={() => setPlan365Open(true)}
                  >
                    IF YOU FEEL GOOD · GET 365-DAY PLAN <span>→</span>
                  </button>
                </>
              )}
            </>
          ) : (
            <div className="plan-out-of-range">
              ENTER A BMI FROM 18 TO 35 TO BUILD YOUR PLAN.
            </div>
          )}
        </div>
      </section>
      <section className="nutrition-section" id="nutrition">
        <div>
          <span className="footer-label">04 / NUTRITION MODE</span>
          <h2>
            FUEL
            <br />
            <em>THE WORK.</em>
          </h2>
          <p className="nutrition-lead">
            Food is part of the training plan. Browse food data and estimate a
            daily calorie target on the dedicated nutrition page.
          </p>
          <a className="red-action route-cta" href="/nutrition">
            OPEN FOOD LIBRARY <span>→</span>
          </a>
        </div>
        <div className="nutrition-grid">
          <article>
            <span>01 / HYDRATION</span>
            <strong>2.4 L</strong>
            <p>Daily water target. Keep the system moving.</p>
          </article>
          <article>
            <span>02 / PRE-SESSION</span>
            <strong>CARBS + PROTEIN</strong>
            <p>A simple meal 60–90 minutes before training.</p>
          </article>
          <article>
            <span>03 / AFTER</span>
            <strong>RECOVER</strong>
            <p>Build the habit: eat, rest, return.</p>
          </article>
        </div>
      </section>
      <section className="custom-plan-section" id="custom-plan">
        <div className="training-guide-intro">
          <span className="footer-label">05 / TRAINING GUIDE</span>
          <h2>
            FOLLOW
            <br />
            <em>THE SPLIT.</em>
          </h2>
          <p>
            A simple weekly structure for independent training. Keep the form
            clean, adjust the load, and let recovery count.
          </p>
        </div>
        <div
          className="training-table-wrap"
          tabIndex="0"
          role="region"
          aria-label="Weekly training guide. Swipe horizontally to view every column."
          aria-describedby="training-table-scroll-hint"
        >
          <span
            className="training-table-scroll-hint"
            id="training-table-scroll-hint"
          >
            SWIPE TO SEE MOVEMENTS + SETS <b aria-hidden="true">→</b>
          </span>
          <table className="training-table">
            <thead>
              <tr>
                <th>DAY</th>
                <th>FOCUS</th>
                <th>MOVEMENT</th>
                <th>SETS × REPS</th>
              </tr>
            </thead>
            <tbody>
              <tr className="push-row">
                <td rowSpan="5">MON</td>
                <td rowSpan="5">
                  PUSH
                  <br />
                  <small>CHEST · SHOULDERS · TRICEPS</small>
                </td>
                <td>
                  <GuideMovement
                    label="Bench Press"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>4 × 8–12</td>
              </tr>
              <tr className="push-row">
                <td>
                  <GuideMovement
                    label="Incline Dumbbell Press"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 10</td>
              </tr>
              <tr className="push-row">
                <td>
                  <GuideMovement
                    label="Shoulder Press"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 10</td>
              </tr>
              <tr className="push-row">
                <td>
                  <GuideMovement
                    label="Lateral Raise"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 12–15</td>
              </tr>
              <tr className="push-row">
                <td>
                  <GuideMovement
                    label="Triceps Pushdown"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 12</td>
              </tr>
              <tr className="pull-row">
                <td rowSpan="5">TUE</td>
                <td rowSpan="5">
                  PULL
                  <br />
                  <small>BACK · BICEPS</small>
                </td>
                <td>
                  <GuideMovement
                    label="Lat Pulldown"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>4 × 8–12</td>
              </tr>
              <tr className="pull-row">
                <td>
                  <GuideMovement
                    label="Seated Cable Row"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 10</td>
              </tr>
              <tr className="pull-row">
                <td>
                  <GuideMovement
                    label="One-arm Dumbbell Row"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 10</td>
              </tr>
              <tr className="pull-row">
                <td>
                  <GuideMovement
                    label="Face Pull"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 15</td>
              </tr>
              <tr className="pull-row">
                <td>
                  <GuideMovement
                    label="Dumbbell Curl"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 12</td>
              </tr>
              <tr className="legs-row">
                <td rowSpan="5">WED</td>
                <td rowSpan="5">
                  LEGS
                  <br />
                  <small>QUADS · HAMSTRINGS · CALVES</small>
                </td>
                <td>
                  <GuideMovement
                    label="Squat"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>4 × 8–10</td>
              </tr>
              <tr className="legs-row">
                <td>
                  <GuideMovement
                    label="Leg Press"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 10</td>
              </tr>
              <tr className="legs-row">
                <td>
                  <GuideMovement
                    label="Romanian Deadlift"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 10</td>
              </tr>
              <tr className="legs-row">
                <td>
                  <GuideMovement
                    label="Leg Curl"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 12</td>
              </tr>
              <tr className="legs-row">
                <td>
                  <GuideMovement
                    label="Calf Raise"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>4 × 15</td>
              </tr>
              <tr className="push-row">
                <td rowSpan="5">THU</td>
                <td rowSpan="5">
                  PUSH
                  <br />
                  <small>CHEST · SHOULDERS · TRICEPS</small>
                </td>
                <td>
                  <GuideMovement
                    label="Incline Bench Press"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>4 × 8–12</td>
              </tr>
              <tr className="push-row">
                <td>
                  <GuideMovement
                    label="Chest Fly"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 12</td>
              </tr>
              <tr className="push-row">
                <td>
                  <GuideMovement
                    label="Arnold Press"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 10</td>
              </tr>
              <tr className="push-row">
                <td>
                  <GuideMovement
                    label="Lateral Raise"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>4 × 15</td>
              </tr>
              <tr className="push-row">
                <td>
                  <GuideMovement
                    label="Overhead Triceps Extension"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 12</td>
              </tr>
              <tr className="pull-row">
                <td rowSpan="5">FRI</td>
                <td rowSpan="5">
                  PULL
                  <br />
                  <small>BACK · BICEPS</small>
                </td>
                <td>
                  <GuideMovement
                    label="Pull-up / Assisted Pull-up"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>4 × 6–10</td>
              </tr>
              <tr className="pull-row">
                <td>
                  <GuideMovement
                    label="Barbell Row"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 8–10</td>
              </tr>
              <tr className="pull-row">
                <td>
                  <GuideMovement
                    label="Cable Row"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 12</td>
              </tr>
              <tr className="pull-row">
                <td>
                  <GuideMovement
                    label="Rear Delt Fly"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 15</td>
              </tr>
              <tr className="pull-row">
                <td>
                  <GuideMovement
                    label="Hammer Curl"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 12</td>
              </tr>
              <tr className="legs-row">
                <td rowSpan="5">SAT</td>
                <td rowSpan="5">
                  LEGS + CORE
                  <br />
                  <small>LOWER BODY · TRUNK STABILITY</small>
                </td>
                <td>
                  <GuideMovement
                    label="Deadlift"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 6–8</td>
              </tr>
              <tr className="legs-row">
                <td>
                  <GuideMovement
                    label="Bulgarian Split Squat"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 10</td>
              </tr>
              <tr className="legs-row">
                <td>
                  <GuideMovement
                    label="Leg Extension"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 12</td>
              </tr>
              <tr className="legs-row">
                <td>
                  <GuideMovement
                    label="Leg Curl"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 12</td>
              </tr>
              <tr className="legs-row">
                <td>
                  <GuideMovement
                    label="Plank"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>3 × 45–60s</td>
              </tr>
              <tr className="recovery-row">
                <td>SUN</td>
                <td>
                  RECOVERY
                  <br />
                  <small>RESTORE · BREATHE · WALK</small>
                </td>
                <td>
                  <GuideMovement
                    label="Easy walk, mobility, and rest"
                    exercises={allExercises}
                    onOpen={setSelectedExercise}
                  />
                </td>
                <td>—</td>
              </tr>
            </tbody>
          </table>
        </div>
      </section>
      <section
        className="calculator-section"
        id="tools"
        aria-labelledby="calculator-heading"
      >
        <header className="calculator-heading">
          <span>06 / TOOLS</span>
          <h2 id="calculator-heading">
            FITNESS
            <br />
            <em>CALCULATORS.</em>
          </h2>
          <p>
            Instant, science-backed estimates for body composition, nutrition,
            strength, and cardio training.
          </p>
        </header>
        <div className="calculator-filters" aria-label="Calculator categories">
          {["ALL", "BODY COMPOSITION", "NUTRITION", "STRENGTH", "CARDIO"].map(
            (category) => (
              <button
                type="button"
                key={category}
                aria-pressed={calculatorCategory === category}
                className={calculatorCategory === category ? "selected" : ""}
                onClick={() => setCalculatorCategory(category)}
              >
                {category}
              </button>
            ),
          )}
        </div>
        <div className="calculator-grid">
          {visibleCalculators.map((calculator) => (
            <article className="calculator-card" key={calculator.id}>
              <span>{calculator.category}</span>
              <h3>{calculator.title}</h3>
              <p>{calculator.description}</p>
              <code>{calculator.formula}</code>
              <button
                type="button"
                onClick={() => setActiveCalculator(calculator.id)}
                aria-haspopup="dialog"
                aria-label={`Open ${calculator.title}`}
              >
                OPEN CALCULATOR <b>→</b>
              </button>
            </article>
          ))}
        </div>
      </section>
      <nav className="mobile-bottom-nav" aria-label="Quick navigation">
        <a href="#top" aria-label="Home"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" aria-hidden="true"><path d="m3 10 9-7 9 7v11h-6v-7H9v7H3Z" /></svg><small>HOME</small></a>
        <a href="#workouts" aria-label="Workouts"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" aria-hidden="true"><path d="M7 12h10M3 8v8m4-11v14M17 5v14m4-11v8" /></svg><small>WORKOUT</small></a>
        <a href="#library" aria-label="Library"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" aria-hidden="true"><path d="M4 4h6v16H4Zm10 0h6v16h-6ZM4 8h6m4 0h6" /></svg><small>LIBRARY</small></a>
        <a href="#plans" aria-label="Plans"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" aria-hidden="true"><path d="M4 5h16v16H4ZM8 2v6m8-6v6M4 11h16m-12 5h3" /></svg><small>PLAN</small></a>
        <a href="/nutrition" aria-label="Nutrition"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" aria-hidden="true"><path d="M4 3v6a3 3 0 0 0 6 0V3M7 3v18M20 3c-4 0-5 4-5 9h5m0-9v18" /></svg><small>NUTRITION</small></a>
      </nav>
      {plan365Open && (
        <div className="modal-backdrop" onClick={() => setPlan365Open(false)}>
          <section
            className="donate-modal plan-365-modal"
            role="dialog"
            aria-modal="true"
            aria-labelledby="plan-365-title"
            onClick={(event) => event.stopPropagation()}
          >
            <button
              className="close-modal"
              onClick={() => setPlan365Open(false)}
              aria-label="Close 365-day plan"
            >
              ×
            </button>
            <span className="footer-label">OPTIONAL SUPPORT</span>
            <h2 id="plan-365-title">
              365
              <br />
              <em>DAYS.</em>
            </h2>
            <p>
              Download the full year plan when you feel ready. Supporting
              FITFLOW is optional.
            </p>
            <img
              className="qr-image"
              src="/qr.jpg"
              alt="QR code for FITFLOW donation"
            />
            {exportError && <p className="auth-feedback auth-error" role="alert">{exportError}</p>}
            <button className="red-action" onClick={download365Plan} disabled={exportBusy} aria-busy={exportBusy}>
              {exportBusy ? "PREPARING EXCEL…" : "DOWNLOAD EXCEL"} <span>↓</span>
            </button>
          </section>
        </div>
      )}
      {donateOpen && (
        <div className="modal-backdrop" onClick={() => setDonateOpen(false)}>
          <section
            className="donate-modal"
            role="dialog"
            aria-modal="true"
            aria-labelledby="donate-title"
            onClick={(event) => event.stopPropagation()}
          >
            <button
              className="close-modal"
              onClick={() => setDonateOpen(false)}
              aria-label="Close donation QR"
            >
              ×
            </button>
            <span className="footer-label">SUPPORT FITFLOW</span>
            <h2 id="donate-title">
              KEEP
              <br />
              <em>FLOWING.</em>
            </h2>
            <p>Scan this QR code to support the project.</p>
            <img
              className="qr-image"
              src="/qr.jpg"
              alt="QR code for FITFLOW donation"
            />
            <small>THANK YOU FOR HELPING FITFLOW GROW.</small>
          </section>
        </div>
      )}
      <WorkoutWizardModal
        isOpen={wizardOpen}
        onClose={() => setWizardOpen(false)}
        onStartWorkout={(exercises) => {
          setWizardOpen(false);
          startWorkout(exercises);
        }}
      />
      {profileOpen && profileDraft && (
        <div className="modal-backdrop" onClick={() => setProfileOpen(false)}>
          <section
            className="profile-modal"
            role="dialog"
            aria-modal="true"
            aria-labelledby="profile-title"
            onClick={(event) => event.stopPropagation()}
          >
            <button
              className="close-modal"
              onClick={() => setProfileOpen(false)}
              aria-label="Close profile"
            >
              ×
            </button>
            <span className="footer-label">PERSONAL PROFILE</span>
            <h2 id="profile-title">
              YOUR
              <br />
              <em>NUMBERS.</em>
            </h2>
            <p className="profile-modal-intro">
              Update the details FITFLOW uses to shape your plan.
            </p>
            <form className="profile-form" onSubmit={saveProfile}>
              <label>
                NAME
                <input
                  value={profileDraft.name}
                  onChange={updateProfileField("name")}
                  required
                />
              </label>
              <div className="profile-fields">
                <label>
                  AGE
                  <input
                    type="number"
                    min="13"
                    max="120"
                    value={profileDraft.age}
                    onChange={updateProfileField("age")}
                  />
                </label>
                <label>
                  HEIGHT / CM
                  <input
                    type="number"
                    min="100"
                    max="250"
                    step="any"
                    value={profileDraft.heightCm}
                    onChange={updateProfileField("heightCm")}
                  />
                </label>
                <label>
                  WEIGHT / KG
                  <input
                    type="number"
                    min="25"
                    max="300"
                    step="any"
                    value={profileDraft.weightKg}
                    onChange={updateProfileField("weightKg")}
                  />
                </label>
                <label>
                  RESTING HEART RATE
                  <input
                    type="number"
                    min="30"
                    max="220"
                    value={profileDraft.restingHeartRate}
                    onChange={updateProfileField("restingHeartRate")}
                  />
                </label>
              </div>
              <label>
                TRAINING GOAL
                <select
                  value={profileDraft.trainingGoal}
                  onChange={updateProfileField("trainingGoal")}
                >
                  <option>BUILD CONSISTENCY</option>
                  <option>BUILD STRENGTH</option>
                  <option>IMPROVE CONDITIONING</option>
                  <option>MOVE MORE</option>
                  <option>IMPROVE MOBILITY</option>
                </select>
              </label>
              <div className="profile-fields">
                <label>
                  LEVEL
                  <select
                    value={profileDraft.trainingLevel}
                    onChange={updateProfileField("trainingLevel")}
                  >
                    <option>BEGINNER</option>
                    <option>INTERMEDIATE</option>
                    <option>ADVANCED</option>
                  </select>
                </label>
                <label>
                  DAYS / WEEK
                  <select
                    value={profileDraft.daysPerWeek}
                    onChange={updateProfileField("daysPerWeek")}
                  >
                    <option value="2">2</option>
                    <option value="3">3</option>
                    <option value="4">4</option>
                    <option value="5">5</option>
                    <option value="6">6</option>
                  </select>
                </label>
              </div>
              <label>
                HEALTH NOTES / LIMITATIONS
                <textarea
                  value={profileDraft.healthNotes}
                  onChange={updateProfileField("healthNotes")}
                  rows="3"
                  placeholder="Optional"
                />
              </label>
              {profileError && <p className="auth-feedback auth-error" role="alert">{profileError}</p>}
              {profileSaved && (
                <p className="auth-feedback auth-success" role="status">
                  PROFILE SAVED.
                </p>
              )}
              <button className="red-action auth-submit" type="submit">
                SAVE PROFILE <span>→</span>
              </button>
            </form>
            <button
              className="profile-logout"
              onClick={() => setLogoutConfirmOpen(true)}
            >
              LOG OUT
            </button>
          </section>
        </div>
      )}
      {logoutConfirmOpen && (
        <div
          className="modal-backdrop logout-confirm-backdrop"
          onClick={() => setLogoutConfirmOpen(false)}
        >
          <section
            className="donate-modal logout-confirm-modal"
            role="dialog"
            aria-modal="true"
            aria-labelledby="logout-confirm-title"
            aria-describedby="logout-confirm-copy"
            onClick={(event) => event.stopPropagation()}
          >
            <button
              className="close-modal"
              onClick={() => setLogoutConfirmOpen(false)}
              aria-label="Close logout confirmation"
            >
              ×
            </button>
            <h2 id="logout-confirm-title">
              LEAVE
              <br />
              <em>FITFLOW?</em>
            </h2>
            <p id="logout-confirm-copy">
              Your saved data stays on this device. You can sign in again
              whenever you are ready.
            </p>
            <div className="logout-confirm-actions">
              <button
                type="button"
                className="clear-filter"
                onClick={() => setLogoutConfirmOpen(false)}
              >
                CANCEL
              </button>
              <button
                type="button"
                className="red-action"
                onClick={() => {
                  logout();
                  window.location.assign("/auth");
                }}
              >
                LOG OUT <span>→</span>
              </button>
            </div>
          </section>
        </div>
      )}
      {activeCalculator ? (
        <CalculatorModal
          calculatorId={activeCalculator}
          values={calculatorInputs}
          onChange={updateCalculatorInput}
          onClose={() => setActiveCalculator(null)}
        />
      ) : null}
      <section className="reviews-section" id="reviews">
        <div className="reviews-heading">
          <span className="footer-label">07 / COMMUNITY NOTES</span>
          <h2>
            THE WORK
            <br />
            <em>IS WORKING.</em>
          </h2>
          <p>
            Real progress is personal. These short notes are illustrative
            community-style reviews for the FITFLOW prototype.
          </p>
        </div>
        <div className="reviews-grid">
          <article>
            <span className="review-mark">“</span>
            <p>
              “I started with ten minutes a day. The library made choosing feel
              simple, and now movement is part of my routine instead of another
              promise I break.”
            </p>
            <small>ANONYMOUS / AUSTRALIA</small>
          </article>
          <article>
            <span className="review-mark">“</span>
            <p>
              “Training at home helped me rebuild strength in a season when
              everything felt exhausting. Small sessions gave me something
              steady to return to.”
            </p>
            <small>ANONYMOUS / COMMUNITY NOTE</small>
          </article>
          <article>
            <span className="review-mark">“</span>
            <p>
              “I did not know how to exercise safely before. Clear instructions,
              visible form, and a plan I could adapt made starting feel
              possible.”
            </p>
            <small>STEEVEN / SWITZERLAND</small>
          </article>
          <article>
            <span className="review-mark">“</span>
            <p>
              “The best part is the lack of pressure. I can choose a lighter
              day, come back tomorrow, and still feel like I am moving forward.”
            </p>
            <small>ANONYMOUS / COMMUNITY NOTE</small>
          </article>
        </div>
      </section>
      <footer className="site-footer" id="footer">
        <div className="footer-brand">
          <span className="mark">F</span>
          <strong>FITFLOW</strong>
          <p>TRAIN WITH INTENT.</p>
          <span className="flutter-badge">
            <i /> FLUTTER / ANDROID APP
          </span>
        </div>
        <div>
          <span className="footer-label">EXPLORE</span>
          <a href="#workouts">Today&apos;s workout</a>
          <a href="#library">Exercise library</a>
          <a href="#nutrition">Nutrition mode</a>
          <a href="#custom-plan">Training guide</a>
        </div>
        <div>
          <span className="footer-label">SUPPORT</span>
          <button className="footer-qr" onClick={() => setDonateOpen(true)}>
            <img src="/qr.jpg" alt="Open donation QR code" />
            <span>SCAN TO DONATE</span>
          </button>
        </div>
        <div className="footer-note">
          FREE TO USE.
          <br />
          MADE FOR HUMANS.
          <br />
          <br />© 2026 FITFLOW
        </div>
      </footer>
    </main>
  );
}

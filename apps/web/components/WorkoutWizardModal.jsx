'use client';

import { useState, useEffect } from 'react';

// Equipment definition matching user's Image 1
const EQUIPMENT_LIST = [
  {
    id: 'body weight',
    label: 'Bodyweight',
    sub: 'Tập tự do không tạ',
    icon: (
      <svg viewBox="0 0 64 64" fill="currentColor" className="eq-svg">
        <path d="M48 20c0-6.6-5.4-12-12-12s-12 5.4-12 12c0 3.8 1.8 7.2 4.6 9.4C19 33.4 12 42.8 12 54h6c0-9.9 8.1-18 18-18s18 8.1 18 18h6c0-11.2-7-20.6-16.6-24.6 2.8-2.2 4.6-5.6 4.6-9.4zm-18 0c0-3.3 2.7-6 6-6s6 2.7 6 6-2.7 6-6 6-6-2.7-6-6z" fill="#EAB308" />
        <path d="M36 28c4.4 0 8 3.6 8 8v4h-6v-4c0-1.1-.9-2-2-2s-2 .9-2 2v4h-6v-4c0-4.4 3.6-8 8-8z" fill="#F59E0B" />
      </svg>
    ),
  },
  {
    id: 'dumbbell',
    label: 'Dumbbell',
    sub: 'Tạ đơn tay',
    icon: (
      <svg viewBox="0 0 64 64" fill="currentColor" className="eq-svg">
        <rect x="8" y="20" width="8" height="24" rx="3" fill="#818CF8" />
        <rect x="16" y="24" width="6" height="16" rx="2" fill="#6366F1" />
        <rect x="22" y="29" width="20" height="6" rx="2" fill="#94A3B8" />
        <rect x="42" y="24" width="6" height="16" rx="2" fill="#6366F1" />
        <rect x="48" y="20" width="8" height="24" rx="3" fill="#818CF8" />
      </svg>
    ),
  },
  {
    id: 'barbell',
    label: 'Barbell',
    sub: 'Tạ đòn chuẩn',
    icon: (
      <svg viewBox="0 0 64 64" fill="currentColor" className="eq-svg">
        <rect x="4" y="30" width="56" height="4" rx="2" fill="#0EA5E9" />
        <rect x="12" y="18" width="6" height="28" rx="2" fill="#0284C7" />
        <rect x="18" y="22" width="4" height="20" rx="1.5" fill="#0369A1" />
        <rect x="42" y="22" width="4" height="20" rx="1.5" fill="#0369A1" />
        <rect x="46" y="18" width="6" height="28" rx="2" fill="#0284C7" />
      </svg>
    ),
  },
  {
    id: 'kettlebell',
    label: 'Kettlebell',
    sub: 'Tạ ấm quai xách',
    icon: (
      <svg viewBox="0 0 64 64" fill="currentColor" className="eq-svg">
        <path d="M32 8c-8.8 0-16 7.2-16 16v4h6v-4c0-5.5 4.5-10 10-10s10 4.5 10 10v4h6v-4c0-8.8-7.2-16-16-16z" fill="#64748B" />
        <circle cx="32" cy="40" r="18" fill="#475569" />
        <ellipse cx="32" cy="38" rx="15" ry="12" fill="#334155" />
      </svg>
    ),
  },
  {
    id: 'band',
    label: 'Band',
    sub: 'Dây kháng lực',
    icon: (
      <svg viewBox="0 0 64 64" fill="currentColor" className="eq-svg">
        <path d="M8 32c0-8.8 21.5-16 24-16s24 7.2 24 16-21.5 16-24 16-24-7.2-24-16z" fill="none" stroke="#F97316" strokeWidth="6" strokeLinecap="round" />
        <ellipse cx="32" cy="32" rx="18" ry="8" fill="none" stroke="#EA580C" strokeWidth="4" />
      </svg>
    ),
  },
  {
    id: 'weighted',
    label: 'Plate',
    sub: 'Bánh tạ đĩa',
    icon: (
      <svg viewBox="0 0 64 64" fill="currentColor" className="eq-svg">
        <circle cx="32" cy="32" r="24" fill="#94A3B8" />
        <circle cx="32" cy="32" r="18" fill="#64748B" />
        <circle cx="32" cy="32" r="7" fill="#1E293B" />
        <circle cx="32" cy="32" r="4" fill="#CBD5E1" />
      </svg>
    ),
  },
  {
    id: 'pull-up bar',
    label: 'Pull-up bar',
    sub: 'Xà đơn / Khung treo',
    icon: (
      <svg viewBox="0 0 64 64" fill="currentColor" className="eq-svg">
        <rect x="14" y="8" width="6" height="48" rx="2" fill="#6366F1" />
        <rect x="44" y="8" width="6" height="48" rx="2" fill="#6366F1" />
        <rect x="8" y="14" width="48" height="6" rx="3" fill="#818CF8" />
        <circle cx="20" cy="17" r="2" fill="#C7D2FE" />
        <circle cx="44" cy="17" r="2" fill="#C7D2FE" />
      </svg>
    ),
  },
  {
    id: 'bench',
    label: 'Bench',
    sub: 'Ghế tập tạ / Đa năng',
    icon: (
      <svg viewBox="0 0 64 64" fill="currentColor" className="eq-svg">
        <path d="M12 28l24-12 3 6-24 12z" fill="#94A3B8" />
        <rect x="36" y="32" width="22" height="6" rx="2" fill="#64748B" />
        <path d="M14 34l-6 18h6l4-12z" fill="#475569" />
        <path d="M38 38l-4 14h6l2-14z" fill="#475569" />
        <path d="M52 38l2 14h6l-4-14z" fill="#475569" />
      </svg>
    ),
  },
];

// Muscle definitions matching the user's anatomical body view
const MUSCLE_GROUPS = [
  { id: 'chest', name: 'Ngực (Chest)', target: 'pectorals', bodyPart: 'chest', badge: 'C', color: '#EF4444' },
  { id: 'lats', name: 'Lưng xô (Lats & Back)', target: 'lats', bodyPart: 'back', badge: 'B', color: '#3B82F6' },
  { id: 'upper_back', name: 'Lưng trên & Cầu vai', target: 'traps', bodyPart: 'back', badge: 'T', color: '#6366F1' },
  { id: 'delts', name: 'Cơ vai (Shoulders)', target: 'delts', bodyPart: 'shoulders', badge: 'S', color: '#F59E0B' },
  { id: 'biceps', name: 'Bắp tay trước (Biceps)', target: 'biceps', bodyPart: 'upper arms', badge: 'Bi', color: '#10B981' },
  { id: 'triceps', name: 'Bắp tay sau (Triceps)', target: 'triceps', bodyPart: 'upper arms', badge: 'Tr', color: '#8B5CF6' },
  { id: 'abs', name: 'Cơ bụng & Lõi (Abs & Core)', target: 'abs', bodyPart: 'waist', badge: 'A', color: '#EC4899' },
  { id: 'quads', name: 'Đùi trước (Quads)', target: 'quads', bodyPart: 'upper legs', badge: 'Q', color: '#14B8A6' },
  { id: 'hamstrings', name: 'Đùi sau (Hamstrings)', target: 'hamstrings', bodyPart: 'upper legs', badge: 'H', color: '#06B6D4' },
  { id: 'glutes', name: 'Cơ mông (Glutes)', target: 'glutes', bodyPart: 'upper legs', badge: 'G', color: '#F97316' },
  { id: 'calves', name: 'Bắp chuối (Calves)', target: 'calves', bodyPart: 'lower legs', badge: 'Ca', color: '#84CC16' },
  { id: 'forearms', name: 'Cẳng tay (Forearms)', target: 'forearms', bodyPart: 'lower arms', badge: 'F', color: '#64748B' },
];

const PRESETS = [
  { name: 'Toàn thân (Full Body)', muscles: ['chest', 'lats', 'delts', 'biceps', 'triceps', 'abs', 'quads', 'hamstrings'] },
  { name: 'Push (Ngực - Vai - Tay sau)', muscles: ['chest', 'delts', 'triceps'] },
  { name: 'Pull (Lưng - Xô - Tay trước)', muscles: ['lats', 'upper_back', 'biceps', 'forearms'] },
  { name: 'Legs & Core (Chân - Bụng)', muscles: ['quads', 'hamstrings', 'glutes', 'calves', 'abs'] },
  { name: 'Thân trên (Upper Body)', muscles: ['chest', 'lats', 'upper_back', 'delts', 'biceps', 'triceps'] },
];

function titleCase(str = '') {
  return str.replace(/\b\w/g, (c) => c.toUpperCase());
}

function exerciseMediaUrl(exercise) {
  const fileName = exercise?.gif_url?.split('/').pop();
  return fileName ? `/media-transparent/${fileName}` : '';
}

export default function WorkoutWizardModal({ isOpen, onClose, onStartWorkout }) {
  const [step, setStep] = useState(1);
  const [selectedEquipment, setSelectedEquipment] = useState(['body weight', 'dumbbell', 'barbell', 'bench']);
  const [selectedMuscles, setSelectedMuscles] = useState(['chest', 'lats', 'quads']);
  const [catalog, setCatalog] = useState([]);
  const [loadingCatalog, setLoadingCatalog] = useState(false);
  const [generatedExercises, setGeneratedExercises] = useState([]);
  const [showAddPicker, setShowAddPicker] = useState(false);
  const [searchFilter, setSearchFilter] = useState('');
  const [hoveredMuscle, setHoveredMuscle] = useState(null);
  const [previewDetail, setPreviewDetail] = useState(null);

  // Load exercises catalog on mount or when wizard opens
  useEffect(() => {
    if (!isOpen) return;
    if (catalog.length > 0) return;
    setLoadingCatalog(true);
    fetch('/api/exercises?scope=home&pageSize=36')
      .then((res) => res.json())
      .then((data) => {
        const items = data.items || [];
        setCatalog(items);
      })
      .catch(() => {})
      .finally(() => setLoadingCatalog(false));
  }, [isOpen, catalog.length]);

  // Toggle equipment
  const toggleEquipment = (id) => {
    setSelectedEquipment((prev) =>
      prev.includes(id) ? (prev.length > 1 ? prev.filter((x) => x !== id) : prev) : [...prev, id]
    );
  };

  const selectAllEquipment = () => {
    setSelectedEquipment(EQUIPMENT_LIST.map((e) => e.id));
  };

  const clearEquipment = () => {
    setSelectedEquipment(['body weight']);
  };

  // Toggle muscle
  const toggleMuscle = (id) => {
    setSelectedMuscles((prev) =>
      prev.includes(id) ? (prev.length > 1 ? prev.filter((x) => x !== id) : prev) : [...prev, id]
    );
  };

  const applyPreset = (presetMuscles) => {
    setSelectedMuscles(presetMuscles);
  };

  // Equipment matching logic for catalog exercises
  const matchesEquipment = (exercise, chosenEq) => {
    const eq = (exercise.equipment || '').toLowerCase();
    for (const chosen of chosenEq) {
      if (chosen === 'body weight' && (eq.includes('body') || eq === 'assisted')) return true;
      if (chosen === 'dumbbell' && eq.includes('dumbbell')) return true;
      if (chosen === 'barbell' && (eq.includes('barbell') || eq.includes('smith') || eq.includes('olympic') || eq.includes('ez'))) return true;
      if (chosen === 'kettlebell' && eq.includes('kettlebell')) return true;
      if (chosen === 'band' && (eq.includes('band') || eq.includes('rope'))) return true;
      if (chosen === 'weighted' && (eq.includes('weighted') || eq.includes('plate') || eq.includes('ball'))) return true;
      if (chosen === 'pull-up bar' && (exercise.name.toLowerCase().includes('pull-up') || exercise.name.toLowerCase().includes('chin-up') || eq.includes('cable'))) return true;
      if (chosen === 'bench' && exercise.name.toLowerCase().includes('bench')) return true;
    }
    return false;
  };

  // Muscle matching logic
  const matchesMuscle = (exercise, muscleId) => {
    const muscleDef = MUSCLE_GROUPS.find((m) => m.id === muscleId);
    if (!muscleDef) return false;
    const target = (exercise.target || '').toLowerCase();
    const bodyPart = (exercise.body_part || '').toLowerCase();
    const name = (exercise.name || '').toLowerCase();

    if (muscleDef.target && target.includes(muscleDef.target)) return true;
    if (muscleDef.bodyPart && bodyPart.includes(muscleDef.bodyPart)) return true;
    if (name.includes(muscleId.replace('_', ' '))) return true;
    return false;
  };

  // Analyze & generate exercises when navigating to Step 3
  const generateWorkout = () => {
    if (!catalog.length) return;
    const available = catalog.filter((ex) => matchesEquipment(ex, selectedEquipment));
    const pool = available.length > 0 ? available : catalog;

    const result = [];
    const usedIds = new Set();

    // Try to find at least 1-2 exercises per selected muscle group
    selectedMuscles.forEach((muscleId) => {
      const candidates = pool.filter((ex) => !usedIds.has(ex.id) && matchesMuscle(ex, muscleId));
      if (candidates.length > 0) {
        const picked = candidates[Math.floor(Math.random() * candidates.length)];
        result.push(picked);
        usedIds.add(picked.id);
      }
    });

    // If fewer than 4 exercises, fill up from pool
    const remaining = pool.filter((ex) => !usedIds.has(ex.id));
    while (result.length < 4 && remaining.length > 0) {
      const idx = Math.floor(Math.random() * remaining.length);
      const picked = remaining.splice(idx, 1)[0];
      result.push(picked);
      usedIds.add(picked.id);
    }

    setGeneratedExercises(result.slice(0, 7));
  };

  const handleNextStep = () => {
    if (step === 1) {
      setStep(2);
    } else if (step === 2) {
      generateWorkout();
      setStep(3);
    }
  };

  const handlePreviousStep = () => {
    if (step > 1) setStep(step - 1);
  };

  // Shuffle individual exercise (Image 4 shuffle button)
  const handleShuffleExercise = (indexToSwap) => {
    const current = generatedExercises[indexToSwap];
    if (!current || !catalog.length) return;

    const usedIds = new Set(generatedExercises.map((e) => e.id));
    const available = catalog.filter(
      (ex) => !usedIds.has(ex.id) && matchesEquipment(ex, selectedEquipment)
    );

    // Try matching same muscle target first
    let candidates = available.filter(
      (ex) => ex.target === current.target || ex.body_part === current.body_part
    );
    if (!candidates.length) candidates = available;
    if (!candidates.length) return;

    const replacement = candidates[Math.floor(Math.random() * candidates.length)];
    const updated = [...generatedExercises];
    updated[indexToSwap] = replacement;
    setGeneratedExercises(updated);
  };

  // Remove exercise from list
  const handleDeleteExercise = (indexToRemove) => {
    setGeneratedExercises((prev) => prev.filter((_, i) => i !== indexToRemove));
  };

  // Add exercise from picker
  const handleAddExercise = (exercise) => {
    if (!generatedExercises.some((e) => e.id === exercise.id)) {
      setGeneratedExercises((prev) => [...prev, exercise]);
    }
    setShowAddPicker(false);
  };

  // Final start workout action
  const handleFinalStart = () => {
    if (onStartWorkout) {
      onStartWorkout(generatedExercises);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="workout-wizard-overlay" role="dialog" aria-modal="true" aria-labelledby="wizard-title">
      <div className="workout-wizard-modal">
        {/* Modal Top Header */}
        <header className="wizard-modal-header">
          <div className="wizard-brand">
            <span className="wizard-badge-icon">⚡</span>
            <span>FITFLOW / WORKOUT BUILDER</span>
          </div>
          <button
            type="button"
            className="wizard-close-btn"
            onClick={onClose}
            aria-label="Đóng giao diện tạo bài tập"
          >
            ✕
          </button>
        </header>

        {/* Stepper Progress Header matching Images 1-4 */}
        <div className="wizard-stepper">
          {/* Step 1 */}
          <div className={`step-node ${step === 1 ? 'active' : step > 1 ? 'completed' : ''}`}>
            <div className="step-circle" onClick={() => setStep(1)}>
              {step > 1 ? '✓' : '1'}
            </div>
            <div className="step-meta">
              <strong className="step-title">Equipment</strong>
              <span className="step-desc">Select your equipment</span>
            </div>
          </div>

          <div className={`step-connector ${step > 1 ? 'completed' : ''}`} />

          {/* Step 2 */}
          <div className={`step-node ${step === 2 ? 'active' : step > 2 ? 'completed' : ''}`}>
            <div className="step-circle" onClick={() => setStep(2)}>
              {step > 2 ? '✓' : '2'}
            </div>
            <div className="step-meta">
              <strong className="step-title">Muscles</strong>
              <span className="step-desc">Choose your training</span>
            </div>
          </div>

          <div className={`step-connector ${step > 2 ? 'completed' : ''}`} />

          {/* Step 3 */}
          <div className={`step-node ${step === 3 ? 'active' : ''}`}>
            <div className="step-circle" onClick={() => { if (step !== 3) { generateWorkout(); setStep(3); } }}>
              3
            </div>
            <div className="step-meta">
              <strong className="step-title">Exercises</strong>
              <span className="step-desc">Customize your workout</span>
            </div>
          </div>
        </div>

        {/* ================= STEP 1: EQUIPMENT ================= */}
        {step === 1 && (
          <div className="wizard-step-content step-equipment">
            <div className="step-instruction-bar">
              <div>
                <h2>SELECT YOUR EQUIPMENT</h2>
                <p>Chọn các dụng cụ bạn đang có để thuật toán phân bổ các bài tập chính xác nhất.</p>
              </div>
              <div className="step-actions-quick">
                <button type="button" onClick={selectAllEquipment} className="btn-text-action">
                  Chọn tất cả
                </button>
                <button type="button" onClick={clearEquipment} className="btn-text-action">
                  Xóa bớt
                </button>
              </div>
            </div>

            <div className="equipment-grid">
              {EQUIPMENT_LIST.map((eq) => {
                const isSelected = selectedEquipment.includes(eq.id);
                return (
                  <div
                    key={eq.id}
                    className={`equipment-card ${isSelected ? 'selected' : ''}`}
                    onClick={() => toggleEquipment(eq.id)}
                    role="checkbox"
                    aria-checked={isSelected}
                    tabIndex={0}
                    onKeyDown={(e) => { if (e.key === ' ' || e.key === 'Enter') toggleEquipment(eq.id); }}
                  >
                    <div className="card-indicator">
                      <span className={`indicator-dot ${isSelected ? 'active' : ''}`} />
                    </div>
                    <div className="card-icon-wrap">{eq.icon}</div>
                    <strong className="card-title">{eq.label}</strong>
                    <span className="card-sub">{eq.sub}</span>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* ================= STEP 2: MUSCLES (INTERACTIVE ANATOMICAL BODY) ================= */}
        {step === 2 && (
          <div className="wizard-step-content step-muscles">
            <div className="step-instruction-bar">
              <div>
                <h2 id="wizard-title">CHOOSE YOUR TARGET MUSCLES</h2>
                <p className="italic-note">
                  <em>Select the muscle(s) you want to train by clicking on them. (Chạm để chọn, hiển thị màu đỏ)</em>
                </p>
              </div>
              {hoveredMuscle && (
                <div className="muscle-hover-indicator">
                  <span>Nhóm cơ:</span> <strong>{hoveredMuscle}</strong>
                </div>
              )}
            </div>

            {/* Anatomical Body Maps (Front & Back Views side by side) */}
            <div className="anatomy-interactive-wrapper">
              {/* FRONT VIEW */}
              <div className="anatomy-figure-panel">
                <div className="figure-header">
                  <span>MẶT TRƯỚC (ANTERIOR)</span>
                </div>
                <div className="svg-canvas-container">
                  <svg
                    viewBox="0 0 240 480"
                    className="anatomy-svg"
                    aria-label="Front anatomical body diagram"
                  >
                    <defs>
                      <filter id="red-glow" x="-20%" y="-20%" width="140%" height="140%">
                        <feGaussianBlur stdDeviation="4" result="blur" />
                        <feComposite in="SourceGraphic" in2="blur" operator="over" />
                      </filter>
                    </defs>

                    {/* Head & Neck Base Outline */}
                    <ellipse cx="120" cy="38" rx="22" ry="28" className="body-silhouette" />
                    <path d="M108 64 L132 64 L138 82 L102 82 Z" className="body-silhouette" />

                    {/* CHEST (PECTORALS) - Red when selected */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('chest') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('chest')}
                      onMouseEnter={() => setHoveredMuscle('Ngực (Pectorals)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      {/* Left Pec */}
                      <path d="M118 88 L86 92 C80 98 80 114 88 126 C98 132 116 130 118 122 Z" />
                      {/* Right Pec */}
                      <path d="M122 88 L154 92 C160 98 160 114 152 126 C142 132 124 130 122 122 Z" />
                    </g>

                    {/* SHOULDERS (DELTOIDS) FRONT */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('delts') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('delts')}
                      onMouseEnter={() => setHoveredMuscle('Cơ vai (Deltoids)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      {/* Left Delt */}
                      <path d="M82 88 C70 94 62 108 64 124 C68 130 76 130 82 120 C84 108 84 96 82 88 Z" />
                      {/* Right Delt */}
                      <path d="M158 88 C170 94 178 108 176 124 C172 130 164 130 158 120 C156 108 156 96 158 88 Z" />
                    </g>

                    {/* BICEPS (UPPER ARMS) */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('biceps') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('biceps')}
                      onMouseEnter={() => setHoveredMuscle('Bắp tay trước (Biceps)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      {/* Left Bicep */}
                      <path d="M64 126 C58 136 56 154 62 168 C68 170 74 166 76 154 C78 142 74 130 64 126 Z" />
                      {/* Right Bicep */}
                      <path d="M176 126 C182 136 184 154 178 168 C172 170 166 166 164 154 C162 142 166 130 176 126 Z" />
                    </g>

                    {/* FOREARMS FRONT */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('forearms') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('forearms')}
                      onMouseEnter={() => setHoveredMuscle('Cẳng tay (Forearms)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      {/* Left Forearm */}
                      <path d="M60 174 C52 190 44 212 38 234 C44 238 52 234 58 220 C64 204 68 188 64 174 Z" />
                      {/* Right Forearm */}
                      <path d="M180 174 C188 190 196 212 202 234 C196 238 188 234 182 220 C176 204 172 188 176 174 Z" />
                    </g>

                    {/* Hands */}
                    <path d="M34 238 C30 248 24 260 28 268 C34 270 42 262 44 250 Z" className="body-silhouette" />
                    <path d="M206 238 C210 248 216 260 212 268 C206 270 198 262 196 250 Z" className="body-silhouette" />

                    {/* ABDOMINALS (ABS & 6-PACK) */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('abs') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('abs')}
                      onMouseEnter={() => setHoveredMuscle('Cơ bụng & Cơ liên sườn (Abs & Obliques)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      {/* Upper Abs */}
                      <rect x="106" y="132" width="12" height="15" rx="3" />
                      <rect x="122" y="132" width="12" height="15" rx="3" />
                      {/* Mid Abs */}
                      <rect x="106" y="150" width="12" height="15" rx="3" />
                      <rect x="122" y="150" width="12" height="15" rx="3" />
                      {/* Lower Abs */}
                      <rect x="106" y="168" width="12" height="17" rx="3" />
                      <rect x="122" y="168" width="12" height="17" rx="3" />
                      {/* Obliques Left & Right */}
                      <path d="M88 132 C82 144 80 162 86 182 C94 182 102 178 102 168 C102 152 98 138 88 132 Z" />
                      <path d="M152 132 C158 144 160 162 154 182 C146 182 138 178 138 168 C138 152 142 138 152 132 Z" />
                    </g>

                    {/* Pelvis / Hip Joint */}
                    <path d="M100 190 L140 190 L132 212 L108 212 Z" className="body-silhouette" />

                    {/* QUADRICEPS (THIGHS) */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('quads') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('quads')}
                      onMouseEnter={() => setHoveredMuscle('Đùi trước (Quadriceps)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      {/* Left Quad */}
                      <path d="M84 212 C74 236 72 278 78 318 C86 322 96 322 104 316 C110 290 112 250 108 212 Z" />
                      {/* Right Quad */}
                      <path d="M156 212 C166 236 168 278 162 318 C154 322 144 322 136 316 C130 290 128 250 132 212 Z" />
                    </g>

                    {/* Knees */}
                    <circle cx="92" cy="330" r="8" className="body-silhouette" />
                    <circle cx="148" cy="330" r="8" className="body-silhouette" />

                    {/* CALVES & SHINS FRONT */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('calves') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('calves')}
                      onMouseEnter={() => setHoveredMuscle('Bắp chân & Cẳng chân (Calves & Shins)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      {/* Left Shin/Calf */}
                      <path d="M84 340 C76 360 76 398 84 430 C90 432 98 428 100 412 C104 388 102 360 98 340 Z" />
                      {/* Right Shin/Calf */}
                      <path d="M156 340 C164 360 164 398 156 430 C150 432 142 428 140 412 C136 388 138 360 142 340 Z" />
                    </g>

                    {/* Feet Front */}
                    <path d="M78 436 C70 450 64 466 74 470 C88 472 96 466 94 446 Z" className="body-silhouette" />
                    <path d="M162 436 C170 450 176 466 166 470 C152 472 144 466 146 446 Z" className="body-silhouette" />
                  </svg>
                </div>
              </div>

              {/* BACK VIEW */}
              <div className="anatomy-figure-panel">
                <div className="figure-header">
                  <span>MẶT SAU (POSTERIOR)</span>
                </div>
                <div className="svg-canvas-container">
                  <svg
                    viewBox="0 0 240 480"
                    className="anatomy-svg"
                    aria-label="Back anatomical body diagram"
                  >
                    {/* Head & Neck Base Back */}
                    <ellipse cx="120" cy="38" rx="22" ry="28" className="body-silhouette" />

                    {/* TRAPEZIUS & UPPER BACK */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('upper_back') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('upper_back')}
                      onMouseEnter={() => setHoveredMuscle('Cầu vai & Lưng trên (Traps & Upper Back)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      {/* Diamond shape traps */}
                      <path d="M120 62 L144 82 L152 108 L120 134 L88 108 L96 82 Z" />
                    </g>

                    {/* SHOULDERS (REAR DELTOIDS) */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('delts') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('delts')}
                      onMouseEnter={() => setHoveredMuscle('Cơ vai sau (Rear Deltoids)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      {/* Left Rear Delt */}
                      <path d="M88 88 C74 94 66 108 68 124 C74 128 82 124 88 116 Z" />
                      {/* Right Rear Delt */}
                      <path d="M152 88 C166 94 174 108 172 124 C166 128 158 124 152 116 Z" />
                    </g>

                    {/* LATS & MID BACK */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('lats') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('lats')}
                      onMouseEnter={() => setHoveredMuscle('Lưng xô & Lưng giữa (Lats & Mid Back)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      {/* Left Lat Wing */}
                      <path d="M86 114 C74 130 76 156 86 178 C98 176 108 166 116 142 C104 132 94 122 86 114 Z" />
                      {/* Right Lat Wing */}
                      <path d="M154 114 C166 130 164 156 154 178 C142 176 132 166 124 142 C136 132 146 122 154 114 Z" />
                      {/* Lower Back / Spine center */}
                      <path d="M116 146 L124 146 L124 190 L116 190 Z" />
                    </g>

                    {/* TRICEPS (UPPER ARMS BACK) */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('triceps') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('triceps')}
                      onMouseEnter={() => setHoveredMuscle('Bắp tay sau (Triceps)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      {/* Left Tricep */}
                      <path d="M66 124 C58 136 56 154 62 168 C68 170 76 166 78 152 C80 138 76 126 66 124 Z" />
                      {/* Right Tricep */}
                      <path d="M174 124 C182 136 184 154 178 168 C172 170 164 166 162 152 C160 138 164 126 174 124 Z" />
                    </g>

                    {/* FOREARMS BACK */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('forearms') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('forearms')}
                      onMouseEnter={() => setHoveredMuscle('Cẳng tay (Forearms)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      <path d="M60 174 C52 190 44 212 38 234 C44 238 52 234 58 220 C64 204 68 188 64 174 Z" />
                      <path d="M180 174 C188 190 196 212 202 234 C196 238 188 234 182 220 C176 204 172 188 176 174 Z" />
                    </g>

                    {/* Hands Back */}
                    <path d="M34 238 C30 248 24 260 28 268 C34 270 42 262 44 250 Z" className="body-silhouette" />
                    <path d="M206 238 C210 248 216 260 212 268 C206 270 198 262 196 250 Z" className="body-silhouette" />

                    {/* GLUTES (CƠ MÔNG) */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('glutes') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('glutes')}
                      onMouseEnter={() => setHoveredMuscle('Cơ mông (Gluteus Maximus)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      {/* Left Glute */}
                      <path d="M84 188 C74 198 76 226 84 246 C94 252 110 248 118 238 C118 212 110 194 84 188 Z" />
                      {/* Right Glute */}
                      <path d="M156 188 C166 198 164 226 156 246 C146 252 130 248 122 238 C122 212 130 194 156 188 Z" />
                    </g>

                    {/* HAMSTRINGS (ĐÙI SAU) */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('hamstrings') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('hamstrings')}
                      onMouseEnter={() => setHoveredMuscle('Đùi sau (Hamstrings)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      {/* Left Hamstring */}
                      <path d="M84 250 C76 268 74 298 80 322 C88 326 96 324 104 316 C110 292 112 266 108 250 Z" />
                      {/* Right Hamstring */}
                      <path d="M156 250 C164 268 166 298 160 322 C152 326 144 324 136 316 C130 292 128 266 132 250 Z" />
                    </g>

                    {/* Knee joint back */}
                    <circle cx="92" cy="330" r="7" className="body-silhouette" />
                    <circle cx="148" cy="330" r="7" className="body-silhouette" />

                    {/* CALVES (BẮP CHUỐI SAU) */}
                    <g
                      className={`muscle-part ${selectedMuscles.includes('calves') ? 'is-selected' : ''}`}
                      onClick={() => toggleMuscle('calves')}
                      onMouseEnter={() => setHoveredMuscle('Bắp chuối (Calves / Gastrocnemius)')}
                      onMouseLeave={() => setHoveredMuscle(null)}
                      role="button"
                      tabIndex={0}
                    >
                      {/* Left Gastrocnemius */}
                      <path d="M82 338 C72 358 72 392 82 422 C90 426 102 422 102 404 C104 378 100 354 94 338 Z" />
                      {/* Right Gastrocnemius */}
                      <path d="M158 338 C168 358 168 392 158 422 C150 426 138 422 138 404 C136 378 140 354 146 338 Z" />
                    </g>

                    {/* Feet Back */}
                    <path d="M80 430 C72 444 68 458 76 464 C88 466 94 460 92 440 Z" className="body-silhouette" />
                    <path d="M160 430 C168 444 172 458 164 464 C152 466 146 460 148 440 Z" className="body-silhouette" />
                  </svg>
                </div>
              </div>
            </div>

            {/* Quick Presets & Chip List */}
            <div className="muscle-selection-dashboard">
              <div className="preset-row">
                <span className="preset-label">Gợi ý nhanh:</span>
                {PRESETS.map((p) => (
                  <button
                    key={p.name}
                    type="button"
                    className="preset-chip"
                    onClick={() => applyPreset(p.muscles)}
                  >
                    {p.name}
                  </button>
                ))}
              </div>

              <div className="muscle-tags-row">
                {MUSCLE_GROUPS.map((m) => {
                  const active = selectedMuscles.includes(m.id);
                  return (
                    <button
                      key={m.id}
                      type="button"
                      className={`muscle-tag ${active ? 'active' : ''}`}
                      onClick={() => toggleMuscle(m.id)}
                    >
                      <span className="tag-dot" style={{ backgroundColor: active ? '#EF4444' : '#64748B' }} />
                      <span>{m.name}</span>
                    </button>
                  );
                })}
              </div>
            </div>
          </div>
        )}

        {/* ================= STEP 3: EXERCISES CUSTOMIZER (MATCHING IMAGE 4) ================= */}
        {step === 3 && (
          <div className="wizard-step-content step-exercises">
            <div className="step-instruction-bar">
              <div>
                <h2>CUSTOMIZE YOUR WORKOUT SESSION</h2>
                <p>
                  Đã phân tích <strong>{generatedExercises.length} bài tập</strong> dựa trên dụng cụ và nhóm cơ bạn chọn. Bạn có thể bấm Đổi bài (Shuffle), Thêm bài hoặc Bắt đầu tập ngay.
                </p>
              </div>
              <button
                type="button"
                className="btn-add-outline"
                onClick={() => setShowAddPicker(true)}
              >
                + Thêm bài tập
              </button>
            </div>

            {/* Exercise List Cards */}
            <div className="wizard-exercise-list">
              {generatedExercises.length === 0 ? (
                <div className="empty-exercise-state">
                  <p>Không tìm thấy bài tập thỏa mãn tất cả tiêu chí. Hãy chọn thêm dụng cụ hoặc nhóm cơ.</p>
                  <button type="button" className="btn-secondary" onClick={() => setStep(1)}>
                    Quay lại chọn dụng cụ
                  </button>
                </div>
              ) : (
                generatedExercises.map((exercise, idx) => {
                  const media = exerciseMediaUrl(exercise);
                  const badgeLetter = (exercise.target || exercise.body_part || 'E').charAt(0).toUpperCase();

                  return (
                    <div className="wizard-exercise-card" key={`${exercise.id}-${idx}`}>
                      {/* Drag handle */}
                      <div className="card-drag-handle" title="Thứ tự bài tập">
                        <span>⋮⋮</span>
                      </div>

                      {/* Animated thumbnail */}
                      <div className="card-thumbnail">
                        {media ? (
                          <img
                            src={media}
                            alt={exercise.name}
                            onError={(e) => {
                              e.currentTarget.style.display = 'none';
                            }}
                          />
                        ) : (
                          <div className="placeholder-thumb">{badgeLetter}</div>
                        )}
                      </div>

                      {/* Badge (B, C, S, Q, etc.) */}
                      <div className="card-badge" title={exercise.target || exercise.body_part}>
                        {badgeLetter}
                      </div>

                      {/* Title & Metadata */}
                      <div className="card-info">
                        <strong className="exercise-name">{titleCase(exercise.name)}</strong>
                        <span className="exercise-meta">
                          {titleCase(exercise.body_part)} · {titleCase(exercise.equipment)} · {titleCase(exercise.target)}
                        </span>
                      </div>

                      {/* Actions: Shuffle, Info, Delete */}
                      <div className="card-actions">
                        <button
                          type="button"
                          className="btn-action-shuffle"
                          onClick={() => handleShuffleExercise(idx)}
                          title="Đổi bài tập tương đương khác"
                        >
                          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2">
                            <polyline points="16 3 21 3 21 8" />
                            <line x1="4" y1="20" x2="21" y2="3" />
                            <polyline points="21 16 21 21 16 21" />
                            <line x1="15" y1="15" x2="21" y2="21" />
                            <line x1="4" y1="4" x2="9" y2="9" />
                          </svg>
                          <span>Shuffle</span>
                        </button>

                        <button
                          type="button"
                          className="btn-action-icon"
                          onClick={() => setPreviewDetail(exercise)}
                          title="Xem thông tin chi tiết bài tập"
                        >
                          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2">
                            <line x1="18" y1="20" x2="18" y2="10" />
                            <line x1="12" y1="20" x2="12" y2="4" />
                            <line x1="6" y1="20" x2="6" y2="14" />
                          </svg>
                        </button>

                        <button
                          type="button"
                          className="btn-action-icon delete"
                          onClick={() => handleDeleteExercise(idx)}
                          title="Xóa bài tập này"
                        >
                          <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2">
                            <polyline points="3 6 5 6 21 6" />
                            <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
                          </svg>
                        </button>
                      </div>
                    </div>
                  );
                })
              )}

              {/* Add Button at bottom of list */}
              {generatedExercises.length > 0 && (
                <div className="add-row-container">
                  <button
                    type="button"
                    className="btn-add-more-row"
                    onClick={() => setShowAddPicker(true)}
                  >
                    <span className="plus-circle">+</span>
                    <span>Add</span>
                  </button>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Modal Bottom Footer Navigation */}
        <footer className="wizard-modal-footer">
          <button
            type="button"
            className="btn-wizard-nav prev"
            onClick={handlePreviousStep}
            disabled={step === 1}
          >
            ← Previous
          </button>

          {step < 3 ? (
            <button
              type="button"
              className="btn-wizard-nav next red-action"
              onClick={handleNextStep}
            >
              Continue <span>→</span>
            </button>
          ) : (
            <button
              type="button"
              className="btn-wizard-nav start-workout green-action"
              onClick={handleFinalStart}
              disabled={generatedExercises.length === 0}
            >
              <span>▶</span> Start Workout
            </button>
          )}
        </footer>

        {/* Picker Modal for Adding Additional Exercises */}
        {showAddPicker && (
          <div className="picker-overlay" role="dialog" aria-modal="true">
            <div className="picker-modal">
              <header className="picker-header">
                <h3>THÊM BÀI TẬP VÀO BUỔI TẬP</h3>
                <button type="button" onClick={() => setShowAddPicker(false)}>✕</button>
              </header>
              <div className="picker-search">
                <input
                  type="text"
                  placeholder="Tìm theo tên bài tập, nhóm cơ, dụng cụ..."
                  value={searchFilter}
                  onChange={(e) => setSearchFilter(e.target.value)}
                  autoFocus
                />
              </div>
              <div className="picker-list">
                {catalog
                  .filter((ex) => {
                    const q = searchFilter.toLowerCase();
                    return (
                      !q ||
                      ex.name.toLowerCase().includes(q) ||
                      (ex.body_part || '').toLowerCase().includes(q) ||
                      (ex.equipment || '').toLowerCase().includes(q)
                    );
                  })
                  .slice(0, 30)
                  .map((item) => (
                    <div
                      key={item.id}
                      className="picker-item"
                      onClick={() => handleAddExercise(item)}
                    >
                      <div className="picker-item-info">
                        <strong>{titleCase(item.name)}</strong>
                        <span>{titleCase(item.body_part)} · {titleCase(item.equipment)}</span>
                      </div>
                      <button type="button" className="btn-picker-add">+ Chọn</button>
                    </div>
                  ))}
              </div>
            </div>
          </div>
        )}

        {/* Exercise Quick Detail Preview Modal */}
        {previewDetail && (
          <div className="picker-overlay" role="dialog" aria-modal="true">
            <div className="picker-modal detail-modal">
              <header className="picker-header">
                <h3>{titleCase(previewDetail.name)}</h3>
                <button type="button" onClick={() => setPreviewDetail(null)}>✕</button>
              </header>
              <div className="detail-body">
                {exerciseMediaUrl(previewDetail) && (
                  <div className="detail-media">
                    <img src={exerciseMediaUrl(previewDetail)} alt={previewDetail.name} />
                  </div>
                )}
                <div className="detail-meta">
                  <p><strong>Nhóm cơ chính:</strong> {titleCase(previewDetail.target)}</p>
                  <p><strong>Bộ phận:</strong> {titleCase(previewDetail.body_part)}</p>
                  <p><strong>Dụng cụ yêu cầu:</strong> {titleCase(previewDetail.equipment)}</p>
                  {previewDetail.instructions && (
                    <div className="instructions-box">
                      <strong>Hướng dẫn kỹ thuật:</strong>
                      <p>{Array.isArray(previewDetail.instructions) ? previewDetail.instructions.join(' ') : previewDetail.instructions}</p>
                    </div>
                  )}
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

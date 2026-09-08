import { NUTRITION_GROUPS } from '@fitflow/contracts/nutrition';

const escapeXml = (value) => String(value ?? '').replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&apos;' }[char]));
const cell = (value) => {
  if (typeof value === 'number' && Number.isFinite(value)) return `<c t="n"><v>${value}</v></c>`;
  return `<c t="inlineStr"><is><t>${escapeXml(value)}</t></is></c>`;
};
const sheet = (rows) => `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>${rows.map((row, rowIndex) => `<row r="${rowIndex + 1}">${row.map(cell).join('')}</row>`).join('')}</sheetData></worksheet>`;
const crc32 = (input) => { let crc = 0xffffffff; for (const byte of input) { crc ^= byte; for (let bit = 0; bit < 8; bit += 1) crc = (crc >>> 1) ^ (crc & 1 ? 0xedb88320 : 0); } return (crc ^ 0xffffffff) >>> 0; };
const u16 = (value) => Buffer.from([value & 255, (value >>> 8) & 255]);
const u32 = (value) => Buffer.from([value & 255, (value >>> 8) & 255, (value >>> 16) & 255, (value >>> 24) & 255]);
const zip = async (files) => {
  const chunks = [];
  const central = [];
  let offset = 0;
  for (const [name, content] of files) {
    const nameBytes = Buffer.from(name);
    const source = Buffer.from(content);
    const compressed = await new Response(new Blob([source]).stream().pipeThrough(new CompressionStream('deflate-raw'))).arrayBuffer().then(Buffer.from);
    const header = Buffer.concat([Buffer.from([0x50, 0x4b, 0x03, 0x04]), u16(20), u16(0), u16(8), u16(0), u16(0), u32(crc32(source)), u32(compressed.length), u32(source.length), u16(nameBytes.length), u16(0), nameBytes, compressed]);
    chunks.push(header);
    central.push(Buffer.concat([Buffer.from([0x50, 0x4b, 0x01, 0x02]), u16(20), u16(20), u16(0), u16(8), u16(0), u16(0), u32(crc32(source)), u32(compressed.length), u32(source.length), u16(nameBytes.length), u16(0), u16(0), u16(0), u16(0), u32(0), u32(offset), nameBytes]));
    offset += header.length;
  }
  const centralBytes = Buffer.concat(central);
  return Buffer.concat([...chunks, centralBytes, Buffer.from([0x50, 0x4b, 0x05, 0x06]), u16(0), u16(0), u16(central.length), u16(central.length), u32(centralBytes.length), u32(offset), u16(0)]);
};

const workbookFiles = (sheets) => {
  const names = ['365 DAY PLAN', 'WORKOUTS', 'MEAL PLAN', 'FOOD DATABASE', 'PROGRESS'];
  const workbook = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets>${names.map((name, index) => `<sheet name="${name}" sheetId="${index + 1}" r:id="rId${index + 1}"/>`).join('')}</sheets></workbook>`;
  const rels = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">${names.map((_, index) => `<Relationship Id="rId${index + 1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet${index + 1}.xml"/>`).join('')}</Relationships>`;
  const contentTypes = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>${names.map((_, index) => `<Override PartName="/xl/worksheets/sheet${index + 1}.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>`).join('')}</Types>`;
  const rootRels = `<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>`;
  return [['[Content_Types].xml', contentTypes], ['_rels/.rels', rootRels], ['xl/workbook.xml', workbook], ['xl/_rels/workbook.xml.rels', rels], ...sheets.map((xml, index) => [`xl/worksheets/sheet${index + 1}.xml`, xml])];
};

export async function POST(request) {
  const contentLength = Number(request.headers.get('content-length') || 0);
  if (contentLength > 100_000) {
    return Response.json({ error: 'Export payload is too large.' }, { status: 413 });
  }

  let body;
  try {
    // Bound the stream itself: Content-Length is optional and untrusted.
    const reader = request.body?.getReader();
    const chunks = [];
    let bytes = 0;
    if (reader) {
      try {
        while (true) {
          const { done, value } = await reader.read();
          if (done) break;
          bytes += value.byteLength;
          if (bytes > 100_000) {
            await reader.cancel();
            return Response.json({ error: 'Export payload is too large.' }, { status: 413 });
          }
          chunks.push(Buffer.from(value));
        }
      } finally {
        reader.releaseLock();
      }
    }
    body = JSON.parse(Buffer.concat(chunks).toString('utf8'));
  } catch {
    return Response.json({ error: 'Export payload must be valid JSON.' }, { status: 400 });
  }

  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    return Response.json({ error: 'Export payload must be an object.' }, { status: 400 });
  }

  const sessions = body.sessions ?? [];
  const isObject = (value) => value !== null && typeof value === 'object' && !Array.isArray(value);
  const isCellValue = (value) => value == null ||
    (typeof value === 'string' && value.length <= 240) ||
    (typeof value === 'number' && Number.isFinite(value));
  if (!Array.isArray(sessions) || sessions.length > 31 || sessions.some((session) =>
    !isObject(session) ||
    ['day', 'focus', 'sets', 'reps', 'durationSeconds'].some((key) => !isCellValue(session[key])) ||
    (session.rest != null && typeof session.rest !== 'boolean') ||
    (session.exercises != null && (!Array.isArray(session.exercises) ||
      session.exercises.length > 100 || session.exercises.some((exercise) =>
        !isObject(exercise) || !isCellValue(exercise.name)))))) {
    return Response.json({ error: 'Export requires up to 31 sessions with valid exercise lists.' }, { status: 400 });
  }
  const groupNames = Object.keys(NUTRITION_GROUPS);
  const nutritionTotals = groupNames.slice(0, 4).reduce((total, type) => (NUTRITION_GROUPS[type] || []).slice(0, 3).reduce((sum, [name, kcal, protein = 0, carbs = 0, fat = 0], index) => { const grams = index === 0 ? 150 : 100; return { kcal: sum.kcal + kcal * grams / 100, protein: sum.protein + protein * grams / 100, carbs: sum.carbs + carbs * grams / 100, fat: sum.fat + fat * grams / 100 }; }, total), { kcal: 0, protein: 0, carbs: 0, fat: 0 });
  const planRows = [['Day', 'Week', 'Phase', 'Workout', 'Breakfast', 'Lunch', 'Dinner', 'Snack', 'Calories', 'Protein', 'Steps', 'Water']];
  for (let day = 1; day <= 365; day += 1) {
    const session = sessions[(day - 1) % Math.max(sessions.length, 1)] || {};
    const week = Math.ceil(day / 7);
    const phase = week <= 4 ? 'Foundation' : week <= 12 ? 'Build' : week <= 24 ? 'Progress' : week <= 44 ? 'Deload + Build' : 'Final';
    planRows.push([day, week, phase, session.rest ? 'REST' : session.focus || 'BALANCE', `MEAL${String(((day - 1) % 4) + 1).padStart(3, '0')}`, `MEAL${String(((day) % 4) + 1).padStart(3, '0')}`, `MEAL${String(((day + 1) % 4) + 1).padStart(3, '0')}`, `MEAL${String(((day + 2) % 4) + 1).padStart(3, '0')}`, Math.round(nutritionTotals.kcal), Math.round(nutritionTotals.protein), 8000, '3L']);
  }
  const workoutRows = [['Workout ID', 'Focus', 'Order', 'Exercise', 'Sets', 'Reps / Seconds', 'Rest']];
  sessions.forEach((session, sessionIndex) => (session.exercises || []).forEach((exercise, exerciseIndex) => workoutRows.push([`DAY${String(session.day || sessionIndex + 1).padStart(2, '0')}`, session.focus || 'BALANCE', exerciseIndex + 1, exercise.name || '', session.sets || 0, session.reps || session.durationSeconds || 0, '90s'])));
  const mealRows = [['Meal ID', 'Meal', 'Meal Type', 'Food', 'Amount', 'Calories', 'Protein', 'Carbs', 'Fat']];
  groupNames.slice(0, 4).forEach((type, mealIndex) => (NUTRITION_GROUPS[type] || []).slice(0, 3).forEach(([name, kcal, protein = 0, carbs = 0, fat = 0], itemIndex) => { const grams = itemIndex === 0 ? 150 : 100; mealRows.push([`MEAL${String(mealIndex + 1).padStart(3, '0')}`, `${type} ${String.fromCharCode(65 + mealIndex)}`, type, name, `${grams}g`, Math.round(kcal * grams / 100), Math.round(protein * grams / 100), Math.round(carbs * grams / 100), Math.round(fat * grams / 100)]); }));
  const foodRows = [['ID', 'Food', 'Category', 'Kcal / 100g', 'Protein', 'Carbs', 'Fat']];
  groupNames.forEach((type) => (NUTRITION_GROUPS[type] || []).forEach(([name, kcal, protein = 0, carbs = 0, fat = 0], index) => foodRows.push([`${type.slice(0, 2)}${String(index + 1).padStart(3, '0')}`, name, type, kcal, protein || 0, carbs || 0, fat || 0])));
  const progressRows = [['Day', 'Date', 'Weight', 'Calories', 'Steps', 'Workout Done', 'Water', 'Sleep', 'Notes']];
  for (let day = 1; day <= 365; day += 1) progressRows.push([day, '', '', '', '', '', '', '', '']);
  const files = workbookFiles([sheet(planRows), sheet(workoutRows), sheet(mealRows), sheet(foodRows), sheet(progressRows)]);
  const output = await zip(files);
  return new Response(output, { headers: { 'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'Content-Disposition': 'attachment; filename="FITFLOW_365_DAYS.xlsx"', 'Cache-Control': 'no-store' } });
}

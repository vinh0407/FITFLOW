import { copyFileSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';

const root = resolve(process.cwd(), '../..');
const source = resolve(root, 'packages/contracts/data/exercises.json');
const destination = resolve(process.cwd(), 'public/data/exercises.json');
const indexDestination = resolve(process.cwd(), 'public/data/exercises-index.json');
const detailsDirectory = resolve(process.cwd(), 'public/data/exercises');

mkdirSync(dirname(destination), { recursive: true });
mkdirSync(detailsDirectory, { recursive: true });
copyFileSync(source, destination);
const exercises = JSON.parse(readFileSync(source, 'utf8'));
const index = exercises.map(({ id, name, category, body_part, equipment, muscle_group, secondary_muscles, target, gif_url, media_id }) => ({
  id, name, category, body_part, equipment, muscle_group, secondary_muscles, target, gif_url, media_id,
}));
for (const exercise of exercises) {
  writeFileSync(resolve(detailsDirectory, `${exercise.id}.json`), `${JSON.stringify({
    id: exercise.id,
    instructions: exercise.instructions,
    instruction_steps: exercise.instruction_steps,
    attribution: exercise.attribution,
  })}\n`);
}
writeFileSync(indexDestination, `${JSON.stringify(index)}\n`);
console.log(`FITFLOW shared data synced: full catalog + lightweight index + ${index.length} lazy details`);

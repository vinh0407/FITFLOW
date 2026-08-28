import { copyFileSync, mkdirSync } from 'node:fs';
import { dirname, resolve } from 'node:path';

const root = resolve(process.cwd(), '../..');
const source = resolve(root, 'packages/contracts/data/exercises.json');
const destination = resolve(process.cwd(), 'public/data/exercises.json');

mkdirSync(dirname(destination), { recursive: true });
copyFileSync(source, destination);
console.log('FITFLOW shared data synced: exercises.json');

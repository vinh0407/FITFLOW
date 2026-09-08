import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { NextResponse } from 'next/server';

export const revalidate = 86400;

export async function GET(_request, { params }) {
  try {
    const { id } = await params;
    if (!/^\d{4}$/.test(id)) {
      return NextResponse.json({ error: 'Exercise details unavailable' }, { status: 404 });
    }
    const details = JSON.parse(readFileSync(resolve(process.cwd(), `public/data/exercises/${id}.json`), 'utf8'));
    return NextResponse.json(details, { headers: { 'Cache-Control': 'public, max-age=86400, immutable' } });
  } catch {
    return NextResponse.json({ error: 'Exercise details unavailable' }, { status: 404 });
  }
}

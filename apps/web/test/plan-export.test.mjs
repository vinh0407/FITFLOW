import test from 'node:test';
import assert from 'node:assert/strict';
import { inflateRawSync } from 'node:zlib';
import { POST } from '../app/api/plan-export/route.js';

const request = (body, headers = {}) => new Request('http://localhost/api/plan-export', {
  method: 'POST', body: JSON.stringify(body), headers,
});

test('export rejects malformed session data instead of throwing or truncating', async () => {
  for (const body of [null, [], { sessions: {} }, { sessions: [null] },
    { sessions: [{ exercises: {} }] }, { sessions: [{ exercises: [null] }] },
    { sessions: [{ focus: {} }] }, { sessions: Array.from({ length: 32 }, () => ({})) }]) {
    const response = await POST(request(body));
    assert.equal(response.status, 400, JSON.stringify(body));
    assert.ok((await response.json()).error);
  }
});

test('export limits actual UTF-8 bytes even without an honest Content-Length', async () => {
  for (const headers of [{}, { 'content-length': '1' }]) {
    const response = await POST(request({ sessions: [], padding: 'ế'.repeat(34_000) }, headers));
    assert.equal(response.status, 413);
  }
});

test('export cancels an oversized stream before consuming the remaining body', async () => {
  let cancelled = false;
  let reads = 0;
  const stream = new ReadableStream({
    pull(controller) {
      reads += 1;
      controller.enqueue(new Uint8Array(60_000).fill(32));
      if (reads === 10) controller.close();
    },
    cancel() { cancelled = true; },
  });
  const response = await POST(new Request('http://localhost/api/plan-export', {
    method: 'POST', body: stream, duplex: 'half',
  }));
  assert.equal(response.status, 413);
  assert.equal(cancelled, true);
  assert.ok(reads < 10);
});

test('export keeps a valid 365-day workbook and escapes user text as strings', async () => {
  const response = await POST(request({ sessions: [
    { day: 1, focus: 'Push & pull', sets: 3, reps: 10, exercises: [{ name: '=SUM(1,2)<test>' }] },
    { day: 2, rest: true, exercises: [] },
  ] }));
  assert.equal(response.status, 200);
  assert.equal(response.headers.get('cache-control'), 'no-store');
  const bytes = Buffer.from(await response.arrayBuffer());
  const files = {};
  for (let offset = 0; bytes.readUInt32LE(offset) === 0x04034b50;) {
    const compressedSize = bytes.readUInt32LE(offset + 18);
    const nameLength = bytes.readUInt16LE(offset + 26);
    const extraLength = bytes.readUInt16LE(offset + 28);
    const start = offset + 30 + nameLength + extraLength;
    const name = bytes.toString('utf8', offset + 30, offset + 30 + nameLength);
    files[name] = inflateRawSync(bytes.subarray(start, start + compressedSize)).toString('utf8');
    offset = start + compressedSize;
  }
  assert.equal(Object.keys(files).length, 9);
  assert.equal((files['xl/worksheets/sheet1.xml'].match(/<row /g) || []).length, 366);
  assert.match(files['xl/worksheets/sheet1.xml'], /REST/);
  assert.match(files['xl/worksheets/sheet2.xml'], /Push &amp; pull/);
  assert.match(files['xl/worksheets/sheet2.xml'], /<t>=SUM\(1,2\)&lt;test&gt;<\/t>/);
  assert.doesNotMatch(files['xl/worksheets/sheet2.xml'], /<f[ >]/);
});

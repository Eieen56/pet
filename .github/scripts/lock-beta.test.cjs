const { test } = require('node:test');
const assert = require('node:assert/strict');
const { lockBeta } = require('./lock-beta.cjs');
const round = require('../beta-round.json');

function fixture() {
  const calls = [];
  const logs = [];
  const issues = [1, 2, 3].map(n => ({ number: n, title: `[beta-2026-10] Tester ${n}`,
    locked: false, labels: [{ name: 'tester-feedback' }, { name: 'beta-2026-10' }] }));
  return { calls, logs, issues, args: {
    now: new Date('2026-10-21T06:00:00Z'),
    dryRun: false,
    core: Object.fromEntries(['info', 'warning', 'error'].map(k => [k, v => logs.push(v)])),
    context: { repo: { owner: 'example', repo: 'example' } },
    github: { rest: { issues: {
      get: async ({ issue_number }) => ({ data: issues[issue_number - 1] }),
      lock: async ({ issue_number }) => { calls.push(issue_number); issues[issue_number - 1].locked = true; }
    } } }
  } };
}

test('protecciones y reintentos sin llamar a GitHub real', async t => {
  const original = round.issueNumbers;
  try {
    round.issueNumbers = [1, 2, 3];
    await t.test('nunca bloquear antes del corte, incluso manualmente', async () => {
      for (const instant of ['2026-10-21T05:59:00Z', '2026-10-21T05:59:59.999Z']) {
        const f = fixture();
        await lockBeta({ ...f.args, now: new Date(instant) });
        assert.deepEqual(f.calls, []);
      }
    });
    await t.test('simulación después del corte sin mutaciones', async () => {
      const f = fixture(); await lockBeta({ ...f.args, dryRun: true });
      assert.deepEqual(f.calls, []); assert.equal(f.logs.length, 3);
    });
    await t.test('bloquea exactamente tres al corte y es idempotente', async () => {
      const f = fixture(); await lockBeta(f.args); await lockBeta(f.args);
      assert.deepEqual(f.calls, [1, 2, 3]);
    });
    await t.test('ejecución tardía recupera bloqueo pendiente', async () => {
      const f = fixture(); await lockBeta({ ...f.args, now: new Date('2026-11-01T12:00:00Z') });
      assert.deepEqual(f.calls, [1, 2, 3]);
    });
    await t.test('ningún bloqueo si un destino es ajeno, PR o tester duplicado', async () => {
      for (const change of [i => i.labels.pop(), i => i.title = 'Otro issue',
        i => i.pull_request = {}, i => i.title = '[beta-2026-10] Tester 1']) {
        const f = fixture(); change(f.issues[2]);
        await assert.rejects(lockBeta(f.args)); assert.deepEqual(f.calls, []);
      }
    });
    await t.test('errores se registran, otros destinos se procesan y el job falla', async () => {
      const f = fixture(); const lock = f.args.github.rest.issues.lock;
      f.args.github.rest.issues.lock = async args => {
        if (args.issue_number === 2) throw new Error('403');
        return lock(args);
      };
      await assert.rejects(lockBeta(f.args), /1 bloqueo/);
      assert.deepEqual(f.calls, [1, 3]); assert.ok(f.logs.some(l => l.includes('#2: 403')));
    });
    await t.test('lista vacía o duplicada impide bloquear', async () => {
      for (const list of [[], [1, 1, 2], [1, 2], [1, 2, -3]]) {
        round.issueNumbers = list; const f = fixture();
        await assert.rejects(lockBeta(f.args)); assert.deepEqual(f.calls, []);
      }
    });
  } finally { round.issueNumbers = original; }
});

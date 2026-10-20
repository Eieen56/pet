const round = require('../beta-round.json');

async function lockBeta({ github, context, core, dryRun = true, now = new Date() }) {
  const cutoff = Date.parse(round.lockAt);
  if (!Number.isFinite(cutoff)) throw new Error('Fecha de bloqueo inválida');
  if (now.getTime() < cutoff) {
    core.info('Antes del vencimiento: no se bloquea ningún issue.');
    return;
  }
  const numbers = round.issueNumbers;
  if (numbers.length !== 3 || new Set(numbers).size !== 3 ||
      numbers.some(n => !Number.isSafeInteger(n) || n <= 0)) {
    const message = 'Registrar exactamente los tres números de issue en .github/beta-round.json.';
    if (dryRun) { core.warning(message); return; }
    throw new Error(message);
  }
  // Validar toda la lista antes de efectuar la primera mutación.
  const issues = [];
  const testers = new Set();
  for (const issue_number of numbers) {
    const { data: issue } = await github.rest.issues.get({ ...context.repo, issue_number });
    const labels = new Set(issue.labels.map(l => typeof l === 'string' ? l : l.name));
    const tester = /^\[beta-2026-10\] Tester ([123])$/.exec(issue.title)?.[1];
    if (issue.pull_request || !labels.has('tester-feedback') ||
        !labels.has(round.round) || !tester || testers.has(tester)) {
      throw new Error(`Issue #${issue_number}: identidad de la ronda no válida; no se bloquea.`);
    }
    testers.add(tester);
    issues.push(issue);
  }
  let errors = 0;
  for (const issue of issues) {
    if (issue.locked) { core.info(`#${issue.number}: ya bloqueado`); continue; }
    if (dryRun) { core.info(`#${issue.number}: se bloquearía (simulación)`); continue; }
    try {
      await github.rest.issues.lock({ ...context.repo, issue_number: issue.number });
      core.info(`#${issue.number}: bloqueado`);
    } catch (error) {
      errors++;
      core.error(`#${issue.number}: ${error.message}`);
    }
  }
  if (errors) throw new Error(`${errors} bloqueo(s) fallaron; repetir ejecución.`);
}
module.exports = { lockBeta };

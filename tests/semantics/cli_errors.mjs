#!/usr/bin/env node
// Verify jq/jqlog stream diagnostics on either Native or Wasm executables.
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { parseArgs } from 'node:util';

const help = `Usage: node tests/semantics/cli_errors.mjs --jq PATH --jqlog PATH [--wasm-runner PATH]

Verify jq/jqlog stream diagnostics on either Native or Wasm executables.

  --jq PATH           jq executable or Wasm module
  --jqlog PATH        jqlog executable or Wasm module
  --wasm-runner PATH  For example moonrun, with Wasm modules
  -h, --help          Show this help
`;

function usageError(message) {
  console.error(`cli_errors.mjs: error: ${message}`);
  process.exit(2);
}

function options() {
  let args;
  try {
    ({ values: args } = parseArgs({
      options: {
        jq: { type: 'string' },
        jqlog: { type: 'string' },
        'wasm-runner': { type: 'string' },
        help: { type: 'boolean', short: 'h' },
      },
      allowPositionals: false,
    }));
  } catch (error) {
    usageError(error.message);
  }
  if (args.help) {
    console.log(help);
    process.exit(0);
  }
  if (!args.jq || !args.jqlog) usageError('--jq and --jqlog are required');
  return args;
}

function run(command, query, input) {
  const result = spawnSync(command[0], [...command.slice(1), query], {
    input,
    encoding: 'utf8',
    timeout: 5000,
    killSignal: 'SIGKILL',
    maxBuffer: 10 * 1024 * 1024,
  });
  if (result.error) throw new Error(`${command[0]}: ${result.error.message}`);
  if (result.signal) throw new Error(`${command[0]} terminated by ${result.signal}`);
  return result;
}

function main() {
  const args = options();
  let checked = 0;
  for (const [name, executable] of [['jq', args.jq], ['jqlog', args.jqlog]]) {
    const command = args['wasm-runner'] ? [args['wasm-runner'], executable, '--'] : [executable];
    for (const [query, input, expected, status] of [
      ['1, error({code:7}), 2', 'null\n', '1\n', 5],
      ['limit(1; (1,error("unused")))', 'null\n', '1\n', 0],
      ['.a.', 'null\n', '', 3],
      ['missing_name', 'null\n', '', 3],
    ]) {
      const flags = name === 'jq' ? ['-c'] : [];
      const result = run([...command, ...flags], query, input);
      const context = `${name}: ${query}`;
      assert.deepEqual([result.stdout, result.status], [expected, status], context);
      assert.equal(Boolean(result.stderr), Boolean(status), `${context}: diagnostic`);
      checked++;
    }
    const flags = name === 'jq' ? ['--logs', '-c'] : [];
    const query = '., if . == 2 then error("stop") else empty end';
    const result = run([...command, ...flags], query, 'invalid\n1\r\n2\n3\n');
    assert.deepEqual([result.stdout, result.status], ['1\n2\n', 5], `${name}: ${query}`);
    assert.ok(result.stderr, `${name}: missing diagnostic`);
    checked++;
  }
  console.log(`${checked} CLI error/prefix/log checks passed`);
}

try {
  main();
} catch (error) {
  console.error(`cli_errors.mjs: ${error.message}`);
  process.exitCode = 1;
}

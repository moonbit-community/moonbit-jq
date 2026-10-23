#!/usr/bin/env node
// Pinned jq oracle, bounded differential checks, and MoonBit fixture generation.
// Expectations are refreshed only from the verified jq reference.
import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { parseArgs } from 'node:util';

const fixturePath = new URL('./jq-1.7.1.json', import.meta.url);
const moonPath = new URL('../../semantics_reference_test.mbt', import.meta.url);
const help = `Usage: node tests/semantics/reference.mjs [options]

Pinned jq oracle, bounded differential checks, and MoonBit fixture generation.

  --reference PATH       Reference executable; must report jq-1.7.1
  --implementation PATH  Native executable or Wasm module to check
  --wasm-runner PATH     For example moonrun, with a Wasm --implementation
  --check-reference      Compare the reference with the recorded fixture
  --refresh              Explicitly update expectations from the reference
  --write-moon           Generate semantics_reference_test.mbt from the fixture
  --generate             Also compare bounded generated queries
  -h, --help             Show this help

Examples:
  node tests/semantics/reference.mjs --reference /path/to/jq-1.7.1 --check-reference
  node tests/semantics/reference.mjs --implementation /path/to/jq.exe
  node tests/semantics/reference.mjs --reference /path/to/jq-1.7.1 --generate --implementation /path/to/jq.exe
`;

function usageError(message) {
  console.error(`reference.mjs: error: ${message}`);
  process.exit(2);
}

function options() {
  let args;
  try {
    ({ values: args } = parseArgs({
      options: {
        reference: { type: 'string' },
        implementation: { type: 'string' },
        'wasm-runner': { type: 'string' },
        'check-reference': { type: 'boolean' },
        refresh: { type: 'boolean' },
        'write-moon': { type: 'boolean' },
        generate: { type: 'boolean' },
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
  if ((args.refresh || args['check-reference'] || args.generate) && !args.reference) {
    usageError('This operation requires --reference pointing to jq-1.7.1');
  }
  if (args.generate && !args.implementation) {
    usageError('--generate also requires --implementation');
  }
  if (args['wasm-runner'] && !args.implementation) {
    usageError('--wasm-runner requires --implementation');
  }
  return args;
}

function run(command, input) {
  const result = spawnSync(command[0], command.slice(1), {
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

function lines(text) {
  const result = text.split(/\r\n|\n|\r/u);
  if (result.at(-1) === '') result.pop();
  return result;
}

function invoke(command, query, value) {
  const result = run([...command, '-c', '--', query], `${JSON.stringify(value)}\n`);
  return {
    outputs: lines(result.stdout).map(line => JSON.parse(line)),
    status: result.status,
    error_prefix: result.stderr ? lines(result.stderr)[0].split(' at ')[0] : null,
  };
}

// MT19937 with integer seeding and rejection sampling preserves the exact
// Random(1701).choice() sequence used by the previous Python generator.
function seededChoice(seed) {
  const state = new Uint32Array(624);
  state[0] = 19650218;
  for (let i = 1; i < state.length; i++) {
    const previous = state[i - 1];
    state[i] = Math.imul(previous ^ (previous >>> 30), 1812433253) + i;
  }
  let index = 1;
  for (let remaining = 624; remaining > 0; remaining--) {
    const previous = state[index - 1];
    state[index] = (state[index] ^ Math.imul(previous ^ (previous >>> 30), 1664525)) + seed;
    if (++index === 624) {
      state[0] = state[623];
      index = 1;
    }
  }
  for (let remaining = 623; remaining > 0; remaining--) {
    const previous = state[index - 1];
    state[index] = (state[index] ^ Math.imul(previous ^ (previous >>> 30), 1566083941)) - index;
    if (++index === 624) {
      state[0] = state[623];
      index = 1;
    }
  }
  state[0] = 0x80000000;
  index = 624;
  function nextWord() {
    if (index === 624) {
      for (let i = 0; i < 624; i++) {
        const bits = (state[i] & 0x80000000) | (state[(i + 1) % 624] & 0x7fffffff);
        state[i] = state[(i + 397) % 624] ^ (bits >>> 1) ^ ((bits & 1) ? 0x9908b0df : 0);
      }
      index = 0;
    }
    let word = state[index++];
    word ^= word >>> 11;
    word ^= (word << 7) & 0x9d2c5680;
    word ^= (word << 15) & 0xefc60000;
    word ^= word >>> 18;
    return word >>> 0;
  }
  return values => {
    const bits = 32 - Math.clz32(values.length);
    let selected;
    do {
      selected = nextWord() >>> (32 - bits);
    } while (selected >= values.length);
    return values[selected];
  };
}

function* generatedCases() {
  const choice = seededChoice(1701);
  const atoms = ['.', 'empty', 'null', 'false', '1', '2', '(1,2)', '(false,null,3)', 'range(0;3)'];
  function expr(depth) {
    if (depth === 0) return choice(atoms);
    const a = expr(depth - 1);
    const b = expr(depth - 1);
    return choice([
      `(${a}),(${b})`, `(${a})|(${b})`, `(${a})+(${b})`,
      `(${a})//(${b})`, `(${a}) and (${b})`, `(${a}) or (${b})`,
      `first((${a}),(${b}))`, `limit(2; (${a}),(${b}))`,
      `if (${a}) then (${b}) else empty end`, `[(${a}),(${b})]`,
      `try ((${a}),error("generated"),(${b})) catch .`,
      `"a\\((${a}))b\\((${b}))"`, `{a:(${a}),b:(${b})}`,
    ]);
  }
  for (let i = 0; i < 200; i++) {
    yield [expr(2), choice([null, 0, 3, false, 'x', [1, 2], { a: 1 }])];
  }
  for (const atom of atoms) {
    for (const source of [null, 1, { a: [1, 2] }, '😀']) {
      yield [`"\\(${atom})"`, source];
      yield [`(${atom}) | tostring`, source];
    }
  }
  // Keep each family finite while crossing the revised compilation and path
  // rules with empty/error streams, multiple results, and early consumers.
  const rhs = ['empty', '(1,2)', '(.k // 3)', '(1,error("rhs"))'];
  for (const source of [{}, { a: null, b: false, k: 4 }, { a: 1, b: 2, k: 5 }]) {
    for (const path of ['.a', '(.a,.b)', '(.a,.a)']) {
      for (const expression of rhs) {
        for (const operator of ['//=', '+=', '|=']) {
          const update = `${path} ${operator} (${expression})`;
          yield [update, source];
          yield [`first(${update})`, source];
        }
      }
    }
  }
  const bounds = ['empty', '(0,1)', '(2,3)', 'error("bound")'];
  for (const start of bounds) {
    for (const end of bounds) {
      for (const step of ['1', '(1,2)', 'empty', 'error("step")']) {
        yield [`range(${start};${end};${step})`, null];
      }
      yield [`range(${start};${end})`, null];
    }
  }
  for (const argument of ['.', '(.+1)', '(1,2)', 'empty', '(1,error("arg"))']) {
    for (const body of [
      '[$x,x]', '10 | x', 'def x: 42; [$x,x]',
      'def saved: x; def x: 42; [$x,saved,x]',
    ]) {
      yield [`def f($x): ${body}; 1 | f(${argument})`, null];
    }
    yield [`def f(x): def x: 42; x; f(${argument})`, null];
    yield [`def f($x;$y): [$x,$y,x,y]; f(${argument};(3,4))`, 1];
  }
  const trees = [null, false, true, 1, 'abc', [null, 1], [false, true],
    [{ a: null }, { a: 2 }], { a: null }, { a: [1, { b: 'abc' }] }];
  for (const container of trees) {
    for (const item of trees) {
      yield [`contains(${JSON.stringify(item)})`, container];
      yield [`inside(${JSON.stringify(container)})`, item];
    }
  }
  const fields = { a: { x: 1, y: null }, k: 'x', keys: ['x', 'y'] };
  for (const key of ['.k', '.keys[]', 'empty', '(.k,error("key"))']) {
    const access = `.a."\\(${key})"`;
    yield [access, fields];
    yield [`path(${access})`, fields];
    for (const expression of ['empty', '(8,9)', '(.k // 3)']) {
      yield [`${access} //= ${expression}`, fields];
      yield [`${access} = ${expression}`, fields];
    }
  }
  const paths = ['.[0:3]', '.[1:4][0]', '.[0:3][-1]',
    '.[1:4][]', '.[0:3][1:2][]', '.[0:3][0:1]'];
  for (const source of [null, [], [0, 1, 2, 3, 4]]) {
    for (const path of paths) {
      for (const expression of ['[8,9]', '1', 'empty']) {
        yield [`${path} = ${expression}`, source];
      }
      yield [`${path} |= empty`, source];
      for (const other of paths) {
        yield [`(${path},${other}) |= empty`, source];
      }
    }
  }
}

// JSON objects compare without regard to key order; numeric -0 equals 0.
function equalJson(a, b) {
  if (a === b) return true;
  if (a === null || b === null || typeof a !== 'object' || typeof b !== 'object') return false;
  if (Array.isArray(a) !== Array.isArray(b)) return false;
  const keys = Object.keys(a);
  return keys.length === Object.keys(b).length &&
    keys.every(key => Object.hasOwn(b, key) && equalJson(a[key], b[key]));
}

// Keep the existing readable JSON literals in the generated MoonBit tests.
function inlineJson(value) {
  if (Array.isArray(value)) return `[${value.map(inlineJson).join(', ')}]`;
  if (value !== null && typeof value === 'object') {
    return `{${Object.entries(value).map(([key, item]) => `${JSON.stringify(key)}: ${inlineJson(item)}`).join(', ')}}`;
  }
  return JSON.stringify(value);
}

function writeMoon(cases) {
  let source = `///|
// Generated exclusively from tests/semantics/jq-1.7.1.json by reference.mjs.
fn reference_case(query : String, input : String, expected : String, status : Int) -> Unit raise {
  let compiled = @moonjq.parse(query) catch {
    _ => { assert_eq(status, 3, msg=query); return }
  }
  assert_true(status != 3, msg=query)
  let stream = compiled.eval(@json.parse(input))
  let outputs : Array[Json] = []
  let mut actual_status = 0
  for event in stream {
    match event {
      Ok(v) => outputs.push(v)
      Err(_) => { actual_status = 5; assert_true(stream.next() is None, msg=query); break }
    }
  }
  assert_eq(Json::array(outputs), @json.parse(expected), msg=query)
  assert_eq(actual_status, status, msg=query)
}
`;
  for (const [i, test] of cases.entries()) {
    const name = `reference jq 1.7.1 ${String(i).padStart(3, '0')}: ${test.tag}`;
    source += `\n///|\ntest ${JSON.stringify(name)} {\n`;
    source += `  reference_case(${JSON.stringify(test.query)}, ` +
      `${JSON.stringify(inlineJson(test.input))}, ` +
      `${JSON.stringify(inlineJson(test.outputs))}, ${test.status})\n}\n`;
  }
  writeFileSync(moonPath, source);
}

function main() {
  const args = options();
  const fixture = JSON.parse(readFileSync(fixturePath, 'utf8'));
  if (args.reference) {
    const result = run([args.reference, '--version']);
    if (result.status !== 0) throw new Error(`${args.reference} --version exited ${result.status}`);
    const version = result.stdout.trim();
    if (version !== 'jq-1.7.1') usageError(`Expected jq-1.7.1, got ${version}`);
  }
  const implementation = args.implementation
    ? (args['wasm-runner'] ? [args['wasm-runner'], args.implementation, '--'] : [args.implementation])
    : null;
  const failures = [];
  let count = 0;
  for (const test of fixture.cases) {
    if (args.reference && (args.refresh || args['check-reference'])) {
      const observed = invoke([args.reference], test.query, test.input);
      if (args.refresh) {
        Object.assign(test, observed);
      } else if (['outputs', 'status', 'error_prefix'].some(key => !equalJson(observed[key], test[key]))) {
        failures.push(['reference drift', test, observed]);
      }
    }
    if (implementation) {
      const observed = invoke(implementation, test.query, test.input);
      if (['outputs', 'status'].some(key => !equalJson(observed[key], test[key]))) {
        failures.push(['implementation', test, observed]);
      } else if ([3, 5].includes(test.status) && !observed.error_prefix) {
        failures.push(['missing diagnostic', test, observed]);
      }
      count++;
    }
  }
  if (args.generate) {
    for (const [query, input] of generatedCases()) {
      const reference = invoke([args.reference], query, input);
      const observed = invoke(implementation, query, input);
      if (['outputs', 'status'].some(key => !equalJson(reference[key], observed[key]))) {
        failures.push(['generated', { query, input, ...reference }, observed]);
      }
      count++;
    }
  }
  if (args.refresh) {
    fixture.sha256 = createHash('sha256').update(readFileSync(args.reference)).digest('hex');
    writeFileSync(fixturePath, `${JSON.stringify(fixture, null, 2)}\n`);
  }
  if (args['write-moon']) writeMoon(fixture.cases);
  for (const [category, expected, observed] of failures) {
    console.log(category, JSON.stringify({ expected, observed }));
  }
  console.log(`${count} implementation comparisons; ${failures.length} failures`);
  process.exitCode = failures.length ? 1 : 0;
}

try {
  main();
} catch (error) {
  console.error(`reference.mjs: ${error.message}`);
  process.exitCode = 1;
}

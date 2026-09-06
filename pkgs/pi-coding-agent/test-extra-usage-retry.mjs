import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdtempSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const piBinary = resolve(process.argv[2]);
const expectUnpatched = process.argv.includes("--expect-unpatched");
const fixture = fileURLToPath(new URL("./retry-test-provider.ts", import.meta.url));
const testRoot = mkdtempSync(join(tmpdir(), "pi-extra-usage-retry-"));

for (const mode of expectUnpatched ? ["transient"] : ["transient", "persistent", "partial", "quota", "disabled"]) {
	const directory = join(testRoot, mode);
	const profile = join(directory, "profile");
	mkdirSync(profile, { recursive: true });
	writeFileSync(join(profile, "settings.json"), JSON.stringify({
		retry: { enabled: mode !== "disabled", maxRetries: 3, baseDelayMs: 10 },
	}));
	const traceFile = join(directory, "requests.jsonl");
	const result = spawnSync(piBinary, [
		"--extension", fixture, "--provider", "anthropic", "--model", "retry-test",
		"--print", "--no-session", "Exercise the tool continuation.",
	], {
		cwd: directory,
		env: { ...process.env, PI_CODING_AGENT_DIR: profile,
			PI_RETRY_TEST_MODE: mode, PI_RETRY_TEST_TRACE: traceFile },
		encoding: "utf8", timeout: 30000,
	});
	assert.ifError(result.error);
	const trace = readFileSync(traceFile, "utf8").trim().split("\n").map(JSON.parse);
	const shouldRecover = !expectUnpatched && mode === "transient";
	assert.equal(result.status, shouldRecover ? 0 : 1, result.stderr);
	assert.equal(readFileSync(join(directory, "tool-executions.txt"), "utf8"), "executed\n",
		"The completed tool must execute exactly once, including across retries.");
	assert.equal(trace.length, shouldRecover ? 3 : mode === "persistent" ? 5 : 2,
		"Retry count must obey the configured budget and terminal-error rules.");
	if (trace.length > 2) {
		assert.ok(trace.slice(2).every(entry => entry.contextDigest === trace[1].contextDigest),
			"Retries must preserve the failed request context, including the completed tool result.");
	}
	if (shouldRecover) assert.match(result.stdout, /RECOVERED/);
	else assert.match(result.stderr, /extra usage|Quota exceeded/);
	console.log(`${mode}: passed (${trace.length} requests, tool executed once)`);
}
console.log(`Diagnostic artifacts: ${testRoot}`);

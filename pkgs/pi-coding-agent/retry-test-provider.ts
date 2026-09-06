import { appendFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { createAssistantMessageEventStream } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// Local-only CLI fixture: no network requests or real credentials are used.
export default function (pi: ExtensionAPI) {
	let requestCount = 0;
	pi.registerProvider("anthropic", {
		baseUrl: "http://127.0.0.1:1",
		apiKey: "local-retry-test",
		api: "anthropic-messages",
		models: [{
			id: "retry-test",
			name: "Local retry test",
			reasoning: false,
			input: ["text"],
			cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
			contextWindow: 200000,
			maxTokens: 1024,
		}],
		streamSimple(model, context) {
			requestCount++;
			appendFileSync(process.env.PI_RETRY_TEST_TRACE!, JSON.stringify({
				requestCount,
				contextDigest: createHash("sha256").update(JSON.stringify(context)).digest("hex"),
			}) + "\n");
			const stream = createAssistantMessageEventStream();
			const message = {
				role: "assistant" as const,
				api: model.api,
				provider: model.provider,
				model: model.id,
				content: [],
				usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, totalTokens: 0,
					cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 } },
				timestamp: Date.now(),
			};
			if (requestCount === 1) {
				const completed = { ...message, stopReason: "toolUse" as const, content: [{
					type: "toolCall" as const, id: "write-marker", name: "bash",
					arguments: { command: "printf 'executed\\n' >> tool-executions.txt" },
				}] };
				stream.push({ type: "done", reason: "toolUse", message: completed });
			} else if (requestCount === 2 || process.env.PI_RETRY_TEST_MODE === "persistent") {
				const errorMessage = process.env.PI_RETRY_TEST_MODE === "quota"
					? '400 {"error":{"type":"insufficient_quota","message":"Quota exceeded"}}'
					: '400 {"type":"error","error":{"type":"invalid_request_error","message":"You\'re out of extra usage. Add more at claude.ai/settings/usage and keep going."}}';
				const content = process.env.PI_RETRY_TEST_MODE === "partial"
					? [{ type: "text" as const, text: "Partial response" }] : [];
				stream.push({ type: "error", reason: "error", error: {
					...message, content, stopReason: "error", errorMessage,
				} });
			} else {
				stream.push({ type: "done", reason: "stop", message: {
					...message, stopReason: "stop", content: [{ type: "text", text: "RECOVERED" }],
				} });
			}
			stream.end();
			return stream;
		},
	});
}

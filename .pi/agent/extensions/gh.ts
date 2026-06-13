/**
 * GitHub CLI (gh) Tool Extension
 * 
 * This tool provides a structured interface to the GitHub CLI, prioritizing 
 * token efficiency via JSON filtering, providing safety gates for mutations, 
 * and handling log truncation for Actions.
 */

import { mkdtemp, writeFile } from "node:fs/promises";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
	DEFAULT_MAX_BYTES,
	DEFAULT_MAX_LINES,
	formatSize,
	truncateHead,
	withFileMutationQueue,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { execSync } from "child_process";
import { tmpdir } from "os";
import { join } from "path";
import { Type } from "typebox";

// Define the supported actions to provide the LLM with a clear API
const GhAction = Type.StringEnum({
	issue_view: "issue_view",
	issue_list: "issue_list",
	issue_edit: "issue_edit",
	pr_view: "pr_view",
	pr_list: "pr_list",
	pr_create: "pr_create",
	run_view: "run_view", // View Action run details
	run_log: "run_log",   // View Action run logs
});

const GhParams = Type.Union([
	// View a specific issue
	Type.Object({
		action: Type.Literal("issue_view"),
		issueId: Type.String({ description: "Issue number" }),
	}),
	// List issues
	Type.Object({
		action: Type.Literal("issue_list"),
		limit: Type.Optional(Type.Number({ default: 10 })),
	}),
	// Edit an issue (Mutation - requires confirmation)
	Type.Object({
		action: Type.Literal("issue_edit"),
		issueId: Type.String({ description: "Issue number" }),
		body: Type.Optional(Type.String({ description: "New body text" })),
		title: Type.Optional(Type.String({ description: "New title" })),
	}),
	// View a specific PR
	Type.Object({
		action: Type.Literal("pr_view"),
		prId: Type.String({ description: "PR number" }),
	}),
	// List PRs
	Type.Object({
		action: Type.Literal("pr_list"),
		limit: Type.Optional(Type.Number({ default: 10 })),
	}),
	// Create a PR (Mutation - requires confirmation)
	Type.Object({
		action: Type.Literal("pr_create"),
		title: Type.String({ description: "PR Title" }),
		body: Type.String({ description: "PR Body" }),
		base: Type.Optional(Type.String({ description: "Base branch (default: main/master)" })),
	}),
	// View run status
	Type.Object({
		action: Type.Literal("run_view"),
		runId: Type.String({ description: "Run ID" }),
	}),
	// View run logs (Heavy output - requires truncation)
	Type.Object({
		action: Type.Literal("run_log"),
		runId: Type.String({ description: "Run ID" }),
	}),
]);

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "gh",
		label: "GitHub",
		description: "Interact with GitHub issues, PRs, and Actions. Mutations require user confirmation. Logs are truncated.",
		parameters: GhParams,

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const { action } = params;

			// 1. Safety Gate: Confirm mutations
			if (action === "pr_create" || action === "issue_edit") {
				const summary = action === "pr_create" 
					? `Create Pull Request: "${(params as any).title}"` 
					: `Edit Issue #${(params as any).issueId}`;
				
				const confirmed = await ctx.ui.confirm("GitHub Mutation", `Allow pi to ${summary}?`);
				if (!confirmed) {
					return { content: [{ type: "text", text: "User declined the GitHub mutation." }] };
				}
			}

			// 2. Build the command based on action
			let command = "";
			let needsTruncation = false;

			switch (action) {
				case "issue_view":
					command = `gh issue view ${(params as any).issueId} --json title,body,state,labels`;
					break;
				case "issue_list":
					command = `gh issue list --limit ${(params as any).limit ?? 10} --json number,title,state`;
					break;
				case "issue_edit": {
					const p = params as any;
					const args = [];
					if (p.title) args.push(`--title "${p.title}"`);
					if (p.body) args.push(`--body "${p.body}"`);
					command = `gh issue edit ${p.issueId} ${args.join(" ")}`;
					break;
				}
				case "pr_view":
					command = `gh pr view ${(params as any).prId} --json title,body,state,headRefOid`;
					break;
				case "pr_list":
					command = `gh pr list --limit ${(params as any).limit ?? 10} --json number,title,state`;
					break;
				case "pr_create": {
					const p = params as any;
					const base = p.base ? `--base ${p.base}` : "";
					command = `gh pr create --title "${p.title}" --body "${p.body}" ${base}`;
					break;
				}
				case "run_view":
					command = `gh run view ${(params as any).runId} --json conclusion,status,createdAt`;
					break;
				case "run_log":
					command = `gh run view ${(params as any).runId} --log`;
					needsTruncation = true;
					break;
			}

			// 3. Execute
			let output: string;
			try {
				output = execSync(command, {
					cwd: ctx.cwd,
					encoding: "utf-8",
					maxBuffer: 100 * 1024 * 1024, // 100MB buffer for logs
				});
			} catch (err: any) {
				throw new Error(`GitHub CLI failed: ${err.message}\nCommand: ${command}`);
			}

			if (!output.trim()) {
				return { content: [{ type: "text", text: "No output returned from GitHub." }] };
			}

			// 4. Post-processing (Truncation or JSON formatting)
			if (needsTruncation) {
				const truncation = truncateHead(output, {
					maxLines: DEFAULT_MAX_LINES,
					maxBytes: DEFAULT_MAX_BYTES,
				});

				let resultText = truncation.content;
				if (truncation.truncated) {
					const tempDir = await mkdtemp(join(tmpdir(), "pi-gh-"));
					const tempFile = join(tempDir, "gh-log.txt");
					await withFileMutationQueue(tempFile, async () => {
						await writeFile(tempFile, output, "utf8");
					});

					resultText += `\n\n[Logs truncated: showing ${truncation.outputLines} of ${truncation.totalLines} lines.`;
					resultText += ` Full logs saved to: ${tempFile}]`;
				}
				return { content: [{ type: "text", text: resultText }] };
			}

			// For JSON responses, we return them as is, but the LLM prefers them 
			// formatted or simply as raw JSON which is token-efficient.
			return { content: [{ type: "text", text: output }] };
		},

		renderCall(args, theme, _context) {
			let text = theme.fg("toolTitle", theme.bold("gh "));
			text += theme.fg("accent", args.action);
			
			if ((args as any).issueId) text += theme.fg("muted", ` #${(args as any).issueId}`);
			if ((args as any).prId) text += theme.fg("muted", ` #${(args as any).prId}`);
			if ((args as any).runId) text += theme.fg("muted", ` Run ${(args as any).runId}`);
			if ((args as any).title) text += theme.fg("dim", ` "${(args as any).title}"`);

			return new Text(text, 0, 0);
		},

		renderResult(result, { expanded, isPartial }, theme, _context) {
			if (isPartial) return new Text(theme.fg("warning", "Calling GitHub..."), 0, 0);

			const content = result.content[0];
			if (!content || content.type !== "text") return new Text(theme.fg("dim", "No result"), 0, 0);

			if (!expanded) {
				const firstLine = content.text.split("\n")[0];
				const display = firstLine.length > 60 ? firstLine.slice(0, 60) + "..." : firstLine;
				return new Text(theme.fg("success", `GH: ${display}`), 0, 0);
			}

			// In expanded view, we just show the start of the output
			const lines = content.text.split("\n").slice(0, 10);
			let text = "";
			for (const line of lines) {
				text += `\n${theme.fg("dim", line)}`;
			}
			if (content.text.split("\n").length > 10) {
				text += `\n${theme.fg("muted", "... (truncated in TUI)")}`;
			}
			return new Text(text, 0, 0);
		},
	});
}

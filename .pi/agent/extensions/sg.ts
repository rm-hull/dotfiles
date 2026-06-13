/**
 * ast-grep (sg) Tool Extension
 * 
 * This tool provides structural search capabilities using ast-grep.
 * Unlike ripgrep (rg) which searches for text, sg searches for 
 * code structures (AST), making it ideal for finding function calls,
 * class definitions, and structural patterns regardless of formatting.
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

const SgParams = Type.Object({
	pattern: Type.String({ description: "Structural pattern to search for (e.g., 'func $NAME($ARGS) { $$$ })'" }),
	lang: Type.String({ description: "Language of the code (e.g., 'ts', 'tsx', 'python', 'go', 'rust')" }),
	path: Type.Optional(Type.String({ description: "Directory to search (default: current directory)" })),
	glob: Type.Optional(Type.String({ description: "File glob pattern, e.g. '*.ts'" })),
});

interface SgDetails {
	pattern: string;
	lang: string;
	path?: string;
	glob?: string;
	matchCount: number;
	truncation?: any;
	fullOutputPath?: string;
}

export default function (pi: ExtensionAPI) {
	pi.registerTool({
		name: "sg",
		label: "ast-grep",
		description: `Perform structural code search using ast-grep. Use this instead of rg when searching for code symbols, function calls, or patterns where formatting/whitespace should be ignored. Output is truncated to ${DEFAULT_MAX_LINES} lines or ${formatSize(DEFAULT_MAX_BYTES)}.`,
		parameters: SgParams,

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			const { pattern, lang, path: searchPath, glob } = params;

			// Build the ast-grep scan command
			// --pattern: the search pattern
			// --lang: the language to use for parsing
			const args = ["sg", "scan", "--pattern", `"${pattern}"`, "--lang", lang, "--color=never"];
			
			if (glob) args.push("--glob", glob);
			if (searchPath) args.push(searchPath);
			else args.push(".");

			let output: string;
			try {
				output = execSync(args.join(" "), {
					cwd: ctx.cwd,
					encoding: "utf-8",
					maxBuffer: 100 * 1024 * 1024,
				});
			} catch (err: any) {
				// ast-grep might exit with non-zero if no matches are found or on parse error
				if (err.status === 1 || err.message.includes("no matches")) {
					return {
						content: [{ type: "text", text: "No structural matches found" }],
						details: { pattern, lang, path: searchPath, glob, matchCount: 0 } as SgDetails,
					};
				}
				throw new Error(`ast-grep failed: ${err.message}`);
			}

			if (!output.trim()) {
				return {
					content: [{ type: "text", text: "No matches found" }],
					details: { pattern, lang, path: searchPath, glob, matchCount: 0 } as SgDetails,
				};
			}

			const truncation = truncateHead(output, {
				maxLines: DEFAULT_MAX_LINES,
				maxBytes: DEFAULT_MAX_BYTES,
			});

			const matchCount = output.split("\n").filter((line) => line.trim()).length;

			const details: SgDetails = {
				pattern,
				lang,
				path: searchPath,
				glob,
				matchCount,
			};

			let resultText = truncation.content;

			if (truncation.truncated) {
				const tempDir = await mkdtemp(join(tmpdir(), "pi-sg-"));
				const tempFile = join(tempDir, "output.txt");
				await withFileMutationQueue(tempFile, async () => {
					await writeFile(tempFile, output, "utf8");
				});

				details.truncation = truncation;
				details.fullOutputPath = tempFile;

				resultText += `\n\n[Output truncated: showing ${truncation.outputLines} of ${truncation.totalLines} lines`;
				resultText += ` (${formatSize(truncation.outputBytes)} of ${formatSize(truncation.totalBytes)}).`;
				resultText += ` Full output saved to: ${tempFile}]`;
			}

			return {
				content: [{ type: "text", text: resultText }],
				details,
			};
		},

		renderCall(args, theme, _context) {
			let text = theme.fg("toolTitle", theme.bold("sg "));
			text += theme.fg("accent", `"${args.pattern}"`);
			text += theme.fg("muted", ` [${args.lang}]`);
			if (args.path) text += theme.fg("dim", ` in ${args.path}`);
			return new Text(text, 0, 0);
		},

		renderResult(result, { expanded, isPartial }, theme, _context) {
			const details = result.details as SgDetails | undefined;

			if (isPartial) {
				return new Text(theme.fg("warning", "Analyzing AST..."), 0, 0);
			}

			if (!details || details.matchCount === 0) {
				return new Text(theme.fg("dim", "No structural matches"), 0, 0);
			}

			let text = theme.fg("success", `${details.matchCount} matches`);

			if (details.truncation?.truncated) {
				text += theme.fg("warning", " (truncated)");
			}

			if (expanded) {
				const content = result.content[0];
				if (content?.type === "text") {
					const lines = content.text.split("\n").slice(0, 20);
					for (const line of lines) {
						text += `\n${theme.fg("dim", line)}`;
					}
				}

				if (details.fullOutputPath) {
					text += `\n${theme.fg("dim", `Full output: ${details.fullOutputPath}`)}`;
				}
			}

			return new Text(text, 0, 0);
		},
	});
}

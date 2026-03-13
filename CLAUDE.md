# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Environment

This is **spark2** (hostname: spark-2e06), a DGX Spark GPU machine.

- **Tailscale IP**: 100.67.176.85
- **spark1 Tailscale IP**: 100.88.90.82

Local AI services running here:
- **Ollama** on port 11434 — model: `qwen3:32b`
- **vLLM** on port 8001

Access from laptop via Tailscale: `http://100.67.176.85:<port>/v1`

## Primary Project: openclaw

Main project lives at `~/openclaw/`. It already has a full `AGENTS.md` / `CLAUDE.md` (symlinked). When working inside that directory, those instructions apply.

**OpenClaw** is a multi-channel AI gateway: TypeScript/ESM, pnpm workspace, Node 22+. Runs as a CLI (`openclaw`) and as desktop/mobile apps.

Key commands (run from `~/openclaw/`):
- `pnpm install` — install deps
- `pnpm build` — typecheck + build
- `pnpm check` — lint + format check + typecheck
- `pnpm test` — run tests (Vitest)
- `pnpm openclaw ...` — run CLI in dev mode
- `scripts/committer "<msg>" <file...>` — create scoped commits

Source layout:
- `src/` — CLI wiring, commands, channels (telegram, discord, slack, signal, imessage, web/WhatsApp), routing, agents, gateway
- `extensions/` — channel plugins (msteams, matrix, zalo, voice-call, etc.)
- `apps/` — android, ios, macos, shared native apps
- `skills/` — built-in skills
- `docs/` — Mintlify docs (hosted at docs.openclaw.ai)
- `dist/` — build output

## Other Projects

- `~/iquest-chatbot/` — chatbot project (separate)
- `~/projects/` — miscellaneous projects
- `~/openclaw-data/` — data files
- `~/openclaw-presentation/` — demo/presentation materials

## Infrastructure Scripts

- `~/monitor-and-fix-spark1.sh` — monitor/fix spark1
- `~/setup-openclaw-whatsapp.sh` — WhatsApp setup
- `~/ollama-cursor-proxy.py` — Ollama proxy for Cursor integration
- `~/dgx-spark-playbooks/` — Ansible playbooks for DGX Spark setup

## Config

- openclaw credentials: `~/.openclaw/credentials/`
- openclaw sessions/logs: `~/.openclaw/agents/<agentId>/sessions/*.jsonl`
- Run `openclaw doctor` for rebrand/migration issues

# claude-md-doctor

CLAUDE.md 감사·최적화 스킬 소스 레포.

## 편집 규칙

- **편집 대상**: `SKILL.md`, `references/rubric.md`, `references/sources.md` — 여기서만 수정
- **배포본** (`~/.claude/skills/claude-md-doctor/`) 직접 편집 금지 — `install.sh`가 덮어씀

## Skill deployment

이 레포가 `/claude-md-doctor` 스킬의 canonical source. `bash install.sh`로 SKILL.md + references를 `~/.claude/skills/claude-md-doctor/`에 배포한다. `~/projects/custom-skills/setup.sh`는 더 이상 이 스킬을 다루지 않는다.

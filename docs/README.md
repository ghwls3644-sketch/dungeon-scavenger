---
id: DOCS-INDEX
title: 폐던전 수색꾼 문서 안내
document_type: project
status: draft
source_version: gdd-v2.1+management-proposal-v0.2.1
canonical_for:
  - document_navigation
  - canonical_source_routing
last_reviewed:
owner: documentation-maintainer
related:
  - GDD.md
  - story/README.md
  - design/README.md
  - reference/README.md
  - project/README.md
---

# 폐던전 수색꾼 문서 안내

이 디렉터리는 게임 개발에 사용하는 활성 문서와 원본 아카이브를 관리한다.

## 영역별 진입점

| 영역 | 답하는 질문 | 진입점 |
|---|---|---|
| GDD | 어떤 게임이며 시스템이 어떻게 연결되는가? | [`GDD.md`](GDD.md) |
| Story | 세계에서 무엇이 사실이고 왜 그런가? | [`story/README.md`](story/README.md) |
| Design | 플레이어에게 어떤 규칙과 데이터로 작동하는가? | [`design/README.md`](design/README.md) |
| Reference | 무엇이라 부르고 어디에서 찾는가? | [`reference/README.md`](reference/README.md) |
| Project | 무엇을 확정했고 무엇이 미정이며 어떻게 이관하는가? | [`project/README.md`](project/README.md) |
| Archive | 이전 시점의 원본은 무엇인가? | [`archive/README.md`](archive/README.md) |

## 작업 진입점

- 문서 이관 현황: [`project/migration_manifest.md`](project/migration_manifest.md)
- 스토리 원본 상세 인벤토리: [`project/story_v1.5_inventory.md`](project/story_v1.5_inventory.md)
- 분할 중 변경 대기열: [`project/migration_changes.md`](project/migration_changes.md)
- 결정과 미결정 사항: [`project/decisions.md`](project/decisions.md), [`project/open_questions.md`](project/open_questions.md)
- M2 Reference 검토 결과: [`project/m2_reference_review.md`](project/m2_reference_review.md)
- M4 공식 용어 검수 결과: [`project/m4_term_review.md`](project/m4_term_review.md)
- M4 Story·Design 중복 검수 결과: [`project/m4_story_design_review.md`](project/m4_story_design_review.md)

## 다른 환경에서 작업 이어가기

다른 컴퓨터나 장소에서는 GitHub의 `origin/main`과 저장소 문서를 작업 인계 기준으로 삼는다.

1. 저장소가 없다면 `git clone https://github.com/ghwls3644-sketch/dungeon-scavenger.git`으로 복제한다.
2. 저장소 루트에서 `git status`를 실행한다. 커밋하지 않은 변경이나 브랜치 분기가 보이면 이를 버리지 말고 먼저 확인한다.
3. 작업 트리가 깨끗하면 `git pull --ff-only origin main`으로 최신 내용을 받는다.
4. `git log -1 --oneline`으로 현재 커밋을 확인한다.
5. 루트의 [`AGENTS.md`](../AGENTS.md)와 이 문서를 읽고, [`project/migration_manifest.md`](project/migration_manifest.md)에서 현재 단계와 다음 티켓을 확인한다.
6. Codex에는 “`AGENTS.md`와 `docs/README.md`, 이관 현황을 읽고 다음 티켓부터 계속 진행해”라고 요청한다.
7. 티켓을 완료하면 검증 결과를 확인한 뒤 커밋·푸시 여부를 승인한다. 두 장소에서 동시에 `main`을 수정하지 않는다.

GitHub 로그인 상태, Codex 대화 기록, 앱별 로컬 설정은 저장소에 포함되지 않으므로 새 환경에서 별도로 준비한다.

## 원본 보존 규칙

- `../게임 기획 파일/`은 이관이 끝날 때까지 원본 보관 위치로 유지한다.
- 원본은 직접 편집하거나 삭제하지 않는다.
- 활성 문서에 반영할 변경은 먼저 `project/migration_changes.md`에 기록한다.
- `archive/`의 문서는 근거 확인과 누락 검수에만 사용하며 현재 설정으로 인용하지 않는다.
- 문서 간 내용이 충돌하면 `GDD.md`의 "자료 충돌 시 우선순위"를 따른다.

## 현재 단계

검토 관문 G-M3를 통과하고 문서 분할 단계 `M3 — 1차 구조 이관`을 완료했다. `M4 — 세계관과 구현 규칙 분리`의 `DOC-0501`~`DOC-0503`에서 공식 용어와 Story·Design 상세 정의를 검수하고 단일 출처 구조로 전환했다. Glossary는 근거가 확정된 19개 항목을 가지며, Story·Design 교차 중복 9건과 Story 내부 중복 1건은 상세 기준과 요약 링크를 분리했다. 다음 티켓은 `DOC-0504` 화자 표현과 NPC 지식 정합성 검토다. 신규 문서는 최종 전환 전까지 `draft`다.

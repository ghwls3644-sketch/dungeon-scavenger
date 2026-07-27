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
- 공식 용어 검수 결과: [`project/m4_term_review.md`](project/m4_term_review.md)
- Story·Design 중복 검수 결과: [`project/m4_story_design_review.md`](project/m4_story_design_review.md)
- 화자 표현·NPC 지식 검수 결과: [`project/m4_speaker_knowledge_review.md`](project/m4_speaker_knowledge_review.md)
- 핵심 설정·Entity·Timeline 검수 결과: [`project/m5_core_entity_timeline_review.md`](project/m5_core_entity_timeline_review.md)

## 다른 환경에서 작업 이어가기

다른 컴퓨터나 장소에서는 GitHub의 `origin/main`과 저장소 문서를 작업 인계 기준으로 삼는다.

1. 저장소가 없다면 `git clone https://github.com/ghwls3644-sketch/dungeon-scavenger.git`으로 복제한다.
2. 저장소 루트에서 `git status`를 실행한다. 커밋하지 않은 변경이나 브랜치 분기가 보이면 이를 버리지 말고 먼저 확인한다.
3. 작업 트리가 깨끗하면 `git pull --ff-only origin main`으로 최신 내용을 받는다.
4. `git log -1 --oneline`으로 현재 커밋을 확인한다.
5. 루트의 [`AGENTS.md`](../AGENTS.md)와 이 문서를 읽고, [`project/migration_manifest.md`](project/migration_manifest.md)에서 현재 단계와 다음 티켓을 확인한다.
6. Codex에는 “`AGENTS.md`와 `docs/README.md`, 이관 현황을 읽고 다음 티켓부터 계속 진행해”라고 요청한다.
7. 티켓을 완료하면 검증 결과를 확인한 뒤 해당 티켓의 로컬 커밋 여부를 승인한다.
8. 완료한 티켓 커밋은 로컬에 모아 두고, 사용자가 현재 작업 묶음의 종료를 선언하거나 명시적으로 push를 요청할 때만 `origin/main`에 push한다. 두 장소에서 동시에 `main`을 수정하지 않는다.

GitHub 로그인 상태, Codex 대화 기록, 앱별 로컬 설정은 저장소에 포함되지 않으므로 새 환경에서 별도로 준비한다.

## 정합성 검사 알림

여러 날짜와 장소에서 작업을 이어갈 때 진행 방향이 달라지지 않도록, 다음 단계로 넘어가기 전에 정합성 검사가 필요한 시점을 저장소에 기록한다. 여기서 정합성 검사는 지금까지 완료한 작업, 현재 기준과 다음 작업이 처음 계획대로 서로 맞는지 검사하는 작업이다.

검사 시점이 오면 완료 보고 첫머리에 아래 문구를 쓰고, 바로 뒤에 이번에 검사할 대상을 한 문장으로 설명한다.

> ⛔ **정합성 검사할 때입니다 — 완료한 작업, 현재 기준과 다음 작업이 서로 맞는지 검사합니다.**

이 표시는 오류가 발생했다는 뜻이 아니다. 검사 결과를 사용자에게 보고하고 계속 진행하라는 지시를 받기 전에는 다음 티켓을 시작하지 않는다.

| 검사 시점 | 검사할 내용 | 검사 통과 후 다음 작업 |
|---|---|---|
| `DOC-0505` 시작 전 | 완료 티켓과 커밋, 현재 단계, M4·M5 명칭과 작업 범위, 다음 티켓이 서로 일치하는지 확인 | `DOC-0505` |
| `DOC-0505` 완료 후 | 핵심 설정·Entity·Timeline 충돌이 모두 해결되었거나 열린 질문으로 분리되었는지 확인 | `DOC-0506` |
| `DOC-0506` 완료 후 | 링크·누락 검사 결과와 M5 전체 완료 조건을 확인 | G-M5 검토 후 `DOC-0601` |
| `DOC-0601` 완료 후 | 사람 검토 후보, 미결정 표기와 문서 상태 승격 범위를 확인 | 승인 후 `DOC-0602` |
| `DOC-0603` 완료 후 | 새 기준 문서와 AGENTS 작업 규칙만으로 다른 환경에서 개발을 시작할 수 있는지 확인 | 개발 티켓 시작 |
| `DEV-0006`, `DEV-0107`, `G2`, `G5`, `G6`, `G8` 도달 시 | 테스트·로그 기반, 첫 핵심 루프, 전체 제품 순환, 반복 상태, 저장 복구, 출시 회귀 검사를 각 단계에 맞게 확인 | 해당 개발 관문의 다음 작업 |

평상시 티켓 완료 보고에도 `정합성 검사: 지금` 또는 `정합성 검사: 아직 아님`을 적어 다음 검사 시점을 놓치지 않게 한다.

## 원본 보존 규칙

- `../게임 기획 파일/`은 이관이 끝날 때까지 원본 보관 위치로 유지한다.
- 원본은 직접 편집하거나 삭제하지 않는다.
- 활성 문서에 반영할 변경은 먼저 `project/migration_changes.md`에 기록한다.
- `archive/`의 문서는 근거 확인과 누락 검수에만 사용하며 현재 설정으로 인용하지 않는다.
- 문서 간 내용이 충돌하면 `GDD.md`의 "자료 충돌 시 우선순위"를 따른다.

## 현재 단계

검토 관문 G-M3와 G-M4를 통과했다. `M3 — 1차 구조 이관`과 `M4 — 세계관과 구현 규칙 분리`를 완료했으며, Story는 세계관 이유·NPC 지식·정보 내용을, Design은 상태·조건·처리·계산을, Reference는 공식 명칭과 화자 표현을 상세 소유한다.

현재는 `M5 — 중복 제거와 정합성 검토`를 진행 중이다. `DOC-0501`~`DOC-0504`에서 공식 용어, Story·Design 상세 정의와 화자 표현·NPC 지식을 검수했다. Glossary는 근거가 확정된 19개 항목을 가지며, Story·Design 중복 10건은 단일 출처 구조로 전환했다. 화자·집단 8개에서는 직접 표현·지식 충돌이 없었고 역할 경계·근거 링크 보완 후보 2건을 사람 검토 대상으로 분리했다.

`DOC-0505` 시작 전 정합성 검사는 완료했다. 완료 커밋과 결과물, 현재 단계와 다음 티켓은 서로 일치하며, 검사에서 발견한 M4·M5 단계 표기와 Git 인계 문구의 차이는 `MIG-CHG-002`로 정정했다.

`DOC-0505`에서 핵심 설정 10개, Entity 15개와 Timeline을 대조했다. Entity의 직접 충돌은 없었고 Story 역링크 3건을 보완했다. Timeline이 마왕 봉인과 던전 증가의 선후를 원본보다 강하게 확정한 모순 1건은 선후 미정으로 정정했다. 폐던전 범람 표현의 차이는 기존 `DEC-004`로 현재 기준을 확인했으며, 동결 GDD 문구 1건은 `DOC-0601` 사람 검토 대상으로 전달한다. 신규 문서는 최종 전환 전까지 `draft`다.

> ⛔ **정합성 검사할 때입니다 — `DOC-0505`에서 발견한 충돌이 해결되었거나 후속 사람 검토 대상으로 분리되었는지 확인한 뒤 `DOC-0506`을 시작합니다.**

다음 티켓은 `DOC-0506` 링크·누락 자동 검사지만, 위 정합성 검사 결과를 사용자에게 보고하고 계속 진행하라는 지시를 받기 전에는 시작하지 않는다.

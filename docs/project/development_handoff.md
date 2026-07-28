---
id: PROJECT-DEVELOPMENT-HANDOFF
title: 개발 문서 인계 안내
document_type: project
status: draft
source_version: development-proposal-v0.1+gdd-v2.1
canonical_for:
  - development_document_handoff
  - development_ticket_routing
last_reviewed:
owner: project-maintainer
related:
  - ../README.md
  - ../GDD.md
  - ../story/README.md
  - ../design/README.md
  - ../reference/README.md
  - decisions.md
  - open_questions.md
  - migration_manifest.md
  - ../../게임 기획 파일/게임 개발 단계별 제안서 v0.1.md
---

# 개발 문서 인계 안내

## 목적

동결된 [`게임 개발 단계별 제안서 v0.1`](<../../게임 기획 파일/게임 개발 단계별 제안서 v0.1.md>)의 단계·티켓 구조를 새 공식 Story·Design·Reference 문서와 연결한다. 원본 제안서는 수정하지 않으며, 개발 작업을 시작할 때는 이 안내에서 현재 기준 문서로 이동한다.

## 개발 작업 읽기 순서

1. 저장소 작업 규칙인 [`../../AGENTS.md`](../../AGENTS.md)를 읽는다.
2. 전체 문서 입구인 [`../README.md`](../README.md)에서 현재 단계와 정합성 검사 시점을 확인한다.
3. 제품과 시스템 연결은 [`../GDD.md`](../GDD.md)에서 확인한다.
4. 작업 규칙은 [`../design/README.md`](../design/README.md)에서 관련 `confirmed` Design 문서를 선택한다.
5. 세계관 이유와 표시 명칭이 필요하면 [`../story/README.md`](../story/README.md), [`../reference/README.md`](../reference/README.md)를 함께 읽는다.
6. 확정·미정 여부는 [`decisions.md`](decisions.md), [`open_questions.md`](open_questions.md)에서 확인한다.
7. 개발 단계와 기존 티켓 ID가 필요할 때만 동결 개발 제안서를 참고한다.

상세 내용이 다르면 최신 사용자 결정, 결정 기록, 해당 책임의 `confirmed` 문서, GDD 개요, 동결 제안서 순서로 판단한다. `provisional` 문서는 문서에 적힌 제한 범위에서만 사용하고 `draft` 문서는 단독 구현 기준으로 사용하지 않는다.

## 작업별 기준 문서

| 개발 작업 | 먼저 읽을 기준 | 함께 확인할 문서 |
|---|---|---|
| 제품 목표·핵심 루프·MVP 범위 | [`../GDD.md`](../GDD.md) | [`../story/00_core_pillars.md`](../story/00_core_pillars.md), [`decisions.md`](decisions.md) |
| 반복 탐험·방문 상태·퇴각 | [`../design/repeat_exploration.md`](../design/repeat_exploration.md) | [`../story/02_dungeon_canon.md`](../story/02_dungeon_canon.md), [`../reference/glossary.md`](../reference/glossary.md) |
| 아이템·감정·판매 보호·저장 상태 | [`../design/item_rules.md`](../design/item_rules.md) | [`../story/05_items_and_discoveries.md`](../story/05_items_and_discoveries.md), [`../reference/glossary.md`](../reference/glossary.md) |
| 정산·비용·실패 안전망 | [`../design/economy_rules.md`](../design/economy_rules.md) | [`../story/03_player_and_society.md`](../story/03_player_and_society.md), [`open_questions.md`](open_questions.md) |
| 발견·등록·NPC 반응·정보 노출 | [`../design/narrative_delivery.md`](../design/narrative_delivery.md) | [`../story/06_narrative_progression.md`](../story/06_narrative_progression.md), [`../reference/speaker_lexicon.md`](../reference/speaker_lexicon.md) |
| 이름·UI 표기·대사 어휘 | [`../reference/glossary.md`](../reference/glossary.md), [`../reference/speaker_lexicon.md`](../reference/speaker_lexicon.md) | 관련 Story·Design 문서 |
| 인물·조직·장소·사건 추적 | [`../reference/entity_index.md`](../reference/entity_index.md), [`../reference/timeline.md`](../reference/timeline.md) | 두 문서의 `provisional` 제한과 관련 Story 문서 |
| 하네스 | [`../GDD.md`](../GDD.md) 7장 | [`../design/harness_engineering.md`](../design/harness_engineering.md)는 상세 이관·검증 전 `draft`이므로 단독 구현 기준으로 사용하지 않음 |

## 기존 개발 단계와 연결

| 동결 제안서 범위 | 현재 문서에서 확인할 내용 |
|---|---|
| 단계 0, `DEV-0001`~`DEV-0006` | AGENTS 작업 규칙, 문서 입구, 결정·질문 기록, GDD 제품 개요와 테스트·로그 관문 |
| 단계 1, `DEV-0101`~`DEV-0107` | GDD 핵심 탐험 범위와 관련 Design 문서, Story 핵심 전제 |
| 단계 2, `DEV-0201`~`DEV-0206` | GDD 제품 흐름과 저장·상태 기준, 반복 탐험·아이템·경제 Design |
| 단계 3~5 | 위험·인벤토리·지도·거점·경제·반복 데이터에 해당하는 `confirmed` Design 문서 |
| 단계 6~8 | GDD의 제품 기능·접근성·출시 범위와 동결 제안서의 검토 관문 |
| 테스트 전략·위험·체크리스트 | 동결 제안서 7장·8장·부록 A와 [`../README.md`](../README.md)의 현재 정합성 검사 지점 |

동결 제안서의 단계와 티켓 ID는 개발 순서를 추적하는 참고 구조다. 실제 티켓을 시작할 때는 현재 저장소 상태와 해당 Design 문서의 확정·미정 범위를 다시 확인한다.

## 사용 제한

- 동결 제안서의 `스토리 정리 v1.5` 직접 참조는 현재 세부 기준으로 사용하지 않는다.
- `게임 기획 파일/`과 `docs/archive/`는 수정하지 않는다.
- Harness Engineering의 빈 상세 규칙을 추정으로 채우지 않는다.
- `open_questions.md`의 항목을 구현 편의를 이유로 임의 확정하지 않는다.
- 새 기능, 수치, 이름, 코드 ID 또는 저장 키는 해당 개발 티켓 범위와 승인 없이 추가하지 않는다.

## 현재 상태

`DOC-0603`에서 동결 개발 제안서의 단계·티켓 구조를 새 공식 문서 체계에 연결했다. 이 문서는 개발 작업의 탐색과 인계를 돕는 Project 문서이며, 게임 규칙의 상세 기준은 각 `confirmed` Story·Design·Reference 문서가 소유한다.

G-M6 통과 후 첫 개발 티켓은 `DEV-0001 — 프로젝트 컨텍스트 문서 생성`이다. 엔진·버전·플랫폼·언어와 실행·테스트 명령을 실제 저장소 상태에 맞게 기록하기 전에는 이후 구현 티켓을 시작하지 않는다.

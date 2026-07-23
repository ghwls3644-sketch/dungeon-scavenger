---
id: PROJECT-MIGRATION-MANIFEST
title: 문서 이관 대장
document_type: project
status: draft
source_version: story-v1.5
canonical_for:
  - migration_status
  - source_target_mapping
last_reviewed:
owner: documentation-maintainer
related:
  - story_v1.5_inventory.md
  - migration_changes.md
  - ../archive/README.md
---

# 문서 이관 대장

## 목적

원본 기획 문서의 보존 상태, 활성 기준 문서, 아카이브 사본과 후속 이관 위치를 추적한다.

스토리 원본의 103개 제목 항목과 32개 구조화 요소에 대한 상세 계획은 [`story_v1.5_inventory.md`](story_v1.5_inventory.md)에서 추적한다.

## 동결 기준

- 기준 일자: 2026-07-20
- Git 기준 커밋: `339ff50` (`docs: preserve original game planning documents`)
- 원본 위치: `게임 기획 파일/`
- 해시 알고리즘: SHA-256
- 정책: 원본은 이동·삭제·편집하지 않고, 활성 문서 또는 아카이브에 사본을 둔다.

## 원본 파일 대장

| ID | 원본 | SHA-256 | 현재 역할 | 대상 | 검증 |
|---|---|---|---|---|---|
| SRC-001 | `통합 게임 기획서 v2.1.md` | `45E92DFEDE482968B31C14EEF712012735AA9657DE18BD7C0922F94D40DD460A` | 최상위 제품·설계 기준 | `docs/GDD.md` | 바이트·해시 일치 |
| SRC-002 | `스토리 정리 v1.5.md` | `4191C100D5B3BFBEF291D3FD4D7588A3C5C31113A1827D33886CC8C90931292D` | 스토리 분할 원본 | `docs/archive/story_v1.5_full.md` | 바이트·해시 일치 |
| SRC-003 | `스토리 문서 분할 및 관리 제안서 v0.1.md` | `A52337ED1CC3DECEBF8BD6840662E12FAFDDCFA95C3E5E8D5E1129FFBBEF796F` | 구버전 제안 | `docs/archive/story_document_management_proposal_v0.1.md` | 바이트·해시 일치 |
| SRC-004 | `스토리 문서 분할 및 관리 제안서 v0.2.md` | `0BAC7F52CF21EDDCD4B720C7B5B8FF76F98FB452904CEBCC3E03C1EB2B220C67` | 구버전 제안 | `docs/archive/story_document_management_proposal_v0.2.md` | 바이트·해시 일치 |
| SRC-005 | `스토리 문서 분할 및 관리 제안서 v0.2.1.md` | `B4451E06D8FFAF5D1A233FA1A639E783BA17973977398C12527333A7707319F0` | 최신 이관 지침 | 원본 위치에서 작업 중 참고 | 원본 해시 기록 |
| SRC-006 | `게임 개발 단계별 제안서 v0.1.md` | `2EE29ACA36E74F5E0206AFF150ED610EBA8381E594B9091141E6F74CAA2B60C1` | 개발 단계·티켓 참고 | 개발 문서 이관 전까지 원본 위치에서 참고 | 원본 해시 기록 |

## 상태 정의

- `source-frozen`: Git과 해시로 원본 기준이 고정됨
- `copied-active`: 원본과 일치하는 사본이 활성 기준으로 사용됨
- `copied-archive`: 원본과 일치하는 사본이 보관 전용으로 사용됨
- `pending-split`: 세부 문서로의 책임별 이관을 기다림
- `verified`: 바이트 길이와 SHA-256이 원본과 일치함

## 현재 상태

| 대상 | 상태 | 다음 작업 |
|---|---|---|
| `docs/GDD.md` | `copied-active`, `verified` | 상호 링크와 책임별 기준 문서 연결 |
| `docs/archive/story_v1.5_full.md` | `source-frozen`, `copied-archive`, `verified`, `pending-split` | M3 Story 티켓 이관 완료. 검토 관문 G-M3 대기 |
| 두 구버전 제안서 | `copied-archive`, `verified` | 추가 작업 없음 |
| 최신 분할 제안서 v0.2.1 | 활성 작업 지침 | M1~M6 완료 후 아카이브 여부 결정 |
| 개발 단계별 제안서 v0.1 | 활성 참고 | 개발 프로젝트 문서에 반영 후 아카이브 |

## M0 완료 확인

- [x] `스토리 정리 v1.5`의 모든 장·소제목을 세부 이관 항목으로 등록한다.
- [x] 표, 인용문, 대사 예시, 추가 검토 메모의 추적 단위를 확정한다.
- [x] 원본을 Git 기준 커밋으로 보존한다.
- [x] 원본 해시를 기록한다.
- [x] 활성 GDD 사본의 해시 일치를 검증한다.
- [x] 스토리 원본과 구버전 제안서의 아카이브 사본을 검증한다.
- [x] 분할 중 변경 기록 위치를 지정한다.

M0 기준 작업은 2026-07-20에 완료했다.

## M1 진행 상태

- [x] `DOC-0003` Story, Design, Reference, Project 파일 골격과 영역별 README를 생성한다.
- [x] `DOC-0004` 공통 Front Matter와 상태 규칙을 통일한다.
- [x] `DOC-0005` Glossary와 Speaker Lexicon 항목 형식 및 책임 규칙을 확정한다.

M1에서 만든 신규 문서는 모두 `draft`로 유지한다.

M1 구조 작업은 완료했으며 2026-07-21 사용자의 다음 단계 진행 지시로 검토 관문 G-M1을 통과했다.

## M2 진행 상태

- [x] `DOC-0101` 원본 13-1~13-3에서 공식 용어와 의미 경계를 추출한다.
- [x] `DOC-0102` 원본 7-7, 13-2, 13-5, 13-6에서 화자 표현을 추출한다.
- [x] `DOC-0103` 원본 12장, 8-4, 13-4에서 문체 규칙을 분리한다.
- [x] `DOC-0104` 원본에 존재하는 고유 개체를 식별한다.
- [x] `DOC-0105` 원본에서 확정된 사건 순서를 추출한다.
- [x] `DOC-0106` 용어·화자·문체 책임 중복을 검토한다.

`DOC-0101`은 공식 용어 12개를, `DOC-0102`는 화자 표현 8개 항목을 등록했다. `DOC-0103`은 공통 톤과 잔재 설명 문체를 분리했고, `DOC-0104`는 이름을 만들지 않고 개체·역할 ID 15개를 등록했다. `DOC-0105`는 확정 상대 순서 5개와 반복·조건부 과정 3개를 등록했다. `DOC-0106` 검토 결과는 [`m2_reference_review.md`](m2_reference_review.md)에 기록했으며 차단 수준의 누락이나 책임 충돌은 발견되지 않았다.

M2 작업은 완료했으며 2026-07-22 사용자의 다음 작업 진행 지시로 검토 관문 G-M2를 통과했다.

## M3 진행 상태

- [x] `DOC-0201` 핵심 전제를 `story/00_core_pillars.md`로 이관한다.
- [x] `DOC-0202` 세계 역사를 `story/01_world_history.md`로 이관한다.
- [x] `DOC-0203` 던전 정설을 `story/02_dungeon_canon.md`로 이관한다.
- [x] `DOC-0204` 플레이어와 사회를 `story/03_player_and_society.md`로 이관한다.
- [x] `DOC-0205` NPC와 세력을 `story/04_characters_and_factions.md`로 이관한다.
- [x] `DOC-0206` 아이템과 발견물을 `story/05_items_and_discoveries.md`로 이관한다.
- [x] `DOC-0207` 내러티브 진행을 `story/06_narrative_progression.md`로 이관한다.

`DOC-0201`은 원본 `STY-0002`~`STY-0008`을 의미 변경 없이 이관하고 핵심 제약과 큰 설정 변경의 판단 경계를 명시했다. `DOC-0202`는 원본 `STY-0010`~`STY-0015`와 `TBL-001`을 이관하고 객관적 사실, 학계의 가설, 사회적 믿음의 경계를 명시했다. `DOC-0203`은 원본 3장·4장의 정설과 11장의 Story 책임, 13-3의 상세 의미를 이관했다. 11장의 실제 방문·랜덤 규칙은 `DOC-0302` 대상으로 남겼다. `DOC-0204`는 원본 5장과 6장의 Story 책임을 이관하고 가격·수수료·난이도 보정을 `DOC-0304` 대상으로 분리했다. `DOC-0205`는 원본 7장의 기능형 NPC와 세력 반응, 13장의 관련 지식·태도를 이관하고 연구자 대사 예시를 Speaker Lexicon, 감정 방식의 시간·횟수·정확도를 `DOC-0303`, 비용을 `DOC-0304` 대상으로 분리했다. `DOC-0206`은 원본 8장의 아이템 의미·원본성과 10장의 발견물·단서 책임을 이관하고 UI·저장·판매 보호·랜덤 배치·노출 조건을 후속 Design 티켓으로 분리했다. `DOC-0207`은 원본 9장의 진행 단계와 10장의 정보 노출 순서, 13장의 연구자 지식 진행을 이관하고 실제 발견·등록·해금 조건을 `DOC-0301` 대상으로 분리했다.

`DOC-0201`~`DOC-0207`의 Story 이관 티켓은 모두 완료했다. 검토 관문 G-M3는 아직 통과시키지 않았으며 사용자 검토 후 다음 단계 진입 여부를 결정한다.

---
title: 폐던전 수색꾼 문서 안내
status: draft
updated: 2026-07-21
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

## 원본 보존 규칙

- `../게임 기획 파일/`은 이관이 끝날 때까지 원본 보관 위치로 유지한다.
- 원본은 직접 편집하거나 삭제하지 않는다.
- 활성 문서에 반영할 변경은 먼저 `project/migration_changes.md`에 기록한다.
- `archive/`의 문서는 근거 확인과 누락 검수에만 사용하며 현재 설정으로 인용하지 않는다.
- 문서 간 내용이 충돌하면 `GDD.md`의 "자료 충돌 시 우선순위"를 따른다.

## 현재 단계

문서 분할 단계 `M1 — 문서 골격 생성`을 진행 중이다. `DOC-0003` 파일 책임 골격을 생성했으며, 다음 작업은 `DOC-0004` Front Matter와 문서 상태 규칙 통일이다. 신규 문서는 최종 전환 전까지 `draft`다.

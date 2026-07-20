---
title: 문서 이관 대장
status: draft
updated: 2026-07-20
source_commit: 339ff50
---

# 문서 이관 대장

## 목적

원본 기획 문서의 보존 상태, 활성 기준 문서, 아카이브 사본과 후속 이관 위치를 추적한다.

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
| `docs/archive/story_v1.5_full.md` | `source-frozen`, `copied-archive`, `verified`, `pending-split` | 원본 장·소제목 단위 이관 항목 등록 |
| 두 구버전 제안서 | `copied-archive`, `verified` | 추가 작업 없음 |
| 최신 분할 제안서 v0.2.1 | 활성 작업 지침 | M1~M6 완료 후 아카이브 여부 결정 |
| 개발 단계별 제안서 v0.1 | 활성 참고 | 개발 프로젝트 문서에 반영 후 아카이브 |

## M0 완료 전 남은 작업

- [ ] `스토리 정리 v1.5`의 모든 장·소제목을 세부 이관 항목으로 등록한다.
- [ ] 표, 인용문, 대사 예시, 추가 검토 메모의 추적 단위를 확정한다.
- [x] 원본을 Git 기준 커밋으로 보존한다.
- [x] 원본 해시를 기록한다.
- [x] 활성 GDD 사본의 해시 일치를 검증한다.
- [x] 스토리 원본과 구버전 제안서의 아카이브 사본을 검증한다.
- [x] 분할 중 변경 기록 위치를 지정한다.


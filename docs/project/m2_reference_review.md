---
id: PROJECT-M2-REFERENCE-REVIEW
title: M2 Reference 검토 보고
document_type: project
status: draft
source_version: story-v1.5+management-proposal-v0.2.1
canonical_for:
  - m2_reference_review
  - reference_responsibility_audit
last_reviewed:
owner: documentation-maintainer
related:
  - ../reference/README.md
  - ../reference/glossary.md
  - ../reference/speaker_lexicon.md
  - ../reference/entity_index.md
  - ../reference/timeline.md
  - ../story/07_tone_and_writing_guide.md
  - migration_manifest.md
  - story_v1.5_inventory.md
---

# M2 Reference 검토 보고

- 리뷰 대상: M2 Reference 우선 추출 결과 (`DOC-0101`~`DOC-0105`)
- 기준 원본: `스토리 정리 v1.5`, `스토리 문서 분할 및 관리 제안서 v0.2.1`
- 리뷰 유형: 누락 / 정합성 / 중복 / 용어 / 화자 표현 / 링크 / 최종 승인
- 검토 티켓: `DOC-0106`
- 검토일: 2026-07-21

## 발견 사항

| ID | 위치 | 유형 | 내용 | 심각도 | 권장 조치 |
|---|---|---|---|---|---|
| R-M2-001 | [`glossary.md`](../reference/glossary.md)의 수색꾼 항목 | 중복 | `도적`, `잔반 처리`, `정찰자`를 혼동 주의 대상으로 언급하지만 객관적 정의나 공식 별칭으로 등록하지 않았다. 실제 사용 주체와 어감은 Speaker Lexicon만 소유한다. | 정보 | 책임 경계를 보여 주는 교차 참조로 유지한다. |
| R-M2-002 | [`speaker_lexicon.md`](../reference/speaker_lexicon.md)의 감정사·연구자 항목 | 화자 표현 | 초반·중반·후반 대사 예시는 표현 근거이며, 적용 시점과 지식 변화는 Story 책임이라고 명시되어 있다. | 정보 | M3에서 지식 진행을 Story에 이관할 때 이 예시를 연결한다. |
| R-M2-003 | [`07_tone_and_writing_guide.md`](../story/07_tone_and_writing_guide.md)의 잔재 설명 | 용어 | 잔재 묘사 예시는 문체 자료이고 공식 정의는 Glossary가 소유한다고 명시되어 있다. | 정보 | 현재 경계를 유지하고 정의 변경은 Glossary에서만 수행한다. |
| R-M2-004 | 상세 Story 문서 | 링크·정합성 | 던전 정설, 화자 지식, 내러티브 진행 문서는 아직 골격 단계라 Reference에서 상세 기준으로 이어지는 내용이 완성되지 않았다. M2 책임 충돌은 아니지만 최종 기준 전환 전 해소해야 한다. | 보통 | `DOC-0203`, `DOC-0205`, `DOC-0207`에서 상세 내용을 이관하고 역링크를 검수한다. |
| R-M2-005 | `STY-0101` | 누락 추적 | 13장의 추가 검토 메모는 내용 확정 대상이 아니라 [`open_questions.md`](open_questions.md) 이관 대상으로 등록되어 있다. | 낮음 | `DOC-0402`에서 질문·보류 항목으로 이관한다. |

차단 수준의 누락, 책임 충돌, 정의 중복은 발견되지 않았다.

## G-M2 검토 결과

- [x] 핵심 용어 12개가 Glossary에 고유 ID로 등록되어 있다.
- [x] 폐던전은 코어가 파괴된 던전 전체, 잔여 구역은 그 안에 남은 탐색 가능 구역으로 구분되어 있다.
- [x] 공식 분류와 현장 명칭, 비하 은어가 서로 다른 책임과 상태로 분리되어 있다.
- [x] 화자별 어휘와 객관적 사실·지식 진행의 책임이 분리되어 있다.
- [x] Glossary는 짧은 의미 경계와 연결만 소유하며 상세 세계관을 중복 복사하지 않는다.
- [x] 원본 7-7과 13장의 제목·표·인용문·검토 메모가 인벤토리 ID로 추적된다.

## 원본 추적 확인

| 원본 범위 | 추적 ID | 현재 대상·상태 |
|---|---|---|
| 7-7. NPC별 말투 기준 | `STY-0051`, `TBL-012` | Speaker Lexicon과 인물·세력 Story로 `split` |
| 13. 용어와 화자별 표현 | `STY-0094` | 하위 항목으로 분할 추적, 장 래퍼는 `planned` |
| 13-1. 기본 용어 정리 | `STY-0095`, `TBL-024` | Glossary로 `moved` |
| 13-2. 수색꾼 명칭 | `STY-0096`, `TBL-025`, `QTE-002` | Glossary와 Speaker Lexicon으로 `split` |
| 13-3. 폐던전 명칭 | `STY-0097` | Glossary와 던전 정설 Story로 `split` |
| 13-4. 잔재 설명 장치 | `STY-0098`, `QTE-003`, `QTE-004` | Glossary와 Tone Guide로 `split` |
| 13-5. 마왕 관련 용어 사용 | `STY-0099`, `TBL-026` | Speaker Lexicon과 관련 Story 문서로 `split` |
| 13-6. 화자별 표현 | `STY-0100`, `TBL-027` | Speaker Lexicon과 인물·세력 Story로 `split` |
| 이 파트의 추가 검토 메모 | `STY-0101` | Open Questions로 이관 `planned` |

## 확인한 핵심 설정과 용어

- [x] 폐던전과 잔여 구역 정의
- [x] 코어와 잔존 에너지
- [x] 수색꾼 공식·현장 명칭
- [x] NPC 지식 범위와 화자별 표현의 책임 경계
- [x] 톤과 문체
- [x] Entity ID와 Timeline의 최소 적용 범위

## 결론

- 승인 상태: 승인
- 승인 기록: 2026-07-22 사용자의 다음 작업 진행 지시로 G-M2 통과
- 남은 질문: `STY-0101`의 추가 검토 메모는 `DOC-0402`에서 Open Questions로 이관한다.
- 후속 티켓: `DOC-0201`; 상세 연결 보강은 `DOC-0203`, `DOC-0205`, `DOC-0207`; 미결정 사항 이관은 `DOC-0402`

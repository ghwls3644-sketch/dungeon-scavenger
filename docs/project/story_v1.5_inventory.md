---
id: PROJECT-STORY-V1-5-INVENTORY
title: 스토리 정리 v1.5 원본 인벤토리
document_type: project
status: draft
source_version: story-v1.5
canonical_for:
  - story_source_inventory
  - structured_source_tracking
last_reviewed:
owner: documentation-maintainer
related:
  - migration_manifest.md
  - migration_changes.md
  - ../archive/story_v1.5_full.md
---

# 스토리 정리 v1.5 원본 인벤토리

## 목적

동결된 스토리 원본의 모든 장과 소제목, 누락 위험이 큰 구조화 요소를 안정적인 ID로 추적한다. 이 문서는 위치와 이관 계획만 기록하며 원문을 재작성하거나 새 설정을 확정하지 않는다.

## 원본 기준

- 원본 파일: `게임 기획 파일/스토리 정리 v1.5.md`
- 보존 사본: [`../archive/story_v1.5_full.md`](../archive/story_v1.5_full.md)
- SHA-256: `4191C100D5B3BFBEF291D3FD4D7588A3C5C31113A1827D33886CC8C90931292D`

## 집계

| 항목 | 수량 |
|---|---:|
| 문서 제목 | 1 |
| 원본 장 | 15 |
| 소제목 | 87 |
| 전체 제목 항목 | 103 |
| 표 블록 | 27 |
| 인용 블록 | 4 |
| 코드 펜스 블록 | 1 |

## 추적 규칙

- 제목 항목의 줄 범위는 해당 제목부터 다음 제목 직전까지다.
- `move`는 주 책임 문서 하나로 옮길 계획임을 뜻한다.
- `split`은 원본 한 절에 Story, Design, Reference 책임이 섞여 있어 여러 문서로 나눠야 함을 뜻한다.
- `review`는 `project/open_questions.md`에서 질문 단위로 다시 등록할 대상이다.
- 표, 인용문, 코드 펜스는 누락 위험이 있어 제목 항목과 별도의 자식 ID로 추적한다.
- 표 안의 대사 예시는 표와 함께 보존하고, 화자 표현 추출 시 `reference/speaker_lexicon.md`로 분리한다.
- 일반 문단, 목록, 인라인 예시는 부모 제목의 줄 범위에 포함한다. 이관 검증 시 원본 범위와 대상 문서를 대조한다.
- 대상 경로는 현재의 이관 계획이다. `planned` 상태에서는 신규 문서가 공식 기준이 아니다.

## 제목별 이관 계획

| ID | 단계 | 원본 장/소제목 | 원본 줄 | 예정 대상 | 이관 방식 | 상태 |
|---|---:|---|---:|---|---|---|
| STY-0001 | 1 | 스토리 정리 v1.5 — 수정 메모 반영본 | 1-15 | `archive/story_v1.5_full.md` | `archive-metadata` | planned |
| STY-0002 | 1 | 1. 핵심 콘셉트 | 16-17 | `story/00_core_pillars.md` | `move` | planned |
| STY-0003 | 2 | 1-1. 현재 핵심 콘셉트 | 18-27 | `story/00_core_pillars.md` | `move` | planned |
| STY-0004 | 2 | 1-2. 마왕 관련 요소의 위치 | 28-42 | `story/00_core_pillars.md` | `move` | planned |
| STY-0005 | 2 | 1-3. 시대적 위치 | 43-50 | `story/00_core_pillars.md` | `move` | planned |
| STY-0006 | 2 | 1-4. 플레이어가 영웅이 아닌 이유 | 51-64 | `story/00_core_pillars.md` | `move` | planned |
| STY-0007 | 2 | 1-5. 게임 초반 목표 | 65-78 | `story/00_core_pillars.md` | `move` | planned |
| STY-0008 | 2 | 1-6. 전투보다 회피와 탈출이 중요한 이유 | 79-82 | `story/00_core_pillars.md` | `move` | planned |
| STY-0009 | 2 | 이 파트의 추가 검토 메모 | 83-89 | `project/open_questions.md` | `review` | planned |
| STY-0010 | 1 | 2. 세계의 과거사 | 90-91 | `story/01_world_history.md` | `move` | planned |
| STY-0011 | 2 | 2-1. 마왕의 봉인 | 92-97 | `story/01_world_history.md` | `move` | planned |
| STY-0012 | 2 | 2-2. 던전의 자연 발생 | 98-108 | `story/01_world_history.md` | `move` | planned |
| STY-0013 | 2 | 2-3. 모험가 시대의 시작 | 109-114 | `story/01_world_history.md` | `move` | planned |
| STY-0014 | 2 | 2-4. 폐던전과 잔여 구역의 등장 | 115-131 | `story/01_world_history.md` | `move` | planned |
| STY-0015 | 2 | 2-5. 이 설정을 게임 안에서 다루는 깊이 | 132-143 | `story/01_world_history.md` | `move` | planned |
| STY-0016 | 2 | 이 파트의 추가 검토 메모 | 144-150 | `project/open_questions.md` | `review` | planned |
| STY-0017 | 1 | 3. 던전 코어와 폐던전의 원리 | 151-156 | `story/02_dungeon_canon.md` | `move` | planned |
| STY-0018 | 2 | 3-1. 코어의 기능 | 157-169 | `story/02_dungeon_canon.md` | `move` | planned |
| STY-0019 | 2 | 3-2. 코어 방 | 170-182 | `story/02_dungeon_canon.md` | `move` | planned |
| STY-0020 | 2 | 3-3. 살아 있는 던전과 죽어가는 던전의 차이 | 183-196 | `story/02_dungeon_canon.md` | `move` | planned |
| STY-0021 | 2 | 3-4. 코어 파괴와 자연 소멸 | 197-202 | `story/02_dungeon_canon.md` | `move` | planned |
| STY-0022 | 2 | 3-5. 던전의 최종 소멸 | 203-208 | `story/02_dungeon_canon.md` | `move` | planned |
| STY-0023 | 2 | 이 파트의 추가 검토 메모 | 209-215 | `project/open_questions.md` | `review` | planned |
| STY-0024 | 1 | 4. 폐던전의 현재 상태 | 216-221 | `story/02_dungeon_canon.md` | `move` | planned |
| STY-0025 | 2 | 4-1. 범람과 폐던전의 관계 | 222-229 | `story/02_dungeon_canon.md` | `move` | planned |
| STY-0026 | 2 | 4-2. 아직 회수 가치가 남아 있는 이유 | 230-242 | `story/02_dungeon_canon.md` | `move` | planned |
| STY-0027 | 2 | 4-3. 주요 위험 | 243-255 | `story/02_dungeon_canon.md` | `move` | planned |
| STY-0028 | 2 | 4-4. 왜 대형 길드가 다시 손대지 않는가 | 256-268 | `story/02_dungeon_canon.md` | `move` | planned |
| STY-0029 | 2 | 4-5. 구역별 스토리 기능 | 269-283 | `story/02_dungeon_canon.md` | `move` | planned |
| STY-0030 | 2 | 이 파트의 추가 검토 메모 | 284-290 | `project/open_questions.md` | `review` | planned |
| STY-0031 | 1 | 5. 플레이어 캐릭터: 수색꾼 | 291-296 | `story/03_player_and_society.md` | `move` | planned |
| STY-0032 | 2 | 5-1. 플레이어 정리 | 297-310 | `story/03_player_and_society.md` | `move` | planned |
| STY-0033 | 2 | 5-2. 플레이어의 동기 | 311-316 | `story/03_player_and_society.md` | `move` | planned |
| STY-0034 | 2 | 5-3. 성장 방향 | 317-330 | `story/03_player_and_society.md` | `move` | planned |
| STY-0035 | 2 | 이 파트의 추가 검토 메모 | 331-337 | `project/open_questions.md` | `review` | planned |
| STY-0036 | 1 | 6. 사회와 경제 구조 | 338-341 | `story/03_player_and_society.md`; `design/economy_rules.md` | `split` | planned |
| STY-0037 | 2 | 6-1. 던전 경제의 계층 구조 | 342-350 | `story/03_player_and_society.md`; `design/economy_rules.md` | `split` | planned |
| STY-0038 | 2 | 6-2. 수색꾼 길드 | 351-362 | `story/03_player_and_society.md`; `design/economy_rules.md` | `split` | planned |
| STY-0039 | 2 | 6-3. 회수품의 가격 구조 | 363-376 | `story/03_player_and_society.md`; `design/economy_rules.md` | `split` | planned |
| STY-0040 | 2 | 6-4. 왜 길드나 군대가 직접 회수하지 않는가 | 377-382 | `story/03_player_and_society.md`; `design/economy_rules.md` | `split` | planned |
| STY-0041 | 2 | 6-5. 회수품의 수요 | 383-392 | `story/03_player_and_society.md`; `design/economy_rules.md` | `split` | planned |
| STY-0042 | 2 | 6-6. 수수료와 난이도 | 393-404 | `story/03_player_and_society.md`; `design/economy_rules.md` | `split` | planned |
| STY-0043 | 2 | 이 파트의 추가 검토 메모 | 405-411 | `project/open_questions.md` | `review` | planned |
| STY-0044 | 1 | 7. 주요 세력과 NPC | 412-415 | `story/04_characters_and_factions.md` | `move` | planned |
| STY-0045 | 2 | 7-1. 추천 NPC/세력 분류 | 416-428 | `story/04_characters_and_factions.md` | `move` | planned |
| STY-0046 | 2 | 7-2. 연구자의 정보 변화 | 429-442 | `story/04_characters_and_factions.md` | `move` | planned |
| STY-0047 | 2 | 7-3. 튜토리얼 조력자 | 443-457 | `story/04_characters_and_factions.md` | `move` | planned |
| STY-0048 | 2 | 7-4. 감정사와 감정 방식 | 458-468 | `story/04_characters_and_factions.md` | `move` | planned |
| STY-0049 | 2 | 7-5. 고유 유물과 세력 반응 | 469-479 | `story/04_characters_and_factions.md` | `move` | planned |
| STY-0050 | 2 | 7-6. 성직자와 봉인 관리인 정리 | 480-490 | `story/04_characters_and_factions.md` | `move` | planned |
| STY-0051 | 2 | 7-7. NPC별 말투 기준 | 491-502 | `reference/speaker_lexicon.md`; `story/04_characters_and_factions.md` | `split` | planned |
| STY-0052 | 2 | 이 파트의 추가 검토 메모 | 503-509 | `project/open_questions.md` | `review` | planned |
| STY-0053 | 1 | 8. 잔류물 체계 | 510-521 | `story/05_items_and_discoveries.md`; `design/item_rules.md` | `split` | planned |
| STY-0054 | 2 | 8-1. UI 분류 색상 | 522-535 | `design/item_rules.md` | `move` | planned |
| STY-0055 | 2 | 8-2. 분류별 처리 방식 | 536-549 | `story/05_items_and_discoveries.md`; `design/item_rules.md` | `split` | planned |
| STY-0056 | 2 | 8-3. 핵심 기록물 보관 방식 | 550-560 | `story/05_items_and_discoveries.md`; `design/item_rules.md` | `split` | planned |
| STY-0057 | 2 | 8-4. 잔재의 표현 방식 | 561-571 | `story/07_tone_and_writing_guide.md`; `reference/glossary.md`; `story/05_items_and_discoveries.md` | `split` | planned |
| STY-0058 | 2 | 8-5. 폐품 반복 등장의 설명 강도 | 572-582 | `story/05_items_and_discoveries.md`; `design/item_rules.md` | `split` | planned |
| STY-0059 | 2 | 이 파트의 추가 검토 메모 | 583-589 | `project/open_questions.md` | `review` | planned |
| STY-0060 | 1 | 9. 메인 스토리 진행 축 | 590-595 | `story/06_narrative_progression.md` | `move` | planned |
| STY-0061 | 2 | 9-1. 1단계: 변두리 수색꾼의 생업 | 596-605 | `story/06_narrative_progression.md` | `move` | planned |
| STY-0062 | 2 | 9-2. 2단계: 폐던전의 규칙 학습 | 606-615 | `story/06_narrative_progression.md` | `move` | planned |
| STY-0063 | 2 | 9-3. 3단계: 발견물을 통한 세계관 해설 | 616-628 | `story/06_narrative_progression.md` | `move` | planned |
| STY-0064 | 2 | 9-4. 4단계: 선택적 떡밥과 장기 수집 | 629-641 | `story/06_narrative_progression.md` | `move` | planned |
| STY-0065 | 2 | 9-5. 엔딩 또는 장기 목표의 방향 | 642-653 | `story/06_narrative_progression.md` | `move` | planned |
| STY-0066 | 2 | 이 파트의 추가 검토 메모 | 654-660 | `project/open_questions.md` | `review` | planned |
| STY-0067 | 1 | 10. 서브 스토리와 발견물 구조 | 661-664 | `story/05_items_and_discoveries.md`; `story/06_narrative_progression.md`; `design/narrative_delivery.md` | `split` | planned |
| STY-0068 | 2 | 10-1. 서브 스토리 유형 | 665-676 | `story/05_items_and_discoveries.md`; `story/06_narrative_progression.md`; `design/narrative_delivery.md` | `split` | planned |
| STY-0069 | 2 | 10-2. 발견물 획득 방식 | 677-689 | `story/05_items_and_discoveries.md`; `story/06_narrative_progression.md`; `design/narrative_delivery.md` | `split` | planned |
| STY-0070 | 2 | 10-3. 텍스트 길이와 연구자 해설 | 690-701 | `story/05_items_and_discoveries.md`; `story/06_narrative_progression.md`; `design/narrative_delivery.md` | `split` | planned |
| STY-0071 | 2 | 10-4. NPC 반응 범위 | 702-713 | `story/05_items_and_discoveries.md`; `story/06_narrative_progression.md`; `design/narrative_delivery.md` | `split` | planned |
| STY-0072 | 2 | 10-5. 잔여 구역 단서와 지도 표현 | 714-729 | `story/05_items_and_discoveries.md`; `story/06_narrative_progression.md`; `design/narrative_delivery.md` | `split` | planned |
| STY-0073 | 2 | 10-6. 실패한 수색꾼의 흔적 | 730-744 | `story/05_items_and_discoveries.md`; `story/06_narrative_progression.md`; `design/narrative_delivery.md` | `split` | planned |
| STY-0074 | 2 | 10-7. 판매 차단 | 745-758 | `story/05_items_and_discoveries.md`; `story/06_narrative_progression.md`; `design/narrative_delivery.md` | `split` | planned |
| STY-0075 | 2 | 이 파트의 추가 검토 메모 | 759-765 | `project/open_questions.md` | `review` | planned |
| STY-0076 | 1 | 11. 반복 탐험의 서사 규칙 | 766-769 | `story/02_dungeon_canon.md`; `design/repeat_exploration.md` | `split` | planned |
| STY-0077 | 2 | 11-1. 반복되는 것 | 770-779 | `story/02_dungeon_canon.md`; `design/repeat_exploration.md` | `split` | planned |
| STY-0078 | 2 | 11-2. 반복되지 않는 것 | 780-787 | `story/02_dungeon_canon.md`; `design/repeat_exploration.md` | `split` | planned |
| STY-0079 | 2 | 11-3. 반복 개연성 | 788-793 | `story/02_dungeon_canon.md`; `design/repeat_exploration.md` | `split` | planned |
| STY-0080 | 2 | 11-4. 랜덤성 적용 범위 추천 | 794-808 | `story/02_dungeon_canon.md`; `design/repeat_exploration.md` | `split` | planned |
| STY-0081 | 2 | 11-5. 잔여 구역 활용 방식 | 809-832 | `story/02_dungeon_canon.md`; `design/repeat_exploration.md` | `split` | planned |
| STY-0082 | 2 | 11-6. 고유 유물 회수 후 변화 | 833-844 | `story/02_dungeon_canon.md`; `design/repeat_exploration.md` | `split` | planned |
| STY-0083 | 2 | 11-7. 잔존 에너지 유실과 보상 노출 규칙 | 845-871 | `story/02_dungeon_canon.md`; `design/repeat_exploration.md` | `split` | planned |
| STY-0084 | 2 | 11-8. 다른 수색꾼의 흔적 | 872-884 | `story/02_dungeon_canon.md`; `design/repeat_exploration.md` | `split` | planned |
| STY-0085 | 2 | 이 파트의 추가 검토 메모 | 885-891 | `project/open_questions.md` | `review` | planned |
| STY-0086 | 1 | 12. 톤과 분위기 | 892-897 | `story/07_tone_and_writing_guide.md` | `move` | planned |
| STY-0087 | 2 | 12-1. 핵심 감정 | 898-909 | `story/07_tone_and_writing_guide.md` | `move` | planned |
| STY-0088 | 2 | 12-2. 피해야 할 톤 | 910-919 | `story/07_tone_and_writing_guide.md` | `move` | planned |
| STY-0089 | 2 | 12-3. 어울리는 톤 | 920-929 | `story/07_tone_and_writing_guide.md` | `move` | planned |
| STY-0090 | 2 | 12-4. 보상 감정 | 930-945 | `story/07_tone_and_writing_guide.md` | `move` | planned |
| STY-0091 | 2 | 12-5. 마왕을 다루는 감정 | 946-956 | `story/07_tone_and_writing_guide.md` | `move` | planned |
| STY-0092 | 2 | 12-6. 공포의 방향 | 957-960 | `story/07_tone_and_writing_guide.md` | `move` | planned |
| STY-0093 | 2 | 이 파트의 추가 검토 메모 | 961-967 | `project/open_questions.md` | `review` | planned |
| STY-0094 | 1 | 13. 용어와 화자별 표현 | 968-969 | `reference/glossary.md`; `reference/speaker_lexicon.md` | `split` | planned |
| STY-0095 | 2 | 13-1. 기본 용어 정리 | 970-986 | `reference/glossary.md` | `move` | moved |
| STY-0096 | 2 | 13-2. 수색꾼 명칭 | 987-1007 | `reference/glossary.md`; `reference/speaker_lexicon.md` | `split` | split |
| STY-0097 | 2 | 13-3. 폐던전 명칭 | 1008-1022 | `reference/glossary.md`; `story/02_dungeon_canon.md` | `split` | split |
| STY-0098 | 2 | 13-4. 잔재 설명 장치 | 1023-1036 | `reference/glossary.md`; `story/07_tone_and_writing_guide.md` | `split` | planned |
| STY-0099 | 2 | 13-5. 마왕 관련 용어 사용 | 1037-1056 | `story/01_world_history.md`; `story/04_characters_and_factions.md`; `story/06_narrative_progression.md`; `reference/speaker_lexicon.md` | `split` | planned |
| STY-0100 | 2 | 13-6. 화자별 표현 | 1057-1068 | `reference/speaker_lexicon.md`; `story/04_characters_and_factions.md` | `split` | planned |
| STY-0101 | 2 | 이 파트의 추가 검토 메모 | 1069-1075 | `project/open_questions.md` | `review` | planned |
| STY-0102 | 1 | 14. GDD 반영용 추천 목차 | 1076-1101 | `project/gdd_mapping.md` | `move` | planned |
| STY-0103 | 1 | 15. 이번 버전에서 확정된 핵심 변경점 | 1102-1133 | `project/decisions.md` | `move` | planned |

## 구조화 요소 인벤토리

| ID | 유형 | 원본 줄 | 소유 제목 | 부모 ID | 상태 |
|---|---|---:|---|---|---|
| TBL-001 | table | 121-124 | 2-4. 폐던전과 잔여 구역의 등장 | `STY-0014` | planned |
| TBL-002 | table | 159-168 | 3-1. 코어의 기능 | `STY-0018` | planned |
| TBL-003 | table | 271-282 | 4-5. 구역별 스토리 기능 | `STY-0029` | planned |
| TBL-004 | table | 299-309 | 5-1. 플레이어 정리 | `STY-0032` | planned |
| TBL-005 | table | 344-349 | 6-1. 던전 경제의 계층 구조 | `STY-0037` | planned |
| TBL-006 | table | 369-375 | 6-3. 회수품의 가격 구조 | `STY-0039` | planned |
| TBL-007 | table | 385-391 | 6-5. 회수품의 수요 | `STY-0041` | planned |
| TBL-008 | table | 399-403 | 6-6. 수수료와 난이도 | `STY-0042` | planned |
| TBL-009 | table | 418-427 | 7-1. 추천 NPC/세력 분류 | `STY-0045` | planned |
| TBL-010 | table | 435-439 | 7-2. 연구자의 정보 변화 | `STY-0046` | planned |
| TBL-011 | table | 462-465 | 7-4. 감정사와 감정 방식 | `STY-0048` | planned |
| TBL-012 | table | 493-501 | 7-7. NPC별 말투 기준 | `STY-0051` | planned |
| TBL-013 | table | 514-520 | 8. 잔류물 체계 | `STY-0053` | planned |
| TBL-014 | table | 526-532 | 8-1. UI 분류 색상 | `STY-0054` | planned |
| TBL-015 | table | 540-546 | 8-2. 분류별 처리 방식 | `STY-0055` | planned |
| TBL-016 | table | 667-675 | 10-1. 서브 스토리 유형 | `STY-0068` | planned |
| TBL-017 | table | 683-688 | 10-2. 발견물 획득 방식 | `STY-0069` | planned |
| TBL-018 | table | 720-726 | 10-5. 잔여 구역 단서와 지도 표현 | `STY-0072` | planned |
| TBL-019 | table | 751-757 | 10-7. 판매 차단 | `STY-0074` | planned |
| TBL-020 | table | 798-805 | 11-4. 랜덤성 적용 범위 추천 | `STY-0080` | planned |
| TBL-021 | table | 815-821 | 11-5. 잔여 구역 활용 방식 | `STY-0081` | planned |
| TBL-022 | table | 853-860 | 11-7. 잔존 에너지 유실과 보상 노출 규칙 | `STY-0083` | planned |
| TBL-023 | table | 936-944 | 12-4. 보상 감정 | `STY-0090` | planned |
| TBL-024 | table | 972-985 | 13-1. 기본 용어 정리 | `STY-0095` | moved |
| TBL-025 | table | 993-1000 | 13-2. 수색꾼 명칭 | `STY-0096` | split |
| TBL-026 | table | 1043-1051 | 13-5. 마왕 관련 용어 사용 | `STY-0099` | planned |
| TBL-027 | table | 1059-1067 | 13-6. 화자별 표현 | `STY-0100` | planned |
| QTE-001 | blockquote | 20-22 | 1-1. 현재 핵심 콘셉트 | `STY-0003` | planned |
| QTE-002 | blockquote | 1004-1006 | 13-2. 수색꾼 명칭 | `STY-0096` | split |
| QTE-003 | blockquote | 1029-1031 | 13-4. 잔재 설명 장치 | `STY-0098` | planned |
| QTE-004 | blockquote | 1035 | 13-4. 잔재 설명 장치 | `STY-0098` | planned |
| FNC-001 | fenced-text | 1080-1096 | 14. GDD 반영용 추천 목차 | `STY-0102` | planned |

## 완료 조건

- [x] 원본의 모든 제목이 고유 ID를 가진다.
- [x] 제목 줄 범위가 원본 1-1133행을 빈틈없이 덮는다.
- [x] 모든 추가 검토 메모가 `project/open_questions.md` 대상으로 표시된다.
- [x] 책임이 섞인 절이 `split`으로 표시된다.
- [x] 모든 표, 인용 블록, 코드 펜스가 부모 제목과 연결된다.
- [ ] 실제 이관 후 각 항목을 `moved`, `split`, `verified`로 갱신한다.

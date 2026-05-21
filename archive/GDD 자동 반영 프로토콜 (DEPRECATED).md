# GDD 자동 반영 프로토콜

## 목적
- 하네스 결과를 일정 기준으로 반자동 반영해 문서 운영 속도를 높인다.
- 반영 실수(충돌, 과복잡성, 누락)를 줄인다.

## 반영 판정 키
- `AUTO_MERGE`: 즉시 반영 가능
- `HOLD`: 수정 후 재실행
- `REJECT`: 주제 축소 또는 입력 보강 후 재요청

## AUTO_MERGE 조건
1. 품질 점수 18~20점
2. 충돌 매트릭스 `영향도 상` 0개
3. 복잡도 예산 초과 0개
4. MVP 티켓 5개 이상, 선행조건 누락 없음
5. 점수 18~19점이면 `잔여 리스크`와 `단기 검증 계획`을 함께 기록

## 반영 절차
1. 하네스 결과에서 `GDD 반영 패치 초안` 확보
2. 대상 섹션 확인 (`## 4~8` 범위 우선)
3. 기존 문장과 중복/충돌 검토
4. 패치 반영
5. 백로그 실행 이력 업데이트

## HOLD 처리 절차
1. 충돌 항목 및 점수 부족 원인 확인
2. 입력 스키마 보강 또는 범위 축소
3. 동일 주제 `v2`로 재실행

## 기록 템플릿
```text
YYYY-MM-DD: [Topic ID] [Topic Name]
Output: [문서 경로]
Merge Decision: [AUTO_MERGE/HOLD/REJECT]
Quality Score: [Consistency]/5, [Implementability]/5, [Balance]/5, [Testability]/5, Total [xx]/20
Patch Target: [GDD section]
Notes: [충돌 요약, 축소안 여부]
```

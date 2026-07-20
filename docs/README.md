# 폐던전 수색꾼 문서 안내

이 디렉터리는 게임 개발에 사용하는 활성 문서와 원본 아카이브를 관리한다.

## 현재 기준

- 제품 방향과 시스템 연결: [`GDD.md`](GDD.md)
- 문서 이관 현황: [`project/migration_manifest.md`](project/migration_manifest.md)
- 분할 중 변경 대기열: [`project/migration_changes.md`](project/migration_changes.md)
- 이전 원본과 구버전: [`archive/README.md`](archive/README.md)

## 원본 보존 규칙

- `../게임 기획 파일/`은 이관이 끝날 때까지 원본 보관 위치로 유지한다.
- 원본은 직접 편집하거나 삭제하지 않는다.
- 활성 문서에 반영할 변경은 먼저 `project/migration_changes.md`에 기록한다.
- `archive/`의 문서는 근거 확인과 누락 검수에만 사용하며 현재 설정으로 인용하지 않는다.
- 문서 간 내용이 충돌하면 `GDD.md`의 "자료 충돌 시 우선순위"를 따른다.

## 현재 단계

문서 분할 단계 `M0 — 준비와 동결`을 완료했다. 다음 작업은 `DOC-0003` Story, Design, Reference, Project 문서 골격 생성이다.

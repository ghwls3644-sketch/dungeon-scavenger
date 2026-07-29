---
id: PROJECT-MODULE-BOUNDARIES
title: 폴더와 모듈 경계
document_type: project
status: confirmed
source_version: development-proposal-v0.1+gdd-v2.1+dev-0002
canonical_for:
  - source_tree_layout
  - module_responsibilities
  - module_dependency_rules
last_reviewed: 2026-07-29
owner: project-maintainer
related:
  - ../../AGENTS.md
  - ../../project.godot
  - ../README.md
  - ../GDD.md
  - ../design/README.md
  - project_context.md
  - development_handoff.md
  - decisions.md
---

# 폴더와 모듈 경계

## 목적

`DEV-0002`부터 사용하는 Godot 소스 폴더와 각 모듈의 책임을 고정한다. 새 파일을 만들 때 어느 폴더에 둘지 판단하고, 화면·저장·게임 규칙이 서로의 책임을 가져가지 않도록 하는 개발 기준이다.

이 문서는 코드 배치와 의존 방향만 소유한다. 실제 게임 규칙은 관련 `confirmed` Design 문서가, 제품과 시스템 연결은 GDD가 소유한다.

## 실제 폴더 구조

```text
res://
  src/
    app/
    core/
    gameplay/
    harness/
    meta/
    infrastructure/
    ui/
    data/
  tests/
```

동결 개발 제안서의 `App`, `Core`, `Gameplay`, `Meta`, `Infrastructure`, `UI`, `Data`, `Tests`를 Godot 경로 관례에 맞춰 소문자로 배치했다. 현재 GDD가 하네스를 독립 시스템으로 구분하므로 `src/harness/`도 함께 둔다.

이번 티켓은 위 최상위 경계만 만든다. 각 모듈 안의 기능별 하위 폴더는 실제 기능 티켓에서 필요한 것만 추가한다.

## 모듈별 책임

| 경로 | 맡는 책임 | 맡지 않는 책임 |
|---|---|---|
| `res://src/app/` | 부팅, 장면 흐름, 전역 게임 상태, 모듈 조립 | 탐험·경제 규칙 계산, 화면 표시 세부 |
| `res://src/core/` | 안정적 ID 기반, 이벤트, 시간, 여러 모듈이 공유하는 최소 타입 | 특정 기능의 규칙, 장면과 UI |
| `res://src/gameplay/` | 플레이어, 탐색, 상호작용, 위험, 인벤토리, 회수와 탈출 | 거점 경제, 화면 전환, 저장 입출력 |
| `res://src/harness/` | 하네스 모듈, 충전, 분석, 작업과 비상 행동 | 하네스 세부 규칙의 임의 확정, 일반 탐험 흐름 |
| `res://src/meta/` | 거점, 경제, 감정, 연구, 장비와 성장 | 탐험 조작, 저장 파일 처리, 화면 그리기 |
| `res://src/infrastructure/` | 저장, 설정, 입력, 오디오, 현지화와 로그의 기술 연결 | 실패 손실·가격·진행처럼 게임이 결정할 규칙 |
| `res://src/ui/` | 타이틀, HUD, 지도, 인벤토리, 거점, 정산과 옵션 표시·사용자 명령 전달 | 게임 규칙 계산, 저장 처리, 직접 장면 전환 |
| `res://src/data/` | 아이템·방·루트·위험·경제·텍스트의 정의와 콘텐츠 값 | 실행 중 상태 변경, 화면 흐름, 저장 시점 결정 |
| `res://tests/` | 단위·통합·스모크 검사와 테스트 전용 자료 | 출시 게임 기능과 실제 콘텐츠 |

`src/harness/`는 코드 위치만 예약한다. [`harness_engineering.md`](../design/harness_engineering.md)가 `draft`인 동안 비어 있는 하네스 상세 규칙을 추정해 구현하지 않는다.

## 의존 방향

1. `core`는 다른 프로젝트 모듈을 참조하지 않는다.
2. `data`는 공통 ID나 타입이 필요할 때 `core`만 참조한다.
3. `gameplay`, `harness`, `meta`는 `core`와 `data`의 공개 정의를 사용한다. 서로 협력할 때는 공개 명령·상태·이벤트를 통하고 상대 모듈의 내부 파일을 직접 조작하지 않는다.
4. `infrastructure`는 전달받은 상태를 읽고 쓰는 기술 처리를 맡는다. 게임 규칙 모듈은 구체적인 저장·입력·오디오 구현을 직접 만들지 않고 `app`에서 연결한다.
5. `ui`는 공개 상태를 표시하고 사용자 명령을 전달할 수 있지만 결과를 계산하거나 장면을 직접 바꾸지 않는다.
6. `app`은 모듈을 조립하고 중앙 상태·장면 흐름을 관리한다. 여러 모듈을 연결해야 하는 조정 코드는 `app`에 둔다.
7. `tests`는 필요한 모듈을 참조할 수 있지만 출시 코드에서는 `tests`를 참조하지 않는다.
8. 순환 의존은 만들지 않는다. 두 모듈이 서로를 필요로 하면 공유 정의를 `core`로 옮기거나 조정을 `app`에 둔다.

## 파일 배치 판단 순서

새 파일을 추가할 때 다음 순서로 위치를 정한다.

1. 하나의 기능 규칙이면 그 기능을 소유한 `gameplay`, `harness`, `meta`에 둔다.
2. 저장·입력·오디오처럼 엔진이나 운영체제와 연결하는 코드면 `infrastructure`에 둔다.
3. 표시와 사용자 명령 전달이면 `ui`에 둔다.
4. 콘텐츠 정의나 조정 가능한 값이면 `data`에 둔다.
5. 여러 모듈을 연결하거나 화면 흐름을 바꾸면 `app`에 둔다.
6. 둘 이상에서 정말 같은 의미로 쓰는 최소 정의만 `core`에 둔다. 편의를 위해 기능 코드를 `core`로 옮기지 않는다.

## DEV-0002 제한과 인계

- 폴더를 추적하기 위한 `.gitkeep` 외에 장면, 스크립트, 리소스와 테스트 코드는 만들지 않는다.
- 메인 장면, Autoload와 게임 상태 구현은 `DEV-0003` 범위다.
- 입력 행동은 `DEV-0004`, 안정적 데이터 ID와 기본 정의는 `DEV-0005`, 테스트·로그·디버그 진입점은 `DEV-0006` 범위다.
- 다음 티켓은 `DEV-0003 — 기본 게임 상태 관리자`다.

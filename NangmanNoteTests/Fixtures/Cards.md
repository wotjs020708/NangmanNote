# 회귀 fixture — 카드 정답표

> M1.2 (#2) 작업 시 실제 카드 이미지(`heic`), 5/30 OCR 측정 결과(`ocr-text.txt`),
> 정답 JSON(`expected.json`)을 `Fixtures/cards/{id}/` 폴더에 추가한다.
> 이번 PR(#7)에서는 정답표 텍스트만 정리.

## 합격 기준 (단일 원두)
핵심 4필드 모두 정답이면 ✓:
- `originCountry`
- `originRegion`
- `variety`
- `tastingNotes ≥ 2`

## 합격 기준 (블렌드)
- `blendName` 정답이면 ✓
- 단일 원두 필드(`originCountry/originRegion/variety`)는 nil이어야 함

---

## honduras (단일 원두)

| 필드 | 정답 |
|---|---|
| inputMode | auto |
| originCountry | "Honduras" 또는 "온두라스" |
| originRegion | "로스 아라야네스" 또는 "Los Arayanes" |
| variety | "Geisha" 또는 "게이샤" |
| process | "washed" |
| roastLevel | "light" |
| tastingNotes | 플로럴, 감귤, 카모마일, 꿀 중 ≥ 2 |
| cafeName | nil |

displayName 기대값: `"온두라스 로스 아라야네스 게이샤"`

---

## ethiopia (단일 원두, 한/영 라벨)

| 필드 | 정답 |
|---|---|
| inputMode | auto |
| originCountry | "Ethiopia" |
| originRegion | "Yirgacheffe Worka Nenke" 또는 일부 |
| variety | "Heirloom" |
| process | "washed" |
| tastingNotes | Jasmine, Citrus, Apricot, Cane Sugar 중 ≥ 2 |
| cafeName | nil (농장명을 cafeName으로 잘못 매핑하면 안 됨) |

displayName 기대값: `"Ethiopia Yirgacheffe Worka Nenke Heirloom"`

---

## blend (블렌드)

| 필드 | 정답 |
|---|---|
| inputMode | auto |
| blendName | "BBINGTIGER" 또는 "DEFAULT VALUE" 포함 |
| originCountry / originRegion / variety | nil (블렌드는 단일 원두 필드 비움) |
| tastingNotes | 편안한, 휴식, 오렌지 등 일부 |

displayName 기대값: blendName 그대로

추가 정보 (블렌드 컴포넌트, M1.2 별도):
- Ethiopia Guji Uraga Tabe Haro Wachu, Red Honey, 65%
- Colombia Jose Meneses CM Mandrin, Washed, 35%

---

## siesta (수동 모드 대조군)

체크박스·손글씨가 섞인 양식. **자동 파싱 대상 외 — 수동 모드 검증용**.
| 필드 | 정답 |
|---|---|
| inputMode | manual |
| (모든 자동 필드) | nil (사용자가 직접 입력) |
| cafeName | "시에스타 커피" (수동 입력) |

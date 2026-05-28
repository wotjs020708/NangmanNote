# OCR + Foundation Models 회귀 추세 로그

이 표는 카드별 정확도 추세를 추적한다. PR마다 `xcodebuild test --filter ParsingRegression`
실행 결과를 한 줄 추가한다. 합격선이 5%p 이상 하락하면 instructions 변경 사유를 PR에 명시.

## 합격 기준 (카드 4장 중 3장 이상)
- 단일 원두: `originCountry`, `originRegion`, `variety`, `tastingNotes ≥ 2` 모두 정답
- 블렌드: `blendName` 정답 + 단일 원두 필드 nil

## 추세

| 일자 | honduras | ethiopia | blend | siesta | 통과 | 비고 |
|------|----------|----------|-------|--------|------|------|
| _(M1.2 #2 작업 시 첫 측정)_ | _-_ | _-_ | _-_ | _-_ | _-_ | regression 테스트 미구현 (#2에서 추가) |

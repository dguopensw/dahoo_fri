# API Structure

Base URL:

```text
http://127.0.0.1:5004
```

## GET /api/health

서버 상태 확인용 API입니다.

### Response

```json
{
  "status": "ok",
  "framework": "fastapi",
  "pipeline": "service_v1"
}
```

## POST /api/scrape

상품 URL을 스크래핑하고, 이미지 후보와 기본 추론 정보를 반환합니다.

### Request

```json
{
  "url": "https://www.daangn.com/..."
}
```

### Response

```json
{
  "title": "상품 제목",
  "description": "상품 설명",
  "price": "가격 문자열",
  "platform": "daangn",
  "image_urls": [
    "https://..."
  ],
  "ai_recommended_image_index": 0,
  "ranked_candidate_indices": [0, 1, 2],
  "image_reasoning": {
    "0": "full furniture visible"
  },
  "furniture_guess": {
    "type": "chair",
    "confidence": "high"
  },
  "dimensions_from_listing": {
    "width_cm": 80.0,
    "depth_cm": 60.0,
    "height_cm": 75.0,
    "source": "listing_text",
    "pattern": "WxDxH",
    "approximate": false,
    "raw_match": "W80xD60xH75"
  }
}
```

### Error

```json
{
  "detail": "당근마켓 또는 중고나라 URL만 지원합니다."
}
```

## POST /api/process

선택한 이미지 기준으로 전체 파이프라인을 실행합니다.

### Request

```json
{
  "url": "https://www.daangn.com/...",
  "selected_image_index": 0
}
```

### Response

응답은 작업 결과와 단계별 산출물 이름을 포함합니다. 파일 산출물은 `/api/output/{job_id}/{filename}`로 조회합니다.

대표 필드:

```json
{
  "job_id": "uuid",
  "steps": [],
  "listing": {
    "title": "상품 제목",
    "description": "상품 설명",
    "price": "가격 문자열",
    "platform": "daangn"
  },
  "selected_image_index": 0,
  "furniture_type": "chair",
  "dimensions": {
    "width_cm": 80.0,
    "depth_cm": 60.0,
    "height_cm": 75.0
  },
  "outputs": {
    "original": "original.jpg",
    "mask": "furniture_mask.png",
    "final_cutout": "final_cutout.png"
  },
  "warnings": []
}
```

실제 응답에는 마스크 품질, 오염물 분석, 인페인팅 상태, 치수 추정 근거 등 추가 필드가 포함될 수 있습니다.

## GET /api/output/{job_id}/{filename}

파이프라인 결과 파일을 내려받습니다.

### Path Parameters

```text
job_id   작업 UUID
filename output/{job_id}/ 하위에 저장된 파일명
```

### Response

파일 바이너리를 반환합니다.

### Error

```json
{
  "detail": "File not found"
}
```

## Frontend Flow

프론트엔드 연결 순서는 다음과 같습니다.

```text
1. POST /api/scrape
2. 사용자 또는 AI 추천값으로 selected_image_index 선택
3. POST /api/process
4. 응답의 outputs 파일명을 /api/output/{job_id}/{filename}로 표시
```

## Secret Handling

API 키와 로컬 경로는 요청/응답에 포함하지 않습니다.

커밋 금지 대상:

```text
.env
output/
checkpoints/
models/
*.pth
*.pt
*.onnx
```


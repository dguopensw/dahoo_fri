# Furniture Service Pipeline

FastAPI 기반 중고 가구 이미지 처리 실험 파이프라인입니다.

입력 URL에서 상품 정보를 스크래핑하고, 대표 이미지를 선택한 뒤 SAM/GroundingDINO 기반 마스크 생성, 컷아웃 생성, 오염물 분석, 치수 추정 결과를 API로 반환합니다.

## 포함 파일

```text
.
├── service_pipeline.py        # 서비스용 FastAPI 엔트리포인트
├── app.py                     # 공통 스크래핑, 분류, 세그먼트, 치수 추정 함수
├── lama_inpaint_worker.py     # LaMa 인페인팅 서브프로세스 워커
├── service_static/index.html  # 간단한 테스트 UI
├── docs/API_STRUCTURE.md      # API 요청/응답 구조
├── docs/DEVELOPER_HANDOFF.md  # 이어받는 개발자용 실행/의존성 메모
├── requirements.txt           # Python 의존성
├── requirements-optional.txt  # 선택 기능인 LaMa 워커 의존성
├── .env.example               # 환경변수 예시
└── .gitignore                 # 비밀키, 결과물, 모델 파일 제외
```

## 보안 주의

실제 API 키는 절대 커밋하지 않습니다.

```bash
cp .env.example .env
```

`.env`에 로컬 키를 넣어 실행하세요.

```env
OPENAI_API_KEY=sk-...
GPT_IMAGE_MODELS=gpt-image-1
SEGMENTATION_PROJECT_DIR=/absolute/path/to/nanobanana_ratio_project
SAM_CHECKPOINT=/absolute/path/to/sam_vit_b_01ec64.pth
LAMA_PYTHON=/absolute/path/to/lama_env/bin/python
```

`.gitignore`는 `.env`, 출력 이미지, 캐시, 가상환경, 모델 체크포인트 파일을 제외하도록 설정되어 있습니다.

## 실행 방법

Python 3.10 이상을 권장합니다.

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn service_pipeline:app --host 127.0.0.1 --port 5004
```

브라우저에서 아래 주소를 열면 테스트 UI를 사용할 수 있습니다.

```text
http://127.0.0.1:5004
```

Swagger 문서는 FastAPI 기본 경로에서 확인할 수 있습니다.

```text
http://127.0.0.1:5004/docs
```

## 외부 모델 의존성

이 저장소에는 대용량 모델 파일을 포함하지 않습니다.

`app.py`는 기본적으로 상위 디렉터리의 `../nanobanana_ratio_project`에서 세그먼테이션 모듈과 SAM 체크포인트를 찾습니다. 로컬 구조가 다르면 `SEGMENTATION_PROJECT_DIR`와 `SAM_CHECKPOINT` 환경변수를 프로젝트 환경에 맞게 지정해야 합니다.

OpenAI 키가 없거나 쿼터가 부족하면 일부 GPT 기반 판단 단계는 fallback 동작으로 넘어갑니다.

이어받는 개발자가 확인해야 할 상세 내용은 [docs/DEVELOPER_HANDOFF.md](docs/DEVELOPER_HANDOFF.md)에 정리했습니다.

## 지원 URL

- 당근마켓: `daangn.com`
- 중고나라: `joongna.com`

## API 구조

자세한 요청/응답 형식은 [docs/API_STRUCTURE.md](docs/API_STRUCTURE.md)를 참고하세요.

핵심 엔드포인트는 다음과 같습니다.

```text
GET  /api/health
POST /api/scrape
POST /api/process
GET  /api/output/{job_id}/{filename}
```

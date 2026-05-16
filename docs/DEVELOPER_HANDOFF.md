# Developer Handoff

이 문서는 `service_pipeline.py`를 다른 개발자가 이어서 실행하거나 수정할 때 확인해야 할 항목입니다.

## 1. 최소 실행 파일

서비스 실행에 필요한 파일은 저장소에 포함되어 있습니다.

```text
service_pipeline.py
app.py
lama_inpaint_worker.py
service_static/index.html
requirements.txt
.env.example
```

`service_pipeline.py`는 FastAPI 엔트리포인트이고, 내부 핵심 함수 일부는 `app.py`에서 재사용합니다.

## 2. 로컬 환경변수

```bash
cp .env.example .env
```

필수 또는 권장 환경변수:

```env
OPENAI_API_KEY=sk-...
SEGMENTATION_PROJECT_DIR=/absolute/path/to/nanobanana_ratio_project
SAM_CHECKPOINT=/absolute/path/to/sam_vit_b_01ec64.pth
LAMA_PYTHON=/absolute/path/to/lama_env/bin/python
```

`OPENAI_API_KEY`가 없으면 GPT 기반 이미지 랭킹, 이미지 분류, 치수 판단 일부가 fallback으로 동작합니다.

## 3. 외부 세그먼테이션 모듈

이 저장소에는 대용량 모델과 외부 실험 프로젝트 전체를 포함하지 않습니다.

현재 코드는 다음 Python API를 기대합니다.

```python
from segmentation import create_segmenter
segmenter = create_segmenter(device="cpu", prefer="grounded_sam")
```

따라서 `SEGMENTATION_PROJECT_DIR`에는 `segmentation.py` 또는 `segmentation/` 패키지가 있어야 합니다.

기본값은 저장소 상위 폴더의 `../nanobanana_ratio_project`입니다.

```text
parent/
├── dahoo_fri/
└── nanobanana_ratio_project/
    ├── segmentation.py
    └── checkpoints/
        └── sam_vit_b_01ec64.pth
```

다른 위치에 있으면 `.env`에서 `SEGMENTATION_PROJECT_DIR`와 `SAM_CHECKPOINT`를 절대경로로 지정하세요.

## 4. LaMa 인페인팅

LaMa는 선택 기능입니다. 실패해도 파이프라인은 원본 이미지를 사용해 fallback합니다.

사용하려면 별도 Python 환경에 optional dependency를 설치합니다.

```bash
python -m venv lama_env
source lama_env/bin/activate
pip install -r requirements-optional.txt
```

그 다음 `.env`에 해당 Python 경로를 지정합니다.

```env
LAMA_PYTHON=/absolute/path/to/lama_env/bin/python
```

## 5. 실행

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn service_pipeline:app --host 127.0.0.1 --port 5004
```

확인:

```bash
curl http://127.0.0.1:5004/api/health
```

## 6. 산출물

파이프라인 결과는 `output/{job_id}/` 아래에 생성됩니다. 이 디렉터리는 `.gitignore`에 의해 커밋되지 않습니다.

## 7. 보안 체크리스트

커밋 전에 아래 항목이 Git에 포함되지 않았는지 확인하세요.

```bash
git status --short
```

커밋 금지 대상:

```text
.env
output/
*.pth
*.pt
*.onnx
*.safetensors
API key, token, private key
```


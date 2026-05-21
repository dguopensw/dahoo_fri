#!/bin/bash
set -e

REPO_URL="https://github.com/dguopensw/dahoo_fri.git"
BRANCH="test"
INSTALL_DIR="/dahoo_fri"
SAM3_DIR="/opt/sam3"

echo "=== [1/4] Cloning / updating repo ==="
if [ -d "$INSTALL_DIR/.git" ]; then
    git -C "$INSTALL_DIR" pull origin "$BRANCH"
else
    git clone -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi
cd "$INSTALL_DIR"

echo "=== [2/4] Installing Python dependencies ==="
pip install --no-cache-dir --ignore-installed -r requirements.txt
pip install --no-cache-dir --ignore-installed -r requirements-optional.txt

echo "=== [3/4] Installing SAM3 ==="
if [ ! -d "$SAM3_DIR" ]; then
    git clone https://github.com/facebookresearch/sam3.git "$SAM3_DIR"
fi
pip install --no-cache-dir --no-deps -e "$SAM3_DIR"

echo "=== [4/4] Setting environment ==="
export SEGMENTATION_PROJECT_DIR="$INSTALL_DIR/segmentation_module"
export LAMA_PYTHON=$(which python3)
export PYTHONPATH="$INSTALL_DIR/segmentation_module:$PYTHONPATH"

if [ ! -f "$INSTALL_DIR/.env" ]; then
    echo ""
    echo "⚠️  .env 파일이 없습니다. 아래 환경변수를 설정하세요:"
    echo "    OPENAI_API_KEY, HF_TOKEN"
    echo "    cp .env.example .env 후 편집하거나 export로 직접 설정하세요."
    echo ""
fi

echo ""
echo "✅ Setup complete."
echo ""
echo "서버 실행:"
echo "  cd $INSTALL_DIR && uvicorn service_pipeline:app --host 0.0.0.0 --port 5004"

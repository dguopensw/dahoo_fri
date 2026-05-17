FROM pytorch/pytorch:2.3.1-cuda12.1-cudnn8-runtime

WORKDIR /app

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install SAM3
RUN git clone https://github.com/facebookresearch/sam3.git /opt/sam3 \
    && pip install --no-cache-dir -e /opt/sam3 \
    && pip install --no-cache-dir einops

# Install service dependencies (including LaMa inpainting)
COPY requirements.txt requirements-optional.txt ./
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir -r requirements-optional.txt

# Copy project files
COPY . .

# Add segmentation_module to Python path
ENV SEGMENTATION_PROJECT_DIR=/app/segmentation_module
ENV SAM_CHECKPOINT=""
ENV LAMA_PYTHON=/opt/conda/bin/python3
ENV PYTHONPATH="/app/segmentation_module:${PYTHONPATH}"

EXPOSE 5004

CMD ["uvicorn", "service_pipeline:app", "--host", "0.0.0.0", "--port", "5004"]

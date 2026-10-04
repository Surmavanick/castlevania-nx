FROM devkitpro/devkita64@sha256:1fc388c3a0d34bd2045a6dadcb1020e069d5f876a187fd705de14b4440c00282

RUN apt-get update \
    && apt-get install -y --no-install-recommends clang-19 glslang-tools \
    && rm -rf /var/lib/apt/lists/*

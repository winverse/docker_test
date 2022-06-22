FROM ubuntu:20.04

# not interactive by question
ARG DEBIAN_FRONTEND=noninteractive

# python
ENV PYTHONUNBUFFERED=1 \
  # prevents python creating .pyc files
  PYTHONDONTWRITEBYTECODE=1 \
  \
  # pip
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  \
  # poetry
  # https://python-poetry.org/docs/configuration/#using-environment-variables
  POETRY_VERSION=1.1.13 \
  # make poetry create the virtual environment in the project's root
  # it gets named `.venv`
  POETRY_VIRTUALENVS_IN_PROJECT=true \
  # do not ask any interactive question
  POETRY_NO_INTERACTION=1 \
  POETRY_HOME=~/.poetry \
  # paths
  # this is where our requirements + virtual environment will live
  APP_PATH="/usr/app" \
  VENV_PATH="/user/app/.venv"\
  # Timezone
  TZ=Asia/Seoul

# `builder-base` stage is used to build deps + create our virtual environment
# FROM python-base as builder-base
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
  # deps for installing poetry
  # timezone
  tzdata \
  # editor
  vim \
  curl \
  # deps for building python deps
  build-essential python3.8 python3.8-venv python3-pip python3.8-dev

# install poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN curl -sSL https://install.python-poetry.org | POETRY_VERSION=$POETRY_VERSION POETRY_HOME=$POETRY_HOME python3 -

ENV PATH="${PATH}:/root/.poetry/bin"

WORKDIR $APP_PATH
COPY ./ ./

# install runtime deps - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
RUN poetry install --no-dev






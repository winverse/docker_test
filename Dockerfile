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

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
  # timezone
  tzdata \
  # editor
  vim \
  # deps for building python deps
  build-essential python3.8 python3.8-venv python3-pip python3.8-dev libmecab-dev \ 
  # for konlpy
  g++ openjdk-8-jdk \
  # etc
  curl git 

# install poetry - respects $POETRY_VERSION & $POETRY_HOME
RUN curl -sSL https://install.python-poetry.org | POETRY_VERSION=$POETRY_VERSION POETRY_HOME=$POETRY_HOME python3 -

ENV PATH="${PATH}:/root/.poetry/bin"

WORKDIR $APP_PATH
COPY ./ ./

WORKDIR $APP_PATH/mecab

# install runtime deps - uses $POETRY_VIRTUALENVS_IN_PROJECT internally
RUN poetry install --no-dev

# install mecab
RUN curl -L https://bitbucket.org/eunjeon/mecab-ko/downloads/mecab-0.996-ko-0.9.2.tar.gz > mecab-0.996-ko-0.9.2.tar.gz
RUN tar xvfz mecab-0.996-ko-0.9.2.tar.gz

# install mecab-ko-dic
RUN curl -L https://bitbucket.org/eunjeon/mecab-ko-dic/downloads/mecab-ko-dic-2.1.1-20180720.tar.gz > mecab-ko-dic-2.1.1-20180720.tar.gz
RUN tar xvfz mecab-ko-dic-2.1.1-20180720.tar.gz

WORKDIR $APP_PATH/mecab/mecab-0.996-ko-0.9.2
RUN ./configure --build=aarch64-unknown-linux-gnu
RUN make && \
  make check && \
  make install 

WORKDIR $APP_PATH/mecab/mecab-ko-dic-2.1.1-20180720
RUN ./configure --build=aarch64-unknown-linux-gnu
RUN make && \
  make check && \
  make install 

WORKDIR $APP_PATH

RUN curl -s "https://raw.githubusercontent.com/konlpy/konlpy/master/scripts/mecab.sh" | bash
RUN pip3 install konlpy

CMD ["/usr/app/.venv/bin/flask", "run"]
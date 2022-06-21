FROM python:3.8-alpine

# directory paht: /usr/app/python_test
WORKDIR /usr/app
COPY ./ ./

RUN apk update
RUN apk upgrade
RUN apk add py3-pip curl

RUN echo 'alias python=python3.8' >> .bashrc
RUN echo 'export PATH="$HOME/.poetry/bin:$PATH"'  >> .bashrc

RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -

RUN ~/.poetry/bin/poetry add gensim
RUN ~/.poetry/bin/poetry add konlpy
RUN ~/.poetry/bin/poetry add pandas




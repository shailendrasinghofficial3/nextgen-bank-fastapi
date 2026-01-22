ARG PYTHON_VERSION=3.13.6
FROM python:${PYTHON_VERSION}-slim-bookworm AS python

# --- Stage 1: Build Stage ---
FROM python AS python-build-stage

RUN apt-get update && apt-get install \
    --no-install-recommends -y \
    build-essential \ 
    libpq-dev \
    curl

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"

WORKDIR /usr/src/app

# CHANGED: Since build context is the root, and pyproject.toml is at root
COPY pyproject.toml poetry.lock* ./

# Install dependencies globally (in this stage only)
RUN poetry config virtualenvs.create false \
    && poetry install --no-interaction --no-ansi --no-root --only main

# --- Stage 2: Run Stage ---
FROM python AS python-run-stage

ARG APP_HOME=/nextgen-bank-fastapi
ARG APP_USER=fastapi
ARG APP_GROUP=fastapi

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR ${APP_HOME}

# Install runtime dependencies only
RUN apt-get update && apt-get install --no-install-recommends -y \
    sudo bash gettext libpq5 \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/*

# Create user and logs directory
RUN groupadd -r ${APP_GROUP} && \
    useradd -r -g ${APP_GROUP} -d ${APP_HOME} -s /sbin/nologin ${APP_USER}

# Copy the installed Python packages from build stage
# Note: Ensure the python version here matches the ARG version
COPY --from=python-build-stage /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=python-build-stage /usr/local/bin /usr/local/bin

# Copy scripts from their deep path to the root for easier access
COPY --chown=${APP_USER}:${APP_GROUP} ./backend/docker/local/fastapi/entrypoint.sh /entrypoint.sh
COPY --chown=${APP_USER}:${APP_GROUP} ./backend/docker/local/fastapi/start.sh /start.sh


COPY --chown=${APP_USER}:${APP_GROUP} ./backend/docker/local/fastapi/celery/worker/start.sh /start-celeryworker.sh
COPY --chown=${APP_USER}:${APP_GROUP} ./backend/docker/local/fastapi/celery/beat/start.sh /start-celerybeat.sh
COPY --chown=${APP_USER}:${APP_GROUP} ./backend/docker/local/fastapi/celery/flower/start.sh /start-celeryflower.sh

RUN sed -i 's/\r$//g' /entrypoint.sh /start.sh /start-celeryworker.sh /start-celerybeat.sh /start-celeryflower.sh && \
    chmod +x /entrypoint.sh /start.sh /start-celeryworker.sh /start-celerybeat.sh /start-celeryflower.sh

# Copy project files from root to APP_HOME
COPY --chown=${APP_USER}:${APP_GROUP} . ${APP_HOME}

# Ensure logs directory exists inside the copied structure
RUN mkdir -p ${APP_HOME}/backend/app/logs && \
    chown -R ${APP_USER}:${APP_GROUP} ${APP_HOME}/backend/app/logs

USER ${APP_USER}

ENTRYPOINT [ "/entrypoint.sh" ]
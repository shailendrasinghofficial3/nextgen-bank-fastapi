#!/bin/bash

set -o errexit

set -o nounset

set -o pipefail

exec watchfiles --filter python celery.__main__.main --args '-A backend.app.cpre.celery_app worker -l INFO'

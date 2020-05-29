import logging
from os import path, environ, getenv

import pytest

import requests
from requests.exceptions import ConnectionError


if 'PYDEVD_HOST' in environ:
    import pydevd
    pydevd.settrace(
        environ['PYDEVD_HOST'],
        port=int(environ.get('PYDEVD_PORT', 5678)),
        stdoutToServer=True,
        stderrToServer=True,
        suspend=False)


@pytest.fixture(scope='session')
def docker_compose_file():
    compose_files = [path.join(path.dirname(__file__), 'docker-compose.yml')]
    if getenv('PYTEST_DOCKER_HOST') == '_internal':
        network_compose_file = path.join(path.dirname(__file__), 'network.yml')
        compose_files.append(network_compose_file)
    return compose_files


def is_responsive(url):
    """Check if something responds to ``url``."""
    try:
        response = requests.get(url)
        if response.status_code == 200:
            return True
    except ConnectionError:
        return False


def test_endpoint_for(docker_services):
    # Build URL to service listening on random port.
    endpoint = docker_services.endpoint_for('httpbin', 80)
    url = "http://%s:%d/" % endpoint
    logging.debug('Waiting for %s to be responsive ...', url)
    docker_services.wait_until_responsive(
        check=lambda: is_responsive(url), timeout=30.0, pause=0.1
    )

    # Contact the service.
    response = requests.get(url)
    assert response.status_code == 200

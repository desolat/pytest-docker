#!/bin/bash
set -o nounset
#set -o errexit
#set -o xtrace

function get_script_dir(){
    SCRIPT_DIR="$( cd "$( dirname "$( readlink -f "${BASH_SOURCE[0]}" )" )" >/dev/null 2>&1 && pwd )"
    echo $SCRIPT_DIR
}
SCRIPT_DIR=$(get_script_dir)

# @todo: copy the src
docker build $SCRIPT_DIR/pytest_docker -t pytest_docker
mkdir -p results

DEFAULT_ARGS=(
    --volume /var/run/docker.sock:/var/run/docker.sock
    --volume $SCRIPT_DIR/../../src:/pytest_docker/src
    --volume $SCRIPT_DIR/tests:/pytest_docker/tests/
    --volume $SCRIPT_DIR/../../results:/results
    -e PYTEST_DOCKER_LOG_DIR=/results
    -e PYTHONPATH=/pytest_docker/src:/pytest_docker/tests
    --workdir /pytest_docker
    #--env-file $SCRIPT_DIR/debug.env
)

test_host_network() {
    docker run "${DEFAULT_ARGS[@]}" \
        --network host \
        pytest_docker \
        python3 -m pytest \
            -v \
            --log-level DEBUG \
            --log-file /results/containerized_host.pytest.log \
            /pytest_docker/tests/_test_integration_container.py
}

test_bridge_outside() {
    # run pytest in a container in a separate user-defined bridged network (not the same as the SUT)

    # cleanup:
    docker network rm pytest_docker_tests

    docker network create pytest_docker_tests
    docker run "${DEFAULT_ARGS[@]}" \
        -e PYTEST_DOCKER_HOST=ibms-dev.local \
        --add-host ibms-dev.local:192.168.79.20 \
        --network pytest_docker_tests \
        pytest_docker \
        python3 -m pytest \
            -v \
            --log-level DEBUG \
            --log-file /results/containerized_outside.pytest.log \
            /pytest_docker/tests/_test_integration_container.py

    # cleanup:
    docker network rm pytest_docker_tests
}

test_bridge_inside() {
    # run pytest in a container in a the same user-defined bridged network as the SUT

    docker network create pytest_docker_tests
    docker run "${DEFAULT_ARGS[@]}" \
        -e PYTEST_DOCKER_HOST=_internal \
        --network pytest_docker_tests \
        pytest_docker \
        python3 -m pytest \
            -v \
            --log-level DEBUG \
            --log-file /results/containerized_inside.pytest.log \
            /pytest_docker/tests/_test_integration_container.py

    # cleanup:
    docker network rm pytest_docker_tests
}

test_host_network
test_bridge_outside
test_bridge_inside

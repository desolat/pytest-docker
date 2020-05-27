import sys
from setuptools import setup

needs_pytest = {'pytest', 'test', 'ptr'}.intersection(sys.argv)
pytest_runner = ['pytest-runner >= 5.0, <6.0'] if needs_pytest else []

setup(
    setup_requires=["wheel >= 0.32"] + pytest_runner,
    entry_points={"pytest11": ["docker = pytest_docker"]},
)

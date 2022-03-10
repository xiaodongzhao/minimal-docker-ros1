docker build \
    --rm \
    --network=host \
    --tag ros1-dev:melodic \
    --file Dockerfile .
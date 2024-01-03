# /bin/bash

# Build the project
echo "Building the project..."

yarn install

export OPENAI_API_KEY=sk-i3cGJnddfZMgcLiAQnclyxwtcPni91fh9lJxiRROZRU4cNBE
export CODE=123456
export BASE_URL=https://api.chatanywhere.tech

yarn build

docker-compose up -d

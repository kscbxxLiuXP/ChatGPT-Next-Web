FROM node:18-alpine AS base
#--------------------------------------
#yarn install
# FROM base AS deps

# RUN apk add --no-cache libc6-compat

# WORKDIR /app

# COPY package.json yarn.lock ./

# RUN yarn config set registry 'https://registry.npm.taobao.org'
# RUN yarn install
#--------------------------------------
# FROM base AS builder

# RUN apk update && apk add --no-cache git

# ENV OPENAI_API_KEY=""
# ENV GOOGLE_API_KEY=""
# ENV CODE=""

# WORKDIR /app
# COPY node_modules ./node_modules
# COPY . .

# RUN yarn build
#--------------------------------------
FROM base AS runner
WORKDIR /app

RUN apk add proxychains-ng

COPY  public ./public
COPY  .next/standalone ./
COPY  .next/static ./.next/static
COPY  .next/server ./.next/server

EXPOSE 3000

CMD if [ -n "$PROXY_URL" ]; then \
    export HOSTNAME="127.0.0.1"; \
    protocol=$(echo $PROXY_URL | cut -d: -f1); \
    host=$(echo $PROXY_URL | cut -d/ -f3 | cut -d: -f1); \
    port=$(echo $PROXY_URL | cut -d: -f3); \
    conf=/etc/proxychains.conf; \
    echo "strict_chain" > $conf; \
    echo "proxy_dns" >> $conf; \
    echo "remote_dns_subnet 224" >> $conf; \
    echo "tcp_read_time_out 15000" >> $conf; \
    echo "tcp_connect_time_out 8000" >> $conf; \
    echo "localnet 127.0.0.0/255.0.0.0" >> $conf; \
    echo "localnet ::1/128" >> $conf; \
    echo "[ProxyList]" >> $conf; \
    echo "$protocol $host $port" >> $conf; \
    cat /etc/proxychains.conf; \
    proxychains -f $conf node server.js; \
    else \
    node server.js; \
    fi

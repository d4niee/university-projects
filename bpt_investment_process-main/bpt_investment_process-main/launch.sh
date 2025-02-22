#!/bin/bash

export ZEEBE_ADDRESS='zeebe:26500'
export ZEEBE_CLIENT_ID='zeebe'
export ZEEBE_CLIENT_SECRET='zecret'
export CAMUNDA_OAUTH_URL='http://keycloak:18080/auth/realms/camunda-platform/protocol/openid-connect/token'
export CAMUNDA_TASKLIST_BASE_URL='http://tasklist:8080'
export CAMUNDA_OPERATE_BASE_URL='http://operate:8080'
export CAMUNDA_OPTIMIZE_BASE_URL='http://optimize:8090'
export CAMUNDA_MODELER_BASE_URL='http://web-modeler-webapp:8070/api'
export CAMUNDA_SECURE_CONNECTION=false

if [ ! -f /.dockerenv ]; then
    export ZEEBE_ADDRESS='localhost:26500'
    export ZEEBE_CLIENT_ID='zeebe'
    export ZEEBE_CLIENT_SECRET='zecret'
    export CAMUNDA_OAUTH_URL='http://localhost:18080/auth/realms/camunda-platform/protocol/openid-connect/token'
    export CAMUNDA_TASKLIST_BASE_URL='http://localhost:8082'
    export CAMUNDA_OPERATE_BASE_URL='http://localhost:8081'
    export CAMUNDA_OPTIMIZE_BASE_URL='http://localhost:8083'
    export CAMUNDA_MODELER_BASE_URL='http://localhost:8070/api'
    export CAMUNDA_SECURE_CONNECTION=false
    echo "No Docker-Env --> launch docker-compose setup"
    docker-compose up -d postgres pgadmin
    docker-compose -f camunda-platform/docker-compose/camunda-8.6/docker-compose.yaml up -d
    npm install --global yarn
    yarn install
fi

npx ts-node src/index.ts
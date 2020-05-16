#!/usr/bin/env bash

figma=https://raw.githubusercontent.com/figma/plugin-typings/master/index.d.ts
scripter=https://raw.githubusercontent.com/rsms/scripter/master/src/common/scripter-env.d.ts

curl -O ${figma}
curl -O ${scripter}
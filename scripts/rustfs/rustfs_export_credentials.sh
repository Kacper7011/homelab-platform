#!/usr/bin/env bash

export AWS_ACCESS_KEY_ID="$(cat ~/.vault/rustfs/access_key)"
export AWS_SECRET_ACCESS_KEY="$(cat ~/.vault/rustfs/secret_key)" 
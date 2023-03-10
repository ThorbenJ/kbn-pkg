#!/bin/bash

cd -- $(dirname -- $0)

cd kibana

git reset --hard
git clean -dfx .


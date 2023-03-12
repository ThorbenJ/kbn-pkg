#!/bin/bash

cd -- $(dirname -- $0)
MYWD=$PWD

cd kibana
# You can install nix on most Linux, MacOS and Windows: https://nixos.org/download.html
# config defined os/software state, using reproducable builds, use different versions of the same thing easily

# Have a shell with Node.js 16.x as that's what Kibana needs
nix-shell -p nodejs-16_x --run /bin/bash << '_EOM_'

set -e

for e in $(env | cut -f1 -d=); do
    if [[ "PATH,SHELL,TMPDIR,USER,HOME,PWD,SHLVL" != *"$e"* ]]; then
        unset $e
    fi
done
export HOME=$PWD

echo "Inside the land of dragons"
# env
# echo ""
# pwd
# node -v

# Pre-empt Kibana's build system
mkdir -p _local
cd _local
npm install --prefix=. @bazel/bazelisk yarn
export PATH="$PWD/node_modules/.bin:$PATH"
cd ..

# which bazel
# which yarn

# yarn kbn bootstrap
yarn kbn bootstrap --force-install

yarn build --skip-archives --skip-os-packages --skip-canvas-shareable-runtime --skip-docker-ubi --skip-docker-ubuntu --release

_EOM_

echo "kibana build might fail, but hopefully not before its built the packages we want"

cd $MYPWD
npm install


#
# Some notes:
# - Goal is not to build kibana and run it, just select .ts in package/
# - I want to use nix, to keep this build env away from my normal (shell) env.
# - kbn bootstrap will try to install npm packages globally (e.g. bazel); that we lead to permissions errors.
#   Do nodejs devs expect that npm "global dirs" are writable by normal users?
#   So, I would like to keep the land of drangs contained. As such we need to pre-empt the bootstrap and
#   locally install such packages - making sure their bins are in PATH.
# - Same for yarn, install local as the global one maybe "linked" against a different node version
# - node_version_validator.js does very naive version comparison (no support for ^ or ~, etc.)
# - I don't want to become an expert on this build system, I just need some .js files
#

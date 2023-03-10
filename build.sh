#!/bin/bash



cd -- $(dirname -- $0)

cd kibana

# You can install nix on most Linux, MacOS and Windows: https://nixos.org/download.html
# config defined os/software state, using reproducable builds, use different versions of the same thing easily

# Have a shell with Node.js 16.x as that's what Kibana needs
nix-shell -p nodejs-16_x --run bash <<'_EOM_'

echo "Inside the land of dragons"
pwd
node -v

test -f package.json.orig || cp package.json package.json.orig
sed -E -e 's/link:/file:/' <package.json.orig >package.json

npm install --force @bazel/bazelisk yarn
# npm install --force

export PATH=$PWD/node_modules/.bin:$PATH

yarn add intl-format-cache

yarn kbn bootstrap --force-install

peggy -o target/types/packages/kbn-es-query/src/kuery/grammar/index.js packages/kbn-es-query/src/kuery/grammar/grammar.peggy

_EOM_

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

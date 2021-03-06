SHELL := /bin/bash

release:
	@(cd server; mix deps.get; MIX_ENV=prod SECRET_KEY_BASE=$${SECRET_KEY_BASE:-supersecret} mix release)

run: release
	server/_build/prod/rel/checksum/bin/checksum start

run-client:
	client/push-commands.sh

test:
	@(cd server; mix deps.get; mix test)

# How to run

Open two terminal windows

## Server
To run the server:
```sh
make run
```

## Client
requires `jq`, `sed` and `xargs`

to run the client 
```sh
make run-client
```

Client code is just a simple script to POST each command to the api and echo the result.

# Ratinale

## Server

### Architecture

The API serves only one route:
```
checksum_path  POST  /v1/number  ChecksumWeb.ChecksumController :process_command
```

It expects a json with the format above:
```json
{"command": "A123", "id": "some_string"}
```

> `id` is optional and if present creates a new checksum sequence apart from the default one.


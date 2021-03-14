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

### Why Agent instead of Genserver?
For this simple problem there is no need to add an Genserver, an Agent is suited for pure state and thats what we need.

### Why the client is in bash?
Because there is no requirements denying it and the code is simpler, shorter and faster to develop

### Why only integrated test?
Since the logic is simple I see no need to add aditional tests to it. The integrated test `Checksum.ChecksumControllerTest` covers everything and also ensures that things are correclty connected

### Why concurrent checksum sequences
The scope didn't ask for it but since I'm expending my free time doing this exercise I wanted to include this complexity to make things more fun.

### Why use a Registry?
Because process names must be an atom and since we are generating dinamic names based on `id` field it could reach the VM limit of 1,048,576 atoms.

# go-boot

Bootstrap template for Go projects.

**Why this is needed**

- setting up projects takes time.
- setting up features needed in every project take even more time.
- simplify with this template.


**Using**
- git clone
- replace **ALL** occurrences of `github.com/ppanyukov/go-boot` with your own github repo name.
- project structure: 
    - `cmd` folder for executable commands (`main.go`).
        - just for `main.go` files to make executables
        - see `cmd/go-boot/main.go` as example
        - replace it with your own
    - `assets` folder for items to embed in executables
    - `pkg` folder for all other code.
        - `pkg/assets` - provides access to embedded resources
        - `pkg/version` - provides access to version info baked in during build
        - add your own code as extra packages.
- run make to build
    - `make build` - just build the exe
    - `make assets` - rebuild assets embedding
    - `make format test lint build` - these things :)
    - `make all` - equivalent of the above 
- to target different OS/Architecture, use `Z_GOOS` and `Z_GOARCH`, e.g:
    - `Z_GOOS=linux Z_GOARCH=arm make build`
- to run dockerised build:
    - `./build.sh make build`
- dockerised build accepts `Z_GOOS` and `Z_GOARCH`:
    - `Z_GOOS=linux Z_GOARCH=arm ./build.sh make build`
- to build on Windows, use dockerised build.



**Features**

- Some ideas were borrowed from established Prometheus and Thanos projects.
- Go 1.13.
- Apache 2.0 license, but change to your own if needed.
- Project structure: 
    - `cmd` folder for executable commands (`main.go`).
    - `pkg` folder for everything else.
    - `assets` folder for items to embed in executable
- `Makefile` with useful targets and tooling
    - `make format test lint build`
    - `make all` (does the above)
- `.gitignore` file with all the right things ignored, including OS X.
- Goland project settings (`.idea` folder).
- Uses Prometheus `promu` tool to build:
    - See https://github.com/prometheus/promu 
    - Embeds version at build time (using `promu`)
    - Cross-platform builds made easy
- Embed static assets into executable (e.g. HTML, CSS etc), see further



**Embedding static files into executable**

- Place your items in `assets` directory.
- Run `make assets`. This will generate go file with embedded items.
- Run `make build` as usual.
- See example in `cmd/go-boot/main.go`



**Building on Windows**

Best bet is to use these:

- git bash
- Docker

then follow instructions for *Building in Docker*



**Building in Docker**

Use `build.sh` script like so:

```
./build.sh make build
./build.sh make all
```

This will run `make build` etc in docker container. The binaries will be written into `bin` directory and they will be for the hosts's OS and architecture. So if you run this on OS X, they will be Darwin/amd64. On Windows they will be Windows/amd64. And so on.


To target different OS, use `Z_GOOS` and `Z_GOARCH`, e.g.:

```
Z_GOOS=linux Z_GOARCH=arm ./build.sh make all
```



**TODO**

- make it easier to use without replacing references, generate stuff?
- CI builds?
- Docker image builds?
- Windows?

----

**Additional Copyrights**

These Apache 2.0 projects were partially used:

- Thanos: https://github.com/thanos-io/thanos
- Prometheus: https://github.com/prometheus/prometheus
- Prometheus Promu: https://github.com/prometheus/promu/

Parts were adjusted to fit the purpose of this repo.

```
Copyright © Prometheus Team
Copyright © Thanos Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```




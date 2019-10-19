# go-boot

The boostrap template for Go projects.


Why this is needed:

- setting up projects takes time.
- setting up features needed in every project take even more time.
- simplify with this template.


Using this:
- git clone
- replace all occurrences of `github.com/ppanyukov/go-boot` with your own github repo name.


Features:

- Some ideas were borrowed from established Prometheus and Thanos projects.
- Go 1.13.
- Apache 2.0 license, but change to your own if needed.
- Project structure: 
    - `cmd` folder for executable commands (`main.go`).
    - `pkg` folder for everything else.
- `Makefile` with useful targets and tooling
    - `make format test lint build`
    - `make all` (does the above)
- `.gitignore` file with all the right things ignored, including OS X.
- Goland project settings (`.idea` folder).
- Uses Prometheus `promu` tool to build:
    - See https://github.com/prometheus/promu 
    - Embeds version at build time (using `promu`)
    - Cross-platform builds made easy

TODO:

- make it easier to use without replacing references, generate stuff?
- CI builds?
- Docker image builds?

----

Other Copyrights:

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




<!--
	This repository contains a small set of container definitions for
	bioinformatics utilities (currently `aragorn` and `tRNAscan-SE`).
	Each toolkit is organised by release version so that we can build and
	publish immutable images for every supported release while also
	maintaining convenient `latest`, `major` and `minor` tags.
-->

# Container images for bioinformatics tools

This repository provides a simple, reproducible way to build and push
Docker/OCI images for two command‑line utilities:

* **aragorn** – tRNA and tmRNA detection program
* **tRNAscan‑SE** – transfer RNA gene prediction software

Both tools are installed from the [Bioconda](https://bioconda.github.io/)
package channel using **micromamba** running on an Alpine base image. The
resulting containers are small (≈80 MB) and suitable for use in pipelines,
Kubernetes jobs, or as base images for other workflows.

## Repository layout

```
/
├─ aragorn/
│  ├─ 1.2.36/Dockerfile
│  ├─ 1.2.38/Dockerfile
│  └─ 1.2.41/Dockerfile
├─ trnascan-se/
│  ├─ 2.0.0/Dockerfile
│  ├─ 2.0.3/Dockerfile
│  └─ ...
├─ .github/
│  ├─ workflows/build-container.yml        # CI workflow
│  └─ dependabot.yml                       # dependency updates
└─ README.md
```

Each version directory contains a nearly‑identical Dockerfile that
parameterises the package version via an `ARG`.  New releases can be added
simply by creating a new directory and copying one of the existing
Dockerfiles, then updating the `ARG` value and the GitHub Actions matrix.

## Building locally

You can build an image manually with `docker build` or `podman`:

```sh
docker build -t aragorn:1.2.41 ./aragorn/1.2.41
```

Replace `aragorn` with `trnascan-se` and the version string as needed.
The containers rely only on the package installed by micromamba, so no
additional build dependencies are required.

## Continuous Integration

A GitHub Actions workflow (`.github/workflows/build-container.yml`) runs on
every push that touches a `Dockerfile`. The logic is as follows:

1. A **detect** job determines which subdirectories have changed using
	 `git diff`.  If no images are affected the workflow exits early.
2. A **build** job uses a dynamic matrix containing the modified
	 versions, builds the corresponding directories, and pushes the resulting
	 images to `ghcr.io/${{ github.repository }}`.

The workflow also supports manual invocation via `workflow_dispatch` and
includes an option to rebuild every image regardless of changes.

### Tagging scheme

For each version built the following tags are pushed:

* `tool:X.Y.Z` – exact version
* `tool:X.Y` – latest minor release (only for the highest version in that
	minor series)
* `tool:X` – latest major release (only for the highest version overall)
* `tool:latest` – alias for the current major release

For example, building `aragorn/1.2.41` produces:
```
ghcr.io/.../aragorn:1.2.41
ghcr.io/.../aragorn:1.2
ghcr.io/.../aragorn:1
ghcr.io/.../aragorn:latest
```

## Dependency updates

A `dependabot.yml` configuration keeps the GitHub Actions and the base
`mambaorg/micromamba` images up to date.  Pull requests are opened weekly
whenever new versions are available; they are labeled `dependencies` and
either `github-actions` or `docker`.

## Contributing

1. Add a new version directory and update the workflow matrix accordingly.
2. Ensure the new Dockerfile builds successfully locally.
3. Commit and push; the CI will publish images automatically.

Please make sure to re-run `docker build` locally if you change any
shared logic in the Dockerfiles.

## License & Attribution

This repository does not contain the tools themselves, which are
distributed under their respective licenses (GPLv3 for ARAGORN, etc.).
The container definitions are provided under the [MIT License](LICENSE).

---

_Maintained by exTerEX – built with GitHub Actions and micromamba._


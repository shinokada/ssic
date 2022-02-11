# SHC: Svelte Heroicons Creator

This script creates a Svelte-heroicons.

## Requirements

- Bash >= 5
- GNU sed

## Installation

Using [Awesome package manager](https://github.com/shinokada/awesome).

```sh
awesome install shinokada/shc
```

Create a dir and run:

```sh
mkdir ~/Downloads/heroicons
cd ~/Downloads/heroicons
shc hero
```

All the icons are under `main` dir.

Move it to `svelte-heroicons` dir.

Create a package and publish.

```sh
cd /path/to/svelte-heroicons
// update the version in the package.json
npm run package
cd package
npm publish
```

## two command

`shc two` command will create `optimize/outline` and `optimize/solid`
directories and their `index.js` in the dir.
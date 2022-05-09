# SIC: Svelte SVG Icon Creator

This script creates a Svelte-heroicons and simpl-icons.

## Requirements

- Bash >= 5
- GNU sed

## Installation

Using [Awesome package manager](https://github.com/shinokada/awesome).

```sh
awesome install shinokada/ssic
```

## How to create Heroicons

Create a dir and run:

```sh
mkdir ~/Downloads/heroicons && cd $_
ssic hero
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

## How to create Simpleicons

```sh
mkdir ~/Downloads/simpleicons && cd $_
ssic simple
```

## How to create Feathericons

```sh
mkdir ~/Downloads/feathericons && cd $_
ssic feather
```

## How to create Flags

```sh
mkdir ~/Downloads/flags && cd $_
ssic flag
```

## How to create Ionicons

```sh
mkdir ~/Downloads/ion && cd $_
ssic ion
```
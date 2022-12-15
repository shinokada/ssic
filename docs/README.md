# SSIC: Svelte SVG Icon Creator

This Bash script creates SVG icons for Svelte/SvelteKit from a wide variety of icon libraries.

- 780+ Ant design icons
- 2000+ Font Awesome icons
- 1660+ Bootstrap icons
- 330+ Circle flag icons
- 470+ Crypto currency icons
- 280+ Feather icons
- 260+ Flag icons
- 250+ Country flag icons
- 930+ File icons
- 10600+ Material icons
- 460+ Heroicons
- 260+ Heroicons v2
- 1330+ Ionicons
- 590+ Lucide icons
- 6980+ Material design icons
- 500+ Octicons
- 310+ Radix icons
- 2270+ Remixicon
- 2230+ Simple icons
- 1970+ Tabler icons
- 600+ Teeny icons
- 3600+ Twitter emoji icons
- 210+ Weather icons

## Requirements

- Bash >= 5
- GNU sed

## Installation

Using [Awesome package manager](https://github.com/shinokada/awesome).

```sh
awesome install shinokada/ssic
```

## How to create Ant design icons

```sh
mkdir ~/Downloads/ant-design && cd $_
ssic ant
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

## How to create Ionicons

```sh
mkdir ~/Downloads/ion && cd $_
ssic ion
```

## How to create Simpleicons

```sh
mkdir ~/Downloads/simpleicons && cd $_
ssic simple
```
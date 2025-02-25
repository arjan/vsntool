# `vsntool` - Lean-and-mean version bumping tool

[![Build Status](https://travis-ci.org/arjan/vsntool.svg?branch=master)](https://travis-ci.org/arjan/vsntool)

The `vsntool` maintains git tags and a text file, VERSION, which
tracks the current software's version number. It provides an easy
method of bumping the major, mnior and patch versions of the software.

The authoritative version of a project is in the VERSION file. `vsntool` also
automagically synchronizes this version number in several other auto-detected
files in the repository for various frameworks and languages:

- NPM packages — `package.json`
- Expo (React Native) — `app.json` version and versionCode attributes
- Cordova — `config.xml`; both `version=` and `android:versionCode` attributes; `plugin.xml` version
- Erlang / OTP libraries — `src/*.app.src`
- Android — `build.gradle` version and versionCode

By using the `vsntool` commands, the version numbers are automatically patched in these files.

## Installation

Install [Elixir](https://elixir-lang.org/install.html), then execute the following in a terminal:

```bash
mix escript.install hex vsntool
```

## Usage

```
▶ vsntool
0.1.2-1-g88547df
```

Running `vsntool` without arguments runs `git describe --tags`, which
retrieves the last version number, but appended with a unique
identifier which describes the current commit. This is handy in CI
systems and development setups where you often want to build or
release snapshots which contain no official version.

To retrieve the last released version, run:

```
▶ vsntool last
0.1.2
```

(which is equivalent to `cat VERSION`).

The default branch on which the releases are being tagged is
`master` or `main`. To change this, change the environment variable
`VSN_BRANCH`.

When vsntool is run on a non-release branch, the branch name is added
to the version:

```
▶ git checkout develop
▶ vsntool
0.1.2-1-develop.1-g88547df
```

### Initialization

`vsntool init` initializes a VERSION file in a directory and ensures
it has a git repository:

```
▶ mkdir ~/new-project; cd ~/new-project
▶ vsntool init
Initialized git repository
Version bump to 0.0.1 OK.
```

### Version bumping

Once a repo has been initialized, you can use the `bump_major`,
`bump_minor` and `bump_patch` commands to increase the version number:

```
▶ vsntool bump_patch
Version bump to 0.1.2 OK.
```

Note that vsntool will refuse to tag a commit twice:

```
▶ vsntool bump_patch
Current commit is already tagged (0.1.2)
```

To release a new version, do another commit before doing another version bump,
or use the `FORCE=true` environment variable to force the version.

### Development versions / Release candidates workflow

Usually after a release you want to set the current project version to a `dev`
prefix to indicate that this is the current working version. You do this by
specifying `--dev` as a flag:

```
▶ vsntool bump_minor --dev
Version bump to 0.1.0-dev OK.
```

> A `--dev` bump will **not** create a git tag.

Once you are happy with your project, bump it to a release candidate:

```
▶ vsntool bump_rc
Version bump to 0.1.0-rc.0 OK.
```

And create as many release candidates after that as you want:

```
▶ vsntool bump_rc
Version bump to 0.1.0-rc.1 OK.
```

To promote an `dev` or `rc` version to a release, call `vsntool release`:

```
▶ vsntool release
Version bump to 0.1.0 OK.
```

### Usage in Elixir projects

Tracking your Elixir project's version number is easy; in your
`mix.exs` file, you don't hardcode the version number but instead read
it from the VERSION file:

```elixir
  def project do
    [
      app: :myproject,
      version: File.read!("VERSION")
      ...
```

This file is evaluated at compile time, so there is no runtime dependency on the existence of the VERSION file.

When releasing your library as dependency, do not forget to add the VERSION file to the list of to-be-packaged files:

```elixir
  defp package do
    %{
      files: ["lib", "mix.exs", "*.md", "LICENSE", "VERSION"],
      ...
```

### Usage with docker

Build the current project and tag it with the correct version:

```
▶ docker build . -t organisation/projectname:$(vsntool)
```

## Plugins

vsntool "knows" about a few common places where version numbers are stored, and
will detect these automatically, using a plugin system. The currently supported
and shipped plugins are:

- Support for npm `package.json` files
- Expo (React Native)'s `app.json`, both version and versionCode
- Android apps, `build.gradle`, both versionName and versionCode
- Cordova apps, `config.xml`, both version and versionCode
- Cordova apps, `plugin.xml`

## Hooks

To execute code just before a version bump, you can create a file called
`.vsntool/hooks/pre_persist`, which gets called with a single argument, the
version that is going to be bumped.

## Bash / zsh completion

To enable command completion, add the following to your `~/.zshrc` or `~/.bashrc`:

```
complete -W "init bump_major bump_minor bump_patch last" vsntool
```

## Building

vsntool is an Elixir project, but builds as an _escript_, a self-contained binary. To build it, you need to have Elixir installed, then run:

```
▶ make
```

This produces a fresh version of the `vsntool` binary in the root of the repository. Happy versioning!

## Features / todo list

- [x] Plugin system for updating version in framework-specific files
- [x] Add support for dev versions (1.0.0-dev)
- [x] Add support for release-candidate-like versions (1.0.0-rc1)
- [ ] Improve error reporting, error messages (stop using `:os.cmd`)
- [ ] Use [artificery](https://github.com/bitwalker/artificery) for command parsing

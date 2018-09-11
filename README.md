# `vsntool` - Lean-and-mean version bumping tool

The `vsntool` maintains git tags and a text file, VERSION, which
tracks the current software's version number. It provides an easy
method of bumping the major, mnior and patch versions of the software.

## Installation

Copy the provided `vsntool` binary to somewhere in your path.

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
0.1.2-1-g88547df
```

(which is equivalent to `cat VERSION`).


## Initialization

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

To release a new version, do another commit before doing another version bump.

### Usage in Elixir projects

Tracking your Elixir project's version number is easy; in your
`mix.exs` file, you don't hardcode the version number but instead read
it from the VERSION file:

```
  def project do
    [
      app: :vsntool,
      version: File.read!("VERSION")
      ...
```

This file is evaluated at compile time, so there is no runtime dependency on the existence of the VERSION file.

When releasing your library as dependency, do not forget to add the VERSION file to the list of to-be-packaged files:

```
  defp package do
    %{
      files: ["lib", "mix.exs", "*.md", "LICENSE", "VERSION"],
      ...
```

## Bash / zsh completion

To enable command completion, add the following to your `~/.zshrc` or `~/.bashrc`:

```
complete -W "init bump_major bump_minor bump_patch last" vsntool
```


## Building

vsntool is an Elixir project, but builds as an *escript*, a self-contained binary. To build it, run:

```
# mix escript.build
```

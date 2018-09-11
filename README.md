# `vsntool` -- lean-and-mean version bumping tool

## Installation

Copy the provided `vsntool` binary to somewhere in your path.

## Usage

The `vsntool` maintains git tags and a text file, VERSION, which
tracks the current software's version number. It provides an easy
method of bumping the major, mnior and patch versions of the software.

### Getting the current version number

The most recently released version number can be retrieved by
inspecting the VERSION file.

Running `vsntool` without arguments runs `git describe --tags`, which
retrieves the last version number, but appended with a unique
identifier which describes the current commit. This is handy in CI
systems and development setups where you often want to build or
release snapshots which contain no official version.



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

 ## Building

 vsntool is an Elixir project, but builds as an *escript*, a self-contained binary. To build it, run:

```
# mix escript.build
```

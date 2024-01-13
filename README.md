# Ruby like dependency management for Elixir

Why? Because we love Ruby and the way bundle adds / removes dependencies and we wanted to have the same for our Elixir projects. This package contains 2 mix functionalities, __mix deps.add__ and __mix deps.rm__. This allows for easy dependency management.

## Installation
Add both files to /lib/mix/tasks of your current project and voila. Or, you can run the following command, providing your project directory:

```bash
$  mkdir -p PROJECT_DIR/lib/mix/tasks && mv *.ex PROJECT_DIR/lib/mix/tasks
```

## Usage
```bash
$ mix deps.add PACKAGE [--version=VERSION --git=GIT_URL]
$ mix deps.rm PACKAGE
```

## Example
```bash
$ mix deps.add cowboy
$ mix deps.rm cowboy
```

## FAQ
1. Is this the best solution? Nope, it was cobbled together quickly, but hey, it works.
2. Can it be improved? Definitely. Especially error handling.
2. Can I do it? Of course, feel free to send pull requests.

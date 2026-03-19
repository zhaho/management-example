# management-example

A Taskfile-driven workflow for generating Kubernetes namespace and resource manifests for multiple teams, in either **YAML** or **JSON** format.

## Prerequisites

| Tool | Purpose | Install |
|---|---|---|
| [Task](https://taskfile.dev) | Task runner | `sh -c "$(curl --location https://taskfile.dev/install.sh)"` |
| [yq](https://github.com/mikefarah/yq) | YAML parse & JSON conversion | `snap install yq` or download binary |
| `envsubst` | Variable substitution in templates | `apt install gettext-base` (usually pre-installed) |

## Project structure

```
.
├── Taskfile.yml               # Task definitions
├── source/
│   ├── base/                  # Base K8s manifest templates (use ${VAR} placeholders)
│   │   ├── namespace.yaml
│   │   ├── resourcequota.yaml
│   │   ├── limitrange.yaml
│   │   └── rolebinding.yaml
│   └── teams/                 # One YAML file per team with their specific values
│       ├── team-alpha.yaml
│       └── team-beta.yaml
└── deploy/                    # Generated output (git-ignored or committed as needed)
    ├── yaml/
    │   ├── team-alpha/        # namespace.yaml, resourcequota.yaml, …
    │   └── team-beta/
    └── json/
        ├── team-alpha/        # namespace.json, resourcequota.json, …
        └── team-beta/
```

## Available tasks

```
task                              # List all tasks
task list-teams                   # Show all configured teams

task generate                     # Generate YAML for all teams (default)
task generate FORMAT=json         # Generate JSON for all teams
task generate:yaml                # Alias for FORMAT=yaml
task generate:json                # Alias for FORMAT=json

task generate:team TEAM=team-alpha             # YAML for one team
task generate:team TEAM=team-alpha FORMAT=json # JSON for one team

task new-team TEAM=my-team                          # Scaffold new team (name = namespace)
task new-team TEAM=my-team NAMESPACE=my-ns ENV=staging  # Full options

task clean                        # Remove all generated files
```

## How it works

1. Each file under `source/teams/` describes one team (name, namespace, environment, resource limits).
2. The Taskfile exports those values as environment variables and runs `envsubst` against every template in `source/base/`.
3. When `FORMAT=json`, the substituted YAML is piped through `yq -o json` before writing.
4. Output lands in `deploy/<format>/<team>/`.

## Adding a new resource type

Create a new template file in `source/base/` using the same `${VAR}` placeholders. It will automatically be picked up the next time you run any `generate` task.

Available variables in templates:

| Variable | Source field |
|---|---|
| `${NAMESPACE}` | `.namespace` |
| `${TEAM_NAME}` | `.name` |
| `${ENVIRONMENT}` | `.environment` |
| `${TEAM_GROUP}` | `.group` |
| `${CPU_REQUEST}` | `.resources.cpu_request` |
| `${CPU_LIMIT}` | `.resources.cpu_limit` |
| `${MEMORY_REQUEST}` | `.resources.memory_request` |
| `${MEMORY_LIMIT}` | `.resources.memory_limit` |
| `${MAX_PODS}` | `.resources.pods` |


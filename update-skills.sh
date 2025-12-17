#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: update-skills.sh [OPTIONS]

Downloads/updates opencode skills listed in a skills.json file.

Options:
  -c, --config PATH       Path to skills.json (default: ~/.config/opencode/skills.json)
  -s, --skills-dir PATH   Destination skills directory (default: <config-dir>/skills)
  -h, --help              Show this help and exit

Config File Format:
  The config file is a JSON array of objects with the following fields:
    - repo: Git repository URL or local path
    - ref: Branch, tag, or commit to fetch
    - path: Path within the repository to checkout

Example skills.json:
[
  {
    "repo": "https://github.com/borisnaydis/skillkit",
    "ref": "main",
    "path": "architecture-advisor"
  }
]
EOF
}

expand_tilde() {
    local path="$1"

    if [[ "$path" == "~" ]]; then
        printf '%s\n' "$HOME"
        return
    fi

    if [[ "$path" == "~/"* ]]; then
        printf '%s\n' "$HOME/${path:2}"
        return
    fi

    printf '%s\n' "$path"
}

resolve_path() {
    local path
    path="$(expand_tilde "$1")"

    if [[ "$path" != /* ]]; then
        path="$(pwd -P)/$path"
    fi

    printf '%s\n' "$path"
}

# Defaults (must not depend on this script's location)
CONFIG_FILE="$HOME/.config/opencode/skills.json"
PROJECT_SKILLS_DIR=""

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--config)
            if [[ $# -lt 2 ]]; then
                echo "Error: $1 requires a path." >&2
                usage >&2
                exit 2
            fi
            CONFIG_FILE="$2"
            shift 2
            ;;
        -s|--skills-dir)
            if [[ $# -lt 2 ]]; then
                echo "Error: $1 requires a path." >&2
                usage >&2
                exit 2
            fi
            PROJECT_SKILLS_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -* )
            echo "Error: Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
        *)
            echo "Error: Unexpected argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if [[ $# -gt 0 ]]; then
    echo "Error: Unexpected argument: $1" >&2
    usage >&2
    exit 2
fi

CONFIG_FILE="$(resolve_path "$CONFIG_FILE")"

if [[ -z "$PROJECT_SKILLS_DIR" ]]; then
    PROJECT_SKILLS_DIR="$(dirname "$CONFIG_FILE")/skills"
fi

PROJECT_SKILLS_DIR="$(resolve_path "$PROJECT_SKILLS_DIR")"

# We avoid creating a persistent repo clone inside the project.
# For each entry we use a temporary sparse+shallow checkout.

# Check dependencies
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' is required but not found." >&2
    exit 1
fi

# Ensure directories exist
mkdir -p "$PROJECT_SKILLS_DIR"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Config file not found at $CONFIG_FILE" >&2
    exit 1
fi

echo "Reading configuration from $CONFIG_FILE..."

TMP_ROOT=$(mktemp -d)
trap 'rm -rf "$TMP_ROOT"' EXIT

# Parse JSON and loop through entries
# Output format: repo|ref|path
while IFS='|' read -r repo ref path; do
    echo "---------------------------------------------------"
    echo "Processing: $path"
    echo "  Source: $repo ($ref)"

    # Create a temporary sparse checkout for just this path.
    # Notes:
    # - Uses a temporary directory (no persistent cache under the project).
    # - Uses sparse checkout so only "$path" is materialized.
    # - Uses a shallow fetch for the requested ref.
    tmp_checkout="$TMP_ROOT/checkout"
    rm -rf "$tmp_checkout"
    mkdir -p "$tmp_checkout"

    echo "  - Creating sparse checkout..."
    git -C "$tmp_checkout" init -q
    git -C "$tmp_checkout" remote add origin "$repo"

    git -C "$tmp_checkout" config core.sparseCheckout true
    git -C "$tmp_checkout" sparse-checkout init --cone
    git -C "$tmp_checkout" sparse-checkout set "$path"

    echo "  - Fetching $ref (shallow)..."
    # Try both "ref" and "refs/heads/ref" to support branches.
    git -C "$tmp_checkout" fetch -q --depth 1 origin "$ref" 2>/dev/null \
        || git -C "$tmp_checkout" fetch -q --depth 1 origin "refs/heads/$ref"

    git -C "$tmp_checkout" -c advice.detachedHead=false checkout -q --force FETCH_HEAD >/dev/null

    # Sync the specific path
    src="$tmp_checkout/$path"
    skill_name=$(basename "$path")
    dest="$PROJECT_SKILLS_DIR/$skill_name"

    if [ -d "$src" ]; then
        echo "  - Installing to $dest..."
        rm -rf "$dest"
        cp -R "$src" "$dest"
        
        # Add warning file
        echo "# GENERATED DIRECTORY - DO NOT EDIT" > "$dest/.generated_warning"
        echo "Source: $repo" >> "$dest/.generated_warning"
        echo "Ref: $ref" >> "$dest/.generated_warning"
        echo "Path: $path" >> "$dest/.generated_warning"
        echo "Run update-skills.sh to update (see --help)." >> "$dest/.generated_warning"
    else
        echo "  ! Error: Path '$path' not found in repo."
    fi
done < <(jq -r '.[] | "\(.repo)|\(.ref)|\(.path)"' "$CONFIG_FILE")

echo "---------------------------------------------------"
echo "Done."

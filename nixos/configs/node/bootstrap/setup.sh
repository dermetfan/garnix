if [[ ! -f flake.nix ]]; then
	>&2 echo 'This script must be run from the repo root.'
	exit 1
fi

set -e

# pin.nix
# Generic import script for a URL contained in an adjacent file.
# URL is adjacent so it can be called by other utilities without importing.
import (builtins.fetchTarball (import ./url.nix))

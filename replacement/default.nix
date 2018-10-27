let
  spec = builtins.fromJSON (builtins.readFile ./default.src.json);
  rev = spec.rev;
  url = "https://github.com/${spec.owner}/${spec.repo}/archive/${spec.rev}.tar.gz";
in
  import (builtins.fetchTarball url)

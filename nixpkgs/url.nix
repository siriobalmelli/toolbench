# Produce a valid tarball URL.
# In this case we just point to the latest commit,
# committing to that branch will automatically update the "pinned" nixpkgs.
let
  spec = {
    "owner"= "siriobalmelli-foss";
    "repo"= "nixpkgs";
    "branch"= "sirio";
  };
in
  "https://github.com/${spec.owner}/${spec.repo}/archive/${spec.branch}.tar.gz"

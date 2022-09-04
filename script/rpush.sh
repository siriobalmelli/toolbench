##
# rpush : rsync push
# quick and dirty push script;
# develop on one machine and build on another
#
# 2022 Sirio Balmelli
##
REMOTE_DIR="$(basename "$(realpath .)")"_rpush
git ls-files --recurse-submodules \
	| rsync -avhPe ssh --files-from=- ./ "$1":"$REMOTE_DIR/"

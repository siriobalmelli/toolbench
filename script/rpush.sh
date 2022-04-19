##
# rpush : rsync push
# quick and dirty push script;
# develop on one machine and building on another
#
# 2022 Sirio Balmelli
##
rsync -avhPe ssh --delete \
	--exclude=.git --exclude='build_*' --exclude='build-*' \
	./ "$1":"$(basename "$(realpath .)")"_rpush/

#!/bin/sh
# Make sure 'real' data partition is as big as possible
thin_vol_pool=lvol0
volgroup_name=mysql
target=/dev/mapper/${volgroup_name}-${thin_vol_pool}

if [ -b "${target}" ]
then
	echo "Extending backing data volume to maximum size"
	lvextend -l +100%FREE "${target}"
fi 2>&1 | logger -t thin_data

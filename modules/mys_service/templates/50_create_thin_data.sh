#!/bin/sh
set -e
# Create thin LVM data partition if missing
thin_vol_name=data
#thin_vol_size=500G
#thin_vol_fs_type=ext4
#thin_vol_fs_type_options='-T largefile4 -E lazy_itable_init=-1,lazy_journal_init=-1 -m 0'
thin_vol_fs_type=xfs
thin_vol_fs_type_options=''
initial_thin_pool_size=5G
thin_metadata_size=20M
volgroup_name=mysql
physical_vol=/dev/vda2
thin_vol=/dev/mapper/${volgroup_name}-lvol0
target=/dev/${volgroup_name}/${thin_vol_name}

if [ -b "${target}" ]
then
	echo "Data Partition already exists"
else
	echo "Generating Thin Data Partition"
	if [ -b "${physical_vol}" ]
	then
	    parted -s -a none -- "${physical_vol%%[0-9]*}" resizepart ${physical_vol##*[!0-9]} -1s
	fi
	vgcreate "${volgroup_name}" "${physical_vol}"
	lvcreate --thin \
		 --size "${initial_thin_pool_size}" \
		 --poolmetadatasize "${thin_metadata_size}" \
		 "${volgroup_name}"
	#Extend to full size. 100%FREE doesn't work on initial create.
	lvextend -l +100%FREE "${thin_vol}"
	thin_vol_size=$(lvs --noheading --unit S "${thin_vol}"|grep -o '[0-9]*S')
  	lvcreate --thin \
		 --name "${thin_vol_name}" \
		 --virtualsize "${thin_vol_size}" \
		 "${thin_vol}"
 	mkfs -t "${thin_vol_fs_type}" ${thin_vol_fs_type_options} -q \
	        -L "${volgroup_name}-${thin_vol_name}" "${target}"
fi 2>&1 | logger -t thin_data

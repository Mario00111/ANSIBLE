#!/bin/bash

archive_dir=${1}
archive_doss="${2}/"
archive_nom="${2}.tar"

cd 
cd ..
cd $archive_dir
tar cf $archive_nom $archive_doss

exit $?
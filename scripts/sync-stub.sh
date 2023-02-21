#!/usr/bin/env bash
set -e

#lead='^### BEGIN STUB'
#tail='^### END STUB'
#sed -e "/$lead/,/$tail/{ /$lead/{p; r scripts/stub/Makefile
#}; /$tail/p; d }" -i ./*/Makefile

shopt -s extglob
ls !(scripts)/**/Makefile | xargs -n 1 cp scripts/stub/Makefile

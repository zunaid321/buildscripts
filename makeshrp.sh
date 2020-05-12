#!/bin/bash
cp_p()
{
   strace -q -ewrite cp -- "${1}" "${2}" 2>&1 \
      | awk '{
        count += $NF
            if (count % 10 == 0) {
               percent = count / total_size * 100
               printf "%3d%% [", percent
               for (i=0;i<=percent;i++)
                  printf "="
               printf ">"
               for (i=percent;i<100;i++)
                  printf " "
               printf "]\r"
            }
         }
         END { print "" }' total_size=$(stat -c '%s' "${1}") count=0
}

## Variables
ROM_DIR=""$HOME"/android/shrp"
BUILD_DIR=""$HOME"/android/shrp/out/target/product/beyond2lte/"

## Environment
set -e
cd "$ROM_DIR"
export ALLOW_MISSING_DEPENDENCIES=true
source "$ROM_DIR/build/envsetup.sh" || :

## Build
echo "Starting EvoX For Beyond2lte(S10+)"
		
lunch omni_beyond2lte-eng || :
mka recoveryimage -j120

## Upload
cd "$BUILD_DIR"
latestbuild=$(ls -t SHRP_*_beyond2lte-*.zip | head -n1)
echo "${latestbuild}"
cp_p ${latestbuild} /home/zunaidaminenan/S10PlusBuilds/SHRP_Recovery_S10Plus/${latest}
rsync -avz --info=progress2 /home/zunaidaminenan/S10PlusBuilds/SHRP_Recovery_S10Plus/${latest} zunaid321@frs.sourceforge.net:/home/frs/project/zunaid-s10plus-builds/S10PlusBuilds/SHRP_Recovery_S10Plus/${latest}


echo "The build has been successfully uploaded!"

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
ROM_DIR=""$HOME"/android/derpfest"
BUILD_DIR=""$HOME"/android/derpfest/out/target/product/beyond2lte/"

## Environment
set -e
cd "$ROM_DIR"
export WITH_MAGISK=true
source "$ROM_DIR/build/envsetup.sh"

## Sync
echo "Syncing latest changes for EvoX"

repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags -j60

## Build
echo "Starting EvoX For Beyond2lte(S10+)"
		
lunch derp_beyond2lte-eng
time mka kronic -j120

## Upload
cd "$BUILD_DIR"
latestbuild=$(ls -t DerpFest-10-Community-beyond2lte-*.zip | head -n1)
echo "${latestbuild}"
cp_p ${latestbuild} /home/zunaidaminenan/S10PlusBuilds/Derpfest/${latest}
rsync -avz --info=progress2 /home/zunaidaminenan/S10PlusBuilds/Derpfest/${latest} zunaid321@frs.sourceforge.net:/home/frs/project/zunaid-s10plus-builds/S10PlusBuilds/Derpfest/${latest}


echo "The build has been successfully uploaded!"

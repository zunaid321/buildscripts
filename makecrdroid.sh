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
ROM="crdroid"
ROM_DIR=""$HOME"/android/"$ROM""
BUILD_DIR=""$HOME"/android/"$ROM"/out/target/product/beyond2lte/"

## Environment
set -e
cd "$ROM_DIR"
export WITH_MAGISK=true
source "$ROM_DIR/build/envsetup.sh"

## Sync
echo "Syncing latest changes for "$ROM""

repo sync -j60

## Build
echo "Starting "$ROM" For Beyond2lte(S10+)"
		
lunch lineage_beyond2lte-eng
time mka bacon -j120

## Upload
cd "$BUILD_DIR"
latestbuild=$(ls -t crDroidAndroid-10.0-*-beyond2lte-v6.6.zip | head -n1)
echo "${latestbuild}"
cp_p changelog_beyond2lte.txt /home/zunaidaminenan/S10PlusBuilds/Crdroid/changelog_beyond2lte.txt
cp_p ${latestbuild} /home/zunaidaminenan/S10PlusBuilds/Crdroid/${latest}
rsync -avz --info=progress2 /home/zunaidaminenan/S10PlusBuilds/Crdroid/changelog_beyond2lte.txt zunaid321@frs.sourceforge.net:/home/frs/project/zunaid-s10plus-builds/S10PlusBuilds/Crdroid/changelog_beyond2lte.txt
rsync -avz --info=progress2 /home/zunaidaminenan/S10PlusBuilds/Crdroid/${latest} zunaid321@frs.sourceforge.net:/home/frs/project/zunaid-s10plus-builds/S10PlusBuilds/Crdroid/${latest}


echo "The "$ROM" build has been successfully uploaded!"

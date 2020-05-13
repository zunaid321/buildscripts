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
ROM="pe"
ROM_FOLDER="Pixel_Experience"
ROM_DIR=""$HOME"/android/"$ROM""
BUILD_DIR=""$HOME"/android/"$ROM"/out/target/product/beyond2lte/"

## Environment
set -e
cd "$ROM_DIR"
export WITH_MAGISK=true
source "$ROM_DIR/build/envsetup.sh"

## Sync
echo "Syncing latest changes for "$ROM_FOLDER""

repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

## Build
echo "Starting "$ROM_FOLDER" For Beyond2lte(S10+)"
		
lunch aosp_beyond2lte-eng
time mka bacon -j120

## Upload
cd "$BUILD_DIR"
latestbuild=$(ls -t PixelExperience_beyond2lte-10.0-*-UNOFFICIAL.zip | head -n1)
latestchangelog=$(ls -t PixelExperience_beyond2lte-10.0-*-UNOFFICIAL-Changelog.txt | head -n1)

echo "The latest build is "${latestbuild}""

echo "Copying Changelog"
cp_p ${latestchangelog} /home/zunaidaminenan/S10PlusBuilds/"$ROM_FOLDER"/${latestchangelog}

echo "Copying ROM"
cp_p ${latestbuild} /home/zunaidaminenan/S10PlusBuilds/"$ROM_FOLDER"/${latest}

echo "Uploading Changelog"
rsync -avz --info=progress2 /home/zunaidaminenan/S10PlusBuilds/"$ROM_FOLDER"/${latestchangelog} zunaid321@frs.sourceforge.net:/home/frs/project/zunaid-s10plus-builds/S10PlusBuilds/"$ROM_FOLDER"/${latestchangelog}

echo "Uploading ROM"
rsync -avz --info=progress2 /home/zunaidaminenan/S10PlusBuilds/"$ROM_FOLDER"/${latest} zunaid321@frs.sourceforge.net:/home/frs/project/zunaid-s10plus-builds/S10PlusBuilds/"$ROM_FOLDER"/${latest}


echo "The "$ROM_FOLDER" build has been successfully uploaded!"

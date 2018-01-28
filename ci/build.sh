#!/bin/bash
set -ev

TAG=$1

echo "Download und extract sourcemod"
wget "http://www.sourcemod.net/latest.php?version=1.8&os=linux" -O sourcemod.tar.gz
tar -xzf sourcemod.tar.gz

echo "Give compiler rights for compile"
chmod +x addons/sourcemod/scripting/spcomp

echo "Set plugins version"
sed -i "s/<TAG>/$TAG/g" addons/sourcemod/scripting/hexprops.sp
  
addons/sourcemod/scripting/compile.sh hexprops.sp

echo "Remove plugins folder if exists"
if [ -d "addons/sourcemod/plugins" ]; then
  rm -r addons/sourcemod/plugins
fi

echo "Create clean plugins folder"
mkdir -p build/addons/sourcemod/scripting/include
mkdir -p build/addons/sourcemod/configs/props
mkdir build/addons/sourcemod/plugins

echo "Move plugins files to their folder"
mv addons/sourcemod/scripting/include/hexprops.inc build/addons/sourcemod/scripting/include
mv addons/sourcemod/scripting/hexprops.sp build/addons/sourcemod/scripting
mv addons/sourcemod/scripting/compiled/hexprops.smx build/addons/sourcemod/plugins
mv addons/sourcemod/configs/props/hextags.cfg build/addons/sourcemod/configs/props


echo "Compress the plugin"
mv LICENSE build/
cd build/ && zip -9rq hexpros.zip addons/ LICENSE && mv hexprops.zip ../

echo "Build done"
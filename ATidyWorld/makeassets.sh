#! /bin/sh
TP=/usr/local/bin/texturepacker
if [ "${ACTION}" = "clean" ]
then
# remove sheets - please add a matching expression here
rm Resources/Art/SpriteSheet*.png
rm Resources/Art/SpriteSheet*.xml
else
# create all assets from tps files
${TP} *.tps
fi

exit 0
#!/bin/sh

#  PackTextures.sh
#  CocosWhackMole
#
#  Created by 欧 on 11/05/16.
#  Copyright 2011 __MyCompanyName__. All rights reserved.

TP="/usr/local/bin/TexturePacker"

if [ "${ACTION}" = "clean" ]
then
    echo "cleaning..."

    rm resources/background*
    rm resources/foreground*
    rm resources/sprites*

else
    echo "building..."

    ${TP} --smart-update \
        --format cocos2d \
        --data resources/background-hd.plist \
        --sheet resources/background-hd.pvr.ccz \
        --dither-fs \
        --opt RGB565 \
        Art/background/*.png

    ${TP} --smart-update \
        --format cocos2d \
        --data resources/background.plist \
        --sheet resources/background.pvr.ccz \
        --dither-fs \
        --scale 0.5 \
        --opt RGB565 \
        Art/background/*.png

    ${TP} --smart-update \
        --format cocos2d \
        --data resources/foreground-hd.plist \
        --sheet resources/foreground-hd.pvr.ccz \
        --dither-fs-alpha \
        --opt RGBA4444 \
        Art/foreground/*.png

    ${TP} --smart-update \
        --format cocos2d \
        --data resources/foreground.plist \
        --sheet resources/foreground.pvr.ccz \
        --dither-fs-alpha \
        --scale 0.5 \
        --opt RGBA4444 \
        Art/foreground/*.png

    ${TP} --smart-update \
        --format cocos2d \
        --data resources/sprites-hd.plist \
        --sheet resources/sprites-hd.pvr.ccz \
        --dither-fs-alpha \
        --opt RGBA4444 \
        Art/sprites/*.png

    ${TP} --smart-update \
        --format cocos2d \
        --data resources/sprites.plist \
        --sheet resources/sprites.pvr.ccz \
        --dither-fs-alpha \
        --scale 0.5 \
        --opt RGBA4444 \
        Art/sprites/*.png

fi
exit 0
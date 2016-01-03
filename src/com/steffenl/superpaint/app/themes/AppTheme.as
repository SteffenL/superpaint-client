package com.steffenl.superpaint.app.themes {

import com.steffenl.superpaint.app.controls.gallery.GalleryList;

import feathers.controls.List;
import feathers.skins.StyleNameFunctionStyleProvider;
import feathers.themes.MetalWorksMobileTheme;

public class AppTheme extends MetalWorksMobileTheme {
    protected override function initializeStyleProviders():void {
        super.initializeStyleProviders();

        const listStyleProvider:StyleNameFunctionStyleProvider = getStyleProviderForClass(List);
        listStyleProvider.setFunctionForStyleName(GalleryList.THUMBNAIL_LIST_STYLE_NAME, setThumbnailListStyles);
    }

    private function setThumbnailListStyles(list:List):void {
        // Use the default style as a base
        super.setListStyles(list);

        list.scrollBarDisplayMode = List.SCROLL_BAR_DISPLAY_MODE_NONE;
        list.decelerationRate = List.DECELERATION_RATE_FAST;
    }
}
}

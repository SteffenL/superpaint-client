package com.steffenl.superpaint.app.controls.gallery {
/**
 * Taken from Feathers' Gallery example
 */
public class GalleryItem {
    public function GalleryItem(title:String, url:String, thumbURL:String) {
        this.title = title;
        this.url = url;
        this.thumbURL = thumbURL;
    }

    public var title:String;
    // This can point to a remote or local resource
    public var url:String;
    public var thumbURL:String;
}
}

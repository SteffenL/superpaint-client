package com.steffenl.superpaint.core.document.detail {
import com.steffenl.superpaint.core.document.*;

public class LocalDocumentStoreEntry implements IDocumentStoreEntry {
    private var _path:String;

    public function LocalDocumentStoreEntry(path:String) {
        _path = path;
    }

    public function getPath():String {
        return _path;
    }
}
}

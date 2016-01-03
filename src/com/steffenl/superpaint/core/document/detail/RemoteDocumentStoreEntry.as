package com.steffenl.superpaint.core.document.detail {
import com.steffenl.superpaint.core.document.*;

public class RemoteDocumentStoreEntry implements IDocumentStoreEntry {
    private var _path:String;

    public function RemoteDocumentStoreEntry(path:String) {
        _path = path;
    }

    public function getPath():String {
        return _path;
    }
}
}

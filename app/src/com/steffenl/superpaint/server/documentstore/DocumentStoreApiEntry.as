package com.steffenl.superpaint.server.documentstore {

public class DocumentStoreApiEntry {
    private var _id:String;
    private var _path:String;

    public function DocumentStoreApiEntry(id:String, path:String) {
        _id = id;
        _path = path;
    }

    public function get id():String {
        return _id;
    }

    public function get path():String {
        return _path;
    }
}
}

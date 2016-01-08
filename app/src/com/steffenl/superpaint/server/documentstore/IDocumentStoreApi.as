package com.steffenl.superpaint.server.documentstore {

public interface IDocumentStoreApi {
    function getListing():void;
    function signals():DocumentStoreApiSignals;
}
}

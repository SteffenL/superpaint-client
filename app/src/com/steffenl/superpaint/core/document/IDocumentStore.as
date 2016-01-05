package com.steffenl.superpaint.core.document {
public interface IDocumentStore {
    function getListing():void;
    function signals():DocumentStoreSignals;
}
}

//
//  StreamToFileOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 7/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class StreamToFileOperation: NSOperation, NSStreamDelegate, NSURLConnectionDataDelegate {
    
    let remoteURL: NSURL
    private var stream: NSOutputStream?
    var error: NSError?
    var mediaURL: NSURL?
    
    init( remoteURL: NSURL ) {
        self.remoteURL = remoteURL
    }
    
    var filePath: String {
        let paths = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true )
        if var path = paths.first as? String, let filename = self.remoteURL.lastPathComponent {
            //path = path.stringByAppendingPathComponent( "com.getvictorious.gifSearch" )
            path = path.stringByAppendingPathComponent( filename )
            return path
        }
        fatalError( "Unable to find file path for temporary media download." )
    }
    
    override func main() {
        self.stream = NSOutputStream(toFileAtPath: self.filePath, append: false )
        if let stream = self.stream {
            stream.open()
            NSURLConnection.sendSynchronousRequest( NSURLRequest(URL: self.remoteURL), returningResponse: nil, error: nil )
            stream.delegate = self
            stream.close()
            self.mediaURL = NSURL(fileURLWithPath: filePath)
        }
        
        if self.mediaURL == nil {
            fatalError( "Unable to create output stream." )
        }
    }
    
    // MARK: - NSURLConnectionDataDelegate
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        
    }
    
    func connection(connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
        <#code#>
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        var bytesRemaining = data.length
        while let bytesWritten = self.stream?.write( UnsafePointer<UInt8>(data.bytes), maxLength: data.length ) where bytesWritten >= 0 && bytesRemaining > 0 {
            bytesRemaining -= bytesWritten
        }
    }
    
    // MARK: - NSStreamDelegate
    
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.ErrorOccurred:
            self.error = NSError(domain: "", code: Int(eventCode.rawValue), userInfo: nil )
        default: ()
        }
    }
}

class LoadImageOperation: NSOperation {
    
    let remoteURL: NSURL
    var error: NSError?
    var image: UIImage?
    
    init( remoteURL: NSURL ) {
        self.remoteURL = remoteURL
    }
    
    override func main() {
        var error: NSError?
        if let previewImageData = NSData(contentsOfURL: self.remoteURL, options: nil, error: &error),
            let image = UIImage(data: previewImageData) {
                self.image = image
        }
    }
}
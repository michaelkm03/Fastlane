//
//  GIFSearchViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

private extension UIView {
    
    /// UIView extension
    /// parameter `pattern`: Closure to call to determine if view is the one sought
    /// returns: A view that passes the test or nil
    func findSubview( pattern: (UIView)->(Bool) ) -> UIView? {
        for subview in self.subviews as! [UIView] {
            if pattern( subview ) {
                return subview
            }
            else if let result = subview.findSubview( pattern ) {
                return result
            }
        }
        return nil
    }
}

private extension UISearchBar {
    
    /// Returns the text field into which users type their search string
    var textField: UITextField? {
        return self.findSubview({ $0 is UITextField }) as? UITextField
    }
}

class GIFSearchViewController: UIViewController, VMediaSource {
    
    enum Action: Selector {
        case Next = "onNext:"
    }
    
    static let headerViewHeight: CGFloat = 50.0
    static let defaultSectionMargin: CGFloat = 10.0
    static let noContentCellHeight: CGFloat = 150.0

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let operationQueue = NSOperationQueue()
    
    var selectedIndexPath: NSIndexPath?
    
    let searchDataSource = GIFSearchDataSource()
    
    static func viewControllerFromStoryboard() -> GIFSearchViewController {
        let bundle = UIStoryboard(name: "GIFSearch", bundle: nil)
        if let viewController = bundle.instantiateInitialViewController() as? GIFSearchViewController {
            return viewController
        }
        fatalError( "Could not load GIFSearchViewController from storyboard." )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        self.searchBar.textField?.textColor = UIColor.whiteColor()
        self.searchBar.textField?.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        
        self.collectionView.dataSource = self.searchDataSource
        self.collectionView.delegate = self
        self.searchBar.placeholder = NSLocalizedString( "Search", comment:"" )
        
        self.navigationItem.titleView = self.titleViewWithTitle( NSLocalizedString( "GIF", comment:"" ) )
        
        let nextTitle = NSLocalizedString( "Next", comment: "" )
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: nextTitle, style: .Plain, target: self, action: Action.Next.rawValue )
        
        self.performSearch()
    }
    
    func downloadPathForRemotePath( remotePath: String ) -> String {
        let filename = remotePath.lastPathComponent
        let paths = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true )
        if var path = paths.first as? String {
            //path = path.stringByAppendingPathComponent( "com.getvictorious.gifSearch" )
            path = path.stringByAppendingPathComponent( filename )
            return path
        }
        fatalError( "Unable to find file path for temporary media download." )
    }
    
    func onNext( sender: AnyObject? ) {
        if let indexPath = self.selectedIndexPath {
            let selectedGIF = self.searchDataSource.sections[ indexPath.section ][ indexPath.row ]
            self.loadMedia( selectedGIF ) { (previewImage, mediaUrl, error) in
                
                if let previewImage = previewImage, let mediaURL = mediaUrl {
                    self.handler?( previewImage, mediaURL )
                }
                else {
                    println( "Error: \(error)" )
                }
            }
        }
    }
    
    private func loadMedia( gifSearchResult: GIFSearchResult, completion: (previewImage: UIImage?, mediaUrl: NSURL?, error: NSError?)->()) {
        
        let downloadPath = self.downloadPathForRemotePath( gifSearchResult.mp4Url )
        if let previewImageURL = NSURL(string: gifSearchResult.thumbnailStillUrl),
            let videoURL = NSURL(string: gifSearchResult.mp4Url ),
            let videoOutputStream = NSOutputStream(toFileAtPath: downloadPath, append: false ) {
                
                let imageOperation = LoadImageOperation(remoteURL: previewImageURL)
                let videoOperation = AFURLConnectionOperation(request: NSURLRequest(URL: videoURL))
                videoOperation.completionBlock = {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(
                            previewImage: imageOperation.image,
                            mediaUrl: NSURL(string: downloadPath),
                            error: nil )
                    }
                }
                videoOperation.outputStream = videoOutputStream
                videoOperation.addDependency( imageOperation )
                self.operationQueue.addOperation( imageOperation )
                self.operationQueue.addOperation( videoOperation )
        }
    }
    
    private func titleViewWithTitle( text: String ) -> UIView {
        var label = UILabel()
        label.text = text
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        return label
    }
    
    private func performSearch( _ searchText: String = "" ) {
        self.searchDataSource.performSearch( searchText ) {
            self.collectionView.setContentOffset( CGPoint.zeroPoint, animated: true )
            self.collectionView.reloadData()
        }
    }
    
    private func clearSearch() {
        self.searchDataSource.clear()
        self.collectionView.reloadData()
    }
    
    func updateSelectionState() {
        for indexPath in self.collectionView.indexPathsForVisibleItems() as! [NSIndexPath] {
            if let selectedIndexPath = self.selectedIndexPath,
                let cell = self.collectionView.cellForItemAtIndexPath(indexPath) {
                cell.selected = (indexPath == selectedIndexPath)
            }
        }
    }
    
    // MARK: - VMediaSource
    
    var handler: VMediaSelectionHandler?
}

extension GIFSearchViewController : UISearchBarDelegate {
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.clearSearch()
        self.performSearch( searchText )
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

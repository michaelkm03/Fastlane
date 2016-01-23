//
//  MediaSearchDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

/// This object adapts the use of a `PaginatedDataSource` to the whackier
/// multiple-section layout in of MediaSearchViewController.
class MediaSearchDataSourceAdapter: NSObject, UICollectionViewDataSource {
	
	struct ReuseIdentifier {
		static let AttributionHeader = "MediaSearchAttributionView" ///< Set in storyboard
		static let ActivityFooter = "MediaSearchActivityFooter" ///< Set in storyboard
	}
	
	/// A type used to record data source chanages that can then be applied to the collection
	/// view in a `performBatchUpdates(_:completion)` call.
	struct ChangeResult {
		var deletedSections: NSIndexSet?
		var insertedSections: NSIndexSet?
		var error: NSError?
		
		var hasChanges: Bool {
			return self.deletedSections?.count > 0 || self.insertedSections?.count > 0
		}
	}
	
	/// A type for organizing search results into grouped sections
	struct Section {
		
		/// The minimum amount of top and bottom space between a fullsize
		/// search result and the colleciton view bounds
		static let MinCollectionContainerMargin: CGFloat = 50.0
		
		let results: [MediaSearchResult]
		
		let isFullSize: Bool
		
		subscript( index: Int ) -> MediaSearchResult {
			return self.results[ index ]
		}
		
		var count: Int {
			return self.results.count
		}
	}
	
    var hasLoadedLastPage: Bool {
        return dataSource?.hasLoadedLastPage ?? true
    }
    
    var state: DataSourceState {
        return dataSource?.state ?? .Cleared
    }
    
	private(set) var sections: [Section] = []
	
	private var highlightedSection: (section: Section, indexPath: NSIndexPath)?
	
    var dataSource: MediaSearchDataSource?
	
	func performSearch( searchTerm searchTerm: String?, pageType: VPageType, completion: ((ChangeResult?)->())? ) {
		guard let dataSource = self.dataSource else {
			fatalError( "Attempt to perform a search without configuring a data source" )
		}
		dataSource.performSearch(searchTerm: searchTerm, pageType: pageType) { error in
            if let results = dataSource.visibleItems.array as? [MediaSearchResult] where error == nil {
                let result = self.updateDataSource(results, pageType: pageType)
                completion?(result)
            }
		}
    }

    /// Clears the backing model, highlighted section and cancels any in-progress search operation
    func clear() -> ChangeResult {
        var result = ChangeResult()
        self.highlightedSection = nil
        if self.sections.count > 0 {
            let range = NSRange( location: 0, length: self.sections.count )
            result.deletedSections = NSIndexSet(indexesInRange: range)
            result.insertedSections = NSIndexSet(index:0)
        } else {
            result.deletedSections = NSIndexSet(index:0)
            result.insertedSections = NSIndexSet(index:0)
        }
        self.sections = []
        self.dataSource?.unload()
        return result
    }
	
    /// Removes the current full size asset section, wherever it may be.
    func removeHighlightSection() -> ChangeResult {
        var result = ChangeResult()
        if let highlightedSection = self.highlightedSection {
            let sectionIndex = highlightedSection.indexPath.section
            self.sections.removeAtIndex( sectionIndex )
            self.highlightedSection = nil
            result.deletedSections = NSIndexSet(index: sectionIndex)
        }
        return result
    }
    
    /// Adds a section beneath that shows the fullsize
    /// asset for the item at the index path.
    func addHighlightSection( forIndexPath indexPath: NSIndexPath ) -> ChangeResult {
        var result = self.removeHighlightSection()
        
        let targetIndexPath: NSIndexPath = {
            if let deletedSection = result.deletedSections?.indexGreaterThanIndex(0) where deletedSection < indexPath.nextSection() {
                return indexPath.previousSectionIndexPath()
            }
            return indexPath
        }()
        
        let resultToHighlight = self.sections[ targetIndexPath.section ][ targetIndexPath.row ]
        let section = Section(results: [ resultToHighlight ], isFullSize: true )
        self.sections.insert( section, atIndex: targetIndexPath.nextSection() )
        self.highlightedSection = (section, targetIndexPath.nextSectionIndexPath())
        
        result.insertedSections = NSIndexSet(index: targetIndexPath.nextSection())
        return result
    }
    
    // MARK: - Private
    
    private func updateDataSource( results: [MediaSearchResult], pageType: VPageType ) -> ChangeResult {
        var result = ChangeResult()
        if pageType == .First {
            if self.sections.count == 0 && results.count > 0 {
                result.deletedSections = NSIndexSet(index: 0) // No content cell
            }
            else if self.sections.count > 0 && results.count == 0 {
                let range = NSRange( location: 0, length: self.sections.count )
                result.deletedSections = NSIndexSet(indexesInRange: range)
            }
            self.sections = []
        }
        let prevSectionCount = self.sections.count
        for var i = 0; i < results.count; i+=2 {
            let resultsForSection: [MediaSearchResult] = {
                if i + 1 < results.count {
                    return [results[i], results[i+1]]
                }
                else {
                    return [results[i]]
                }
            }()
            
            let section = Section( results:resultsForSection, isFullSize: false )
            self.sections.append( section )
        }
        let range = NSRange( location: prevSectionCount, length: self.sections.count - prevSectionCount )
        result.insertedSections = NSIndexSet(indexesInRange: range)
        return result
	}
	
	// MARK: - UICollectionViewDataSource
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.sections.count == 0 ? 1 : self.sections[ section ].count
	}
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return self.sections.count == 0 ? 1 : self.sections.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		if self.sections.count == 0,
			let cell = collectionView.dequeueReusableCellWithReuseIdentifier( MediaSearchNoContentCell.ReuseIdentifier, forIndexPath: indexPath ) as? MediaSearchNoContentCell {
				self.configureNoContentCell( cell, forState: self.state )
				return cell
		}
		
		let section = self.sections[ indexPath.section ]
		let resultObject = section.results[ indexPath.row ]
		if section.isFullSize,
			let cell = collectionView.dequeueReusableCellWithReuseIdentifier( MediaSearchPreviewCell.ReuseIdentifier, forIndexPath: indexPath ) as? MediaSearchPreviewCell {
				cell.previewAssetUrl = resultObject.thumbnailImageURL
				cell.assetUrl = resultObject.sourceMediaURL
				return cell
				
		} else if let cell = collectionView.dequeueReusableCellWithReuseIdentifier( MediaSearchResultCell.ReuseIdentifier, forIndexPath: indexPath ) as? MediaSearchResultCell {
			cell.assetUrl = resultObject.thumbnailImageURL
			
			if let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems() {
				cell.selected = indexPathsForSelectedItems.contains( indexPath )
			}
			return cell
		}
		
		fatalError( "Could not find cell." )
	}
	
	func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		
		if indexPath.section == 0 {
			return collectionView.dequeueReusableSupplementaryViewOfKind( UICollectionElementKindSectionHeader, withReuseIdentifier: ReuseIdentifier.AttributionHeader, forIndexPath: indexPath )
		}
		return collectionView.dequeueReusableSupplementaryViewOfKind( UICollectionElementKindSectionFooter, withReuseIdentifier: ReuseIdentifier.ActivityFooter, forIndexPath: indexPath )
	}
	
	// MARK: - Helpers
	
	private func configureNoContentCell( cell: MediaSearchNoContentCell, forState state: DataSourceState ) {
		switch state {
		case .Loading:
			cell.text = ""
			cell.loading = true
		case .Error:
			cell.text = NSLocalizedString( "Error loading results", comment:"" )
			cell.loading = false
		case .Results where self.sections.count == 0:
			cell.loading = false
			cell.text = NSLocalizedString( "No results", comment:"" )	
		default:
			cell.text = ""
			cell.loading = false
		}
    }
}

/// Some convenience methods to easily get next/prev sections as Int or NSIndexPath.
private extension NSIndexPath {
	
	func nextSection() -> Int { return self.section + 1 }
	
	func nextSectionIndexPath() -> NSIndexPath {
		return NSIndexPath(forRow: self.row, inSection: self.nextSection() )
	}
	
	func previousSection() -> Int { return self.section - 1 }
	
	func previousSectionIndexPath() -> NSIndexPath {
		return NSIndexPath(forRow: self.row, inSection: self.previousSection() )
	}
}

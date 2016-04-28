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
		static let attributionHeader = "MediaSearchAttributionView" ///< Set in storyboard
		static let activityFooter = "MediaSearchActivityFooter" ///< Set in storyboard
	}
    
    weak var delegate: VPaginatedDataSourceDelegate?
	
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
		static let minCollectionContainerMargin: CGFloat = 50.0
		
		let results: [MediaSearchResult]
		
		let isFullSize: Bool
		
		subscript( index: Int ) -> MediaSearchResult {
			return self.results[ index ]
		}
		
		var count: Int {
			return self.results.count
		}
	}
    
    var state: VDataSourceState {
        return dataSource?.state ?? .Cleared
    }
    
	private(set) var sections: [Section] = []
	
	private var highlightedSection: (section: Section, indexPath: NSIndexPath)?
	
    var dataSource: MediaSearchDataSource?
	
	func performSearch( searchTerm searchTerm: String?, pageType: VPageType, completion: ((ChangeResult?) -> ())? ) {
		guard let dataSource = self.dataSource else {
			fatalError( "Attempt to perform a search without configuring a data source" )
		}
        let resultsBefore = self.dataSource?.visibleItems ?? NSOrderedSet()
        dataSource.performSearch(searchTerm: searchTerm, pageType: pageType) { error in
            if let results = dataSource.visibleItems.array.filter({ !resultsBefore.containsObject($0) }) as? [MediaSearchResult] {
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
        self.dataSource?.cancelCurrentOperation()
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
            if self.sections.isEmpty && results.count > 0 {
                result.deletedSections = NSIndexSet(index: 0) // No content cell
            }
            else if self.sections.count > 0 && results.isEmpty {
                let range = NSRange( location: 0, length: self.sections.count )
                result.deletedSections = NSIndexSet(indexesInRange: range)
            }
            self.sections = []
        }
        let prevSectionCount = self.sections.count
        
        var i = 0
        while i < results.count {
            let resultsForSection: [MediaSearchResult] = {
                if i + 1 < results.count {
                    return [results[i], results[i + 1]]
                }
                else {
                    return [results[i]]
                }
            }()
            i += 2
            
            let section = Section( results: resultsForSection, isFullSize: false )
            self.sections.append( section )
        }
        let range = NSRange( location: prevSectionCount, length: self.sections.count - prevSectionCount )
        result.insertedSections = NSIndexSet(indexesInRange: range)
        return result
	}
	
	// MARK: - UICollectionViewDataSource
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.sections.isEmpty ? 1 : self.sections[ section ].count
	}
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return self.sections.isEmpty ? 1 : self.sections.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		if self.sections.isEmpty,
			let cell = collectionView.dequeueReusableCellWithReuseIdentifier( MediaSearchNoContentCell.defaultReuseIdentifier, forIndexPath: indexPath ) as? MediaSearchNoContentCell {
				self.configureNoContentCell( cell, forState: self.state )
				return cell
		}
		
		let section = self.sections[ indexPath.section ]
		let resultObject = section.results[ indexPath.row ]
		if section.isFullSize,
			let cell = collectionView.dequeueReusableCellWithReuseIdentifier( MediaSearchPreviewCell.defaultReuseIdentifier, forIndexPath: indexPath ) as? MediaSearchPreviewCell {
				cell.previewAssetUrl = resultObject.thumbnailImageURL
				cell.assetUrl = resultObject.sourceMediaURL
				return cell
				
		} else if let cell = collectionView.dequeueReusableCellWithReuseIdentifier( MediaSearchResultCell.defaultReuseIdentifier, forIndexPath: indexPath ) as? MediaSearchResultCell {
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
			return collectionView.dequeueReusableSupplementaryViewOfKind( UICollectionElementKindSectionHeader, withReuseIdentifier: ReuseIdentifier.attributionHeader, forIndexPath: indexPath )
		}
		return collectionView.dequeueReusableSupplementaryViewOfKind( UICollectionElementKindSectionFooter, withReuseIdentifier: ReuseIdentifier.activityFooter, forIndexPath: indexPath )
	}
	
	// MARK: - Helpers
	
    private func configureNoContentCell( cell: MediaSearchNoContentCell, forState state: VDataSourceState ) {
		switch state {
		case .Loading:
			cell.text = ""
			cell.loading = true
		case .Error:
			cell.text = NSLocalizedString( "Error loading results", comment:"" )
			cell.loading = false
        case .NoResults:
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

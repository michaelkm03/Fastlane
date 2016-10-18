//
//  MediaSearchDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK
private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
		var deletedSections: IndexSet?
		var insertedSections: IndexSet?
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
        return dataSource?.state ?? .cleared
    }
    
	private(set) var sections: [Section] = []
	
	private var highlightedSection: (section: Section, indexPath: IndexPath)?
	
    var dataSource: MediaSearchDataSource?
	
	func performSearch( searchTerm: String?, pageType: VPageType, completion: ((ChangeResult?) -> ())? ) {
		guard let dataSource = self.dataSource else {
			fatalError( "Attempt to perform a search without configuring a data source" )
		}
        let resultsBefore = self.dataSource?.visibleItems ?? NSOrderedSet()
        dataSource.performSearch(searchTerm: searchTerm, pageType: pageType) { error in
            if let results = dataSource.visibleItems.array.filter({ !resultsBefore.contains($0) }) as? [MediaSearchResult] {
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
            result.deletedSections = IndexSet(integersIn: range.toRange() ?? 0..<0)
            result.insertedSections = IndexSet(integer:0)
        } else {
            result.deletedSections = IndexSet(integer:0)
            result.insertedSections = IndexSet(integer:0)
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
            let sectionIndex = (highlightedSection.indexPath as NSIndexPath).section
            self.sections.remove( at: sectionIndex )
            self.highlightedSection = nil
            result.deletedSections = IndexSet(integer: sectionIndex)
        }
        return result
    }
    
    /// Adds a section beneath that shows the fullsize
    /// asset for the item at the index path.
    func addHighlightSection( forIndexPath indexPath: IndexPath ) -> ChangeResult {
        var result = self.removeHighlightSection()
        
        let targetIndexPath: IndexPath = {
            if let deletedSection = result.deletedSections?.integerGreaterThan(0) , deletedSection < indexPath.nextSection() {
                return indexPath.previousSectionIndexPath()
            }
            return indexPath
        }()
        
        let resultToHighlight = self.sections[ (targetIndexPath as NSIndexPath).section ][ (targetIndexPath as NSIndexPath).row ]
        let section = Section(results: [ resultToHighlight ], isFullSize: true )
        self.sections.insert( section, at: targetIndexPath.nextSection() )
        self.highlightedSection = (section, targetIndexPath.nextSectionIndexPath())
        
        result.insertedSections = IndexSet(integer: targetIndexPath.nextSection())
        return result
    }
    
    // MARK: - Private
    
    private func updateDataSource( _ results: [MediaSearchResult], pageType: VPageType ) -> ChangeResult {
        var result = ChangeResult()
        if pageType == .first {
            if self.sections.isEmpty && results.count > 0 {
                result.deletedSections = IndexSet(integer: 0) // No content cell
            }
            else if self.sections.count > 0 && results.isEmpty {
                let range = NSRange( location: 0, length: self.sections.count )
                result.deletedSections = IndexSet(integersIn: range.toRange() ?? 0..<0)
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
        result.insertedSections = IndexSet(integersIn: range.toRange() ?? 0..<0)
        return result
	}
	
	// MARK: - UICollectionViewDataSource
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.sections.isEmpty ? 1 : self.sections[ section ].count
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.sections.isEmpty ? 1 : self.sections.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if self.sections.isEmpty,
			let cell = collectionView.dequeueReusableCell( withReuseIdentifier: MediaSearchNoContentCell.defaultReuseIdentifier, for: indexPath ) as? MediaSearchNoContentCell {
				self.configureNoContentCell( cell, forState: self.state )
				return cell
		}
		
		let section = self.sections[ (indexPath as NSIndexPath).section ]
		let resultObject = section.results[ (indexPath as NSIndexPath).row ]
		if section.isFullSize,
			let cell = collectionView.dequeueReusableCell( withReuseIdentifier: MediaSearchPreviewCell.defaultReuseIdentifier, for: indexPath ) as? MediaSearchPreviewCell {
				cell.previewAssetUrl = resultObject.thumbnailImageURL
				cell.assetUrl = resultObject.sourceMediaURL
				return cell
				
		} else if let cell = collectionView.dequeueReusableCell( withReuseIdentifier: MediaSearchResultCell.defaultReuseIdentifier, for: indexPath ) as? MediaSearchResultCell {
			cell.assetUrl = resultObject.thumbnailImageURL
			
			if let indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems {
				cell.isSelected = indexPathsForSelectedItems.contains( indexPath )
			}
			return cell
		}
		
		fatalError( "Could not find cell." )
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		if (indexPath as NSIndexPath).section == 0 {
			return collectionView.dequeueReusableSupplementaryView( ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ReuseIdentifier.attributionHeader, for: indexPath )
		}
		return collectionView.dequeueReusableSupplementaryView( ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: ReuseIdentifier.activityFooter, for: indexPath )
	}
	
	// MARK: - Helpers
	
    private func configureNoContentCell( _ cell: MediaSearchNoContentCell, forState state: VDataSourceState ) {
		switch state {
		case .loading:
			cell.text = ""
			cell.loading = true
		case .error:
			cell.text = NSLocalizedString( "Error loading results", comment:"" )
			cell.loading = false
        case .noResults:
			cell.loading = false
			cell.text = NSLocalizedString( "No results", comment:"" )
        default:
			cell.text = ""
			cell.loading = false
		}
    }
}

/// Some convenience methods to easily get next/prev sections as Int or NSIndexPath.
private extension IndexPath {
	
	func nextSection() -> Int { return (self as NSIndexPath).section + 1 }
	
	func nextSectionIndexPath() -> IndexPath {
		return IndexPath(row: (self as NSIndexPath).row, section: self.nextSection() )
	}
	
	func previousSection() -> Int { return (self as NSIndexPath).section - 1 }
	
	func previousSectionIndexPath() -> IndexPath {
		return IndexPath(row: (self as NSIndexPath).row, section: self.previousSection() )
	}
}

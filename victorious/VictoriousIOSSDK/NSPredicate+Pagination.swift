//
//  NSPredicate+Pagination.swift
//  victorious
//
//  Created by Patrick Lynch on 1/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

//public extension NSPredicate {
//	
//	public convenience init(vsdk_format format: String, vsdk_argumentArray argumentArray: [AnyObject]?, vsdk_paginator paginator: NumericPaginator ) {
//		let connector = format.isEmpty ? "" : " && "
//		let paginationFormat = connector + "displayOrder >= %@ && displayOrder < %@"
//		let paginationArguments: [AnyObject] = [paginator.displayOrderRangeStart, paginator.displayOrderRangeEnd]
//		self.init(format: format + paginationFormat, argumentArray: (argumentArray ?? []) + paginationArguments)
//	}
//	
//	public convenience init(vsdk_paginator paginator: NumericPaginator ) {
//		self.init(vsdk_format: "", vsdk_argumentArray: [], vsdk_paginator: paginator)
//	}
//}

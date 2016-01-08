//
//  NSPredicate+Pagination.swift
//  victorious
//
//  Created by Patrick Lynch on 1/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension NSPredicate {
	
	convenience init(vsdk_format format: String, v_argumentArray argumentArray: [AnyObject]?, v_paginator paginator: NumericPaginator ) {
		let start = (paginator.pageNumber - 1) * paginator.itemsPerPage
		let end = start + paginator.itemsPerPage
		let connector = format.isEmpty ? "" : " && "
		let paginationFormat = connector + "displayOrder >= %@ && displayOrder < %@"
		let paginationArguments: [AnyObject] = [start, end]
		self.init(format: format + paginationFormat, argumentArray: (argumentArray ?? []) + paginationArguments)
	}
	
	convenience init(v_paginator paginator: NumericPaginator ) {
		self.init(vsdk_format: "", v_argumentArray: [], v_paginator: paginator)
	}
}

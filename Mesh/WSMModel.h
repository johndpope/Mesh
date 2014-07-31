//
//  WSMModel.h
//  Mesh
//
//  Created by Cristian Monterroza on 9/21/13.
//  Copyright (c) 2013 wrkstrm. All rights reserved.
//

/**
 * CBLModel subclass which adds the "type property for DynamicSubclassing and geoJSON.
 */

@interface WSMModel : CBLModel

/**
 This string links back to the CBLModel used during runtime. 
 Also, if the document is a geoJSON document, it identifies the data structure.
 */

@property (nonatomic, strong) NSString *type;

- (NSString *)docID;

@end

//
//  SGPathManager.h
//  CheckBox
//
//  Created by Bobo on 9/19/15.
//  Copyright (c) 2015 Boris Emorine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGCheckBox.h"

/** Path object used by SGCheckBox to generate paths.
 */
@interface SGPathManager : NSObject

/** The paths are assumed to be created in squares. 
 * This is the size of width, or height, of the paths that will be created.
 */
@property (nonatomic) CGFloat size;

/** The width of the lines on the created paths.
 */
@property (nonatomic) CGFloat lineWidth;

/** The corner radius of the path when the boxType is SGBoxTypeSquare.
 */
@property (nonatomic) CGFloat cornerRadius;

/** The type of box.
 * Depending on the box type, paths may be created differently
 * @see SGBoxType
 */
@property (nonatomic) SGBoxType boxType;

/** Returns a UIBezierPath object for the box of the checkbox
 * @returns The path of the box.
 */
- (UIBezierPath *)pathForBox;

/** Returns a UIBezierPath object for the checkmark of the checkbox
 * @returns The path of the checkmark.
 */
- (UIBezierPath *)pathForCheckMark;

/** Returns a UIBezierPath object for an extra long checkmark which is in contact with the box.
 * @returns The path of the checkmark.
 */
- (UIBezierPath *)pathForLongCheckMark;

/** Returns a UIBezierPath object for the flat checkmark of the checkbox
 * @see SGAnimationTypeFlat
 * @returns The path of the flat checkmark.
 */
- (UIBezierPath *)pathForFlatCheckMark;

@end

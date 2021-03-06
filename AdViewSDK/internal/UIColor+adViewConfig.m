/*

 UIColor+AdViewConfig.m

  Copyright 2010 www.adview.cn

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 */

#import "UIColor+AdViewConfig.h"
#import "AdViewConfig.h"

@implementation UIColorHelper

+ (id)initWithDict:(NSDictionary *)dict {
  id red, green, blue, alpha;
  CGFloat r, g, b, a;
	
	UIColor *ret = [[UIColor alloc]init];

  red   = [dict objectForKey:@"red"];
  if (red == nil) {
    [ret release];
    return nil;
  }
  green = [dict objectForKey:@"green"];
  if (green == nil) {
    [ret release];
    return nil;
  }
  blue  = [dict objectForKey:@"blue"];
  if (blue == nil) {
    [ret release];
    return nil;
  }

  NSInteger temp;
  if (!advIntVal(&temp, red)) {
    [ret release];
    return nil;
  }
  r = (CGFloat)temp/255.0;
  if (!advIntVal(&temp, green)) {
    [ret release];
    return nil;
  }
  g = (CGFloat)temp/255.0;
  if (!advIntVal(&temp, blue)) {
    [ret release];
    return nil;
  }
  b = (CGFloat)temp/255.0;

  a = 1.0; // default 1.0
  alpha = [dict objectForKey:@"alpha"];
  CGFloat temp_f;
  if (alpha != nil && advFloatVal(&temp_f, alpha)) {
    a = (CGFloat)temp_f;
  }

  return [ret initWithRed:r green:g blue:b alpha:a];
}

@end

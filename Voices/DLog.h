#ifdef DEBUG
#include <libgen.h>
#define DLogm()
#define DLog(xx, ...)
#define DLogv(var)
#define DLogv_separator()
#define DLogi(int) DLog( @"(int) "# int " = %i", int );
#define DLogNSInteger(NSInteger) DLog( @"(NSInteger) "# NSInteger " = %ld", (long)NSInteger );
#define DLogf(float) DLog( @"(float) "# float " = %f", float );
#define DLogrect(CGRect) DLog( @"(CGRect) "# CGRect " = %@", NSStringFromCGRect(CGRect) );
#define DLogpoint(CGPoint) DLog( @"(CGPoint) "# CGPoint " = %@", NSStringFromCGPoint(CGPoint) );
#define DLogsize(CGSize) DLog( @"(CGPSize) "# CGSize " = %@", NSStringFromCGSize(CGSize) );
#define DLogbool(BOOL) DLog( @"(BOOL) "# BOOL " = %@", ( BOOL == YES ? @"YES" : @"NO" ) );
#define DLoginsets(UIEdgeInsets) DLog( @"(UIEdgeInsets) "# UIEdgeInsets " = %@", NSStringFromUIEdgeInsets(UIEdgeInsets) );

#else
#define DLog(...) /* */
#define DLogv(var) /* */
#define DLogm() /* */
#define DLogv_separator() /* */
#define DLogi(int) /* */
#define DLogNSInteger(NSInteger) /* */
#define DLogf(float) /* */
#define DLogrect(CGRect) /* */
#define DLogpoint(CGPoint) /* */
#define DLogsize(CGSize) /* */
#define DLogbool(BOOL) /* */
#define DLoginsets(UIEdgeInsets) /* */

#endif

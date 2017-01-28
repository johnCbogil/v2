#ifdef DEBUG
#include <libgen.h>
#define DLogm() NSLog(@"[%s:%d %@]",basename((char *)__FILE__),__LINE__,NSStringFromSelector(_cmd))
#define DLog(xx, ...) NSLog(@"%s(%d): " xx, ((strrchr(__FILE__, '/') ? : __FILE__- 1) + 1), __LINE__, ##__VA_ARGS__)
#define DLogv(var) NSLog(@"[%s:%d %@] "# var " = %@",basename((char *)__FILE__),__LINE__,NSStringFromSelector(_cmd), var)
#define DLogv_separator() NSLog( @"────────────────────────────────────────────────────────────────────────────" );
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

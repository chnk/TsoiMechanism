//
//  ProblemView.m
//  TsoiMechanism
//
//  Created by Brennan Maddox on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProblemView.h"

#define iPad UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define MOLECULE_WIDTH 240.0f
#define MOLECULE_MULTIPLIER (iPad ? 2.0f : 1.0f)

#define HITBOX_SIZE (iPad ? 80.0f : 40.0f)

@implementation ProblemView

@synthesize problems, electrophileMarker, nucleophileMarker, problemMarkersArray, movableMarker, arrowStack;

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) 
    {
        electrophileMarker = nil;
        nucleophileMarker = nil;
        showProblemMarkers = FALSE;
        problemMarkersArray = [[NSMutableArray alloc] init];
        movableMarker = nil;
        arrowStack = [[NSMutableArray alloc] init];
        arrowInProgress = FALSE;
        arrowOrder = 1;
        problems = [Problems shared];
        [problems randomize];
        [self setNeedsDisplay];
    }
    return self;
}

-(void) showNextProblem 
{
    [problems getNext];
    [problemMarkersArray removeAllObjects];
    if (showProblemMarkers == TRUE)
    {
        [self setProblemMarkers];
    }
    [arrowStack removeAllObjects];
    arrowOrder = 1;
    if (electrophileMarker != nil)
    {
        [electrophileMarker release];
        electrophileMarker = nil;
    }
    if (nucleophileMarker != nil)
    {
        [nucleophileMarker release];
        nucleophileMarker = nil;
    }
    if (movableMarker != nil) 
    {
        [movableMarker release];
        movableMarker = nil;
    }
    [self setNeedsDisplay];
}

-(CGPoint) isHitbox:(CGPoint)point 
{
    
    int moleculeIndex = 0;
    if (point.x > (MOLECULE_WIDTH * MOLECULE_MULTIPLIER)) 
    {
        moleculeIndex = 1;
        point.x -= (MOLECULE_WIDTH * MOLECULE_MULTIPLIER);
    }
    
    Molecule *molecule = [[problems getCurrent].moleculeArray objectAtIndex:moleculeIndex];
    
    for (Element *element in [molecule.elements allValues]) 
    {    
        if (CGRectContainsPoint(CGRectMake((element.location.x * MOLECULE_MULTIPLIER) - (HITBOX_SIZE / 2.0f), (element.location.y * MOLECULE_MULTIPLIER) - (HITBOX_SIZE / 2.0f), HITBOX_SIZE, HITBOX_SIZE), point))
        {
            if (moleculeIndex == 1)
            {
                return CGPointMake((element.location.x* MOLECULE_MULTIPLIER) + (MOLECULE_WIDTH * MOLECULE_MULTIPLIER), element.location.y * MOLECULE_MULTIPLIER);
            } else {
                return CGPointMake(element.location.x * MOLECULE_MULTIPLIER, element.location.y * MOLECULE_MULTIPLIER);
            }
        }
    }
    
    for (Bond *bond in [molecule.bonds allValues])
    {
        if (CGRectContainsPoint(CGRectMake((bond.location.x * MOLECULE_MULTIPLIER) - (HITBOX_SIZE / 2.0f), (bond.location.y * MOLECULE_MULTIPLIER) - (HITBOX_SIZE / 2.0f), HITBOX_SIZE, HITBOX_SIZE), point))
        {
            if (moleculeIndex == 1)
            {
                return CGPointMake((bond.location.x * MOLECULE_MULTIPLIER) + (MOLECULE_WIDTH * MOLECULE_MULTIPLIER), bond.location.y * MOLECULE_MULTIPLIER);
            } else {
                return CGPointMake(bond.location.x * MOLECULE_MULTIPLIER, bond.location.y * MOLECULE_MULTIPLIER);
            }
        }
    }
    
    return CGPointMake(-1.0f, -1.0f);
}

-(CGPoint) isHitbox:(CGPoint)point ofType:(int) type
{
    int moleculeIndex = 0;
    if (point.x > (MOLECULE_WIDTH * MOLECULE_MULTIPLIER)) 
    {
        moleculeIndex = 1;
        point.x -= (MOLECULE_WIDTH * MOLECULE_MULTIPLIER);
    }
    
    Molecule *molecule = [[problems getCurrent].moleculeArray objectAtIndex:moleculeIndex];
    
    for (Element *element in [molecule.elements allValues]) 
    {
        if ((element.type == type) && CGRectContainsPoint(CGRectMake((element.location.x * MOLECULE_MULTIPLIER) - (HITBOX_SIZE / 2.0f), (element.location.y * MOLECULE_MULTIPLIER) - (HITBOX_SIZE / 2.0f), HITBOX_SIZE, HITBOX_SIZE), point))
        {
            if (moleculeIndex == 1)
            {
                return CGPointMake(element.location.x + (MOLECULE_WIDTH * MOLECULE_MULTIPLIER), element.location.y * MOLECULE_MULTIPLIER);
            } else {
                return CGPointMake(element.location.x * MOLECULE_MULTIPLIER, element.location.y * MOLECULE_MULTIPLIER);
            }
        }
    }
    
    return CGPointMake(-1.0f, -1.0f);
}

-(void) showElectrophileMarker:(CGPoint)point
{
    if (electrophileMarker != nil)
    {
        [electrophileMarker release];
        electrophileMarker = nil;
    }
    
    electrophileMarker = [[Marker alloc] init];
    electrophileMarker.type = ELEMENT_ELECTROPHILE;
    electrophileMarker.point = point;
    [self setNeedsDisplay];
}

-(void) clearElectrophileMarker
{
    if (electrophileMarker != nil)
    {
        [electrophileMarker release];
        electrophileMarker = nil;
        [self setNeedsDisplay];
    }
}

-(void) showNucleophileMarker:(CGPoint)point
{
    if (nucleophileMarker != nil)
    {
        [nucleophileMarker release];
        nucleophileMarker = nil;
    }
    
    nucleophileMarker = [[Marker alloc] init];
    nucleophileMarker.type = ELEMENT_NUCLEOPHILE;
    nucleophileMarker.point = point;
    [self setNeedsDisplay];
}

-(void) clearNucleophileMarker
{
    if (nucleophileMarker != nil)
    {
        [nucleophileMarker release];
        nucleophileMarker = nil;
        [self setNeedsDisplay];
    }
}

-(void) showProblemMarkers
{
    showProblemMarkers = TRUE;
    if ([problemMarkersArray count] == 0)
    {
        [self setProblemMarkers];
    }
    [self setNeedsDisplay];
}

-(void) clearProblemMarkers
{
    showProblemMarkers = FALSE;
    [self setNeedsDisplay];
}

-(void) createMovableMarker:(CGPoint)point ofType:(int)type
{
    if (movableMarker == nil)
    {
        movableMarker = [[Marker alloc] init];
    }
    
    movableMarker.point = point;
    movableMarker.type = type;
    
    [self setNeedsDisplay];
}

-(void) setMovableMarkerPosition:(CGPoint)point
{
    if (movableMarker != nil)
    {
        movableMarker.point = point;
        [self setNeedsDisplay];
    }
}

-(int) getMovableMarkerType
{
    if (movableMarker != nil)
    {
        return movableMarker.type;
    } else 
    {
        return -1;
    }
}

-(void) clearMovableMarker
{
    if (movableMarker != nil)
    {
        [movableMarker release];
        movableMarker = nil;
        [self setNeedsDisplay];
    }
}

-(void) startArrow:(CGPoint)point 
{
    if (arrowInProgress)
    {
        [arrowStack removeLastObject];
    }
    arrowInProgress = TRUE;
    Arrow *arrow = [[Arrow alloc] init];
    arrow.locationA = point;
    arrow.locationB = CGPointMake(-1.0f, -1.0f);
    arrow.order = arrowOrder;
    [arrowStack addObject:arrow];
    [arrow release];
}

-(void) setArrowEnd:(CGPoint)point 
{
    if (arrowInProgress)
    {
        ((Arrow*)[arrowStack lastObject]).locationB = point;
        [self setNeedsDisplay];
    }
}

-(BOOL) isArrowInProgress
{
    if (arrowInProgress) 
    {
        return TRUE;
    } else 
    {
        return FALSE;
    }
}

-(void) endArrow:(CGPoint)point 
{
    arrowInProgress = FALSE;
    Arrow *lastArrow = (Arrow*)[arrowStack lastObject];
    if (!CGPointEqualToPoint(point, lastArrow.locationA))
    {
        arrowOrder++;
        lastArrow.locationB = point;
    } else
    {
        [arrowStack removeLastObject];
    }
    [self setNeedsDisplay];
    
}

-(void) removeLastArrow 
{
    arrowInProgress = FALSE;
    arrowOrder--;
    [arrowStack removeLastObject];
    [self setNeedsDisplay];
}

-(void) removeAllArrows 
{
    arrowOrder = 1;
    [arrowStack removeAllObjects];
    [self setNeedsDisplay];
}

-(int) getArrowStackCount
{
    return [arrowStack count];
}

-(int) getProblemArrowCount
{
    Problem *problem = [problems getCurrent];
    int arrowCount = 1;
    for (Molecule *molecule in problem.moleculeArray)
    {
        arrowCount += [molecule.arrows count];
    }
    return arrowCount;
}

-(BOOL) isLastArrowStartType:(int) type
{
    Arrow *lastArrow = [arrowStack lastObject];
    CGPoint locationA = lastArrow.locationA;
    int moleculeIndex = 0;
    if (locationA.x > (MOLECULE_WIDTH * MOLECULE_MULTIPLIER)) 
    {
        moleculeIndex = 1;
        locationA.x -= (MOLECULE_WIDTH * MOLECULE_MULTIPLIER);
    }
    
    Molecule *molecule = [[problems getCurrent].moleculeArray objectAtIndex:moleculeIndex];
    
    Element *element = [molecule.elements valueForKey:[NSString stringWithFormat:@"%i,%i", (int)locationA.x, (int)locationA.y]];
    
    if (element != nil)
    {
        if (element.type == type)
        {
            return TRUE;
        }
    }

    return FALSE;
}

-(BOOL) isLastArrowEndType:(int) type
{
    Arrow *lastArrow = [arrowStack lastObject];
    CGPoint locationB = lastArrow.locationB;
    int moleculeIndex = 0;
    if (locationB.x > (MOLECULE_WIDTH * MOLECULE_MULTIPLIER)) 
    {
        moleculeIndex = 1;
        locationB.x -= (MOLECULE_WIDTH * MOLECULE_MULTIPLIER);
    }
    
    Molecule *molecule = [[problems getCurrent].moleculeArray objectAtIndex:moleculeIndex];
    
    Element *element = [molecule.elements valueForKey:[NSString stringWithFormat:@"%i,%i", (int)locationB.x, (int)locationB.y]];
    
    if (element != nil)
    {
        if (element.type == type)
        {
            return TRUE;
        }
    }
    
    return FALSE;
}

-(BOOL) doesLastArrowMatchProblem
{
    Arrow *lastArrow = [arrowStack lastObject];
    if ([self doesArrowMatchProblem:lastArrow])
    {
        return TRUE;
    } else 
    {
        return FALSE;
    }
}

-(BOOL) doesAllArrowsMatchProblem
{
    if ([self getArrowStackCount] != [self getProblemArrowCount])
    {
        return FALSE;
    }
    for (Arrow *arrow in arrowStack)
    {
        if (![self doesArrowMatchProblem:arrow])
        {
            return FALSE;
        }
    }
    
    return TRUE;
}

-(BOOL) doesArrowMatchProblem:(Arrow*)arrow
{
    Problem *currentProblem = [problems getCurrent];
    
    CGPoint locationA = arrow.locationA;
    CGPoint locationB = arrow.locationB;
    
    if ((locationA.x < (MOLECULE_WIDTH * MOLECULE_MULTIPLIER)) && (locationB.x < (MOLECULE_WIDTH * MOLECULE_MULTIPLIER)))
    {
        Molecule *moleculeA = [currentProblem.moleculeArray objectAtIndex:0];
        Arrow *arrowA = [moleculeA.arrows valueForKey:[NSString stringWithFormat:@"%i,%i,%i,%i", (int)locationA.x, (int)locationA.y, (int)locationB.x, (int)locationB.y]];
        if (arrowA != nil)
        {
            if (arrowA.order == arrow.order)
            {
                return TRUE;
            }
        }
        
    } else if ((locationA.x > (MOLECULE_WIDTH * MOLECULE_MULTIPLIER)) && (locationB.x > (MOLECULE_WIDTH * MOLECULE_MULTIPLIER)))
    {
        locationA.x -= (MOLECULE_WIDTH * MOLECULE_MULTIPLIER);
        locationB.x -= (MOLECULE_WIDTH * MOLECULE_MULTIPLIER);
        Molecule *moleculeB = [currentProblem.moleculeArray objectAtIndex:1];
        Arrow *arrowB = [moleculeB.arrows valueForKey:[NSString stringWithFormat:@"%i,%i,%i,%i", (int)locationA.x, (int)locationA.y, (int)locationB.x, (int)locationB.y]];
        if (arrowB != nil)
        {
            if (arrowB.order == arrow.order)
            {
                return TRUE;
            }
        }
    } else if ((locationA.x < (MOLECULE_WIDTH * MOLECULE_MULTIPLIER)) && (locationB.x > (MOLECULE_WIDTH * MOLECULE_MULTIPLIER)))
    {
        if (arrow.order == 1)
        {
            locationB.x -= (MOLECULE_WIDTH * MOLECULE_MULTIPLIER);
            Molecule *moleculeA = [currentProblem.moleculeArray objectAtIndex:0];
            Molecule *moleculeB = [currentProblem.moleculeArray objectAtIndex:1];
            Element *elementA = [moleculeA.elements valueForKey:[NSString stringWithFormat:@"%i,%i", (int)locationA.x, (int)locationA.y]];
            Element *elementB = [moleculeB.elements valueForKey:[NSString stringWithFormat:@"%i,%i", (int)locationB.x, (int)locationB.y]];
            if ((elementA != nil) && (elementB != nil))
            {
				if ((elementA.type == ELEMENT_NUCLEOPHILE) && (elementB.type == ELEMENT_ELECTROPHILE))
				{
					return TRUE;
				}
            }
        }
        
    } else if ((locationA.x > (MOLECULE_WIDTH * MOLECULE_MULTIPLIER)) && (locationB.x < (MOLECULE_WIDTH * MOLECULE_MULTIPLIER)))
    {
        if (arrow.order == 1)
        {
            locationA.x -= (MOLECULE_WIDTH * MOLECULE_MULTIPLIER);
            Molecule *moleculeA = [currentProblem.moleculeArray objectAtIndex:1];
            Molecule *moleculeB = [currentProblem.moleculeArray objectAtIndex:0];
			
            Element *elementA = [moleculeA.elements valueForKey:[NSString stringWithFormat:@"%i,%i", (int)locationA.x, (int)locationA.y]];
            Element *elementB = [moleculeB.elements valueForKey:[NSString stringWithFormat:@"%i,%i", (int)locationB.x, (int)locationB.y]];
            if ((elementA != nil) && (elementB != nil))
            {
				if ((elementA.type == ELEMENT_NUCLEOPHILE) && (elementB.type == ELEMENT_ELECTROPHILE))
				{
					return TRUE;   
				}
            }
        }
        
    }    
    
    return FALSE;
}

-(void) setProblemMarkers
{

    Problem *currentProblem = [problems getCurrent];
    NSMutableSet *markerSet = [[NSMutableSet alloc] init];
    
    for (int i = 0; i < 2; i++)
    {
        float moleculeOffset = 0.0f;
        
        if (i == 1) 
        {
            moleculeOffset += MOLECULE_WIDTH * MOLECULE_MULTIPLIER;
        }
        
        Molecule *molecule = [currentProblem.moleculeArray objectAtIndex:i];
        
        for (Element *element in [molecule.elements allValues])
        {
            if (element.type == ELEMENT_ELECTROPHILE)
            {
                if (![markerSet containsObject:[NSNumber valueWithCGPoint:CGPointMake(element.location.x + moleculeOffset, element.location.y)]])
                {
                    Marker *marker = [[Marker alloc] init];
                    marker.type = ELEMENT_ELECTROPHILE;
                    marker.point = CGPointMake((element.location.x * MOLECULE_MULTIPLIER) + moleculeOffset, (element.location.y * MOLECULE_MULTIPLIER));
                    [problemMarkersArray addObject:marker];
                    [marker release];
                    [markerSet addObject:[NSNumber valueWithCGPoint:CGPointMake(element.location.x + moleculeOffset, element.location.y)]];
                }
            } else if (element.type == ELEMENT_NUCLEOPHILE)
            {
                if (![markerSet containsObject:[NSNumber valueWithCGPoint:CGPointMake(element.location.x + moleculeOffset, element.location.y)]])
                {
                    Marker *marker = [[Marker alloc] init];
                    marker.type = ELEMENT_NUCLEOPHILE;
                    marker.point = CGPointMake((element.location.x * MOLECULE_MULTIPLIER) + moleculeOffset, (element.location.y * MOLECULE_MULTIPLIER));
                    [problemMarkersArray addObject:marker];
                    [marker release];
                    [markerSet addObject:[NSNumber valueWithCGPoint:CGPointMake(element.location.x + moleculeOffset, element.location.y)]];
                }
            }
        }
        
        for (Arrow *arrow in [molecule.arrows allValues])
        {
            if (![markerSet containsObject:[NSNumber valueWithCGPoint:CGPointMake(arrow.locationA.x + moleculeOffset, arrow.locationA.y)]])
            {
                Marker *marker = [[Marker alloc] init];
                marker.type = ELEMENT_OTHER;
                marker.point = CGPointMake((arrow.locationA.x * MOLECULE_MULTIPLIER) + moleculeOffset, (arrow.locationA.y * MOLECULE_MULTIPLIER));
                [problemMarkersArray addObject:marker];
                [marker release];
                [markerSet addObject:[NSNumber valueWithCGPoint:CGPointMake(arrow.locationA.x + moleculeOffset, arrow.locationA.y)]];
            }
            if (![markerSet containsObject:[NSNumber valueWithCGPoint:CGPointMake(arrow.locationB.x + moleculeOffset, arrow.locationB.y)]])
            {
                Marker *marker = [[Marker alloc] init];
                marker.type = ELEMENT_OTHER;
                marker.point = CGPointMake((arrow.locationB.x * MOLECULE_MULTIPLIER) + moleculeOffset, (arrow.locationB.y * MOLECULE_MULTIPLIER));
                [problemMarkersArray addObject:marker];
                [marker release];
                [markerSet addObject:[NSNumber valueWithCGPoint:CGPointMake(arrow.locationB.x + moleculeOffset, arrow.locationB.y)]];
            }
        }
        
    }
    [markerSet release];
}

-(void) drawRect:(CGRect)rect 
{
    Problem *currentProblem = [problems getCurrent];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(context, rect);
    
    
    if (electrophileMarker != nil)
    {
        CGContextSetRGBFillColor(context, 1.0f, 0.0f, 0.0f, 0.3f);
        CGContextFillEllipseInRect(context, CGRectMake((electrophileMarker.point.x * MOLECULE_MULTIPLIER) - (HITBOX_SIZE / 2.0f), (electrophileMarker.point.y * MOLECULE_MULTIPLIER) - (HITBOX_SIZE / 2.0f), HITBOX_SIZE, HITBOX_SIZE));
    }
    
    if (nucleophileMarker != nil)
    {
        CGContextSetRGBFillColor(context, 0.0f, 0.0f, 1.0f, 0.3f);
        CGContextFillEllipseInRect(context, CGRectMake((nucleophileMarker.point.x * MOLECULE_MULTIPLIER) - (HITBOX_SIZE / 2.0f), (nucleophileMarker.point.y * MOLECULE_MULTIPLIER) - (HITBOX_SIZE / 2.0f), HITBOX_SIZE, HITBOX_SIZE));
    }

    if (showProblemMarkers == TRUE)
    { 
        for (Marker *marker in problemMarkersArray)
        {
            BOOL drawMarker = TRUE;
            if ((electrophileMarker != nil) && CGPointEqualToPoint(marker.point, electrophileMarker.point))
            {
                drawMarker = FALSE;
            } else if ((nucleophileMarker != nil) && CGPointEqualToPoint(marker.point, nucleophileMarker.point))
            {
                drawMarker = FALSE;
            }
            
            if (drawMarker == TRUE)
            {
                CGContextSetRGBFillColor(context, 0.0f, 0.5f, 0.5f, 0.3f);
                CGContextFillEllipseInRect(context, CGRectMake(marker.point.x - (HITBOX_SIZE / 2.0f), marker.point.y - (HITBOX_SIZE / 2.0f), HITBOX_SIZE, HITBOX_SIZE));
            }
        }
 
    }
    
    

    
    for (int i = 0; i < 2; i++) 
    {
        float moleculeOffset = 0.0f;
        
        if (i == 1) 
        {
            moleculeOffset += MOLECULE_WIDTH * MOLECULE_MULTIPLIER;
        }
        
        
        Molecule *molecule = [currentProblem.moleculeArray objectAtIndex:i];

        for (Element *element in [molecule.elements allValues]) 
        {
            CGContextSelectFont(context, "Helvetica", (24.0f * MOLECULE_MULTIPLIER), kCGEncodingMacRoman);
            CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
            
            CGAffineTransform flipMatrix = CGAffineTransformIdentity;
            flipMatrix.d = -1;
            CGContextSetTextMatrix(context, flipMatrix);
            
            CGSize labelSize = [element.label sizeWithFont:[UIFont fontWithName:@"Helvetica" size:(24.0f * MOLECULE_MULTIPLIER)]];
            CGPoint elementLocation = CGPointMake(element.location.x * MOLECULE_MULTIPLIER, element.location.y * MOLECULE_MULTIPLIER);
            
            CGContextSetTextPosition(context, (elementLocation.x - (labelSize.width / 2.0f) + moleculeOffset), (elementLocation.y + (labelSize.height / 4.0f)));
            CGContextShowText(context, [element.label UTF8String], strlen([element.label UTF8String]));
            
            //add charge, electrons
        }
        
        for (Bond *bond in [molecule.bonds allValues]) 
        {

            CGContextSetLineWidth(context, 2.0f * MOLECULE_MULTIPLIER);
            CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
            
            CGPoint locationA = CGPointMake(bond.locationA.x * MOLECULE_MULTIPLIER, bond.locationA.y * MOLECULE_MULTIPLIER);
            CGPoint locationB = CGPointMake(bond.locationB.x * MOLECULE_MULTIPLIER, bond.locationB.y * MOLECULE_MULTIPLIER);
            
            CGPoint insetA = CGPointMake(0.0f, 0.0f);
            CGPoint insetB = CGPointMake(0.0f, 0.0f);
            
            Element *elementA = [molecule.elements valueForKey:[NSString stringWithFormat:@"%i,%i", (int)bond.locationA.x, (int)bond.locationA.y]];

            if (![elementA.label isEqualToString:@""]) {
                insetA = [self insetPoint:locationA andPoint:locationB withLabel:elementA.label];    
            }
            
            Element *elementB = [molecule.elements valueForKey:[NSString stringWithFormat:@"%i,%i", (int)bond.locationB.x, (int)bond.locationB.y]];
            
            if (![elementA.label isEqualToString:@""]) {
                insetB = [self insetPoint:locationB andPoint:locationA withLabel:elementB.label];    
            }

            
            if (bond.bondOrder == 1)
            {
                CGContextMoveToPoint(context, (locationA.x + insetA.x + moleculeOffset), (locationA.y + insetA.y));
                CGContextAddLineToPoint(context, (locationB.x + insetB.x + moleculeOffset), (locationB.y + insetB.y));
                CGContextStrokePath(context);
                
            } else if (bond.bondOrder == 2)
            {
                float dx = locationA.x - locationB.x;
                float dy = locationB.y - locationA.y;
                float dist = sqrtf(dx*dx + dy*dy);
                
                float length = 4.0;
                
                float x1p = locationA.x - length * (locationB.y-locationA.y) / dist;
                float y1p = locationA.y - length * (locationA.x-locationB.x) / dist;
                float x2p = locationB.x - length * (locationB.y-locationA.y) / dist;
                float y2p = locationB.y - length * (locationA.x-locationB.x) / dist;
                
                float x3p = locationA.x + length * (locationB.y-locationA.y) / dist;
                float y3p = locationA.y + length * (locationA.x-locationB.x) / dist;
                float x4p = locationB.x + length * (locationB.y-locationA.y) / dist;
                float y4p = locationB.y + length * (locationA.x-locationB.x) / dist;
                
                CGContextMoveToPoint(context, (x1p + insetA.x + moleculeOffset), (y1p + insetA.y));
                CGContextAddLineToPoint(context, (x2p + insetB.x + moleculeOffset), (y2p + insetB.y));
                CGContextStrokePath(context);
                
                CGContextMoveToPoint(context, (x3p + insetA.x + moleculeOffset), (y3p + insetA.y));
                CGContextAddLineToPoint(context, (x4p + insetB.x + moleculeOffset), (y4p + insetB.y));
                CGContextStrokePath(context);
                
            } else if (bond.bondOrder == 3)
            {
                float dx = locationA.x - locationB.x;
                float dy = locationB.y - locationA.y;
                float dist = sqrtf(dx*dx + dy*dy);
                
                float length = 6.0;
                
                float x1p = locationA.x - length * (locationB.y-locationA.y) / dist;
                float y1p = locationA.y - length * (locationA.x-locationB.x) / dist;
                float x2p = locationB.x - length * (locationB.y-locationA.y) / dist;
                float y2p = locationB.y - length * (locationA.x-locationB.x) / dist;
                
                float x3p = locationA.x + length * (locationB.y-locationA.y) / dist;
                float y3p = locationA.y + length * (locationA.x-locationB.x) / dist;
                float x4p = locationB.x + length * (locationB.y-locationA.y) / dist;
                float y4p = locationB.y + length * (locationA.x-locationB.x) / dist;
                
                CGContextMoveToPoint(context, (x1p + insetA.x + moleculeOffset), (y1p + insetA.y));
                CGContextAddLineToPoint(context, (x2p + insetB.x + moleculeOffset), (y2p + insetB.y));
                CGContextStrokePath(context);
                
                CGContextMoveToPoint(context, (locationA.x + insetA.x + moleculeOffset), (locationA.y + insetA.y));
                CGContextAddLineToPoint(context, (locationB.x + insetB.x + moleculeOffset), (locationB.y + insetB.y));
                CGContextStrokePath(context);
                
                CGContextMoveToPoint(context, (x3p + insetA.x + moleculeOffset), (y3p + insetA.y));
                CGContextAddLineToPoint(context, (x4p + insetB.x + moleculeOffset), (y4p + insetB.y));
                CGContextStrokePath(context);
            }

        }
    }
    
    if (movableMarker != nil)
    {
        NSString *label;
        if (movableMarker.type == ELEMENT_ELECTROPHILE)
        {
            CGContextSetRGBFillColor(context, 1.0f, 0.0f, 0.0f, 0.6f);
            CGContextSetRGBStrokeColor(context, 1.0f, 0.0f, 0.0f, 0.3f);
            label = [[NSString alloc] initWithString:@"EP"];
        } else if (movableMarker.type == ELEMENT_NUCLEOPHILE)
        {
            CGContextSetRGBFillColor(context, 0.0f, 0.0f, 1.0f, 0.6f);
            CGContextSetRGBStrokeColor(context, 0.0f, 0.0f, 1.0f, 0.3f);
            label = [[NSString alloc] initWithString:@"NP"];
        } else 
        {
            CGContextSetRGBFillColor(context, 0.0f, 0.5f, 0.5f, 0.6f);
            CGContextSetRGBStrokeColor(context, 0.0f, 0.5f, 0.5f, 0.3f);
            label = [[NSString alloc] initWithString:@""];
        }
        
        CGContextFillEllipseInRect(context, CGRectMake(movableMarker.point.x - (HITBOX_SIZE / 2.0f), movableMarker.point.y - (HITBOX_SIZE / 2.0f), HITBOX_SIZE, HITBOX_SIZE));
        CGContextStrokeEllipseInRect(context, CGRectMake(movableMarker.point.x - (HITBOX_SIZE / 2.0f), movableMarker.point.y - (HITBOX_SIZE / 2.0f), HITBOX_SIZE, HITBOX_SIZE));
        
        
        CGContextSelectFont(context, "Helvetica", (24.0f * MOLECULE_MULTIPLIER), kCGEncodingMacRoman);
        CGContextSetRGBFillColor(context, 0.0f, 0.0f, 0.0f, 1.0f);
        
        CGAffineTransform flipMatrix = CGAffineTransformIdentity;
        flipMatrix.d = -1;
        CGContextSetTextMatrix(context, flipMatrix);
        
        CGSize labelSize = [label sizeWithFont:[UIFont fontWithName:@"Helvetica" size:(24.0f * MOLECULE_MULTIPLIER)]];
        
        CGContextSetTextPosition(context, movableMarker.point.x - (labelSize.width / 2.0f), movableMarker.point.y + (labelSize.height / 4.0f));
        CGContextShowText(context, [label UTF8String], strlen([label UTF8String]));
        
        if (label != nil)
        {
            [label release];
        }
        
        CGPoint hitbox = [self isHitbox:movableMarker.point];
        if (!CGPointEqualToPoint(hitbox, CGPointMake(-1.0f, -1.0f))) 
        {
            CGContextSetRGBStrokeColor(context, 0.5f, 0.1f, 1.0f, 0.5f);
            CGContextSetLineWidth(context, 2.0f * MOLECULE_MULTIPLIER);
            CGContextStrokeEllipseInRect(context, CGRectMake(hitbox.x - (HITBOX_SIZE / 2.0f), hitbox.y - (HITBOX_SIZE / 2.0f), HITBOX_SIZE, HITBOX_SIZE));
            
        }
    }
    
    if ([arrowStack count] > 0) 
    {
        if ([self isArrowInProgress]) 
        {
            Arrow *lastArrow = [arrowStack lastObject];
            if (!CGPointEqualToPoint(lastArrow.locationB, CGPointMake(-1.0f, -1.0f))) 
            {
                CGPoint hitbox = [self isHitbox:lastArrow.locationB];
                if (!CGPointEqualToPoint(hitbox, CGPointMake(-1.0f, -1.0f)) && !CGPointEqualToPoint(hitbox, lastArrow.locationA)) 
                {
                    CGContextSetRGBStrokeColor(context, 0.5f, 0.1f, 1.0f, 0.5f);
                    CGContextSetLineWidth(context, 2.0f * MOLECULE_MULTIPLIER);
                    CGContextStrokeEllipseInRect(context, CGRectMake(hitbox.x - (HITBOX_SIZE / 2.0f), hitbox.y - (HITBOX_SIZE / 2.0f), HITBOX_SIZE, HITBOX_SIZE));
                }
            }
        }
        
        for (Arrow *arrow in arrowStack) 
        {
            if (!CGPointEqualToPoint(arrow.locationB, CGPointMake(-1.0f, -1.0f))) 
            {
                CGContextSetRGBStrokeColor(context, 140.0f/255.0f, 200.0f/255.0f, 60.0f/255.0f, 1.0f);
                CGContextSetLineWidth(context, 2.0f * MOLECULE_MULTIPLIER);
                CGContextMoveToPoint(context, arrow.locationA.x, arrow.locationA.y);

                float dx = arrow.locationA.x - arrow.locationB.x;
                float dy = arrow.locationB.y - arrow.locationA.y;
                float dist = sqrtf(dx*dx + dy*dy);
                
                float length = 60.0;
                
                float x1p = arrow.locationA.x + length * (arrow.locationB.y-arrow.locationA.y) / dist;
                float y1p = arrow.locationA.y + length * (arrow.locationA.x-arrow.locationB.x) / dist;
                float x2p = arrow.locationB.x + length * (arrow.locationB.y-arrow.locationA.y) / dist;
                float y2p = arrow.locationB.y + length * (arrow.locationA.x-arrow.locationB.x) / dist;
                
                CGPoint cp1 = CGPointMake(x1p,y1p);
                CGPoint cp2 = CGPointMake(x2p,y2p);
                
                
                CGContextAddCurveToPoint(context, cp1.x, cp1.y, cp2.x, cp2.y, arrow.locationB.x, arrow.locationB.y);
                CGContextStrokePath(context);
                
                
                CGContextSetRGBFillColor(context, 140.0f/255.0f, 200.0f/255.0f, 60.0f/255.0f, 0.5f);
                CGContextFillEllipseInRect(context, CGRectMake(arrow.locationB.x - (10.0f / 2.0f), arrow.locationB.y - (10.0f / 2.0f), 10.0f,10.0f));
                
//                float length = 10.0f;
//                float width = 10.0f;
//            
//                CGContextSetRGBFillColor(context, 140.0f/255.0f, 200.0f/255.0f, 60.0f/255.0f, 1.0f);
//                CGContextMoveToPoint(context, arrow.locationB.x - (width / 2.0f), arrow.locationB.y - length);
//                CGContextAddLineToPoint(context, arrow.locationB.x + (width / 2.0f), arrow.locationB.y - length);
//                CGContextAddLineToPoint(context, arrow.locationB.x, arrow.locationB.y);
//                CGContextClosePath(context);
//                CGContextFillPath(context);
                               
            }
        }
   
    }
    
}

-(CGPoint) insetPoint:(CGPoint)pointA andPoint:(CGPoint)pointB withLabel:(NSString*)label {
    
    CGSize labelSize = [label sizeWithFont:[UIFont fontWithName:@"Helvetica" size:(24.0f * MOLECULE_MULTIPLIER)]];
    
    float dx = pointB.x - pointA.x;
    float dy = pointB.y - pointA.y;
    
    CGPoint inset = CGPointMake(0.0f, 0.0f);
    
    if (CGPointEqualToPoint(pointA, pointB)) 
    {
        return inset;
    }
    
    if (dx == 0) 
    {
        if (pointB.y < pointA.y) 
        {
            inset.y -= (labelSize.height / 2.0f);
        } else {
            inset.y += (labelSize.height / 2.0f);
        }
    } else if (dy == 0) 
    {
        if (pointB.x < pointA.x) 
        {
            inset.x -= (labelSize.width / 1.5f);
        } else {
            inset.x += (labelSize.width / 1.5f);
        }
    } else 
    {
        float length = sqrtf(dx * dx + dy * dy);
        float scale = (length + (labelSize.width > labelSize.height ? (labelSize.width / 2.0f) : (labelSize.height / 2.0f))) / length;
        dx *= scale;
        dy *= scale;
        inset.x = dx;
        inset.y = dy;
    }
    
    return inset;
}



-(void) dealloc {
    if (electrophileMarker != nil)
        [electrophileMarker release];
    if (nucleophileMarker != nil)
        [nucleophileMarker release];
    [problemMarkersArray release];
    if (movableMarker != nil)
        [movableMarker release];
    [arrowStack release];
    [super dealloc];
}

@end

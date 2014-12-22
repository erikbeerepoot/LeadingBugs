//
//  SmileView.swift
//  Smiles
//
//  Created by Erik E. Beerepoot on 2014-12-18.
//  Copyright (c) 2014 Dactyl Studios. All rights reserved.
//

import Foundation
import AppKit

class SmileView : NSView {
    let kCircleDiameter : CGFloat = 100;
    let kSmileDiameter : CGFloat = 70;
    let kSmileArcLength : CGFloat = 2.0;
    let kEyeOffset : CGFloat = 20.0;
    let kEyeLength : CGFloat = 15.0;
    let kTextOffsetHorizontal : CGFloat = 30;
    
    //animation properties
    let kAnimationDuration : CFTimeInterval = 1.2;
    let kTextUpdateInterval : NSTimeInterval = 2;
    
    //store text for display
    var uitext : NSString? = nil;
    
    required init?(coder: NSCoder) {
        super.init(coder : coder);
        //do something
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect);
        self.frame = frameRect;
    }
    
    override func drawRect(dirtyRect: NSRect) {
        //make a pretty background
        NSColor.blueColor().set();
        NSRectFill(dirtyRect);
        
        NSColor.whiteColor().set();
        
        DrawSmileInRect(dirtyRect);

        //display text if we have some
        if(uitext != nil){
            let textSize = GetTextSize(uitext!);
            let textRect = CGRectMake(CGRectGetMidX(self.frame) - (textSize.width/2), CGRectGetMidY(self.frame)-kCircleDiameter-kTextOffsetHorizontal, textSize.width, textSize.height);
            DrawTextInRect(uitext!, rect: textRect);
        }
    }
    
    func SetTextToDisplay(text : NSString){
        uitext = text;
        self.setNeedsDisplayInRect(self.bounds);
    }
    
    func GetTextSize(text : NSString) -> (CGSize) {
        let font = NSFont(name: "helvetica", size: 40.0);
        
        //create attribute dict
        let attributes = NSMutableDictionary(object: font!, forKey: NSFontAttributeName);
        attributes.setObject(NSColor.whiteColor(), forKey: NSForegroundColorAttributeName);
        
        return text.sizeWithAttributes(attributes);
    }
    
    func DrawTextInRect(text : NSString , rect : NSRect) -> () {
        //create font
        let font = NSFont(name: "helvetica", size: 40.0);
        
        //create attribute dict
        let attributes = NSMutableDictionary(object: font!, forKey: NSFontAttributeName);
        attributes.setObject(NSColor.whiteColor(), forKey: NSForegroundColorAttributeName);
        
        //now draw the string
        text.drawInRect(rect, withAttributes: attributes);
    }
    
    func DrawSmileInRect(rect : NSRect) -> () {
        let rotRect = CGRectMake(CGRectGetMidX(rect)-(kCircleDiameter/2),CGRectGetMidY(rect)-(kCircleDiameter/2),kCircleDiameter,kCircleDiameter);
        
        
        //****** Outside Circle ******///
        //create shapelayer for path
        var shapeLayer = CAShapeLayer();
        
        //create path
        let circle = CGPathCreateWithEllipseInRect(rotRect,nil);
        shapeLayer.path = circle;
        shapeLayer.fillColor =  kClearColor;
        shapeLayer.strokeColor = kWhiteColor;
        shapeLayer.lineWidth = 5;
        self.layer?.addSublayer(shapeLayer);
        
        //create animation
        var animation = CABasicAnimation();
        animation.keyPath = "strokeEnd";
        animation.duration = kAnimationDuration;
        animation.repeatCount = 1;
        animation.fromValue =  NSNumber(double:0.0);
        animation.toValue = NSNumber(double:1.0);
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut);
        shapeLayer.addAnimation(animation, forKey: "animation");
        
        //****** Smile Semi-circle ******///
        let smileRect = CGRectMake(CGRectGetMidX(rect)-(kSmileDiameter/2),CGRectGetMidY(rect)-(kSmileDiameter/2),kSmileDiameter,kSmileDiameter);
        
        
        //create smilepath
        var smilePath = CGPathCreateMutable();
        CGPathAddArc(smilePath, nil, CGRectGetMidX(rect), CGRectGetMidY(rect), kSmileDiameter/2, 4.712092-(kSmileArcLength/2),4.712092+(kSmileArcLength/2) ,false);
        
        CGPathMoveToPoint(smilePath, nil, CGRectGetMidX(rect)-kEyeOffset, CGRectGetMidY(rect)+kEyeOffset)
        CGPathAddLineToPoint(smilePath, nil, CGRectGetMidX(rect)-kEyeOffset, CGRectGetMidX(rect)+1*kEyeOffset-kEyeLength);
        
        CGPathMoveToPoint(smilePath, nil, CGRectGetMidX(rect)+kEyeOffset, CGRectGetMidY(rect)+kEyeOffset)
        CGPathAddLineToPoint(smilePath, nil, CGRectGetMidX(rect)+kEyeOffset, CGRectGetMidX(rect)+1*kEyeOffset-kEyeLength);
        
        
        var smileShape = CAShapeLayer();
        smileShape.path = smilePath;
        smileShape.fillColor = kClearColor;
        smileShape.strokeColor = kWhiteColor;
        smileShape.lineWidth = 5;
        self.layer?.addSublayer(smileShape);
        
        var animation2 = CABasicAnimation();
        animation2.keyPath = "strokeEnd";
        animation2.duration = kAnimationDuration;
        animation2.repeatCount = 1;
        animation2.fromValue =  NSNumber(double:0.0);
        animation2.toValue = NSNumber(double:1.0);
        animation2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        smileShape.addAnimation(animation, forKey: "animation");
    }
}

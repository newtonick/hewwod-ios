//
//  ComplicationController.swift
//  testwatchapp WatchKit Extension
//
//  Created by Klockenga,Nick on 1/10/19.
//  Copyright © 2019 Klockenga,Nick. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        
        switch complication.family {
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularImage()
            if ExtensionDelegate.pendingUpdateAlert {
                template.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Graphic Circular Alert")!)
            } else {
                template.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Circular")!)
            }
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerTextImage()
            template.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Corner")!)
            template.textProvider = CLKSimpleTextProvider(text: "HEW WOD", shortText: "HEW WOD")
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        case .graphicBezel:
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            template.textProvider = CLKSimpleTextProvider(text: "HEW WOD", shortText: "HEW WOD")
            let imageTemplate = CLKComplicationTemplateGraphicCircularImage()
            imageTemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Circular")!)
            template.circularTemplate = imageTemplate
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
        default:
            handler(nil)
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        switch complication.family {
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularImage()
            template.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Circular")!)
            handler(template)
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerTextImage()
            template.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Corner")!)
            template.textProvider = CLKSimpleTextProvider(text: "HEW WOD")
            handler(template)
        case .graphicBezel:
           let template = CLKComplicationTemplateGraphicBezelCircularText()
           template.textProvider = CLKSimpleTextProvider(text: "HEW WOD")
           let imageTemplate = CLKComplicationTemplateGraphicCircularImage()
           imageTemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(named: "Complication/Graphic Circular")!)
           template.circularTemplate = imageTemplate
            handler(template)
        default:
            handler(nil)
        }
    }
    
}

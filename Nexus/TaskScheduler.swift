/*
*      ___           ___           ___           ___                         ___           ___
*     /  /\         /  /\         /  /\         /  /\          ___          /  /\         /  /\          ___
*    /  /::\       /  /::\       /  /::\       /  /::\        /  /\        /  /::\       /  /::\        /__/\
*   /  /:/\:\     /  /:/\:\     /  /:/\:\     /  /:/\:\      /  /::\      /  /:/\:\     /  /:/\:\       \  \:\
*  /  /::\ \:\   /  /::\ \:\   /  /::\ \:\   /  /::\ \:\    /  /:/\:\    /  /:/  \:\   /  /:/  \:\       \__\:\
* /__/:/\:\_\:| /__/:/\:\_\:\ /__/:/\:\_\:\ /__/:/\:\ \:\  /  /::\ \:\  /__/:/ \__\:\ /__/:/ \__\:\      /  /::\
* \  \:\ \:\/:/ \__\/  \:\/:/ \__\/~|::\/:/ \  \:\ \:\_\/ /__/:/\:\ \:\ \  \:\ /  /:/ \  \:\ /  /:/     /  /:/\:\
*  \  \:\_\::/       \__\::/     |  |:|::/   \  \:\ \:\   \__\/  \:\_\/  \  \:\  /:/   \  \:\  /:/     /  /:/__\/
*   \  \:\/:/        /  /:/      |  |:|\/     \  \:\_\/        \  \:\     \  \:\/:/     \  \:\/:/     /__/:/
*    \__\::/        /__/:/       |__|:|~       \  \:\           \__\/      \  \::/       \  \::/      \__\/
*        ~~         \__\/         \__\|         \__\/                       \__\/         \__\/
* @name: TaskScheduler.swift
* @author: Erik E. Beerepoot
* @company: Barefoot Inc.
* @brief: Generic task (closure) scheduling facility, and default coffeetask definition.
*/

import Foundation

//THe TaskScheduler class allows you to actually schedule the schedulable tasks.
class TaskScheduler {
    class func ScheduleTask( task : SchedulableTask) -> () {
        //first, compute the offset from the current date in seconds
        let currentDate  = NSDate();
        let interval = task.taskDate.timeIntervalSinceDate(currentDate);

        //convert to nanoseconds & schedule closure
        let startTime = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC)));
        dispatch_after(startTime, dispatch_get_main_queue(),{task.Task()});
    }
};

//this protocol defines a schedulable task; a combination of a date and a function
protocol SchedulableTask {
    func Task()->();
    var taskDate : NSDate { get set };
}

//example task, the coffeetask: Selects a random slack user, and tells them to make coffee.
class CoffeeTask : SchedulableTask {
    var taskDate : NSDate = NSDate.distantFuture() as NSDate;
    
    init() {
        //using the user's current calendar, create a date components pointing to 10:30am, today
        let calendar = NSCalendar.currentCalendar();
        let flags: NSCalendarUnit = .HourCalendarUnit | .DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit;
        var components = calendar.components( flags, fromDate: NSDate());
        components.hour = 10;
        components.minute = 30;
        
        //create date from components
        var date = calendar.dateFromComponents(components)!;
        
        //check if this is in the past or the future and adjust date if required
        if date.timeIntervalSinceNow < 0 {
            //in the past
            components.day += 1;
        }
    }
    
    func Task()->(){
        //select user from list, send instruction to make coffee
    }
}
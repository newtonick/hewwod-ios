//
//  WorkoutController.swift
//  HEW WOD
//
//  Created by Klockenga,Nick on 1/15/19.
//  Copyright © 2019 Klockenga,Nick. All rights reserved.
//

import Foundation
import os.log
import WatchConnectivity

class WorkoutController : NSObject, WCSessionDelegate {
    
    var workouts:[Workout?] = [Workout]()
    var latestWorkout:Workout?
    
    var workoutsUpdated = Date()
    var latestWorkoutUpdated = Date()
    
    var loadInprogress:Bool = false

    #if os(watchOS)
    var watchInterface:InterfaceController?
    #endif
    
    override init() {
        super.init()
        
        self.workoutsUpdated = UserDefaults.standard.object(forKey: "workoutsUpdated") as? Date ?? Date().addingTimeInterval(-301)
        self.latestWorkoutUpdated = UserDefaults.standard.object(forKey: "latestWorkoutUpdated") as? Date ?? Date().addingTimeInterval(-301)
        
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func fetchWorkoutsFromWeb(completion: @escaping ([Workout]) -> Void, failure: @escaping () ->Void){
        os_log("WorkoutController fetchWorksoutFromWeb called", log: OSLog.default, type: .debug)
        if self.loadInprogress == false {
            self.loadInprogress = true
            os_log("WorkoutController fetchWorksoutFromWeb started", log: OSLog.default, type: .debug)
            let uuid = UserDefaults.standard.string(forKey: "uuid") ?? "empty"
            var request = URLRequest(url: URL(string:"https://api.hewwod.com/api/1.0/workouts?src=ios&uuid=\(uuid)")!)
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 10.0
            sessionConfig.timeoutIntervalForResource = 10.0
            let session = URLSession(configuration: sessionConfig)
            let task = session.dataTask(with: request) {(data, response, error ) in
                guard error == nil else {
                    os_log("WorkoutController fetchWorksoutFromWeb url call to /api/1.0/workouts failed", log: OSLog.default, type: .debug)
                    failure()
                    self.loadInprogress = false
                    return
                }
                
                guard let content = data else {
                    os_log("WorkoutController fetchWorksoutFromWeb url call to /api/1.0/workout has no data", log: OSLog.default, type: .debug)
                    failure()
                    self.loadInprogress = false
                    return
                }
                
                guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                    os_log("WorkoutController fetchWorksoutFromWeb url call to /api/1.0/workout does not have valid JSON", log: OSLog.default, type: .debug)
                    failure()
                    self.loadInprogress = false
                    return
                }
                
                if json["status"] != nil && json["status"] as? String == "success" {
                    var tempWorkouts = [Workout?]()
                    if let workouts = json["workouts"] as? [[String: Any]] {
                        //load workouts from json into workouts array property
                        for (idx,w) in workouts.enumerated() {
                            let workout = Workout(json: w)
                            tempWorkouts += [workout]
                            
                            if idx == 0 {
                                self.sendWatchMessage(workout: workout!)
                            }
                        }
                        self.workouts = tempWorkouts
                        
                        // calls completion callback function and passes workout array with optionals removed
                        completion(self.workouts.compactMap{$0})
                        os_log("WorkoutControllerfetch WorksoutFromWeb complete", log: OSLog.default, type: .debug)
                    }
                }
                self.loadInprogress = false
            }
            task.resume()
        }
    }
        
    func fetchLatestWorkoutFromWeb(completion: @escaping (Workout) -> Void, failure: @escaping () ->Void) {
        os_log("WorkoutController fetchLatestWorkoutFromWeb called", log: OSLog.default, type: .debug)
        if self.loadInprogress == false {
            self.loadInprogress = true
            os_log("WorkoutController fetchLatestWorkoutFromWeb started", log: OSLog.default, type: .debug)
            let uuid = UserDefaults.standard.string(forKey: "uuid") ?? "empty"
            var request = URLRequest(url: URL(string:"https://api.hewwod.com/api/1.0/workout?src=ios&uuid=\(uuid)")!)
            request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 10.0
            sessionConfig.timeoutIntervalForResource = 10.0
            let session = URLSession(configuration: sessionConfig)
            let task = session.dataTask(with: request) {(data, response, error ) in
                guard error == nil else {
                    os_log("WorkoutController fetchLatestWorkoutFromWeb url call to /api/1.0/workouts failed", log: OSLog.default, type: .debug)
                    failure()
                    self.loadInprogress = false
                    return
                }
                
                guard let content = data else {
                    os_log("WorkoutController fetchLatestWorkoutFromWeb url call to /api/1.0/workout has no data", log: OSLog.default, type: .debug)
                    failure()
                    self.loadInprogress = false
                    return
                }
                
                guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                    os_log("WorkoutController fetchLatestWorkoutFromWeb url call to /api/1.0/workout does not have valid JSON", log: OSLog.default, type: .debug)
                    failure()
                    self.loadInprogress = false
                    return
                }
                
                if json["status"] != nil && json["status"] as? String == "success" {
                    if let w = json["workout"] as? [String: Any] {
                        //load latest workout from json
                        let lw = Workout(json: w)
                        self.latestWorkout = lw
                        completion(self.latestWorkout!)
                        os_log("WorkoutController fetchLatestWorkoutFromWeb complete", log: OSLog.default, type: .debug)
                    }
                }
                self.loadInprogress = false
            }
            task.resume()
        }
    }
    
    func saveWorkoutsToUserDefaults() {
        os_log("WorkoutController saveWorkoutsToUserDefaults called", log: OSLog.default, type: .debug)
        let encodedData = try! JSONEncoder().encode(self.workouts)
        UserDefaults.standard.set(encodedData, forKey: "workouts")
        self.workoutsUpdated = Date()
        UserDefaults.standard.set(self.workoutsUpdated, forKey:"workoutsUpdated")
        UserDefaults.standard.synchronize()
    }
    
    func fetchWorkoutsFromUserDefaults(completion: @escaping ([Workout?]) -> Void) {
        os_log("WorkoutController fetchWorkoutsFromUserDefaults called", log: OSLog.default, type: .debug)
        let encodedData = UserDefaults.standard.data(forKey: "workouts") ?? Data()
        if encodedData.isEmpty { completion([Workout]()); return }
        let workouts = try! JSONDecoder().decode([Workout?].self, from: encodedData)
        self.workouts = workouts
        completion(workouts)
    }
    
    func saveLatestWorkoutToUserDefault() {
        os_log("WorkoutController saveLatestWorkoutToUserDefault called", log: OSLog.default, type: .debug)
        let encodedData = try! JSONEncoder().encode(self.latestWorkout)
        UserDefaults.standard.set(encodedData, forKey: "latest-workout")
        self.latestWorkoutUpdated = Date()
        UserDefaults.standard.set(self.workoutsUpdated, forKey:"latestWorkoutUpdated")
        UserDefaults.standard.synchronize()
    }
    
    func fetchLatestWorkoutFromUserDefault(completion: @escaping (Workout?) -> Void) {
        os_log("WorkoutController fetchLatestWorkoutFromUserDefault called", log: OSLog.default, type: .debug)
        let encodedData = UserDefaults.standard.data(forKey: "latest-workout") ?? Data()
        if encodedData.isEmpty { completion(Workout()); return }
        let latestWorkout = try! JSONDecoder().decode(Workout.self, from: encodedData)
        self.latestWorkout = latestWorkout
        completion(latestWorkout)
    }
    
    func isLatestWorkoutToday() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")

        if self.localDateString(date: (self.latestWorkout?.date) ?? Date().addingTimeInterval(-86400)) == self.localDateString(date: Date()) {
            //print("latest workout is today")
            return true
        }
        
        //print(self.localDateString(date: (self.latestWorkout?.date) ?? Date().addingTimeInterval(-86400)))
        //print(" == ")
        //print(self.localDateString(date: Date()))
        //print("false: latest workout is today")
        return false
    }
    
    func localDateString(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyyMMdd"
        
        return dateFormatter.string(from: date)
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    #endif
    
    func sendWatchMessage(workout:Workout) {
        print("sendWatchMessage")
        if (WCSession.default.activationState == .activated) {
            print("watch is paired and activated")
            let encodedData = try! JSONEncoder().encode(workout)
            let message = ["workout": encodedData]
            WCSession.default.transferUserInfo(message)
        }
        
        print(WCSession.default.outstandingUserInfoTransfers)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("didReceiveUserInfo")
        print(userInfo)
        let latestWorkout = try! JSONDecoder().decode(Workout.self, from: userInfo["workout"] as! Data)
        self.latestWorkout = latestWorkout
        self.saveLatestWorkoutToUserDefault()
        #if os(watchOS)
            self.watchInterface?.loadWorkoutFromUserDefault()
        #endif
    }

}

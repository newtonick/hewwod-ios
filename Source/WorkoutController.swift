//
//  WorkoutController.swift
//  HEW WOD
//
//  Created by Klockenga,Nick on 1/15/19.
//  Copyright © 2019 Klockenga,Nick. All rights reserved.
//

import Foundation
import os.log

class WorkoutController : NSObject {
    
    var workouts:[Workout?] = [Workout]()
    var latestWorkout:Workout?
    
    var workoutsUpdated = Date()
    var latestWorkoutUpdated = Date()

    func fetchWorksoutFromWeb(completion: @escaping ([Workout]) -> Void, failure: @escaping () ->Void){
        os_log("WorkoutController fetchWorksoutFromWeb called", log: OSLog.default, type: .debug)
        var request = URLRequest(url: URL(string:"https://hew.klck.in/api/1.0/workouts")!)
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        let task = URLSession.shared.dataTask(with: request) {(data, response, error ) in
            guard error == nil else {
                os_log("WorkoutController fetchWorksoutFromWeb url call to /api/1.0/workouts failed", log: OSLog.default, type: .debug)
                failure()
                return
            }
            
            guard let content = data else {
                os_log("WorkoutController fetchWorksoutFromWeb url call to /api/1.0/workout has no data", log: OSLog.default, type: .debug)
                failure()
                return
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                os_log("WorkoutController fetchWorksoutFromWeb url call to /api/1.0/workout does not have valid JSON", log: OSLog.default, type: .debug)
                failure()
                return
            }
            
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "fetch-workouts-count") + 1, forKey: "fetch-workouts-count")
            
            if json["status"] != nil && json["status"] as? String == "success" {
                if let workouts = json["workouts"] as? [[String: Any]] {
                    //empty workouts array and populate from json (replace)
                    self.workouts = [Workout]()
                    
                    //load workouts from json into workouts array property
                    for w in workouts {
                        let workout = Workout(json: w)
                        self.workouts += [workout]
                    }
                    
                    // calls completion callback function and passes workout array with optionals removed
                    completion(self.workouts.compactMap{$0})
                    os_log("WorkoutControllerfetch WorksoutFromWeb complete", log: OSLog.default, type: .debug)
                }
            }
        }
        task.resume()
    }
        
    func fetchLatestWorkoutFromWeb(completion: @escaping (Workout) -> Void, failure: @escaping () ->Void) {
        os_log("WorkoutController fetchLatestWorkoutFromWeb called", log: OSLog.default, type: .debug)
        var request = URLRequest(url: URL(string:"https://hew.klck.in/api/1.0/workout")!)
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 10.0
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) {(data, response, error ) in
            guard error == nil else {
                os_log("WorkoutController fetchLatestWorkoutFromWeb url call to /api/1.0/workouts failed", log: OSLog.default, type: .debug)
                failure()
                return
            }
            
            guard let content = data else {
                os_log("WorkoutController fetchLatestWorkoutFromWeb url call to /api/1.0/workout has no data", log: OSLog.default, type: .debug)
                failure()
                return
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                os_log("WorkoutController fetchLatestWorkoutFromWeb url call to /api/1.0/workout does not have valid JSON", log: OSLog.default, type: .debug)
                failure()
                return
            }
            
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "fetch-latest-workout-count") + 1, forKey: "fetch-latest-workout-count")
            
            if json["status"] != nil && json["status"] as? String == "success" {
                if let w = json["workout"] as? [String: Any] {
                    //load latest workout from json
                    self.latestWorkout = Workout(json: w)
                    completion(self.latestWorkout!)
                    os_log("WorkoutController fetchLatestWorkoutFromWeb complete", log: OSLog.default, type: .debug)
                }
            }
        }
        task.resume()
    }
    
    func saveWorkoutsToUserDefaults() {
        os_log("WorkoutController saveWorkoutsToUserDefaults called", log: OSLog.default, type: .debug)
        let encodedData = try! JSONEncoder().encode(self.workouts)
        UserDefaults.standard.set(encodedData, forKey: "workouts")
        UserDefaults.standard.synchronize()
        self.workoutsUpdated = Date()
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
        UserDefaults.standard.synchronize()
        self.latestWorkoutUpdated = Date()
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
            return true
        }
        
        return false
    }
    
    func localDateString(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyyMMdd"
        
        return dateFormatter.string(from: date)
    }
}

//
//  WorkoutController.swift
//  HEW WOD
//
//  Created by Klockenga,Nick on 1/15/19.
//  Copyright © 2019 Klockenga,Nick. All rights reserved.
//

import Foundation

class WorkoutController : NSObject {
    
    var workouts:[Workout?] = [Workout]()
    var latestWorkout:Workout?
    
    var workoutsUpdated = Date()
    var latestWorkoutUpdated = Date()

    func fetchWorksoutFromWeb(completion: @escaping ([Workout]) -> Void){
        print("fetchWorksoutFromWeb")
        var request = URLRequest(url: URL(string:"https://hew.klck.in/api/1.0/workouts")!)
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        let task = URLSession.shared.dataTask(with: request) {(data, response, error ) in
            guard error == nil else {
                print("fetchWorksoutFromWeb url call to /api/1.0/workouts failed")
                return
            }
            
            guard let content = data else {
                print("fetchWorksoutFromWeb url call to /api/1.0/workout has no data")
                return
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                print("fetchWorksoutFromWeb url call to /api/1.0/workout does not have valid JSON")
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
                }
            }
        }
        task.resume()
    }
        
    func fetchLatestWorkoutFromWeb(completion: @escaping (Workout) -> Void, failure: @escaping () ->Void) {
        print("fetchLatestWorkoutFromWeb")
        var request = URLRequest(url: URL(string:"https://hew.klck.in/api/1.0/workout")!)
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringLocalCacheData
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) {(data, response, error ) in
            guard error == nil else {
                print("fetchWorksoutFromWeb url call to /api/1.0/workouts failed")
                failure()
                return
            }
            
            guard let content = data else {
                print("fetchWorksoutFromWeb url call to /api/1.0/workout has no data")
                failure()
                return
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                print("fetchWorksoutFromWeb url call to /api/1.0/workout does not have valid JSON")
                failure()
                return
            }
            
            UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "fetch-latest-workout-count") + 1, forKey: "fetch-latest-workout-count")
            
            if json["status"] != nil && json["status"] as? String == "success" {
                if let w = json["workout"] as? [String: Any] {
                    //load latest workout from json
                    self.latestWorkout = Workout(json: w)
                    completion(self.latestWorkout!)
                }
            }
        }
        task.resume()
    }
    
    func saveWorkoutsToUserDefaults() {
        let encodedData = try! JSONEncoder().encode(self.workouts)
        UserDefaults.standard.set(encodedData, forKey: "workouts")
        UserDefaults.standard.synchronize()
        self.workoutsUpdated = Date()
    }
    
    func fetchWorkoutsFromUserDefaults(completion: @escaping ([Workout?]) -> Void) {
        let encodedData = UserDefaults.standard.data(forKey: "workouts") ?? Data()
        if encodedData.isEmpty { completion([Workout]()); return }
        let workouts = try! JSONDecoder().decode([Workout?].self, from: encodedData)
        self.workouts = workouts
        completion(workouts)
    }
    
    func saveLatestWorkoutToUserDefault() {
        let encodedData = try! JSONEncoder().encode(self.latestWorkout)
        UserDefaults.standard.set(encodedData, forKey: "latest-workout")
        UserDefaults.standard.synchronize()
        self.latestWorkoutUpdated = Date()
        print(self.latestWorkoutUpdated)
    }
    
    func fetchLatestWorkoutFromUserDefault(completion: @escaping (Workout?) -> Void) {
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
        
        print(self.localDateString(date: (self.latestWorkout?.date) ?? Date().addingTimeInterval(-86400)))
        
        if self.localDateString(date: (self.latestWorkout?.date) ?? Date().addingTimeInterval(-86400)) == self.localDateString(date: Date()) {
            return true
        }
        
        return false
    }
    
    func localDateString(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.string(from: date)
        
        return dateFormatter.string(from: date)
    }
}

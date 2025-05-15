//
//  SettingsViewController.swift
//  iQuiz
//
//  Created by Munir Emam on 5/14/25.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var URLSource: UITextField!
    
    var quizData: [[String]] = []
    var questionData: [String: [[String: Any]]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        URLSource.text = UserDefaults.standard.string(forKey: "quizURL") ?? "http://tednewardsandbox.site44.com/questions.json"
    }
    
    @IBAction func checkUpdate(_ sender: Any) {
        let url = URL(string: URLSource.text ?? "http://tednewardsandbox.site44.com/questions.json")!
        URLSession.shared.dataTask(with: url) {data, response, error in
            
            if let error = error {
                print("Network request error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                        print("network error")
                    } else {
                        print("donwload error")
                    }
                }
                let alertController = UIAlertController(title: "Network Error", message: "Check Network Connection", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                if Thread.isMainThread {
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("HTTP Error: Invalid response or status code \(statusCode)")
                return
            }
            
            guard let validData = data else {
                print("No data received from server.")
                return
            }
            
            DispatchQueue.main.async {
                do {
                    let quizObject = try JSONSerialization.jsonObject(with: validData, options: .allowFragments)
                    
                    self.quizData = self.quizObjectToData(transformData: quizObject as! [[String : Any]])
                    
                    print(self.quizData)
                    
                    let categoriesData = try PropertyListEncoder().encode(self.quizData)
                    
                    
                    UserDefaults.standard.set(categoriesData, forKey: "categories")
                    
                    self.questionData = self.quizObjectToTest(transformData: quizObject as! [[String : Any]])
                    
                    print(self.questionData)
                    
                    let questionsData = try PropertyListSerialization.data(
                        fromPropertyList: self.questionData,
                        format: .binary,
                        options: 0
                    )
                    print("should print something")
                    print(questionsData)
                    
                    UserDefaults.standard.set(questionsData, forKey: "questions")
                    
                    
                } catch {
                    print("JSON parsing error: \(error)")
                    
                }
            }
        }.resume()
    }
    
    func quizObjectToData(transformData: [[String: Any]]) -> [[String]] {
        var output: [[String]] = []
        for topicDict in transformData {
            if let title = topicDict["title"] as? String,
               let desc = topicDict["desc"] as? String {
                output.append([title, desc, "default_icon.png"]) 
            }
        }
        return output
    }
    
    func quizObjectToTest(transformData: [[String: Any]]) -> [String: [[String: Any]]] {
        var output: [String: [[String: Any]]] = [:]
        for topic in transformData {
            if let title = topic["title"] as? String,
               let rest = topic["questions"] as? [[String: Any]] {
                output[title] = rest
            }
        }
        return output
    }
    
}

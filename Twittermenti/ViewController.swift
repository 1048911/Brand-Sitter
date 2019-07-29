//
//  ViewController.swift
//  Brand Sitter
//


import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100

    let swifter = Swifter(consumerKey: consumerKey, consumerSecret: consumerSecret)
    let sentimentClassifier = TwitterSentientClassifier()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
   
    //MARK: - UPDATES UI METHODS
    
    func updateUI(with classificationScore: Int){
        DispatchQueue.main.async {
            
        self.sentimentLabel.font = self.sentimentLabel.font.withSize(100)
            
         if classificationScore > 20 {
            self.sentimentLabel.text = "😍"
        } else if classificationScore > 10 {
            self.sentimentLabel.text = "😀"
        } else if classificationScore > 0 {
            self.sentimentLabel.text = "🙂"
        } else if classificationScore == 0 {
            self.sentimentLabel.text = "😐"
        } else if classificationScore > -10 {
            self.sentimentLabel.text = "😕"
        } else if classificationScore > -20 {
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤮"
        }
        }
    }
    
     //MARK: - MACHINE LEARNING METHODS
    
    
    func classifyTweets(from tweetsArray: [TwitterSentientClassifierInput]){
        do {
            let classifications = try self.sentimentClassifier.predictions(inputs: tweetsArray)
            var classificationScore = 0
            
            for classification in classifications {
                switch classification.label {
                case "Neg" : classificationScore -= 1
                case "Pos" : classificationScore += 1
                case "Neutral" : classificationScore += 0
                default: print("There was an error with the classification.label of the current tweet.")
                }
            }
            print(classificationScore)
            updateUI(with: classificationScore)
            
            
        } catch {
            print("There was an error classifying the tweet.")
        }
    }
    
     //MARK: - GET TWEET METHODS
    
    func fetchTweets(bySearch searchText: String){
        if searchText == "" {
            DispatchQueue.main.async {
                self.sentimentLabel.font = self.sentimentLabel.font.withSize(15)
                self.sentimentLabel.text = "Please enter a Twitter @username or a #hashtag."
            }
            
        } else {
            
            
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode:.extended, success: { (results, metadata) in
               
                var tweetsForPredictions = [TwitterSentientClassifierInput]()
                
                for i in 0..<self.tweetCount {
                    
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassifier = TwitterSentientClassifierInput(text: tweet)
                        tweetsForPredictions.append(tweetForClassifier)
                        print(tweet)
                    }
                }
                self.classifyTweets(from: tweetsForPredictions)
                
            }) { (error) in
                print("There was an error with the Twitter API request: \(error)")
            }
        }
    }
    


    @IBAction func predictPressed(_ sender: Any) {
       
        let searchText = textField.text!
        fetchTweets(bySearch: searchText)
        
        
    }
    
}


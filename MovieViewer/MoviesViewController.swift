//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Noureddine Youssfi on 1/12/16.
//  Copyright © 2016 Noureddine Youssfi. All rights reserved.
//

import UIKit
import AFNetworking
import BXProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var searchedMovies: [NSDictionary]?
    
    var refresh = UIRefreshControl()
    var refreshed = false
    var timer: NSTimer?
    var time : Float = 0.0
    var tracker = NSDate().timeIntervalSince1970;
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var errorBar: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        
        refresh.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refresh, atIndex: 0)
        self.refresh.backgroundColor = UIColor.grayColor()
        self.refresh.tintColor = UIColor.whiteColor()
        
        
        var targetView: UIView {
            return self.view
        }
        BXProgressHUD.showHUDAddedTo(targetView).hide(afterDelay: 3)

        loadstuff()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let searchedMovie = searchedMovies {
            return searchedMovie.count
        } else {
            return 0
        }
//        return
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = searchedMovies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        

        
        let posterPath = movie["poster_path"] as! String
        let imageUrl =  NSURL(string: baseUrl + posterPath)
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        cell.posterView.setImageWithURL(imageUrl!)
        

        print(title)
        
        return cell
    }
    
    //search function
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            
            searchedMovies = movies
        } else {
            searchedMovies = movies?.filter({ (movie: NSDictionary) -> Bool in
                if let title = movie["title"] as? String {
                    if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                        
                        return  true
                    } else {
                        return false
                    }
                }
                return false
            })
        }
        tableView.reloadData()
    }
    // added stuff
    func loadstuff(){
        let apiKey = "05c69b790262f896811556cdcb0ceb3b"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        // added cachepolicy, timeoutinterval
        let request = NSURLRequest(URL: url!)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                
                //                self.tableView.reloadData()
                //                self.refresh.endRefreshing()
                // start new
                if error != nil {
                    self.loadEnded(false);
                    self.showError();
                } else if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies = responseDictionary["results"] as! [NSDictionary];
                            
                            self.searchedMovies = self.movies;
                            let curTrack = NSDate().timeIntervalSince1970;
                            print(curTrack);
                            if((self.refreshed == false) || (curTrack - self.tracker > 2)) {
                                self.search.text = "";
                                self.search.resignFirstResponder();
                                self.tableView.reloadData();
                                self.refresh.endRefreshing();
                                self.loadEnded();
                            } else {
                                self.search.text = "";
                                self.search.resignFirstResponder();
                                self.delay(1.5) {
                                    self.tableView.reloadData();
                                    self.loadEnded();
                                    //                                    self.refresh.endRefreshing();
                                }
                            }
                    }
                }
                // end new
                
                
        });
        task.resume()
    }
    func refreshControlAction(refreshControl: UIRefreshControl){
        refreshed = true;
        loadstuff();
    }
    func loadEnded(showContent : Bool? = true) {

        if(showContent != false) {

            self.tableView.hidden = false;
            UIView.animateWithDuration(1.0, animations: {
                self.tableView.alpha = 1.0;
            });
            if(refreshed == true) {
                refreshed = false;
                self.refresh.endRefreshing();
            }

        }
    }
    func showError() {
        self.errorBar.alpha = 0.0;
        self.errorBar.hidden = false;
        UIView.animateWithDuration(0.5, animations: {
            self.errorBar.alpha = 1.0;
        });
    }
    
    func hideError() {
        if(self.errorBar.hidden == false) {
            UIView.animateWithDuration(0.5, animations: {
                self.errorBar.alpha = 0.0;
            });
            delay(0.5, block: {
                self.errorBar.hidden = true;
            });
        }
    }
    func delay(delay: NSTimeInterval, block: dispatch_block_t) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
        dispatch_after(time, dispatch_get_main_queue(), block)
    }
    @IBAction func errorOnTap(sender: AnyObject) {
        hideError();
        loadstuff();
    }
    
    @IBAction func onViewTap(sender: AnyObject) {
        view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
}
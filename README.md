# Qritic
A rootless arm64e IOS tweak for the Queue movie app that removes the soft character limit on reviews, comments, and the user bio

# Features:
+ Expands Reviews character limit to 600
+ Expands Comments character limit to 300
+ Expands User Bio character limit to 290
+ Users who do not follow you back will have their Following button colored red in various locations throughout the app
+ Within the Watch Streaks badges, the progress section will now tell you the dates the badges will be rewarded on
- Added advanced features only accessible through commands executed within the searchbars spread through the application
  - Command Prefix: ~
  - Current Commands
    - auto [usage: ~auto] enables auto follow/unfollow
      - -s [usage: ~auto -s] enables smart mode
    - kill [usage: ~kill] kills the app
  - When you want to execute the command just press return on the keyboard
 
  - Things to know about auto follow/unfollow
    - It works throughout the application, specifically within Followers/Following tabs and Suggested Friends views
    - You'll likely get alerts saying "Oops" or "Conflict", these can be ignored for the first several but eventually they will be because you've gotten rate limited
    - How to get rate limited/what is it?
      - I had a few people test this and we each followed >=5000 people and are accounts were limited multiple times throughout, took us about an hour or two to finish
      - Its pretty much the app limiting what data is being sent/received from your account, from my testing if you are rate limited you can expect:
        - Nothing will load (movies, notifications, Discover page, Friends page, profile edit page, etc..)
        - IQueue will not update for the time being
        - Followers/Following will not update for the time being 
    - Following >= 5000 people (w/out smart mode) scored us each roughly 700 followers and counting over the course of three days, we are assuming most of the accounts we followed are inactive
     - Follow pool we all dug into (@bumblebee, @rikif7, and @xpascal) and we strictly avoided their "Following" counts and stuck to only their followers

This tweak is mostly for personal use so I have no real interest or motivation to add these settings as toggles, if the day comes that _I_ go public with this (r/jailbreak) i'll probably implement some sort of Settings

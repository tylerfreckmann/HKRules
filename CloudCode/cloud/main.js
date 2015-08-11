require('cloud/app.js')
// Use Parse.Cloud.define to define as many cloud functions as you want.
Parse.Cloud.define("hello", function(request, response) {
  response.success("Goodbye world!");
});

// Sets the alarm in the cloud, and notifies user of the result through push notifcation. 
Parse.Cloud.define("setCloudAlarm", function(request, response) {
	var alarmDate = new Date(request.params.alarmTime);
    var user = Parse.User.current();
    var wakeConfig = user.get("wakeConfig");
    var greetingURL;
    wakeConfig.fetch().then(function(wakeConfig) {
        // Get greeting
        var baseSpeechURL = "http://tts-api.com/tts.mp3?q=";
        var greeting = wakeConfig.get("greeting").replace(' ', '+');
        var ttsURL = baseSpeechURL+greeting+"&return_url=1";
        return Parse.Cloud.httpRequest({ url: ttsURL});
    }).then(function(httpResponse) {
        greetingURL = httpResponse.text;
        var pushQuery = new Parse.Query(Parse.Installation);
        pushQuery.equalTo("user", user);
        return Parse.Push.send({
            where: pushQuery,
            data: {
                "alert": "ALARM",
                //"category": "STOP_ALARM_SOUND_CATEGORY",
                "content-available": 1,
                "soundAlarm": 1,
                "soundFile": wakeConfig.get("sound"),
                "greeting": greetingURL,
                "weather": wakeConfig.get("weather"),
                "lights": wakeConfig.get("lights")
            },
            push_time: alarmDate
        });
    }).then(function() {
        response.success("push scheduled for "+user.get("username"));
    }, function(error) {
        response.error(error.message+' '+error.code);
    });
});

// Called to push notification to HKRules application after shower timer triggered.
Parse.Cloud.define("showerStarted", function(request, response) {

	var userQuery = new Parse.Query(Parse.User);        
	userQuery.equalTo("username", request.params.username);

	userQuery.find({
        success: function(users) {
                   
        // Get the current time
        var alertTime = new Date();
        alertTime.getHours();
        alertTime.getMinutes();
        alertTime.getSeconds();
                            
        // Init the push query
        var pushQuery = new Parse.Query(Parse.Installation);
        pushQuery.equalTo("user", users[0]);
        pushQuery.equalTo("appName", "HKRules")
                   
        var baseSpeechURL = "http://tts-api.com/tts.mp3?q=Alert+Alert+Alert+Alert+Alert+You+have+showered+for+";
        var concatTimeURL = baseSpeechURL.concat(request.params.timeInSeconds);
        var ttsURL = concatTimeURL.concat("&return_url=1");
                   
        Parse.Cloud.httpRequest({
            url: ttsURL,
            success: function(httpResponse) {

                // Push to HKRules phone
                Parse.Push.send({
                    where: pushQuery,
                    data: {
                        "alert": "Shower ALERT",
                        "content-available": 1,
                        "ttsURL":  httpResponse.text
                    },
                        push_time: alertTime
                },{ success: function() {
                    response.success("push for " + request.params.username + " scheduled.");
                },
                    error: function(error) {
                    response.error("push errored");         
                }
                }); //end push
            },
            error: function(httpResponse) {
            response.error(httpResponse)
            }
        });
                   
    },
        error: function(error) {
		    response.error("user find query errored");
        }
                   
    });
});

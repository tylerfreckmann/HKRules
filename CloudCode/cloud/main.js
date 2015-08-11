require('cloud/app.js')

var baseSpeechURL = "http://tts-api.com/tts.mp3?q=";

// Sets the alarm in the cloud, and notifies user of the result through push notifcation. 
Parse.Cloud.define("setCloudAlarm", function(request, response) {
	var alarmDate = new Date(request.params.alarmTime);
    var user = Parse.User.current();
    var wakeConfig = user.get("wakeConfig");
    var greetingURL;
    wakeConfig.fetch().then(function(wakeConfig) {
        // Get greeting
        var greeting = wakeConfig.get("greeting").split(" ").join("%20");
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
                "category": "STOP_ALARM_SOUND_CATEGORY",
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

	var user = Parse.User.current();
               
    // Get the current time
    var alertTime = new Date();
    alertTime.getHours();
    alertTime.getMinutes();
    alertTime.getSeconds();
                        
    var pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.equalTo("user", user);
    pushQuery.equalTo("appName", "HKRules")                   
    
    var ttsURL = baseSpeechURL 
                + "Alert Alert Alert Alert Alert You have showered for ".split(" ").join("%20") 
                + request.params.showerTime 
                + "&return_url=1";
    
    Parse.Cloud.httpRequest({
        url: ttsURL,
        success: function(httpResponse) {
            // Push to HKRules phone
            Parse.Push.send({
                where: pushQuery,
                data: {
                    "alert": "You showered for " + request.params.showerTime.replace("+", " ") + "!",
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
});

// Called when client is about to leave the house 
Parse.Cloud.define("prepareToLeaveHouse", function (request, response) {
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
         
        var message = "%2C let me check if the house is safe right now".split(" ").join("%20")
        var initialCheckURL =  baseSpeechURL + "Hi%20" + request.params.username + message + "&return_url=1"          
                   
        Parse.Cloud.httpRequest({
            url: initialCheckURL,
            success: function(httpResponse) {
                // Able to GET intialCheckURL


            },
            error: function(httpResponse) {
                response.error("GET request failed for initialCheckURL")
            }
        });
                   
    },
        error: function(error) {
            response.error("user find query errored");
        }
                   
    });
});


                
// Parse.Push.send({
//     where: pushQuery,
//     data: {
//         "alert": "Checking for house TTS",
//         "content-available": 1,
//         "ttsURL":  httpResponse.text
//     },
//         push_time: alertTime
// },{ success: function() {
//     response.success("push for " + request.params.username + " scheduled.");
// },
//     error: function(error) {
//     response.error("push errored");         
// }
// }); //end push

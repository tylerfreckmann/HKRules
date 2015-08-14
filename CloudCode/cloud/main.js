require('cloud/app.js')

// Global variables used for speech URLS 
var weatherAPIKey = "2746bc27d6d47ddd627f76d17870dab3";
var baseSpeechURL = "http://tts-api.com/tts.mp3?q=";
var speechPadding = ",,,".split(",").join("%2C");
var longerPadding = ",,,,,".split(",").join("%2C");

// Used in "prepareToLeaveHouse"
var finalMsgForLeaveHouse = "";
var initialGreetingURL = "";


/* Sets the alarm in the cloud, and notifies user of the result through push notifcation. */
Parse.Cloud.define("setCloudAlarm", function(request, response) {
    var alarmDate = new Date(request.params.alarmTime);
    var user = Parse.User.current();
    var wakeConfig = user.get("wakeConfig");
    wakeConfig.fetch().then(function(wakeConfig) {
        var pushQuery = new Parse.Query(Parse.Installation);
        pushQuery.equalTo("user", user);
        return Parse.Push.send({
            where: pushQuery,
            data: {
                "alert": "ALARM",
                "content-available": 1,
                "soundAlarm": 1,
                "soundFile": wakeConfig.get("sound"),
                "greeting": wakeConfig.get("greeting"),
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

/* Called to push notification to HKRules application after shower timer triggered. */
Parse.Cloud.define("showerAlert", function(request, response) {

    var user = Parse.User.current();
               
    // Get the current time
    var alertTime = getCurrentTime();
                        
    var pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.equalTo("user", user);
    pushQuery.equalTo("appName", "HKRules")                   
    
    // Convert alert message to TTS URL to get mp3 to stream from
    var showerAlertURL = baseSpeechURL 
        + speechPadding
        + "Alert%2C You have showered for ".split(" ").join("%20") 
        + request.params.showerTime.split(" ").join("%20") 
        + "&return_url=1";

    console.log(showerAlertURL);

    Parse.Cloud.httpRequest({
        url: showerAlertURL,
        success: function(showerAlertResponse) {
            // Push to HKRules phone
            Parse.Push.send({
                where: pushQuery,
                data: {
                    "alert": "You showered for " + request.params.showerTime,
                    "content-available": 1,
                    "showerAlertURL":  showerAlertResponse.text
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
        error: function() {
            response.error("GET request failed for showerAlertURL");
        }
    });        
});

/* Called when client is about to leave the house, checking home security and weather forecast */ 
Parse.Cloud.define("prepareToLeaveHouse", function (request, response) {
    var user = Parse.User.current();
    var alertTime = getCurrentTime();

    var pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.equalTo("user", user);
    pushQuery.equalTo("appName", "HKRules");
     
    // Get TTS URL for  initial check message  
    var message = "%2C let me check if the house is safe right now. Give me a second or two.".split(" ").join("%20");
    var initialCheckURL =  baseSpeechURL + longerPadding + "Hi%20" + request.params.username + message + "&return_url=1";          

    // Requests for the initial check TTS 
    Parse.Cloud.httpRequest({url: initialCheckURL}).then(function(initialCheckMP3) {
        var requestEndPointURL = "https://graph.api.smartthings.com/api/smartapps/endpoints?access_token="
            + user.get("sttoken");
        initialGreetingURL = initialCheckMP3.text;
        // Request for the endpoint URL
        return Parse.Cloud.httpRequest({url: requestEndPointURL});
    }).then(function(endPointResponse) {
        var json = JSON.parse(endPointResponse.text);
        var endPointURL = json[0]["url"];
        var apiCallURL = "https://graph.api.smartthings.com" + endPointURL;
        var checkSensorsURL = apiCallURL + "/contactSensors?access_token=" + user.get("sttoken");
        // Get list of contact sensors (doors, windows, etc...)
        return Parse.Cloud.httpRequest({url: checkSensorsURL});
    }).then(function(sensors) {
        parseListOfSensors(sensors, request);
        // Gets the current weather forecast
        return getWeatherMsg(request.params.locationLatitude, request.params.locationLongitude);
    }).then(function(weatherMessage) {
        var recapMessageURL = finalMsgForLeaveHouse + weatherMessage + "&return_url=1";
        // Request for the final TTS MP3 url
        return Parse.Cloud.httpRequest({url: recapMessageURL});
    }).then(function(recapMessageMP3) {
        // Push to HKRules 
        return Parse.Push.send({
                    where: pushQuery,
                    data: {
                        "alert": "Checking security of your home & getting your weather forecast!",
                        "content-available": 1,
                        "leaveFlag": 1, 
                        "initialCheckURL":  initialGreetingURL,
                        "recapMessageURL": recapMessageMP3.text
                    },
                    push_time: alertTime
                });
    }).then(function() {
        response.success("push for " + request.params.username + " scheduled.");
    }, function(error) {
        response.error(error);
    });
});

/* Helper function for getting the current time */
var getCurrentTime = function() {
    var alertTime = new Date();
    alertTime.getHours();
    alertTime.getMinutes();
    alertTime.getSeconds();
    return alertTime;
}

/* Helper function for going through the list of sensors, checking if any are open and creating TTS for them. */
var parseListOfSensors = function(sensors, request) {
    // Break up the list of sensors into JSON strings (based on [...])
    var matches = [];
    var pattern = /\[(.*?)\]/g;
    var match;
    while ((match = pattern.exec(sensors.text)) != null) {
        matches.push(match[1]);
    }

    var listOpenSensors = [];
    var anyOpenSensors = false; 
    // Loops through all sensors, and keeps track of them. 
    for (i = 0; i < matches.length; i++) {
        var currentSensor = JSON.parse(matches[i]);
        if (currentSensor["value"] != "closed") {
            anyOpenSensors = true;
            listOpenSensors.push(("%2C Your " + currentSensor["name"] + " is open!").split(" ").join("%20"));
        }
    }

    if (!anyOpenSensors) {
        finalMsgForLeaveHouse = 
            baseSpeechURL 
            + speechPadding
            + "Hi%20" 
            + request.params.username 
            + "%2C All of your sensors are closed. Your home is safe and secured. ".split(" ").join("%20")
    } else {
        finalMsgForLeaveHouse =  
            baseSpeechURL 
            + speechPadding
            + "Hi%20" 
            + request.params.username 
            + "%2C I am currently seeing some open sensors".split(" ").join("%20");

        for (i = 0; i < listOpenSensors.length; i++) {
            finalMsgForLeaveHouse += listOpenSensors[i];
        }
    }
}

/* Recieves the weather forecast given a coordinate. Returns a promise of a weather forecast. */
var getWeatherMsg = function(latitude, longitude) {
    var promise = new Parse.Promise()
    // Start fetching weather forecast
    var weatherURL = "https://api.forecast.io/forecast/" 
        + weatherAPIKey 
        + "/" + latitude 
        + "," + longitude;  

    // Get the weather format in JSON 
    Parse.Cloud.httpRequest( {
        url: weatherURL, 
        success: function(weatherJSON) {
            var weatherJson = JSON.parse(weatherJSON.text);
            var temp =  
                speechPadding + "Today, the weather is " + weatherJson["currently"]["summary"]
                + speechPadding + "The current temperature is " + Math.floor(weatherJson["currently"]["temperature"]) + "degrees"
                + speechPadding + "The chance of it raining is " + Math.floor((weatherJson["currently"]["precipProbability"]*100)) + " percent"
                + speechPadding + "Have a good rest of the day!" ;
            var weatherMessage = temp.split(" ").join("%20"); 
            promise.resolve(weatherMessage);
        }, 
        error: function () {
            promise.reject("getWeatherMsg failed");
        }
    });
    return promise;
}

/* Parse Cloud method for getting the weather forecast in String */ 
Parse.Cloud.define("getWeather", function (request, response) {
    getWeatherMsg(request.params.latitude, request.params.longitude).then(function(weatherMessage) {
        response.success(weatherMessage);
    });
});

/* After save method for transforming wake config greeting text into tts url*/
Parse.Cloud.afterSave("WakeConfig", function(request) {
    var greeting = request.object.get("greeting");
    if (greeting.search("http") != 0) {
        greeting.split(" ").join("%20");
        var ttsURL = baseSpeechURL+greeting+"&return_url=1";
        Parse.Cloud.httpRequest({ url: ttsURL}).then(function(httpResponse) {
            return request.object.save({ greeting: httpResponse.text});
        }).then(function(wakeConfig) {
            console.log("successfully transformed greeting");
        }, function(wakeConfig, error) {
            console.log("greeting transformation failed: " + error.message);
        });
    }
});
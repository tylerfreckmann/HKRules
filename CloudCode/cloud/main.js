require('cloud/app.js')

var weatherAPIKey = "2746bc27d6d47ddd627f76d17870dab3";
var baseSpeechURL = "http://tts-api.com/tts.mp3?q=";
var speechPadding = ",,,".split(",").join("%2C");
var longerPadding = ",,,,,".split(",").join("%2C");

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
    
    // Convert alert message to TTS URL to get mp3 to stream from
    var ttsURL = baseSpeechURL 
        + speechPadding
        + "Alert%2C You have showered for ".split(" ").join("%20") 
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
    var user = Parse.User.current();

    // Get the current time
    var alertTime = new Date();
    alertTime.getHours();
    alertTime.getMinutes();
    alertTime.getSeconds();

    var pushQuery = new Parse.Query(Parse.Installation);
    pushQuery.equalTo("user", user);
    pushQuery.equalTo("appName", "HKRules");
     
    var finalMessage = "";

    // Get TTS URL for  initial check message  
    var message = "%2C let me check if the house is safe right now. Give me a second or two.".split(" ").join("%20");
    var initialCheckURL =  baseSpeechURL + longerPadding + "Hi%20" + request.params.username + message + "&return_url=1";          

    // Requests for the initial check TTS 
    Parse.Cloud.httpRequest({
        url: initialCheckURL,
        success: function(initialCheckMP3) {
            // Check home security
            var requestEndPointURL = "https://graph.api.smartthings.com/api/smartapps/endpoints?access_token=" 
                + user.get("sttoken");
            
            // Request for the endpoint URL
            Parse.Cloud.httpRequest({
                url: requestEndPointURL,
                success: function(endPointResponse) {
                    var json = JSON.parse(endPointResponse.text);
                    var endPointURL = json[0]["url"];
                    var apiCallURL = "https://graph.api.smartthings.com" + endPointURL;
                    var checkSensorsURL = apiCallURL + "/contactSensors?access_token=" + user.get("sttoken");

                    // Get list of contact sensors (doors, windows, etc...)
                    Parse.Cloud.httpRequest({
                        url: checkSensorsURL,
                        success: function(sensors) {
                            // Break up the list of sensors into JSON strings (based on [...])
                            var matches = [];
                            var pattern = /\[(.*?)\]/g;
                            var match;
                            while ((match = pattern.exec(sensors.text)) != null) {
                                matches.push(match[1]);
                            }

                            var anyOpen = false; 
                            var listOpenSensors = [];
                            // Loops through all sensors, and keeps track of them. 
                            for (i = 0; i < matches.length; i++) {
                                var currentSensor = JSON.parse(matches[i]);
                                if (currentSensor["value"] != "closed") {
                                    anyOpen = true;
                                    listOpenSensors.push(("%2C Your " + currentSensor["name"] + " is open!").split(" ").join("%20"));
                                }
                            }

                            if (!anyOpen) {
                                finalMessage = 
                                    baseSpeechURL 
                                    + speechPadding
                                    + "Hi%20" 
                                    + request.params.username 
                                    + "%2C All of your sensors are closed. Your home is safe and secured. ".split(" ").join("%20")
                            }
                            else {
                                finalMessage =  
                                    baseSpeechURL 
                                    + speechPadding
                                    + "Hi%20" 
                                    + request.params.username 
                                    + "%2C I am currently seeing some open sensors".split(" ").join("%20");

                                for (i = 0; i < listOpenSensors.length; i++) {
                                    finalMessage += listOpenSensors[i];
                                }
                            }

                            // Start fetching weather forecast
                            var weatherURL = "https://api.forecast.io/forecast/" 
                                + weatherAPIKey 
                                + "/" + request.params.locationLatitude 
                                + "," + request.params.locationLongitude;  

                            // Get the weather format in JSON 
                            Parse.Cloud.httpRequest( {
                                url: weatherURL, 
                                success: function(weatherJSON) {
                                    var weatherJson = JSON.parse(weatherJSON.text);
                                    var weatherMessage = 
                                        speechPadding + "Today, the weather is " + weatherJson["currently"]["summary"]
                                        + speechPadding + "The current temperature is " + Math.floor(weatherJson["currently"]["temperature"]) + "degrees"
                                        + speechPadding + "The chance of it raining is " + weatherJson["currently"]["precipProbability"] + " percent"
                                        + speechPadding + "Have a good rest of the day!" ;
                                    weatherMessage = weatherMessage.split(" ").join("%20"); 
                                    var recapMessageURL = finalMessage + weatherMessage + "&return_url=1";

                                    console.log("recapMessageURL: " + recapMessageURL);

                                    Parse.Cloud.httpRequest({
                                        url: recapMessageURL,
                                        success: function(recapMessageMP3) {

                                            // Push to HKRules 
                                            Parse.Push.send({
                                                where: pushQuery,
                                                data: {
                                                    "alert": "Checking for house TTS",
                                                    "content-available": 1,
                                                    "leaveFlag": 1, 
                                                    "initialCheckURL":  initialCheckMP3.text,
                                                    "recapMessageURL": recapMessageMP3.text
                                                },
                                                push_time: alertTime
                                            },
                                                { success: function() {
                                                    response.success("push for " + request.params.username + " scheduled.");
                                                }, error: function(error) {
                                                    response.error("push errored");         
                                                }
                                            }); 

                                        },
                                        error: function() {
                                            response.error("GET request failed for weatherMessageMP3");
                                        }
                                    });
                                }, 
                                error: function () {
                                    response.error("GET request failed for weatherURL");
                                }
                            });
                            
                        },
                        error: function() {
                            response.error("GET request failed for contactSensorsRequest")
                        }
                    });
                        
                },
                error: function() {
                    response.error("GET request failed for requestEndPointURL");
                }
            });
        },
        error: function() {
            response.error("GET request failed for initialCheckURL");
        }
    });
});
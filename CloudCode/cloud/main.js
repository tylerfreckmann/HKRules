require('cloud/app.js')
// Use Parse.Cloud.define to define as many cloud functions as you want.
Parse.Cloud.define("hello", function(request, response) {
  response.success("Goodbye world!");
});

// Sets the alarm in the cloud, and notifies user of the result through push notifcation. 
Parse.Cloud.define("setCloudAlarm", function(request, response) {
	var alarmDate = new Date(request.params.alarmTime);
	var userQuery = new Parse.Query(Parse.User);
	userQuery.equalTo("username", request.params.username);
	userQuery.find({
		success: function(users) {
			var user = users[0];
			var pushQuery = new Parse.Query(Parse.Installation);
			pushQuery.equalTo("user", user);

			Parse.Push.send({
				where: pushQuery,
				data: {
					"alert": "ALARM",
					"content-available": 1,
					"soundAlarm": 1
				},
				push_time: alarmDate
			}, {
				success: function() {
					response.success("push for " + request.params.username + " scheduled.");
				},
				error: function(error) {
					response.error("push errored");
				}
			});
		},
		error: function(error) {
			response.error("user find query errored");
		}
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
        alertTime.setSeconds(alertTime.getSeconds());
                            
        // Init the push query
        var pushQuery = new Parse.Query(Parse.Installation);
        pushQuery.equalTo("user", users[0]);
        pushQuery.equalTo("appName", "HKRules")
                     
        // Push to HKRules phone
        Parse.Push.send({
             where: pushQuery,
             data: {
                 "alert": "Shower ALERT",
                 "content-available": 1,
             },
             push_time: alertTime
        },  {
            success: function() {
                 response.success("push for " + request.params.username + " scheduled.");
            },
            error: function(error) {
                 response.error("push errored");
            }
        }); //end push
                   
    },
        error: function(error) {
		    response.error("user find query errored");
        }
                   
    });
});

// Called when SmartThings token acquired
Parse.Cloud.define("sttoken", function(request, response) {
	response.success("sttoken");
});
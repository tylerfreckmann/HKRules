require('cloud/app.js')
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

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

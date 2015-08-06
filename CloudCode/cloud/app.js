
// These two lines are required to initialize Express in Cloud Code.
express = require('express');
app = express();
var Buffer = require('buffer').Buffer;
var oauth2 = require('simple-oauth2')({
	clientID: '04e5f073-c826-482f-a6b5-e22e7d2d61fe',
	clientSecret: '908091ac-6690-4349-8cf1-592b970a00ec',
	site: 'https://graph.api.smartthings.com',
	tokenPath: '/oauth/token',
	authorizationPath: '/oauth/authorize'
});

var authorization_uri = oauth2.authCode.authorizeURL({
	redirect_uri: 'http://hkrules.parseapp.com/callback',
	scope: 'app'
});

// Global app configuration section
app.set('views', 'cloud/views');  // Specify the folder to find templates
app.set('view engine', 'ejs');    // Set the template engine
app.use(express.bodyParser());    // Middleware for reading request body

// This is an example of hooking up a request handler with a specific request
// path and HTTP verb using the Express routing API.
app.get('/hello', function(req, res) {
	res.render('hello', { message: 'Congrats, you just set up your app!' });
});

app.get('/auth', function(req, res) {
	res.redirect(authorization_uri);
});

app.get('/callback', function(req, res) {
	var u = new Buffer("04e5f073-c826-482f-a6b5-e22e7d2d61fe:908091ac-6690-4349-8cf1-592b970a00ec").toString('base64');
	console.log('reached code');
	Parse.Cloud.httpRequest({
		url: 'https://graph.api.smartthings.com/oauth/token?code='+req.query.code+'&grant_type=authorization_code&redirect_uri=https%3A%2F%2Fgraph.api.smartthings.com%2Foauth%2Fcallback&scope=app',
		headers: {
			'Authorization': 'Basic '+u
		},
	}).then(function(httpResponse) {
		console.log(httpResponse.data['access_token']);
		res.end();
	}, function(httpResponse) {
		console.log(httpResponse.text);
		res.end();
	});
});

// // Example reading from the request query string of an HTTP get request.
// app.get('/test', function(req, res) {
//   // GET http://example.parseapp.com/test?message=hello
//   res.send(req.query.message);
// });

// // Example reading from the request body of an HTTP post request.
// app.post('/test', function(req, res) {
//   // POST http://example.parseapp.com/test (with request body "message=hello")
//   res.send(req.body.message);
// });

// Attach the Express app to Cloud Code.
app.listen();

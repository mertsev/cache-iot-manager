// REST data for testing
(function() {
	angular.module('Sensors').factory('sensorsREST', [ '$http', function($http) {
		var factory = {};
		
		var randomLight = function() { return Math.floor(Math.random() * 500); }
		var randomAccel = function() { return Math.random() * 6 - 3; }
		
		factory.url = '/resttest/json/'
		
		factory.getData = function(connectionid, successHandler, errorHandler) {
			var ret = { success: true, error: "", data: [
					{ device: "Phone Attila", sensor: "accelerometer", created: "2016-07-25 23:28:00.000", value1: randomLight() },
					{ device: "Phone Pavel", sensor: "accelerometer", created: "2016-07-25 23:27:59.678", value1: randomLight() },
					{ device: "Phone Roman", sensor: "accelerometer", created: "2016-07-25 23:28:04.46", value1: randomLight() },
					{ device: "Phone Sergey", sensor: "accelerometer", created: "2016-07-25 23:28:02.345", value1: randomLight() },
					{ device: "Tablet Attila", sensor: "accelerometer", created: "2016-07-25 23:27:56.754", value1: randomLight() },
					{ device: "Phone Attila", sensor: "light", created: "2016-07-25 23:28:00.000", value1: randomAccel() },
					{ device: "Phone Pavel", sensor: "light", created: "2016-07-25 23:27:59.678", value1: randomAccel() },
					{ device: "Phone Roman", sensor: "light", created: "2016-07-25 23:28:04.46", value1: randomAccel() },
					{ device: "Phone Sergey", sensor: "light", created: "2016-07-25 23:28:02.345", value1: randomAccel() },
					{ device: "Tablet Attila", sensor: "light", created: "2016-07-25 23:27:56.754", value1: randomAccel() },
			] };
			if (typeof successHandler === 'function') {
				successHandler.call(this, ret);
			}
			// TODO: error handling
		}
		
		return factory;
	}]); 
})();
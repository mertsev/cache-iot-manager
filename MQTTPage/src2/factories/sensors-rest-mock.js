(function() {
	angular.module('Sensors').factory('sensorsREST', [ '$http', function($http) {
		var factory = {};
		
		var randomLight = function() { return Math.floor(Math.random() * 500); }
		var randomAccel = function() { return Math.random() * 6 - 3; }
		
		factory.getData = function(connectionid, successHandler, errorHandler) {
			var ret = { success: true, error: '', data: [
				{ sensorType: "light", devices: [
					{ deviceID: 'Phone Attila', createdAt: '2016-07-25 23:28:00.000', value: randomLight() },
					{ deviceID: 'Phone Pavel', createdAt: '2016-07-25 23:27:59.678', value: randomLight() },
					{ deviceID: 'Phone Roman', createdAt: '2016-07-25 23:28:04.46', value: randomLight() },
					{ deviceID: 'Phone Sergey', createdAt: '2016-07-25 23:28:02.345', value: randomLight() },
					{ deviceID: 'Tablet Attila', createdAt: '2016-07-25 23:27:56.754', value: randomLight() },
				]},
				{ sensorType: "accelerometer", devices: [
					{ deviceID: 'Phone Attila', createdAt: '2016-07-25 23:28:00.000', value: randomAccel() },
					{ deviceID: 'Phone Pavel', createdAt: '2016-07-25 23:27:59.678', value: randomAccel() },
					{ deviceID: 'Phone Roman', createdAt: '2016-07-25 23:28:04.46', value: randomAccel() },
					{ deviceID: 'Phone Sergey', createdAt: '2016-07-25 23:28:02.345', value: randomAccel() },
					{ deviceID: 'Tablet Attila', createdAt: '2016-07-25 23:27:56.754', value: randomAccel() },
				]},
			] };
			if (typeof successHandler === 'function') {
				successHandler.call(this, ret);
			}
			// TODO: error handling
		}
		
		return factory;
	}]); 
})();
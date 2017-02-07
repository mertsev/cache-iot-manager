(function() {
	angular.module('Sensors').controller('SensorController', [ '$rootScope', '$scope', '$interval', 'sensorsREST', function($rootScope, $scope, $interval, sensorsREST) {
		var ctrl = this;

		ctrl.connectionID = '';
		ctrl.connected = false;
		ctrl.data = [];
		ctrl.autoRefresh = '';
		
		ctrl.activeTab = 0;
		
		ctrl.isActiveTab = function(tabindex) {
			return tabindex === ctrl.activeTab;
		}
		
		ctrl.setActiveTab = function(tabindex) {
			this.activeTab = tabindex;
		}

		ctrl.getConnID = function() {
		return this.connectionID;
	}

		$rootScope.$on('ConnectionEvent', function(event, data) {
			ctrl.connected = data.connected;
			ctrl.connectionID = data.connectionID;
			if (ctrl.connected) {
				ctrl.start();
			}
			else {
				ctrl.stop();
			}
		});

		
		var doRefresh = function() {
			sensorsREST.getData(
				ctrl.connectionID,
				function(result) {
					if (typeof result === 'object') {
						if (!result.success) {
							console.log('Server error while refreshing sensor data:\n' + result.error);
						}
						else {
							var data = [];
							var lamps = [];
							var sensors = {};
							
							for (var i = 0; i < result.data.length; i++) {
								var item = result.data[i];

								if (item.sensor.toLowerCase().indexOf("light") !== -1)
									item.sensor = "Light";
								if (item.sensor.toLowerCase().indexOf("acceler") !== -1)
									item.sensor = "Accelerometer";

								if (typeof sensors[item.sensor] === 'undefined') {
									data.push({ sensorType: item.sensor, devices: [] });
									sensors[item.sensor] = data.length - 1;
								}
								var val = (parseFloat(item.value1));
								
								// light lamp sensors
								if (item.sensor == "Light")
								{			
									var light = 0;
									
									if (Date.parse(item.created) > (Date.now() - 25210000))
									{
										if (val < 20)
											light = 1;
										else
											light = 2;
									}
									if (light == 0)
										val = 0;
									lamps.push({ device: item.device, value: (val.toFixed(2)), light: light})
								}
								data[sensors[item.sensor]].devices.push(
									{ deviceID: item.device, createdAt: item.created, value: val }
								);
							}														
							ctrl.data = data;
							ctrl.lamps = lamps;
						}
					}
					else {
						console.log('Unexpected return value in refresh(): \'' + result + '\'')
					}
				},
				function(error) {
					console.log('Error while refreshing sensor data:\n' + error);
				}
			)
		};

		
		ctrl.isConnected = function() {
			return this.connected;
		}

		ctrl.start = function() {
			if (ctrl.autoRefresh === '') {
				doRefresh();
				ctrl.autoRefresh = $interval(doRefresh, 3000); 
			}
		}
		
		ctrl.stop = function() {
			if (ctrl.autoRefresh !== '') {
				$interval.cancel(ctrl.autoRefresh);
				ctrl.autoRefresh = '';
			}
		}
		
        $scope.$on('$destroy', function() {
			ctrl.stop();
        });
}]);
})();
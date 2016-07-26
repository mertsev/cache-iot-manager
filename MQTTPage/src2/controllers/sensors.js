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
			if (ctrl.connected) {
				ctrl.start();
			}
			else {
				ctrl.stop();
			}
		});
		
		var doRefresh = function() {
			console.log('Refreshing...');
			sensorsREST.getData(
				ctrl.connectionID,
				function(result) {
					if (typeof result === 'object') {
						if (!result.success) {
							console.log('Server error while refreshing sensor data:\n' + result.error);
						}
						else {
							ctrl.data = result.data;
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
				ctrl.autoRefresh = $interval(doRefresh, 5000); 
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
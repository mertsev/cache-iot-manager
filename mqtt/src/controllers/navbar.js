(function() {
	angular.module('Sensors').controller('NavbarController', [ '$rootScope', '$scope', 'connectionREST', function($rootScope, $scope, connectionREST) {
	var ctrl = this;

	ctrl.connected = false;
	ctrl.connectionID = '';

	
	$rootScope.$on('ConnectionEvent', function(event, data) {
		ctrl.connected = data.connected;
		ctrl.connectionID = data.connectionID;
	});	

	ctrl.subscribe = function() {
		$rootScope.$emit('ShowModal', { numberOfModal: 2});
	}

	ctrl.sendMessage = function() {
		$rootScope.$emit('ShowModal', { numberOfModal: 3});
	}

	ctrl.stop = function() {
		$rootScope.$emit('ConnectionEvent', { connected: false, connectionID: ctrl.connectionID });
		if (ctrl.connectionID !== '') {
			connectionREST.disconnect(
				ctrl.connectionID,
				function(result) {
					if (typeof result === 'object') {
						// we remove the connectionID either ways, because on error we can't be sure about it any more.
						$rootScope.$emit('ConnectionEvent', { connected: false, connectionID: '' });
						if (!result.success) {
							sessionStorage.setItem('loaded', false);
							console.log('Server error while stopping MQTT Client:\n' + result.error);
						}
						else
						{
							var $winArea = $('#window-area');
  							$winArea.delay(100).fadeIn('slow');
						}
					}
					else {
						console.log('Unexpected return value in stop(): \'' + result + '\'')
					}
				},
				function(error) {
					console.log('Error while stopping MQTT Client:\n' + error);
				}
			);
		}
	}

	$scope.$on('Reload', function() {
        ctrl.stop();
    });

    // if tab is closed
	window.onbeforeunload = function (e) {
		ctrl.stop();
	};

}]);
})();
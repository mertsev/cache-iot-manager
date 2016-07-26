(function() {
	angular.module('Sensors').directive('sendmessageModal', function() {
		return {
			restrict: 'E',
			templateUrl: 'src2/templates/sendmessage-modal.html',
			controller: 'SendMessageController',
			controllerAs: 'sendmessage',
			bindToController: true
		}
	});
})();
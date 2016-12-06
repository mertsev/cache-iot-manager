(function() {
	angular.module('Sensors').directive('subscriptionModal', function() {
		return {
			restrict: 'E',
			templateUrl: 'src/templates/subscription-modal.html',
			controller: 'SubscriptionController',
			controllerAs: 'subscription',
			bindToController: true
		}
	});
})();
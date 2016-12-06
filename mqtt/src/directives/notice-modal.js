(function() {
	angular.module('Sensors').directive('noticeModal', function() {
		return {
			restrict: 'E',
			templateUrl: 'src/templates/notice-modal.html',
			controller: 'NoticeController',
			controllerAs: 'notice',
			bindToController: true
		}
	});
})();
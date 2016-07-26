(function() {
	angular.module('Sensors').directive('noticeModal', function() {
		return {
			restrict: 'E',
			templateUrl: 'src2/templates/notice-modal.html',
			controller: 'NoticeController',
			controllerAs: 'notice',
			bindToController: true
		}
	});
})();
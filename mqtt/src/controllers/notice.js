(function() {
  angular.module('Sensors').controller('NoticeController', [ '$rootScope', '$scope', function($rootScope, $scope) {
    var ctrl = this;

    // it's a first modal
    $rootScope.$on('ShowModal', function(event, data) {
      if (data.numberOfModal === 1) {
        if (data.Type == 3) {
      $('#modalType').attr('class', 'modal-header modal-error');
    } else if (data.Type == 2) {
      $('#modalType').attr('class', 'modal-header modal-warning');
    } else {
      $('#modalType').attr('class', 'modal-header modal-info');
    }
      $('#noticeHeader').html(data.Header);
      $('#noticeText').html(data.Text);
      $('#NoticeModal').modal('show');
    }
    });
    


    }]);
})();
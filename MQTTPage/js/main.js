 $(window).on('load', function () {
    var $preloader = $('#page-preloader'),
        $spinner   = $preloader.find('.spinner');
    $spinner.fadeOut();
    $preloader.delay(100).fadeOut('slow');
});



// getting data source
var app = angular.module('MQTTApp', []);
app.controller('MQTTCtrl', function($scope, $http) {
  $scope.isConnected = false;
  $scope.ShowNotice = function(nHead, nText, nType) {
    if (nHead == undefined) {
      nHead = "Title";
    }
    if (nText == undefined) {
      nText = "Text";
    }
    if (nType == undefined) {
      nType = 1;
    }
    if (nType == 3) {
      $scope.modalType = "modal-error";
    } else if (nType == 2) {
      $scope.modalType = "modal-warning";
    } else {
      $scope.modalType = "modal-info";
    }
    $scope.noticeHeader = nHead;
    $scope.noticeText = nText;
    $('#NoticeModal').modal('show');
  };
  // Connect
  $scope.Connect = function() {
    $http({
      method: 'GET',
      url: "../../rest/json/connect/" + $scope.UserId
    }).success(function(data, status, header, config) {
      if (!data.success) {
        $scope.ErrMessages = data.error;
        return false;
      }
      $scope.isConnected = true;
      $scope.ClientObj = data;
      var $winArea = $('#window-area');
      $winArea.delay(100).fadeOut('slow');
    }).error(function(data, status, header, config) {
      $scope.ErrMessages = "Connection error!";
  });
  }
  // Disconnect
  $scope.Disconnect = function() {
    $http({
      method: 'GET',
      url: "../../rest/json/disconnect/" + $scope.UserId
    }).success(function(data, status, header, config) {
      if (!data.success) {
        $scope.ShowNotice('Disconnectoin error', data.error, 3);
        return false;
      }
      $scope.isConnected = false;
      var $winArea = $('#window-area');
      $winArea.delay(100).fadeIn('slow');
    }).error(function(data, status, header, config) {
      $scope.ShowNotice('Disconnection error', data.error, 3);
    });
  }
  // Subscribe
  $scope.Subscribe = function() {
    // Getting array of topics
    var topics = $scope.link.split(", ");
    var dataObjs = new Array();
    for (var i=0; i<topics.length; i++) {
      dataObjs.push({"topicFilter": topics[i], "qos": "2"})
    }
    $http({
      method: 'POST',
      headers: "",//{ 'Content-Type': 'application/json' },
      url: "../../rest/json/subscribe/" + $scope.ClientObj.clientObject,
      data: dataObjs
    }).success(function(data, status, header, config) {
      if (!data.success) {
        $scope.ShowNotice('Subscribe error', data.error, 3);
        return false;
      }
      var bufstr = data.topics[0].topicFilter;
      for (var i=1; i<data.topics.length; i++) {
        bufstr += ", " + data.topics[i].topicFilter;
      }
      $scope.ShowNotice('Subscribe', 'Subscribe successfully complete! \nYou are subscribed to: ' + bufstr + ".");
    }).error(function(data, status, header, config) {
      $scope.ShowNotice('Subscribe error', data.error, 3);
    });
  }

  // Unubscribe
  $scope.Unsubscribe = function() {
    // Getting array of topics
    var topics = $scope.link.split(", ");
    var dataObjs = new Array();
    for (var i=0; i<topics.length; i++) {
      dataObjs.push({"topicFilter": topics[i], "qos": "2"})
    }
    $http({
      method: 'POST',
      headers: "",//{ 'Content-Type': 'application/json' },
      url: "../../rest/json/unsubscribe/" + $scope.ClientObj.clientObject,
      data: dataObjs
    }).success(function(data, status, header, config) {
      if (!data.success) {
        $scope.ShowNotice('Unsubscribe error', data.error, 3);
        return false;
      }
      $scope.ShowNotice('Subscribe', 'Unubscribe successfully complete! \nYou are unsubscribed to: ' + $scope.link + ".");
    }).error(function(data, status, header, config) {
      $scope.ShowNotice('Unsubscribe error', data.error, 3);
    });
  }

  $scope.GetMessages = function() {
    $http({
      method: 'GET',
      url: "mes2.html"
    }).success(function(data, status, header, config) {
      $scope.myData = data;
      $scope.ShowNotice('Data', 'The data was successfully loaded.');
    }).error(function(data, status, header, config) {
      $scope.ShowNotice('Data', 'Error loading data.', 3);
  });
  }

});
 $(window).on('load', function () {
    var $preloader = $('#page-preloader'),
        $spinner   = $preloader.find('.spinner');
    $spinner.fadeOut();
    $preloader.delay(100).fadeOut('slow');
});


// getting data source
var app = angular.module('testApp', []);
app.controller('testCtrl', function($scope, $http) {
  $scope.isConnected = false;
  $scope.connectClass = "btn-success";
  $scope.connectText = "Connect";
  $scope.subscribeClass = "btn btn-block btn-primary";
  $scope.subscribeText = "Subscribe";
  $scope.connOrDisc = function () {
    if (!$scope.isConnected)
    {
      $scope.getData();
    }
    else
    {
      $scope.Disconnect();
      $scope.connectClass = "btn-success";
      $scope.connectText = "Connect";
      $scope.isConnected = false;
    }
  }
  // Connect
  $scope.getData = function() {
    $http({
      method: 'GET',
      url: "../../rest/json/connect/" + $scope.UserId
    }).success(function(data, status, header, config) {
	  $scope.connectClass = "btn-danger";
      $scope.connectText = "Disconnect";
      $scope.isConnected = true;
      $scope.ClientObj = data;
    }).error(function(data, status, header, config) {
      alert("incorrect url!");
  });
  }
  // Disconnect
  $scope.Disconnect = function() {
    var act = "../../rest/json/disconnect/" + $scope.UserId;
    $http.get(act);
  }
  // Subscribe
  $scope.Subscribe = function() {
    $http({
      method: 'POST',
      url: "../../rest/json/subscribe/" + $scope.ClientObj.clientObject,
      data:   { "topicFilter": $scope.link, "qos": 2 }
    }).success(function(data, status, header, config) {
      $scope.myData = data.children;
    }).error(function(data, status, header, config) {
      alert("obj not found!");
  });
  }
});
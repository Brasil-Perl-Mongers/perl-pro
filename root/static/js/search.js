function JobListController($scope, $http, $location) {
    $scope.filters = {
        "contract_types": {
            "clt":        false,
            "pj":         false,
            "internship": false,
            "freelance":  false
        },
        "is_telecommute": false,
        "attributes":     [],
        "companies":      [],
        "location":       '',
        "salary_from":    '',
        "salary_to":      '',
        "wages_for":      '',
        "terms":          ''
    };
    $scope.server_error = false;
    $scope.jobs = [];

    $scope.close_and_reload = function () {
        $scope.fetch_results();
        jQuery('.modal:visible').modal('hide');
    };

    $scope.fetch_results = function () {
        var p = serialize_params();
        $http.get('/ajax_search', { params: p }).
            success(function (data) {
                $scope.server_error = false;
                $scope.jobs  = data.items;
                $scope.pager = data.pager;
            }).
            error(function () {
                $scope.server_error = true;
            });
    };

    function parse_location() {
        var s = $location.search();

        if (s.hasOwnProperty('contract_types')) {
            var ct = s.contract_types.split(',');
            angular.forEach(ct, function (i) {
                $scope.filters.contract_types[i] = true;
            });
        }

        if (s.hasOwnProperty('companies')) {
            var c = s.companies.split(',');
            angular.forEach(c, function (i) {
                // TODO:
                // get the real name
                $scope.filters.companies.push({ name: i, name_in_url: i });
            });
        }

        if (s.hasOwnProperty('attributes')) {
            $scope.filters.attributes = s.attributes.split(',');
        }

        if (s.hasOwnProperty('is_telecommute')) {
            $scope.filters.is_telecommute = !!s.is_telecommute;
        }

        angular.forEach([ "location", "salary_from", "salary_to", "wages_for", "terms" ], function (item) {
            if (s.hasOwnProperty(item)) {
                $scope.filters[item] = s[item];
            }
        });
    }

    function serialize_params() {
        var p = {};

        var ct = [];

        angular.forEach($scope.filters.contract_types, function (value, key) {
            if (value) {
                ct.push(key);
            }
        });

        if (ct) {
            p.contract_types = ct.join(',');
        }
        if ($scope.filters.attributes.length) {
            p.attributes = $scope.filters.attributes.join(',');
        }
        if ($scope.filters.companies.length) {
            p.companies = $scope.filters.companies.map(function (item) { return item.name_in_url; }).join(',');
        }
        if ($scope.filters.location) {
            p.location = $scope.filters.location;
        }
        if ($scope.filters.is_telecommute) {
            p.is_telecommute = 1;
        }
        if ($scope.filters.salary_from) {
            p.salary_from = $scope.filters.salary_from;
        }
        if ($scope.filters.salary_to) {
            p.salary_to = $scope.filters.salary_to;
        }
        if ($scope.filters.wages_for) {
            p.wages_for = $scope.filters.wages_for;
        }
        if ($scope.filters.terms) {
            p.terms = $scope.filters.terms;
        }

        $location.path('');
        $location.search(p);

        return p;
    }

    parse_location();
    $scope.fetch_results();
}

function CompanyFilterController($scope, $rootScope) {
    $scope.new_company = {
        name_in_url: '',
        name: ''
    };

    $scope.add_company = function() {
        if (!$scope.new_company.name_in_url) {
            return;
        }
        $rootScope.$apply(function () {
            $scope.filters.companies.push({
                name_in_url : $scope.new_company.name_in_url,
                name: $scope.new_company.name
            });
            $('#form_companies')[0].reset();

            $scope.new_company.name_in_url = '';
            $scope.new_company.name = '';
        });
    };

    $scope.remove_company = function (i) {
        var a = $scope.filters.companies;

        // remove do vetor
        for (var j = i; j < a.length-1; j++) {
            a[j] = a[j+1];
        }
        a.pop();

        $scope.filters.companies = a;

        // para o link não seguir o href
        return false;
    };

    jQuery(function ($) {
        $('#companies').typeahead({
            remote: '/companies/%QUERY',
            name: 'companies',
            valueKey: 'name'
        });
        $('#companies').on('typeahead:selected', function (ev, datum) {
            $scope.new_company.name_in_url = datum.name_in_url;
            $scope.new_company.name = datum.name;
            $scope.add_company();
        });
    });
}

function AttributesFilterController($scope, $rootScope) {
    $scope.new_attribute = '';

    $scope.add_attribute = function() {
        $rootScope.$apply(function () {
            $scope.filters.attributes.push($scope.new_attribute);
            $('#form_attributes')[0].reset();

            $scope.new_attribute = '';
        });
    };

    $scope.remove_attribute = function (i) {
        var a = $scope.filters.attributes;

        // remove do vetor
        for (var j = i; j < a.length-1; j++) {
            a[j] = a[j+1];
        }
        a.pop();

        $scope.filters.attributes = a;

        // para o link não seguir o href
        return false;
    };

    jQuery(function ($) {
        $('#attributes').typeahead({
            remote: '/attributes/%QUERY',
            name: 'attributes'
        });
        $('#attributes').on('typeahead:selected', function (ev, datum) {
            $scope.new_attribute = datum.value;
            $scope.add_attribute();
        });
    });
}

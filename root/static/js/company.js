jQuery(function ($) {
    $( '#jobs_form' ).submit(function () {
        var desired  = [];
        var required = [];

        $( 'ul.desired_attributes > li' ).each(function () {
            var element = $(this).clone();
            element.find('a').remove();
            desired.push(element.text().replace(/^\s+/,'').replace(/\s+$/,''));
        });
        $( 'ul.required_attributes > li' ).each(function () {
            var element = $(this).clone();
            element.find('a').remove();
            required.push(element.text().replace(/^\s+/,'').replace(/\s+$/,''));
        });

        $( '#required_attributes_field' ).val( required.join(',') );
        $( '#desired_attributes_field'  ).val(  desired.join(',') );

        return true;
    });

    $( 'form.requirements' ).submit( function() {
        var values = $(this).find( 'input[type="text"]' ).val().split(',');
        var value;
        var ul = $(this).find( 'ul.requirements' );
        var found;

        for (var i = 0; i < values.length; i++) {
            value = values[i];

            if ( value === '' ) {
                continue;
            }

            found = false;

            ul.find('li').each(function () {
                if ($(this).text() === value) {
                    found = true;
                    return false;
                }
            });

            if (found) {
                continue;
            }

            ul.append( '<li>' + value + ' <a href="#" class="remove-requirement"><i class="icon-remove-sign"></i></a></li>' );
        }

        $(this).find('.remove-requirement').unbind('click');
        $(this).find('.remove-requirement').click( function() {
            $(this).parent('li').remove();
            return false;
        });

        $(this)[0].reset();

        return false;
    });

    $('table.my_jobs td.remove a').click(function () {
        window.about_to_be_removed = $(this).data('job-id');
        $('#remove_job_modal').modal('show');
        return false;
    });

    $('#confirm_remove_button_trigger').click(function () {
        $.ajax({
            type: 'DELETE',
            url: '/account/job/' + window.about_to_be_removed,
            success: function () {
//              TODO: remove this alert and replace it with something decent
                alert('Removido com sucesso.');
                $('#remove_job_modal').modal('hide');
                location.reload();
            }
        });
    });

    $('ul.requirements > li > a.remove-requirement').click( function() {
        $(this).parent().remove();
        return false;
    });

    $('div.btn-radio').each(function () {
        var data_for = $(this).data('radio-for');
        var real_el  = $('[name="'+data_for+'"]');
        var value    = real_el.val();

        $(this).find('button.active').removeClass('active');

        $(this).find('button').each(function () {
            if ($(this).val() == value) {
                $(this).addClass('active');
            }
        });

        $(this).find('button').click(function () {
            real_el.val($(this).val());
        });
    });

    var map = {};
    var timeout;
    var last;

    $("#job_location_search").typeahead({
        source: function (query, process) {
            if (query === last) {
                return;
            }
            if (timeout) {
                clearTimeout(timeout);
            }

            last = query;

            timeout = setTimeout(function () {
                $.getJSON('http://dev.virtualearth.net/REST/v1/Locations/' + encodeURIComponent(query.trim()) + '?c=pt-br&output=json&maxResults=10&jsonp=?&key=Ak3hUY8K4w522FcOQlCwpN7Nt6iZCgNbjZYyIePw2UI-pPzltCRbqO3-dfJT2pds').done(function (data) {
                    map = {};
                    var locations = [];
                    if (data.resourceSets && data.resourceSets.length > 0) {
                        $.each(data.resourceSets[0].resources, function (i, item) {
                            if (!map[item.address.formattedAddress]) {
                                locations.push(item.address.formattedAddress);
                                item.address.lat = item.point.coordinates[0];
                                item.address.lng = item.point.coordinates[1];
                                map[item.address.formattedAddress] = item.address;
                            }
                        });
                        process(locations);
                    }
                });
            }, 300);
        },
        matcher: function () {
            return true;
        },
        sorter: function (items) {
            return items;
        },
        updater: function (item) {
            $('[name="job.create_or_update.location.address"]').val(map[item].addressLine);
            $('[name="job.create_or_update.location.city"]').val(map[item].locality);
            $('[name="job.create_or_update.location.state"]').val(map[item].adminDistrict);
            $('[name="job.create_or_update.location.country"]').val(map[item].countryRegion);
            $('[name="job.create_or_update.location.lat"]').val(map[item].lat);
            $('[name="job.create_or_update.location.lng"]').val(map[item].lng);
            return item;
        }
    });
});

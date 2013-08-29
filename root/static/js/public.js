jQuery(function ($) {
    $('.company-access button').qtip({
        content: {
            title: 'Fazer Login',
            text: $('#login_form')
        },
        style: {
            classes: 'qtip-bootstrap'
        },
        position: {
            at: 'bottom center',
            my: 'top right'
        },
        show: {
            event: 'click'
        },
        hide: {
            event: 'click'
        }
    });


    $('.one-filter').each( function(){

        $( this ).qtip({
            content: {
                title: $( '.filter-title', this ).html(),
                text: $( '.filter-content', this )
            },
            style: {
                classes: 'qtip-bootstrap'
            },
            position: {
                at: 'bottom center',
                my: 'top center'
            },
            show: {
                event: 'click'
            },
            hide: {
                event: 'click'
            },
            events: {
                show: function() {
                    $('.qtip').hide();
                }
            }
        });

    });

    $( '.add-filter' ).click( function() {
        var value = $( this ).parent().find( 'input[type="text"]' ).val();

        if( value != '' ){
            var html = '<li>'+value+' <i class="icon-remove-sign"></i></li>';
            $( this ).parent().parent().find( '.selected-filters' ).append( html );

            $( '.icon-remove-sign' ).click( function() {
                $( this ).parent( 'li' ).remove();
            });
        }
    });

    $( '#job_search_form' ).submit(function () {

        return false;
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
                if ($(this).text().replace(/^\s+/,'').replace(/\s+$/,'') === value) {
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
            var ul = $(this).parent().parent();
            $(this).parent().remove();
            update_empty(ul);
            return false;
        });

        $(this)[0].reset();
        update_empty($(this).find('ul.requirements'));

        return false;
    });

    $('div.btn-radio,div.btn-checkbox').each(function () {
        var data_for = $(this).data('input-for');
        var real_el  = $('[name="'+data_for+'"]');
        var value    = real_el.val().split(',');

        $(this).find('button.active').removeClass('active');

        $(this).find('button').each(function () {
            if (in_array($(this).val(), value) >= 0) {
                $(this).addClass('active');
            }
        });

        $(this).find('button').click(function () {
            var s = real_el.val();
            var current_value = s ? s.split(',') : [];
            var btnval = $(this).val();
            var pos = in_array(btnval, current_value);
            if (pos >= 0 && $(this).parent().hasClass('btn-checkbox')) {
                for (var i = pos; i < current_value.length-1; i++) {
                    current_value[i] = current_value[i+1];
                }
                current_value.pop();
            }
            else {
                current_value.push(btnval);
            }
            real_el.val(current_value.join(','));
        });
    });

    $('ul.requirements > li > a.remove-requirement').click( function() {
        var ul = $(this).parent().parent();
        $(this).parent().remove();
        update_empty(ul);
        return false;
    });

    function update_empty(w) {
        if (w.find('li').not('.zero').size() === 0) {
            w.find('li.zero').show();
        }
        else {
            w.find('li.zero').hide();
        }
    }

    function in_array(needle, haystack) {
        for (var i = 0; i < haystack.length; i++) {
            if (haystack[i] === needle) {
                return i;
            }
        }
        return -1;
    }


    $('ul.requirements').each(function () {
        update_empty($(this));
    });
});

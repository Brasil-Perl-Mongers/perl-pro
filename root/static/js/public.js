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

});

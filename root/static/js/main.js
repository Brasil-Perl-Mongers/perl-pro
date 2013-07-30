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
});

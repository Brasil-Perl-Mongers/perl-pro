jQuery(function ($) {
    $( '#job_search_form' ).submit(function () {

        setTimeout(function () {
            window.location = '/jobs#?terms=' + encodeURIComponent($('#job_search_terms').val());
        }, 100);

        return false;
    });
});

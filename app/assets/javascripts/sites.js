// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var do_on_load = function() {
    var prioritize_wrap  = $(".prioritize_urls");
    var prioritize_field = '<div class="field"><div class="input-group"><input class="form-control" type="text" value="" name="prioritize_urls[]" /><span class="input-group-btn"><button class="btn btn-default remove_prioritize_url"><i class="fa fa-trash"></i></button></span></div></div>';

    $('.add_prioritize_url').click(function(e)
    {
        $(prioritize_wrap).append(prioritize_field);

        e.preventDefault();
    });

    $('.prioritize_urls').on("click", ".remove_prioritize_url", function(e)
    {
        $(this).parent().parent().remove();
        e.preventDefault();
    });

    $('.remove_prioritize_url').click(function(e)
    {
        $(this).parent().parent().remove();
        e.preventDefault();
    });
};

$(document).ready(do_on_load)
$(window).bind('page:change', do_on_load)
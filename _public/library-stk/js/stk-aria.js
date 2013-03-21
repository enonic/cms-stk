$(function() {
    // All article elements that are not child of an article element, without a role
    $('article:not([role]):not(article *)').each(function() {
        $(this).attr('role', 'article');
    });
    
    $('aside:not([role])').each(function() {
        $(this).attr('role', 'complementary');
    });
    
    $('nav:not([role])').each(function() {
        $(this).attr('role', 'navigation');
    });
    
    $(':required').each(function() {
        $(this).attr('aria-required', 'true');
    });
        
    if (typeof Modernizr !== 'undefined') {
        /* More coming */
    }
});
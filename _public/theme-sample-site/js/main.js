var STK = STK || {
};


// Prevent Internet Explorer from halting scripts when encountering console.log()
if (typeof console == 'undefined') {
	console = {
		log: function () {}
	};
}


$(function() {
    STK.responsive.optimizeImages();    
});
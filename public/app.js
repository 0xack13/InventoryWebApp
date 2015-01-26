$(function(){
	$('#click').click(function()
	{
		console.log("clicked!");
	    $("#panel").animate({width:'toggle'},500);       
	});
});
/**
 * Manage documentready event
 *
 */
$( document ).ready(function() {
	console.log( "Document ready !" );
	console.log($.urlParam('id'));
	srvI = new ServiceI();
	srvI.ajax("http://localhost:8080/");
});


function ServiceI(){
	/* Object to manage ServiceI api */
	this.ajax = function(url){
		var response = $.ajax({
			url: url,
			type: "GET",
			crossDomain:true,
			success: function (response) {
				console.log(response);
				console.log(response.Service);
			},
			error: function (xhr, status, ajaxerror) {
				console.log(status);
				console.log(ajaxerror);
				throw status + " connecting to " + url;
			}
		});
	}
}



$.urlParam = function(name){
    var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (results==null){
       return null;
    }
    else{
       return results[1] || 0;
    }
}

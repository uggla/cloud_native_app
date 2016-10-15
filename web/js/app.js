/**
 * Manage documentready event
 *
 */
$( document ).ready(function() {
	console.log( "Document ready !" );
	id = $.urlParam("id");
	console.log("id=" + id);
	if (id=='' || id==null){
		$("body").html("Please provide a user id !");
		$("body").css({"opacity":"100"});
	}
	else{	
		$("body").css({"opacity":"100"});
		srvI = new Service();
		srvI.ajax(I, "http://localhost:8080/user/" + id);
	}
});


function Service(){
	/* Object to manage Service api */
	this.ajax = function(service_name, url){
		var response = $.ajax({
			url: url,
			type: "GET",
			crossDomain:true,
			success: function (response) {
				console.log(response);
				service_name("ok", response)
			},
			error: function (xhr, status, ajaxerror) {
				console.log(status);
				console.log(ajaxerror);
				//throw status + " connecting to " + url;
				service_name("ko")
			}
		});
	}
}

function I(status, response)
{
	if (status=="ok"){
		// Craft the answer.
		if (response.id=="Not found"){
			$("#srvIstatus").html("User id not found.")
		}
		else{
			var answer = '';
			answer += '<table id="userdata">';
			answer += '<tr>';
			answer += '<td>id</td><td>' + response.id + '</td>';
			answer += '</tr>';
			answer += '<tr>';
			answer += '<td>firstname</td><td>' + response.firstname + '</td>';
			answer += '</tr>';
			answer += '<tr>';
			answer += '<td>lastname</td><td>' + response.lastname + '</td>';
			answer += '</tr>';
			answer += '<tr>';
			answer += '<td>email</td><td>' + response.email + '</td>';
			answer += '</tr>';
			answer += '</table>';
			$("#srvIstatus").html(answer)
		}
	}
	else{
		$("#srvIstatus").html("Service <b>i</b> is currently not available.")

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

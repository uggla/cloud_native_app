/**
 * Manage documentready event
 *
 */
$( document ).ready(function() {
	console.log( "Document ready !" );
	id = $.urlParam("id");
	forceplay = $.urlParam("forceplay");
	console.log("id=" + id);
	console.log("forceplay=" + forceplay);
	if (id=='' || id==null){
        var html = '<div id=provide>';
        html += '<h1>Please provide a user id !</h1>';
        html += '<p><input type="text" id="submitinput" value="1"></p>';
        html += '<p><button class="btn btn-primary" id="submitid" onClick="provideid()">Submit</button></p>';
        html += '</div>';
		$("#content").html(html);
		$("body").css({"opacity":"100"});
	}
	else{
		$("body").css({"opacity":"100"});
		srvI = new Service();
		srvI.ajax(I, srvIurl + id);
		srvS = new Service();
		srvS.ajax(S, srvSurl + id);
		srvP = new Service();
		srvP.ajax(P, srvPurl + id);
	}
	$("#play").click(function(){play();});
	if (forceplay == 'true'){
		play();
	}
});

function provideid()
{
console.log($('#submitinput').val())
if ($("#submitinput").val()){
    location.href += '?id=' + $("#submitinput").val();
    location.replace();
    }

}


function play(){
	console.log("Play clicked !");
	$("#srvBstatus").html('<img src="/img/waiting.gif" alt="wait" style="width:20px;height:20px;"> Defining your price, please wait...');
	srvB = new Service();
	srvB.ajax(B, srvBurl + id);
}

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
			answer += '<table class="table"  id="userdata">';
			answer += '<tr>';
			answer += '<td>Id</td><td>' + response.id + '</td>';
			answer += '</tr>';
			answer += '<tr>';
			// Firstname and lastname seems inverted so fixing it here
			answer += '<td>Firstname</td><td>' + response.lastname + '</td>';
			answer += '</tr>';
			answer += '<tr>';
			answer += '<td>Lastname</td><td>' + response.firstname + '</td>';
			answer += '</tr>';
			answer += '<tr>';
			answer += '<td>Email</td><td>' + response.email + '</td>';
			answer += '</tr>';
			answer += '</table>';
			$("#srvIstatus").html(answer)
		}
	}
	else{
		$("#srvIstatus").html("Service <b>i</b> is currently not available.")

	}
}

function S(status, response)
{
	if (status=="ok"){
		// Craft the answer.
		if (response.status=="not_played"){
			$("#srvSstatus").html("You have not played the game so far...")
		}
		else{
			var answer = '';
			answer += 'You played the game the ';
			answer += response.status;
			answer += ', please look at your price below...';
			$("#srvSstatus").html(answer)
			$("#play").prop("disabled", true)
			$("#srvBstatus").html("You already played the game, you can not play again.")
		}
	}
	else{
		$("#srvSstatus").html("Service <b>s</b> is currently not available.")

	}
}

function B(status, response)
{
	if (status=="ok"){
		// Craft the answer.
		if (response.status=="ok"){
            location.reload();
		}
	}
	else{
		$("#srvBstatus").html("Service <b>b</b> is currently not available, please retry later.")
	}
}

function P(status, response)
{
	if (status=="ok"){
		// Craft the answer.
		if (response.status=="ok"){
			var answer = '';
			answer += '<img class="img-responsive" src="data:image/jpg;base64,';
			answer += response.img;
			answer += '" width="900px">'
			console.log(answer)
			$("#srvPstatus").html(answer)
		}
		else if (response.status=="swiftko"){
			$("#srvPstatus").html("Service <b>p</b> is not able to reach swift object storage")
		}
		else{
			$("#srvPstatus").html("You have not played yet...")
		}
	}
	else{
		$("#srvPstatus").html("Service <b>p</b> is currently not available, please retry later.")

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

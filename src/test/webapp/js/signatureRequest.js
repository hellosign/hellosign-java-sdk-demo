function initSignatureRequests() {
    var selectList = $("#signatureRequests");
    for (var i = 0; i < requests.length; i++) {
        selectList.append('<option value="' + i + '">' + requests[i].title + '</option>');
    }
    $('#startButton').hide();
    selectList.change(function(e) {
        var request = requests[$("option:selected", this).attr("value")];
        if (request) {
            $('#signatureRequestId').val(request.signature_request_id);
            $('#startButton').show();
        }
    });
};
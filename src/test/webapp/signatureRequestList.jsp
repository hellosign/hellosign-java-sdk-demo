<%@ page import="com.hellosign.sdk.*,com.hellosign.sdk.resource.*,com.hellosign.sdk.resource.support.*,java.io.*,java.util.*,org.apache.commons.fileupload.*,org.apache.commons.fileupload.servlet.*,org.apache.commons.fileupload.disk.*,org.apache.commons.io.*" %>
<%
// Load authentication properties
Properties properties = new Properties();
properties.load(getServletContext().getResourceAsStream("/WEB-INF/web.properties"));
String apiKey = properties.getProperty("hellosign.api.key");
HelloSignClient client = new HelloSignClient(apiKey);
String clientId = properties.getProperty("client.id");
String myName = properties.getProperty("my.name");
String myEmail = properties.getProperty("my.email");
String editUrl = "";
String errorMessage = null;

//Get the user's templates to populate the form
SignatureRequestList list = null;
if (apiKey != null) {
	try {
	    list = client.getSignatureRequests();
	} catch (HelloSignException ex) {
		errorMessage = ex.getMessage();
		ex.printStackTrace();
	}
}

// If this is a form submission, pull the form fields from the request
if (ServletFileUpload.isMultipartContent(request)) {

	// Store the form field information for our request
    Map<String, Signer> signersList = new HashMap<String, Signer>();
    Map<String, String> ccList = new HashMap<String, String>();
    Map<String, String> customFieldList = new HashMap<String, String>();
    String id = null;

    try {
        List<FileItem> items = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
        for (FileItem item : items) {
            String fieldName = item.getFieldName();
            String value = item.getString();
            System.out.println("item.getFieldName() = " + fieldName);
            System.out.println("item.getString() = " + value);
            if (item.isFormField()) {
                if ("signatureRequest".equals(item.getFieldName())) {
                    id = item.getString();
                }
            }
        }
    } catch (Exception e) {
    	errorMessage = e.getMessage();
        e.printStackTrace();
    }

    // If we have a template ID, let's try to create the embedded request
    if (id != null) {

        try {

            /* NOT RECOMMENDED - JSPs serve character data
               and a ZIP is binary data.
            File f = client.getFiles(id, "zip");
            FileInputStream fis = new FileInputStream(f);
            response.setContentType("application/x-zip-compressed");
            response.setCharacterEncoding("UTF-8");
            response.setHeader("Content-Disposition","attachment; filename=\"test.zip\"");   

            int i;   
            while ((i=fis.read()) != -1) {  
              out.write(i);   
            }   
            fis.close();
            */
        } catch (HelloSignException ex) {
        	errorMessage = ex.getMessage();
            ex.printStackTrace();
        }
    }
}
%>
<jsp:include page="/common-jsp/header.jsp">
    <jsp:param name="title" value="Signature Request List Demo"/>
    <jsp:param name="description" value="View a list of sent signature requests and download the associated files." />
    <jsp:param name="errorMessage" value="${errorMessage}"/>
</jsp:include>
	<input type="hidden" name="signatureRequest" id="signatureRequestId" value="" />
	<div id="demoForm">
		<h3>Your Signature Requests</h3>
		<select id="signatureRequests">
			<option selected>Choose a signature request to download...</option>
		</select>
	</div>
<jsp:include page="/common-jsp/footer.jsp" />

<script type="text/javascript" src="/js/signatureRequest.js"></script>
<script type='text/javascript'>
    var requests = [<% if (list != null) {
    Iterator<SignatureRequest> it = list.iterator();
    while (it != null && it.hasNext()) {
        SignatureRequest req = it.next();
        out.write(req.toString());
        if (it.hasNext()) {
            out.write(",");
        }
    }
}%>];
    $(document).ready(function() {
        initSignatureRequests();
    });
</script>
    </body>
</html>

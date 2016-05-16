<%@ page import="java.io.File,com.hellosign.sdk.*,com.hellosign.sdk.resource.*,com.hellosign.sdk.resource.support.*,java.io.*,java.util.*,org.apache.commons.fileupload.*,org.apache.commons.fileupload.servlet.*,org.apache.commons.fileupload.disk.*,org.apache.commons.io.*" %>
<%
// Load authentication properties
Properties properties = new Properties();
properties.load(getServletContext().getResourceAsStream("/WEB-INF/web.properties"));
String apiKey = properties.getProperty("hellosign.api.key");
HelloSignClient client = new HelloSignClient(apiKey);
String clientId = properties.getProperty("client.id");
String myName = properties.getProperty("my.name");
String myEmail = properties.getProperty("my.email");
String signUrl = "";
String errorMessage = "";
String sid = request.getParameter("sid");
String nextSig = request.getParameter("nextSig");

//Get the user's templates to populate the form
TemplateList templateList = null;
if (apiKey != null) {
	try {
	    templateList = client.getTemplates();
	} catch (HelloSignException ex) {
		errorMessage = ex.getMessage();
		ex.printStackTrace();
	}
}

if (sid != null) {
	File pdf = client.getFiles(sid);
	System.out.println("GOT IT: " + pdf.getAbsolutePath());
}
else if (nextSig != null && !"".equals(nextSig)) {
    try {
        // Retrieve the embedded signing URL for the signature
        EmbeddedResponse embeddedResponse = client.getEmbeddedSignUrl(nextSig);

        // Use the sign URL to open the embedded signing page
        signUrl = embeddedResponse.getSignUrl();

    } catch (HelloSignException ex) {
        errorMessage = ex.getMessage();
        ex.printStackTrace();
    }
}
// If this is a form submission, pull the form fields from the request
else if (ServletFileUpload.isMultipartContent(request)) {

	// Store the form field information for our request
    Map<String, Signer> signersList = new HashMap<String, Signer>();
    Map<String, String> ccList = new HashMap<String, String>();
    Map<String, String> customFieldList = new HashMap<String, String>();
    String templateId = null;

    try {
        List<FileItem> items = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
        for (FileItem item : items) {
            String fieldName = item.getFieldName();
            String value = item.getString();
            System.out.println("item.getFieldName() = " + fieldName);
            System.out.println("item.getString() = " + value);
            if (item.isFormField()) {
                if ("template".equals(item.getFieldName())) {
                    templateId = item.getString();
                }
                else if (fieldName.startsWith("signerRole_")) {
                    String type = fieldName.substring(fieldName.indexOf("_") + 1, fieldName.lastIndexOf("_"));
                    String role = fieldName.substring(fieldName.lastIndexOf("_") + 1, fieldName.length());
                    Signer s;
                    if (!signersList.containsKey(role)) {
                        s = new Signer();
                        signersList.put(role, s);
                    } else {
                        s = signersList.get(role);
                    }
                    if ("name".equals(type)) {
                        s.setNameOrRole(value);
                    } else if ("email".equals(type)) {
                        s.setEmail(value);
                    }
                }
                else if (fieldName.startsWith("ccRole_")) {
                    String role = fieldName.substring(fieldName.lastIndexOf("_") + 1, fieldName.length());
                    ccList.put(role, value);
                }
                else if (fieldName.startsWith("cf_")) {
                    String role = fieldName.substring(fieldName.lastIndexOf("_") + 1, fieldName.length());
                    customFieldList.put(role, value);
                }
            }
        }
    } catch (Exception e) {
    	errorMessage = e.getMessage();
        e.printStackTrace();
    }

    if (templateId != null) {
        // If we have a template ID, let's try to create the embedded request
        try {

        	// First, create a templated request
            TemplateSignatureRequest sigReq = new TemplateSignatureRequest();
            // sigReq.setTestMode(true);
            System.out.println("Using templateId: " + templateId);
            sigReq.setTestMode(true);
            sigReq.setTemplateId(templateId);
            CustomField field = new CustomField();
            field.setName("Test Textbox");
            field.setValue("Test Name");
            field.setEditor("Manager");
            field.setIsRequired(true);
            sigReq.addCustomField(field);
            CustomField box = new CustomField();
            box.setName("Test Checkbox");
            box.setValue("true");
            sigReq.addCustomField(box);
            for (String role : signersList.keySet()) {
            	Signer s = signersList.get(role);
            	sigReq.setSigner(role, s.getEmail(), s.getNameOrRole());
            }
            for (String role : ccList.keySet()) {
            	sigReq.setCC(role, ccList.get(role));
            }
            /* for (String fieldName : customFieldList.keySet()) {
            	sigReq.setCustomFieldValue(fieldName, customFieldList.get(fieldName));
            } */

            // Second, create an embedded request with it
            EmbeddedRequest embedded = new EmbeddedRequest(clientId, sigReq);

            // Send it to HelloSign
            SignatureRequest newSigReq = (SignatureRequest) client.createEmbeddedRequest(embedded);

            // Retrieve the first Signature ID
            // (for demo purposes we'll just demonstrate embedding the first signature request)
            List<Signature> sigs = newSigReq.getSignatures();
            Signature sig = sigs.get(0);
            nextSig = null;
            if (sigs.size() > 1) {
                nextSig = sigs.get(1).getId();
            }

            // Retrieve the embedded signing URL for the signature
            EmbeddedResponse embeddedResponse = client.getEmbeddedSignUrl(sig.getId());

            // Use the sign URL to open the embedded signing page
            signUrl = embeddedResponse.getSignUrl();
			sid = newSigReq.getId();

        } catch (HelloSignException ex) {
            errorMessage = ex.getMessage();
            ex.printStackTrace();
        }
    }
}
%>
<jsp:include page="/common-jsp/header.jsp">
    <jsp:param name="title" value="Embedded Template Signing Demo"/>
    <jsp:param name="description" value="Request signatures for documents based on a HelloSign Template directly from your website. Follow the steps below to add this feature to your Java-based web application." />
    <jsp:param name="errorMessage" value="<%= errorMessage %>"/>
</jsp:include>
	<input type="hidden" name="template" id="templateId" value="" />
	<div id="demoForm">
		<h3>Your Templates</h3>
		<select id="templates">
			<option selected>Choose a template...</option>
		</select>
		<div id="templateFields">
			<h3>Template Details</h3>
			<fieldset id="signers">
				<legend>Signers</legend>
				<div id="signersContainer"></div>
			</fieldset>
			<fieldset id="ccs">
				<legend>Carbon Copy</legend>
				<div id="ccsContainer"></div>
			</fieldset>
			<fieldset id="customFields">
				<legend>Custom Fields</legend>
				<div id="customFieldsContainer"></div>
			</fieldset>
		</div>
	</div>
<jsp:include page="/common-jsp/footer.jsp" />

<script type="text/javascript" src="/js/embeddedTemplateXDemo.js"></script>
<script type='text/javascript'>
    var templates = [
<%if(templateList != null) {
    Iterator<Template> it = templateList.iterator();
    while(it != null && it.hasNext()) {
        Template t = it.next();
        out.write(t.toString());
        if (it.hasNext()) {
            out.write(",");
        }
    }
}%>
    ];
    $(document).ready(function() {

        // Defined in /js/embeddedTemplateXDemo.js
        initTemplates();

<% if (!signUrl.isEmpty()) { %>
        // Initialize HelloSign with the client ID
        HelloSign.init("<%= clientId %>");

        // Open the iFrame dialog for embedded signing
        HelloSign.open({
            url: "<%= signUrl %>",
            debug: true,
            allowCancel: true,
            uxVersion: 1,
            // skipDomainVerification: true,
            messageListener: function(eventData) {
                console.log("Event received: " + eventData);
                var msg;
                if (eventData.event == HelloSign.EVENT_SENT) {
                    msg = "Request Sent!";
                } else if (eventData.event == HelloSign.EVENT_SIGNED) {
                    msg = "Request Signed!";
                    <% if (nextSig != null && !"".equals(nextSig)) { %>
                    window.location = 'http://jellosign.ngrok.io/embeddedTemplateSigningDemo.jsp?nextSig=<%= nextSig %>';
                    <% } else { %>
					$.ajax({
						'url' : 'http://jellosign.ngrok.io/embeddedTemplateSigningDemo.jsp',
						'data' : {
							'sid' : '<%= sid %>'
						},
						'complete' : function(xhr, status) {
							console.log("AJAX SENT", status);
						}
					});
					<% } %>
                } else {
                    msg = eventData.event;
                }
                $("#demoContainer").html("<h3>" + msg + "</h3><a class=\"btn btn-lg btn-success\" href=\"/embeddedTemplateRequestingDemo.jsp\">Try it again</a>");
            }
        });
<% } %>
    });
</script>
    </body>
</html>

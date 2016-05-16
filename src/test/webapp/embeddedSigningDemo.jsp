<%@page import="com.hellosign.sdk.resource.support.types.ValidationType"%>
<%@page import="com.hellosign.sdk.resource.support.types.FieldType"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@ page import="com.hellosign.sdk.*,com.hellosign.sdk.resource.*,com.hellosign.sdk.resource.support.*,java.io.File,java.util.*" %>
<%
    // Load authentication properties
    Properties properties = new Properties();
    properties.load(getServletContext().getResourceAsStream("/WEB-INF/web.properties"));
    String apiKey = properties.getProperty("hellosign.api.key");
    String clientId = properties.getProperty("client.id");
    String signUrl = null;
    String errorMessage = null;
    String hideButton = "false";
    List<File> files = new ArrayList<File>();
    List<String> signerRoles = new ArrayList<String>();
    List<String> ccRoles = new ArrayList<String>();
    String subject = null;
    String message = null;
    boolean isOrdered = false;

    if (ServletFileUpload.isMultipartContent(request)) {
        String myName = null;
        String myEmail = null;
      try {
          // Process the fields entered by the user
          List<FileItem> items = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
          for (FileItem item : items) {
              if (item.isFormField()) {
                  String fieldName = item.getFieldName();
                  String value = item.getString();
                  System.out.println("item.getFieldName() = " + fieldName);
                  System.out.println("item.getString() = " + value);
                  if (value == null || value.equals("") || fieldName == null || fieldName.equals("")) {
                      continue;
                  }
                  if ("yourName".equals(fieldName)) {
                      myName = value;
                  } else if ("yourEmail".equals(fieldName)) {
                      myEmail = value;
                  }
              }
          }
      } catch (Exception e) {
        errorMessage = e.getMessage();
          e.printStackTrace();
      }
      if (myEmail != null && apiKey != null && clientId != null) {

        try {
            // Create the signature request
            SignatureRequest sigReq = new SignatureRequest();
            Document doc = new Document();
            doc.setFile(new File(application.getRealPath("/docs/nda.pdf")));
            FormField textField = new FormField();
            textField.setSigner(1);
            textField.setApiId("textfield_1");
            textField.setHeight(25);
            textField.setWidth(300);
            textField.setName("Name");
            textField.setPage(1);
            textField.setRequired(true);
            textField.setType(FieldType.text);
            textField.setValidationType(ValidationType.letters_only);
            textField.setX(100);
            textField.setY(100);
            
            FormField sigField = new FormField();
            sigField.setSigner(1);
            sigField.setApiId("sigfield_1");
            sigField.setHeight(50);
            sigField.setWidth(200);
            sigField.setName("Signature");
            sigField.setPage(1);
            sigField.setRequired(true);
            sigField.setType(FieldType.signature);
            sigField.setX(350);
            sigField.setY(720);

            doc.addFormField(textField);
            doc.addFormField(sigField);

            sigReq.addDocument(doc);
            sigReq.setTitle("Embedded NDA");
            sigReq.addSigner(myEmail, myName);
            sigReq.setTestMode(true);

            /// Turn it into an embedded request
            EmbeddedRequest embedded = new EmbeddedRequest(clientId, sigReq);

            // Send it to HelloSign
            HelloSignClient client = new HelloSignClient(apiKey);
            SignatureRequest newRequest = (SignatureRequest) client.createEmbeddedRequest(embedded);

            // Grab the signature ID for the signature page that will
            // be embedded in the page (for the demo, we'll just use the first one)
            Signature signature = newRequest.getSignatures().get(0);

            // Retrieve the URL to sign the document
            EmbeddedResponse embeddedResponse = client.getEmbeddedSignUrl(signature.getId());

            // Store it to use with the embedded.js HelloSign.open() call
            signUrl = embeddedResponse.getSignUrl();

            hideButton = "true";

        } catch (HelloSignException ex) {
          errorMessage = ex.getMessage();
        }
      }
    }

%>
<jsp:include page="/common-jsp/header.jsp">
    <jsp:param name="title" value="Embedded Signing Demo"/>
    <jsp:param name="description" value="Add document signing directly to your Java-based web application." />
    <jsp:param name="errorMessage" value="${errorMessage}"/>
</jsp:include>
<% if (signUrl == null) { %>
    <input type="text" name="yourName" placeholder="Your Name" />
    <input type="text" name="yourEmail" placeholder="Your Email" />
    <br /><br />
    <input type="checkbox" name="embedded" />&nbsp;<label for="embedded">Embed in page</label>
    <br /><br />
    <label for="ux_version">UX Version</label>
    <select name="ux_version">
        <option value="1" selected>Default</option>
        <option value="2">Responsive</option>
    </select>
    <div id="hello-container" style="width:600px;"></div>
<jsp:include page="/common-jsp/footer.jsp" />
<% } else { %>
<jsp:include page="/common-jsp/footer.jsp">
    <jsp:param name="hideButton" value="${hideButton}" />
</jsp:include>
<% } %>

<% if (clientId != null && signUrl != null) { %>
    <script type='text/javascript'>
        $(document).ready(function(){
            // Initialize HelloSign with the client ID
            HelloSign.init("<%= clientId %>");
            // Open the iFrame dialog for embedded signing
            HelloSign.open({
                url: "<%= signUrl %>",
                debug: true,
                // skipDomainVerification: true,
                uxVersion: 2,
                /* whiteLabelingOptions: {
                    'primary_button_color': '#FF0000'
                }, */
                // container: document.getElementById("hello-container"),
                messageListener: function(eventData) {
                    console.log("Event received:");
                    console.log(eventData);
                    var msg = "Received event: " + eventData.event;
                    if (eventData.event == HelloSign.EVENT_SIGNED) {
                        msg = "Thanks for signing!";
                    }
                    $("#demoContainer").html("<h3>" + msg + "</h3><a class=\"btn btn-lg btn-success\" href=\"/embeddedSigningDemo.jsp\">Try it again</a>");
                }
            });
        });
    </script>
<% } %>
    </body>
</html>

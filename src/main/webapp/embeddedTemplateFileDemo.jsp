<%@ page import="com.hellosign.sdk.*,com.hellosign.sdk.resource.*,com.hellosign.sdk.resource.support.*,java.io.*,java.util.*,org.apache.commons.fileupload.*,org.apache.commons.fileupload.servlet.*,org.apache.commons.fileupload.disk.*,org.apache.commons.io.*" %>
<%
// Load authentication properties
String apiKey = System.getProperty("hellosign.api.key");
HelloSignClient client = new HelloSignClient(apiKey);
String clientId = System.getProperty("hellosign.client.id");
String editUrl = "";
String errorMessage = null;

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

// If this is a form submission, pull the form fields from the request
if (ServletFileUpload.isMultipartContent(request)) {

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
            }
        }
    } catch (Exception e) {
        errorMessage = e.getMessage();
        e.printStackTrace();
    }

    // If we have a template ID, let's try to create the embedded request
    if (templateId != null) {

        try {
            File f = client.getTemplateFile(templateId);
            FileInputStream fis = new FileInputStream(f);
            response.setContentType("APPLICATION/OCTET-STREAM");   
            response.setHeader("Content-Disposition","attachment; filename=\"" + f.getName() + "\"");   
                      
            int i;   
            while ((i=fis.read()) != -1) {  
              out.write(i);   
            }   
            fis.close();
        } catch (HelloSignException ex) {
            errorMessage = ex.getMessage();
            ex.printStackTrace();
        }
    }
}
%>
<jsp:include page="/common-jsp/header.jsp">
    <jsp:param name="title" value="Embedded Template File Demo"/>
    <jsp:param name="description" value="Allow your users to retrieve the base document(s) for a template." />
    <jsp:param name="errorMessage" value="${errorMessage}"/>
</jsp:include>
    <input type="hidden" name="template" id="templateId" value="" />
    <div id="demoForm">
        <h3>Your Templates</h3>
        <select id="templates">
            <option selected>Choose a template to edit...</option>
        </select>
    </div>
<jsp:include page="/common-jsp/footer.jsp">
    <jsp:param name="cta" value="Download File" />
</jsp:include>

<script type="text/javascript" src="/js/embeddedTemplateXDemo.js"></script>
<script type='text/javascript'>
    var templates = [
<% if(templateList != null) {
    Iterator<Template> it = templateList.iterator();
    while(it != null && it.hasNext()) {
        Template t = it.next();
        if (t.isEmbedded()) {
            out.write(t.toString());
            if (it.hasNext()) {
                out.write(",");
            }
        }
    }
} %>
    ];
    $(document).ready(function() {

        // Defined in /js/embeddedTemplateXDemo.js
        initTemplates();
    });
</script>
    </body>
</html>

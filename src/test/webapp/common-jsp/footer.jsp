<%
  String env = System.getProperty("hellosign.env");
  boolean isLocalDev = "dev".equalsIgnoreCase(env);
  boolean isStaging = "staging".equalsIgnoreCase(env);
%>
<%
if (request.getParameter("hideButton") == null) {
%>
                        <button class="btn btn-lg btn-primary" id="startButton" type="submit">Launch Demo</button>
<% } %>
                    </form>
                    <div id="hello-container"></div>
                </div>
            </div>

            <footer class="footer">
                <p>&copy; HelloSign 2015</p>
            </footer>
        </div>
    </div>

    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js"></script>
    <!-- Include the HelloSign embedded.js library -->
    <%
        if (isLocalDev) {
    %>
    <script type="text/javascript"
        src="https://cdn.dev-hellosign.com/js/embedded.js"></script>
    <%
        } else if (isStaging) {
    %>
    <script type="text/javascript"
        src="//staging.hellosign.com/js/embedded.js"></script>
    <%
        } else {
    %>
    <script type="text/javascript"
        src="//s3.amazonaws.com/cdn.hellofax.com/js/embedded.js"></script>
    <%
        }
    %>
    <script type='text/javascript'>
      $("#startButton").click(function(e) {
        $(this).addClass("disabled").html('<i class="fa fa-cog fa-spin"></i>');
        return true;
      })
    </script>

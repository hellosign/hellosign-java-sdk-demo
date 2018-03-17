<%
  String baseUrl = System.getProperty("hellosign.base.url");
  boolean isLocalDev = baseUrl != null && baseUrl.contains("dev-hellosign.com");
  boolean isStaging = baseUrl != null && baseUrl.contains("staging-hellosign.com");

%>
<%
if (request.getParameter("hideButton") == null) {
%>
                        <button class="btn btn-lg btn-primary" id="startButton" type="submit">${(empty param.cta) ? "Launch Demo" : param.cta}</button>
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
    <script type="text/javascript" src="https://s3.amazonaws.com/cdn.hellosign.com/public/js/hellosign-embedded.LATEST.min.js"></script>

    <script type='text/javascript'>
      $("#startButton").click(function(e) {
        $(this).addClass("disabled").html('<i class="fa fa-cog fa-spin"></i>');
        return true;
      })
    </script>

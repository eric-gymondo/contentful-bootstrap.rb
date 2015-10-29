require "sinatra"
require "launchy"
require "thin"
require "contentful_bootstrap/constants"
require "contentful_bootstrap/token"

module ContentfulBootstrap
  class OAuthEchoView
    def render
      <<-JS
      <html><head></head><body>
      <script type="text/javascript">
        (function() {
          var access_token = window.location.hash.split('&')[0].split('=')[1];
          window.location.replace('http://localhost:5123/save_token/' + access_token);
        })();
      </script>
      </body></html>
      JS
    end
  end

  class ThanksView
    def render
      <<-HTML
      <html><head>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" />
      </head><body>
        <div class="container">
          <div class="jumbotron">
            <h1>Contentful Bootstrap</h1>
            <h4>Thanks! The OAuth Token has been generated</h4>
            <p>The Space you specified will now start to create. You can close this window freely</p>
          </div>
        </div>
      </body></html>
      HTML
    end
  end

  class Server < Sinatra::Base
    configure do
      set :port, 5123
      set :logging, nil
      set :quiet, true
      Thin::Logging.silent = true # Silence Thin startup message
    end

    get '/' do
      client_id = ContentfulBootstrap::Constants::OAUTH_APP_ID
      redirect_uri = ContentfulBootstrap::Constants::OAUTH_CALLBACK_URL
      scope = "content_management_manage"
      Launchy.open("https://be.contentful.com/oauth/authorize?response_type=token&client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{scope}")
      ""
    end

    get '/oauth_callback' do
      OAuthEchoView.new.render
    end

    get '/save_token/:token' do
      Token.write(params[:token])
      ThanksView.new.render
    end
  end
end

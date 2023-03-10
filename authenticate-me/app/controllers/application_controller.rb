class ApplicationController < ActionController::API

    before_action :snake_case_params

    helper_method :current_user

    def test
  if params.has_key?(:login)
    login!(User.first)
  elsif params.has_key?(:logout)
    logout!
  end

  if current_user
    render json: { user: current_user.slice('id', 'username', 'session_token') }
  else
    render json: ['No current user']
  end
end

    def current_user
        @current_user ||= User.find_by(session_token: session[:session_token])
    end

    def login!(user)
        # reset `user`'s `session_token` and store in `session` cookie
        session[:session_token] = user.reset_session_token!
        @current_user = user
        debugger
    end

    def logout!
        current_user.reset_session_token!
        session[:session_token] = nil
        # reset the `current_user`'s session cookie, if one exists
        # clear out token from `session` cookie
        @current_user = nil # so that subsequent calls to `current_user` return nil
    end

    def require_logged_in
        unless current_user
            render json: { message: 'Unauthorized' }, status: :unauthorized 
        end
    end

    private

    def snake_case_params
        params.deep_transform_keys!(&:underscore)
    end

end

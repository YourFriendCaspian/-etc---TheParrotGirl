# https://github.com/hassox/warden/wiki/Examples
# https://github.com/hassox/rails_warden
# http://team.skroutz.gr/posts/skroutz-warden/
# http://railscasts.com/episodes/305-authentication-with-warden

Warden::Manager.serialize_into_session do |user|
  user.email
end

Warden::Manager.serialize_from_session do |id|
  User.new(email: id)
end


Rails.configuration.middleware.use Warden::Manager do |manager|
  manager.default_strategies :shared_password
  manager.failure_app = ->(env) { SessionsController.action(:new).call(env) }
end

# A simple db-backed strategy that uses the User.authenticate() method.
Warden::Strategies.add(:shared_password) do
  def valid?
    params['login'] || params['password']
  end
  def authenticate!
    username = params.fetch('login', nil)
    password = params.fetch('password', nil)

    if not ( username.blank? || password.nil? || ::BCrypt::Password.new(::Configuration.shared_password) != password )
      success!(User.new(email: username))
    else
      fail 'Invalid credentials.'
    end
  end
end

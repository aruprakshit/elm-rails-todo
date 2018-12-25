class CreateUser
  class BadCredentials < StandardError;end
  class AuthenticationFailed < StandardError;end

  attr_reader :errors, :result

  def initialize(attrs)
    @attrs = attrs
    @errors = nil
  end

  def call
    user = User.new(@attrs)
    if user.valid?
      user.save
    else
      raise BadCredentials, {
        body: user.errors.full_messages.join(", "),
        code: :unauthorized
      }
    end

    command = AuthenticateUser
      .call(
        user.email,
        user.password
      )

    if command.success?
      @result = command.result
    else
      raise AuthenticationFailed, {
        body: "We are sorry for not let you login this time! Please use the login form to sign in after some time.",
        code: :unprocessable_entity
      }
    end

    self
  rescue BadCredentials, AuthenticationFailed => e
    @errors = e.message
  end

  def has_error?
    @errors.present?
  end
end

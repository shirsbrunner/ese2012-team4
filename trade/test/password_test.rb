require 'test/unit'
require 'rubygems'
require 'require_relative'
require_relative('../app/models/utility/password_check')
require_relative('../app/models/utility/password_reset')
require_relative('../app/models/module/user')

include Models

class PasswordTest <Test::Unit::TestCase
  def test_password_length_check
    assert(PasswordCheck.safe?("pas22"),"Passwords longer than 4 digits should be safe.")
    assert(!PasswordCheck.safe?("pa22"),"Strings shorter than 5 digits should be unsafe")
  end

  def test_password_contains_numbers
    assert(PasswordCheck.safe?("pass0"), "Passwords containing a number should be safe.")
    assert(PasswordCheck.safe?("pass5"), "Passwords containing a number should be safe.")
    assert(PasswordCheck.safe?("pass9"), "Passwords containing a number should be safe.")
    assert(!PasswordCheck.safe?("passw"), "Passwords containing no number should be unsafe.")
    assert(PasswordCheck.safe?("pas01"), "Passwords containing two numbers should be safe.")
  end

  def test_password_contains_letters
    assert(PasswordCheck.safe?("123%4a"), "Passwords containing a letter and numbers should be safe.")
    assert(PasswordCheck.safe?("123%4k"), "Passwords containing a letter and numbers should be safe.")
    assert(PasswordCheck.safe?("123%4z"), "Passwords containing a letter and numbers should be safe.")
    assert(!PasswordCheck.safe?("123**"), "Passwords containing no letter should be unsafe")
    assert(PasswordCheck.safe?("123*A"), "Passwords containing a capital letter and numbers should be safe")
    assert(PasswordCheck.safe?("123*F"), "Passwords containing a capital letter and numbers should be safe")
    assert(PasswordCheck.safe?("123*Z"), "Passwords containing a capital letter and numbers should be safe")
  end

  def text_reset_creation
    request1 = PasswordReset.created("pw1", "username")
    assert(PasswordReset.request_exists_for_user?("username"))
  end

  def test_reset_request_for_user
    @user = User.created( "testuser", "password", "test@mail.com" )
    @user.forgot_password
    assert(PasswordReset.request_exists_for_user?(@user.name))
  end

end
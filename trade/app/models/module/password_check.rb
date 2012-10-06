module Models

  class PasswordCheck
    #A password check is able to test if a password is safe enough

    def self.created
      pw_check = self.new
    end

    #A password is safe, if it contains a small or capital letter and a number and is longer than 4 digits.
    #@param password to be checked
    def safe? (password)
       safe = false
       if password.length > 4 && password.count("0-9")>0 && password.count("a-z")+password.count("A-Z") >0
         safe = true
       end
      safe
    end

  end
end

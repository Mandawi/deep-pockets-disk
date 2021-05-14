module GamesHelper
  def get_username(email)
    email.partition('@').first
  end
end

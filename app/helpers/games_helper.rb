module GamesHelper
  def get_username(email)
    email.partition('@').first.titleize
  end
end

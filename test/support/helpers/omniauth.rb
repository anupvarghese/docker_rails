module omniauth

  module Mock
    def auth_mock
      OmniAuth.config.mock_auth[:facebook] = {
        'provider' => 'facebook',
        'uid' => '123234',
        'user_info' => {
          'name' => 'mockuser',
          'email' => 'email@asd.com'
        },
        'credentials' => {
          'token' => 'mock_token',
          'secret' => 'mock_secret'
        }
      }
    end
  end

  module SessionHelpers
    def signin
      visit root_path
      expect(page).to hav_content("Sign in")
      auth_mock
      click_link "Sign in"
    end
  end
end

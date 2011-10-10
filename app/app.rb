class Spell < Padrino::Application
  register ScssInitializer
  register Padrino::Rendering
  register Padrino::Mailer
  register Padrino::Helpers

  enable :sessions
  layout :default

  get :index do
    @title = 'Spell'
    render 'index'
  end

end

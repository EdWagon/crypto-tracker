class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit::Authorization


  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  private

  def skip_pundit?

    # devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)|(^coins$)|(^search$)|(^jobs$)/

    return true if params[:controller] =~ /(^(rails_)?admin)|(^pages$)|(^coins$)|(^search$)|(^prices$)|(^jobs$)/
    return true if devise_controller?
    return true if mission_control_controller?
    return false



  end

  def mission_control_controller?
    is_a?(::MissionControl::Jobs::ApplicationController)
  end

end

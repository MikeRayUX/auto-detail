module Users::Orders::Resolvable
  extend ActiveSupport::Concern

  protected

  def resolve_user_setup
    unless current_user.completed_setup?
      redirect_to users_resolve_setups_path && return
    end
  end
end
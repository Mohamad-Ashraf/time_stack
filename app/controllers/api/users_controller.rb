module Api
	class UsersController < ActionController::Base
		 include UserHelper
		#before_action :authenticate_user_from_token
		def get_all_users
			
			user = User.find_by(email: params[:email])
			logger.debug("the user email you sent is : #{params[:email]}")
			#debugger

			#user = User.first
			 if user&.valid_password?(params[:password])
		        render json: user.as_json(only: [:email, :authentication_token, message: "success"]),status: :created
		      else
		        render :json => {status: :unauthorized ,message: "The email or password was incorrect. Please try again"}
		      end
      		
			#render :json=> {status: :ok, :user_email=> user.email}
		end 

		
	end
end

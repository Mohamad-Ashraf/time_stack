module Api
  class UsersController < ActionController::Base
		include UserHelper
		#before_action :authenticate_user_from_token, except: [:login_user, :update_date, :post_data]
			
		def login_user	
		  user = User.find_by(email: params[:email])
		  logger.debug("the user email you sent is : #{params[:email]}")
		
			if user&.valid_password?(params[:password])
		    render json: user.as_json(only: [:email, :authentication_token, message: "success"]),status: :created
		  else
		    render :json => {status: :unauthorized ,message: "The email or password was incorrect. Please try again"}
	    end
	  end 

	  def update_date
    	
			#Used to find week_id for today's time entry 
			time_entry = TimeEntry.where("date_of_activity = ? && user_id = ?", Date.today.to_datetime, params[:email]).first
			logger.debug("Today's Time Entry #{time_entry.inspect}")
			gimme = time_entry.week_id
			logger.debug("GIMME THAT ID #{gimme}")

			#Find new time_entry with matching parameters
			update_date = TimeEntry.where("date_of_activity = ? and user_id = ?", params[:date_of_activity], params[:email])
			logger.debug("the new entry is #{update_date.inspect}")

			#needed for dropdown
			avaliable_entries = TimeEntry.where("week_id = ?", gimme).collect{|w| w.date_of_activity.strftime("%Y/%m/%d")}

			render :json => { status: :ok, 
												timeEntry_hash: { id: update_date[0].id,
																					user_id: update_date[0].user_id,
																					week_id: update_date[0].week_id,
																					task_id: update_date[0].task_id,
																					project_id: update_date[0].project_id,
																					hours: update_date[0].hours,
																					vacation_type_id: update_date[0].vacation_type_id,
																					activity_log: update_date[0].activity_log,
																				},
												date_of_activity: avaliable_entries
											}
		end 


		def get_time_entry
			#get user
			user = User.find_by_email(params[:email])
			logger.debug("User ID is #{user.id}")
		
			#Find Current Time Entry
			time_entry = TimeEntry.where("date_of_activity = ? && user_id = ?", Date.today.to_datetime, user.id).first
			#logger.debug("Today's Time Entry #{time_entry.inspect}")
			
			#TimeEntries To Load Into DropDown
			avaliable_entries = TimeEntry.where("week_id = ?", time_entry.week_id).collect{|w| w.date_of_activity.strftime("%Y/%m/%d")}
			logger.debug("These are entries Avaliable #{avaliable_entries.count}")

			#List Projects
			avaliable_projects =  Project.where(inactive: [false, nil]).joins(:projects_users).where("projects_users.user_id=?", user.id)
			project_list = []
			avaliable_projects.each do |p|
				project_hash = {id: p.id, name: p.name}
				project_list.push(project_hash)
			end
			logger.debug (" These are the avaliable project's #{avaliable_projects.count}")
			#vacation lists
			emp_type = EmploymentType.find user.employment_type
    	vacation_types = emp_type.vacation_types.where("customer_id=? && active=?", user.customer_id, true)
			vacation_list = []
			vacation_types.each do |v|
				vacation_hash = {id: v.id, title: v.vacation_title}
				vacation_list.push(vacation_hash)
			end
			logger.debug (" These are the avaliable vacations #{vacation_types.count}")
			

			render :json => { status: :ok, 
												timeEntry_hash: { id: time_entry.id,
																					user_id: time_entry.user_id,
																					week_id: time_entry.week_id,
																					task_id: time_entry.task_id,
																					project_id: time_entry.project_id,
																					hours: time_entry.hours,
																					vacation_type_id: time_entry.vacation_type_id,
																					activity_log: time_entry.activity_log,
																				},
												date_of_activity: avaliable_entries,
												avaliable_projects: project_list,
												vacations: vacation_list

											}
		end

		def post_data
			te = TimeEntry.find_by_id(params[:id])
			te.project_id = params[:project]
			te.task_id = params[:task]
			te.vacation_type_id = params[:vacation]
			te.activity_log = params[:activity_log]
			te.save
			if params[:vacation].present?
				te.hours = params[:hours]
			else	
				te.hours = params[:hours]
			end
			render :json => {status: :ok, message: "successfully updated"}
		end 

		def get_tasks
			u = User.find params[:email]
			project = Project.find params["project_id"].split(": ").last
			task_list = []
			project.tasks.each do |t|
				task_hash = {id: t.id, code: t.code}
				task_list.push(task_hash)
			end
			render :json => {status: :ok, task_hash: {
																								avaliable_tasks: task_list
																							}
											}
		end
	end 
end
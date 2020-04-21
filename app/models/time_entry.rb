class TimeEntry < ApplicationRecord
  belongs_to :project
  belongs_to :task
  belongs_to :week
  belongs_to :user
  belongs_to :vacation_type
  belongs_to :project_shift
  has_many :archived_time_entry


  before_save :calculate_hours
  before_save :add_project_shift_id


  def calculate_hours
  	
  	if hours.nil? && !time_out.nil? && !time_in.nil?
  		Rails.logger.debug("TimeEntry model- calculate_hours- *****TIME IN- #{time_in}")
  		self.hours = ((time_out.to_i - time_in.to_i)/3600.0).round(1)
  		Rails.logger.debug ("TimeEntry model- calculate_hours #{hours}***** time_in: #{time_in.strftime('%M')}")
  	end
  end

  def add_project_shift_id
    if project_id && user_id
      projects_user = ProjectsUser.where(user_id: user_id, project_id: project_id).last
      if projects_user
        self.project_shift_id = projects_user.project_shift_id
      end
    end
  end

end

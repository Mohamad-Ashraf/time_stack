class Week < ApplicationRecord
  has_many :time_entries, -> {order(:date_of_activity)}
  has_many :user_week_statuses
  accepts_nested_attributes_for :time_entries, allow_destroy: true, reject_if: proc { |time_entries| time_entries[:date_of_activity].blank? }
  mount_uploader :time_sheet, TimeSheetUploader

  def self.current_user_time_entries(current_user)
    logger.debug "Week - current_user_time_entries entering"
    TimeEntry.where(week_id: id, user_id: current_user.id).take
    logger.debug "Week - current_user_time_entries leaving"
  end
  
  def self.left_join_weeks(some_user, status)
    weeks = Week.arel_table
    user_week_statuses = UserWeekStatus.arel_table

    weeks = weeks.join(user_week_statuses, Arel::Nodes::OuterJoin).
                  on(weeks[:id].eq(user_week_statuses[:week_id]), user_week_statuses[:user_id].eq(some_user)).
                  join_sources
                  
    joins(weeks)
  end

  def self.left_joins_user_week_statuses(some_user, week_id)
    weeks = Week.where("weeks.id = ?", week_id).weeks_with_user_week_statuses(some_user)
  end

  def self.weeks_with_invitation_start_date(user)
      next_week_start_date = Date.today.beginning_of_week + 7.days
      user_invite_start_date = user.invitation_start_date.beginning_of_week 

      until user_invite_start_date == next_week_start_date
        new_week = Week.where(user_id: user.id, start_date: user_invite_start_date).last
        if new_week.blank?
          new_week = Week.new
          new_week.start_date = user_invite_start_date
          new_week.end_date = user_invite_start_date.to_date.end_of_week.strftime('%Y-%m-%d') 
          new_week.user_id = user.id
          new_week.status_id = 1
          new_week.save
        end

        7.times { new_week.time_entries.build( user_id: user.id )}
        new_week.time_entries.each_with_index do | te, i |
          new_week.time_entries[i].date_of_activity = Date.new(new_week.start_date.year, new_week.start_date.month, new_week.start_date.day) + i
          new_week.time_entries[i].user_id = user.id
        end
        new_week.save
        user_invite_start_date += 7.days
      end
  end

  def self.copy_week(current_time_entries, pre_week_time_entries)
    count = 0
    current_time_entries.each do |t|
       
     Rails.logger.debug("#{count}")
     Rails.logger.debug("NEW WEEKS DATE OF ACTIVITY: #{t.date_of_activity}")
     Rails.logger.debug("OLD WEEKS DATE OF ACTIVITY: #{pre_week_time_entries[count].date_of_activity}")
     Rails.logger.debug("HOURS to populate: #{pre_week_time_entries[count].hours}")
     Rails.logger.debug("OLD WEEKS PROJECT: #{pre_week_time_entries[count].project_id}")
     Rails.logger.debug("COPYING OLD WEEKS TASKS: #{pre_week_time_entries[count].task_id}")
     Rails.logger.debug("COPYING OLD WEEKS TIME-IN: #{pre_week_time_entries[count].time_in}")
     Rails.logger.debug("COPYING OLD WEEKS TIME-OUT: #{pre_week_time_entries[count].time_out}")
     Rails.logger.debug("COPYING DESCRIPTION: #{pre_week_time_entries[count].activity_log}")
     Rails.logger.debug("COPYING SICK DAY: #{pre_week_time_entries[count].sick}")
     Rails.logger.debug("COPYING PERSONAL DAY: #{pre_week_time_entries[count].personal_day}")
     t.hours = pre_week_time_entries[count].hours
     t.project_id = pre_week_time_entries[count].project_id
     t.task_id = pre_week_time_entries[count].task_id
     t.time_in = pre_week_time_entries[count].time_in
     t.time_out = pre_week_time_entries[count].time_out
     t.activity_log = pre_week_time_entries[count].activity_log
     t.sick = pre_week_time_entries[count].sick
     t.personal_day = pre_week_time_entries[count].personal_day
     t.save

     count += 1
    end
  end
  
  def self.weekly_weeks
    User.all.each do |u|
      user_week_end_date = Week.where(user_id: u.id, end_date: "#{Date.today.end_of_week.strftime('%Y-%m-%d')}")
      if user_week_end_date.blank?
        @week = Week.new
        @week.start_date = Date.today.beginning_of_week.strftime('%Y-%m-%d')
        @week.end_date = Date.today.end_of_week.strftime('%Y-%m-%d')
        @week.user_id = u.id
        @week.status_id = Status.find_by_status("NEW").id
        @week.save!
        7.times {  @week.time_entries.build( user_id: u.id )}
          
        @week.time_entries.each_with_index do |te, i|
          logger.debug "weeks_controller - edit now for each time_entry we need to set the date  and user_id and also set the hours  to 0"
          logger.debug "year: #{@week.start_date.year}, month: #{@week.start_date.month}, day: #{@week.start_date.day}"
          logger.debug "i #{i}"
          @week.time_entries[i].date_of_activity = Date.new(@week.start_date.year, @week.start_date.month, @week.start_date.day) + i
          @week.time_entries[i].user_id = u.id
        end
        @week.save!
      end
    end
  end
end

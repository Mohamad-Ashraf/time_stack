class Customer < ApplicationRecord 
  has_many :projects
  has_and_belongs_to_many :holidays, join_table: :customers_holidays
  accepts_nested_attributes_for :projects, allow_destroy: true, reject_if: proc { |projects| projects[:name].blank? }
  has_many :vacation_requests
  has_many :employment_types
  mount_uploader :logo, LogoUploader
  has_many :vacation_types 


  validates_numericality_of :zipcode


  

  def build_consultant_hash(customer_id, dates_array, start_date, end_date, users, projects, current_week=nil, current_month=nil, billable)
    logger.debug "Billable are :#{billable}"
    hash_report_data = Hash.new
    consultant_ids = users
    customer = Customer.find(customer_id)

    if current_month == "current_month"
      start_day = Time.now.beginning_of_month.to_date.to_s
    elsif current_month == "last_month"
      start_day = (Time.now.beginning_of_month-1.month).to_date.to_s
    elsif start_date.nil? || current_week == "true"
      start_day = Time.now.beginning_of_week.to_date.to_s
    else
      start_day = start_date
    end


    if current_month == "current_month"
      last_day = Time.now.end_of_month.to_date.to_s
    elsif current_month == "last_month"
      last_day = (Time.now.end_of_month-1.month).to_date.to_s
    elsif end_date.nil? || current_week == "true"
      last_day = Time.now.end_of_week.to_date.to_s
    else
      last_day = end_date
    end

    logger.debug "consultant_ids: #{consultant_ids}"
    if (projects.is_a? Integer) || (projects.is_a? String)
      project_list = Project.where(id: projects)
    else
      project_list = projects
    end

    consultant_ids.each do |c|
     total_hours = 0
     project_list.each do |p|
      time_entries = TimeEntry.where(user_id: c, project_id: p.id, date_of_activity: start_date..end_date).order(:date_of_activity)
      logger.debug "consultant is #{c}"
      employee_time_hash = Hash.new
      daily_hours = 0
      count = 1
      time_entries.each do |t|
        logger.debug "COUNT THIS: #{count}"
        count += 1
        #to get billable hours
        task_ids = t.task_id
        task = Task.find(task_ids)
        logger.debug "The Task billable are : #{task.billable}"
        logger.debug "Billable is : #{billable.class}"
        task_value = (task.billable ? "true" : "false")
        logger.debug "THE taks VALUE ARE : #{task_value.class}"
        logger.debug "COMPARISION IS : #{task_value == billable}"
        if task_value == billable
          logger.debug "TASK BILLABLE inside ARE: #{task.billable}"
          if !employee_time_hash[t.date_of_activity.strftime('%m/%d')].blank?
            logger.debug "EMPLOYEE TIME HASH: #{employee_time_hash[t.date_of_activity.strftime('%m/%d')]}"
            if employee_time_hash[t.date_of_activity.strftime('%m/%d')][:hours].blank?
              daily_hours = t.hours if !t.hours.blank?
              daily_hours = 0 if t.hours.blank?
            else
              logger.debug "DAILY HOURS 1: #{daily_hours}"
              daily_hours = employee_time_hash[t.date_of_activity.strftime('%m/%d')][:hours] + t.hours if !t.hours.blank?
              daily_hours = employee_time_hash[t.date_of_activity.strftime('%m/%d')][:hours] if t.hours.blank?
              logger.debug "DAILY HOURS 2: #{daily_hours}"
            end
          else
            daily_hours = !t.hours.blank? ? t.hours : 0
            logger.debug "DAILY HOURS 3: #{daily_hours}"
          end
        
          total_hours = total_hours + t.hours if !t.hours.blank?
          employee_time_hash[t.date_of_activity.strftime('%m/%d')] = { id: t.id, hours: daily_hours, activity_log: t.activity_log }
        end
      end
      logger.debug "POST LOOP EMPLOYEE HASH: #{employee_time_hash.inspect}"
      if hash_report_data[c].blank?
        hash_report_data[c] = { daily_hash: employee_time_hash, total_hours: total_hours } if hash_report_data[c].nil?
        logger.debug "DAILY HASH: #{hash_report_data[c][:daily_hash]}"
      else
        logger.debug "UUUHHHHHHHH"
        hash_report_data[c][:daily_hash].each do |d|
          unless employee_time_hash[d[0]].blank?
            logger.debug "WHAT IS D #{d} AND WHAT IS D[0] #{d[0]}"
            logger.debug "EMPLOYEE TIME HASH D[0]: #{employee_time_hash[d[0]]}"
            employee_time_hash[d[0]][:hours] += d[1][:hours]
          else
            employee_time_hash[d[0]] = d[1]
          end
        end
        hash_report_data[c] = { daily_hash: employee_time_hash, total_hours: total_hours } if !hash_report_data[c].nil?
      end
         logger.debug "HASH REPORT_DATA: #{hash_report_data}"
     end
    end
    logger.debug "build_consultant_hash - hash_report_data is #{hash_report_data.inspect}"
    return hash_report_data
  end

  def find_dates_to_print(proj_report_start_date = nil, proj_report_end_date = nil, current_week = nil, current_month = nil) 
    if current_month == "current_month"
      start_day = Time.now.beginning_of_month
    elsif current_month == "last_month"
      start_day = Time.now.beginning_of_month-1.month
    elsif proj_report_start_date.nil? || current_week == "true"
      start_day = Time.now.beginning_of_week
    else
      start_day = Date.parse(proj_report_start_date)
    end

    if current_month == "current_month"
      last_day = Time.now.end_of_month
    elsif current_month == "last_month"
      last_day = Time.now.end_of_month-1.month
    elsif proj_report_end_date.nil? || current_week == "true"
      last_day = start_day.end_of_week
    else
      last_day = Date.parse(proj_report_end_date).end_of_day
    end
    dates_array = []
    this_day = start_day
    while this_day < last_day
      dates_array << this_day.strftime('%m/%d')
      this_day = this_day.tomorrow

    end
    logger.debug "DATE ARRAAAAAAAAAAAAAAAAY: #{dates_array}"
    return dates_array
  end

  def find_week_id(start_date, end_date,user_array)
    week_array = []

    user_array.each do |u|
      t = TimeEntry.where(user_id: u, date_of_activity: start_date..end_date)
      logger.debug("THE T ARE : #{t} and the user is #{u}")
      t.each do |tw|
        week_array << tw.week_id
      end
    end
    week_with_attachment_array = []
    week_array.uniq.each do |w|
      week_with_attachment_array << Week.find(w) if UploadTimesheet.find_by_week_id(w).present?
    end
    return week_with_attachment_array

  end

end
